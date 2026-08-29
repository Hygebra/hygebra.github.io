# ========================================
# Pandoc Build Script
# Generate HTML from Markdown files
# ASCII-only version for Windows PowerShell
# ========================================

param(
    [switch]$Force = $false,
    [string]$ConfigFile = "",
    [ValidateSet("html", "pdf")]
    [string]$OutputType = "html"
)

# ========================================
# 1. Config
# ========================================

$scriptPath = $PSScriptRoot

if ([string]::IsNullOrWhiteSpace($scriptPath)) {
    if ($MyInvocation.MyCommand.Path) {
        $scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
    } else {
        $scriptPath = (Get-Location).Path
    }
}

function Get-RelativeToRoot {
    param([string]$Path)
    $prefix = $scriptPath.TrimEnd('\') + '\'
    if ($Path -and $Path.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $Path.Substring($prefix.Length).Replace('\', '/')
    }
    return $Path
}


$config = @{
    "pandocExe"    = (Get-Command pandoc).Source
    "outputType"   = $OutputType
    "mathjax"      = $true
    "templateFile" = Join-Path $scriptPath "template-root.html"
}

# Load config file
if ($ConfigFile -and (Test-Path $ConfigFile)) {

    Write-Host "Loading config file: $ConfigFile" -ForegroundColor Cyan

    try {

        $jsonConfig = Get-Content $ConfigFile -Raw | ConvertFrom-Json

        if ($jsonConfig.pandocPath) {
            $config["pandocExe"] = $jsonConfig.pandocPath
        }

        if ($jsonConfig.outputType) {
            $config["outputType"] = $jsonConfig.outputType
        }

        if ($jsonConfig.mathjax -is [bool]) {
            $config["mathjax"] = $jsonConfig.mathjax
        }

    } catch {

        Write-Host "Failed to parse config file. Using defaults." -ForegroundColor Yellow
    }
}

# Check pandoc
if (!(Test-Path $config["pandocExe"])) {

    Write-Host "ERROR: Pandoc executable not found." -ForegroundColor Red
    Write-Host "Path: $($config["pandocExe"])" -ForegroundColor Red
    exit 1
}

Write-Host "Pandoc path: $($config["pandocExe"])" -ForegroundColor Green

# ========================================
# 2. Detect directories & load top-level dirs
# ========================================

$isRootDir = $false

# Root dir
if ((Test-Path "index.html") -or (Test-Path "sidebar.html")) {

    $isRootDir = $true
    $config["templateFile"] = Join-Path $scriptPath "template-root.html"

    Write-Host "Root directory detected." -ForegroundColor Cyan
}

# Load top-level dirs (one folder name per line)
$topDirs = @()
$topDirListFile = Join-Path $scriptPath "top_dir_list.txt"

if (Test-Path $topDirListFile) {

    $topDirs = [System.IO.File]::ReadAllLines($topDirListFile, [System.Text.Encoding]::UTF8) |
        ForEach-Object { $_.Trim() } |
        Where-Object { $_ -and -not $_.StartsWith("#") } |
        Select-Object -Unique

    Write-Host "Loaded top dirs from $(Get-RelativeToRoot $topDirListFile)" -ForegroundColor Cyan

} else {

    Write-Host "Warning: $topDirListFile not found." -ForegroundColor Yellow
}

# Fallback to blog if nothing was loaded (preserve legacy behavior)
if ($topDirs.Count -eq 0) {

    $topDirs = @("blog")
    Write-Host "Falling back to default top dir: blog" -ForegroundColor Yellow
}

# Validate dirs and resolve a template for each one
$topDirTemplates = @{}

foreach ($topDir in $topDirs) {

    $topDirPath = Join-Path $scriptPath $topDir

    if (-not (Test-Path $topDirPath -PathType Container)) {
        Write-Host "Warning: top dir '$topDir' not found. Skipping." -ForegroundColor Yellow
        continue
    }

    if (Test-Path (Join-Path $scriptPath "template-$topDir.html")) {
        $topDirTemplates[$topDir] = Join-Path $scriptPath "template-$topDir.html"
    } elseif (Test-Path (Join-Path $scriptPath "template-blog.html")) {
        $topDirTemplates[$topDir] = Join-Path $scriptPath "template-blog.html"
    } else {
        $topDirTemplates[$topDir] = $config["templateFile"]
    }

    Write-Host "Top dir: $topDir -> template: $(Get-RelativeToRoot $topDirTemplates[$topDir])" -ForegroundColor Cyan
}

# Keep only the dirs that exist
$topDirs = @($topDirs | Where-Object { $topDirTemplates.ContainsKey($_) })

# ========================================
# 3. Scan markdown files
# ========================================

Write-Host ""
Write-Host "Scanning markdown files..." -ForegroundColor Cyan

$allMdFiles = @()
$mdFilesToProcess = @()
$projectStructures = @{}
$fileTopDir = @{}

# Current dir markdown files
$localMds = Get-ChildItem -Path . -Filter "*.md" -File -ErrorAction SilentlyContinue

foreach ($md in $localMds) {

    if ($md.Name -eq "README.md") {
        continue
    }

    $allMdFiles += $md
}

# Top-level dir markdown files and project structure
foreach ($topDirName in $topDirs) {

    $topDirPath = Join-Path $scriptPath $topDirName
    $projectStructures[$topDirName] = @{}

    # Scan subdirectories in <topDir>/
    $subDirs = Get-ChildItem -Path $topDirPath -Directory -ErrorAction SilentlyContinue

    foreach ($dir in $subDirs) {
        $dirName = $dir.Name
        $projectStructures[$topDirName][$dirName] = @{
            "path" = $dir.FullName
            "files" = @()
        }

        # Scan md files in project subdirectory
        $projectMds = Get-ChildItem -Path $dir.FullName -Filter "*.md" -File -ErrorAction SilentlyContinue

        foreach ($md in $projectMds) {
            if ($md.Name -eq "README.md") {
                continue
            }

            $projectStructures[$topDirName][$dirName]["files"] += @{
                "name" = $md.Name
                "baseName" = $md.BaseName
                "path" = $md.FullName
                "isHomePage" = ($md.BaseName -eq $dirName)
            }

            $fileTopDir[$md.FullName] = $topDirName
            $allMdFiles += $md
        }
    }

    # Also scan top-level md files (backward compatibility)
    $topMds = Get-ChildItem -Path $topDirPath -Filter "*.md" -File -ErrorAction SilentlyContinue

    foreach ($md in $topMds) {

        if ($md.Name -eq "README.md") {
            continue
        }

        $fileTopDir[$md.FullName] = $topDirName
        $allMdFiles += $md
    }
}

# Detect rebuild
foreach ($mdFile in $allMdFiles) {

    $outFile = $mdFile.FullName -replace '\.md$', ".html"

    $needsRebuild = $false

    if ($Force) {

        $needsRebuild = $true

    } elseif (!(Test-Path $outFile)) {

        $needsRebuild = $true

    } else {

        $htmlTime = (Get-Item $outFile).LastWriteTime

        if ($mdFile.LastWriteTime -gt $htmlTime) {
            $needsRebuild = $true
        }
    }

    if ($needsRebuild) {

        $mdFilesToProcess += $mdFile

    } else {

        Write-Host "Skip: $(Get-RelativeToRoot $mdFile.FullName)" -ForegroundColor Gray
    }
}

if ($mdFilesToProcess.Count -eq 0) {

    Write-Host ""
    Write-Host "All files are up to date." -ForegroundColor Green
    exit 0
}

Write-Host ""
Write-Host "Files to process: $($mdFilesToProcess.Count)" -ForegroundColor Cyan

foreach ($file in $mdFilesToProcess) {
    Write-Host "  $(Get-RelativeToRoot $file.FullName)" -ForegroundColor Cyan
}

# ========================================
# 4. Generate HTML
# ========================================

Write-Host ""
Write-Host "Generating HTML files..."
Write-Host ""

$successCount = 0
$failCount = 0

for ($i = 0; $i -lt $mdFilesToProcess.Count; $i++) {

    $mdFile = $mdFilesToProcess[$i]
    $outFile = $mdFile.FullName -replace '\.md$', ".html"
    $index = $i + 1

    Write-Host "[$index/$($mdFilesToProcess.Count)] $(Get-RelativeToRoot $mdFile.FullName)" -ForegroundColor White -NoNewline

    try {

        # Determine template based on file location
        $templateToUse = $config["templateFile"]
        $mdTopDir = $fileTopDir[$mdFile.FullName]
        if ($mdTopDir -and $topDirTemplates.ContainsKey($mdTopDir)) {
            $templateToUse = $topDirTemplates[$mdTopDir]
        }

        $args = @(
            $mdFile.FullName,
            "-o", $outFile,
            "-s",
            "--template=$templateToUse"
        )

        $useMathJax = $config["mathjax"] -and $mdTopDir

        if ($useMathJax) {
            $args += "--mathjax"
        }

        & $config["pandocExe"] @args 2>&1 | Out-Null

        if ($LASTEXITCODE -eq 0) {

            Write-Host " OK" -ForegroundColor Green
            $successCount++

        } else {

            Write-Host " FAILED" -ForegroundColor Red
            $failCount++
        }

    } catch {

        Write-Host " EXCEPTION: $($_.Exception.Message)" -ForegroundColor Red
        $failCount++
    }
}

# ========================================
# 5. Generate sidebar.html for each top-level dir
# ========================================

foreach ($topDirName in $topDirs) {

    Write-Host ""
    Write-Host "Generating sidebar.html for '$topDirName'..." -ForegroundColor Cyan

    $projectStructure = $projectStructures[$topDirName]
    $topDirPath = Join-Path $scriptPath $topDirName

    $sectionLabel = $topDirName.Substring(0, 1).ToUpper() + $topDirName.Substring(1) + " Content"

    $sidebarContent = @()
    $sidebarContent += '<ul>'
    $sidebarContent += '  <li>'
    $sidebarContent += "    <a class=`"blog-nav-item`" href=`"index.html`">$sectionLabel</a>"
    $sidebarContent += '  </li>'

# Add project sections from subdirectories
$projectKeys = $projectStructure.Keys | Sort-Object

foreach ($projectKey in $projectKeys) {
    $project = $projectStructure[$projectKey]
    $projectFiles = $project["files"] | Sort-Object { $_.isHomePage -eq $false }, { $_.baseName }

    if ($projectFiles.Count -eq 0) {
        continue
    }

    # Convert project name to slug for ID
    $projectId = ($projectKey -replace '[^a-zA-Z0-9]', '-').ToLower()

    # Find the home page
    $homePage = $projectFiles | Where-Object { $_.isHomePage } | Select-Object -First 1

    # Add project folder item
    $sidebarContent += '  <li>'
    $sidebarContent += "    <a class=`"toggle-item`" data-toggle=`"$projectId`">$projectKey <span class=`"toggle-btn`">&#9660;</span></a>"

    $sidebarContent += "    <ul id=`"$projectId`" class=`"submenu expanded`">"

    # Add home page link
    if ($homePage) {
        $homePageHref = "$projectKey/$($homePage.name -replace '\.md$', '.html')" -replace '\\', '/'
        $sidebarContent += "      <li><a href=`"$homePageHref`">$projectKey (Home)</a></li>"
    }

    # Add other pages
    $otherPages = $projectFiles | Where-Object { -not $_.isHomePage }

    foreach ($page in $otherPages) {
        $pageHref = "$projectKey/$($page.name -replace '\.md$', '.html')" -replace '\\', '/'
        # Extract readable name from file name
        $pageName = $page.baseName -replace '_', ' '
        $sidebarContent += "      <li><a href=`"$pageHref`">$pageName</a></li>"
    }

    $sidebarContent += '    </ul>'
    $sidebarContent += '  </li>'
}

    # Add top-level files (backward compatibility)
    $topLevelMds = Get-ChildItem -Path $topDirPath -Filter "*.md" -File -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -ne "README.md" -and $_.Name -ne "index.md" } |
        Sort-Object -Property Name

    foreach ($md in $topLevelMds) {
        # Skip if this is a project home page (already listed above)
        $projectName = $md.BaseName
        $isProjectHomePage = $projectStructure.ContainsKey($projectName)

        if (!$isProjectHomePage) {
            $mdHref = $md.Name -replace '\.md$', '.html'
            $mdDisplayName = $md.BaseName -replace '_', ' '
            $sidebarContent += '  <li>'
            $sidebarContent += "    <a class=`"blog-nav-item`" href=`"$mdHref`">$mdDisplayName</a>"
            $sidebarContent += '  </li>'
        }
    }

$sidebarContent += '</ul>'
$sidebarContent += ''
# $sidebarContent += '<script>'
# $sidebarContent += @"
# // Handle sidebar menu toggle
# document.querySelectorAll('.toggle-item').forEach(item => {
#   item.addEventListener('click', function(e) {
#     e.preventDefault();
#     const targetId = this.getAttribute('data-toggle');
#     const submenu = document.getElementById(targetId);
#     submenu.classList.toggle('expanded');

#     // Update toggle button appearance
#     const toggleBtn = this.querySelector('.toggle-btn');
#     if (toggleBtn) {
#       toggleBtn.classList.toggle('collapsed');
#     }
#   });
# });

# // Highlight current page
# const currentPage = window.location.pathname.split('/').pop() || 'index.html';
# document.querySelectorAll('.sidebar a').forEach(link => {
#   const href = link.getAttribute('href');
#   if (href === currentPage || href.endsWith(currentPage)) {
#     link.classList.add('active');
#     // Auto-expand parent menu if current link is in a submenu
#     if (link.closest('ul.submenu')) {
#       link.closest('ul.submenu').classList.add('expanded');
#       const toggleItem = link.closest('li').querySelector('.toggle-item');
#       if (toggleItem) {
#         toggleItem.classList.add('active');
#         const toggleBtn = toggleItem.querySelector('.toggle-btn');
#         if (toggleBtn && !toggleBtn.classList.contains('collapsed')) {
#           // Menu is expanded, so toggle btn should show collapsed state visually
#         }
#       }
#     }
#   }
# });
# "@
# $sidebarContent += '</script>'

    $sidebarPath = Join-Path $scriptPath "$topDirName\sidebar.html"
    $sidebarContent -join "`n" | Out-File -FilePath $sidebarPath -Encoding UTF8

    Write-Host "Sidebar generated: $(Get-RelativeToRoot $sidebarPath)" -ForegroundColor Green
}

# ========================================
# 6. Report
# ========================================

Write-Host ""
Write-Host ("=" * 50) -ForegroundColor Gray

Write-Host "Build complete." -ForegroundColor Green
Write-Host "Success: $successCount" -ForegroundColor Green

if ($failCount -gt 0) {
    Write-Host "Failed : $failCount" -ForegroundColor Red
} else {
    Write-Host "Failed : $failCount" -ForegroundColor Green
}

Write-Host ("=" * 50) -ForegroundColor Gray

if ($failCount -gt 0) {
    exit 1
} else {
    exit 0
}
