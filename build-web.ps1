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

$config = @{
    "pandocExe"    = "D:\miniconda3\envs\blog\Library\bin\pandoc.exe"
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
# 2. Detect directories
# ========================================

$currentDir = (Get-Location).Path

$isRootDir = $false
$isBlogDir = $false

# Root dir
if ((Test-Path "index.html") -or (Test-Path "sidebar.html")) {

    $isRootDir = $true
    $config["templateFile"] = Join-Path $scriptPath "template-root.html"

    Write-Host "Root directory detected." -ForegroundColor Cyan
}

# Blog dir
if ((Test-Path "blog\index.html") -or (Test-Path "blog\sidebar.html")) {

    $isBlogDir = $true
    $config["templateFile"] = Join-Path $scriptPath "template-blog.html"

    Write-Host "Blog directory detected." -ForegroundColor Cyan
}

# Fallback
if (!$isRootDir -and !$isBlogDir) {

    Write-Host "Warning: Cannot detect directory type. Using default template." -ForegroundColor Yellow
}

# ========================================
# 3. Scan markdown files
# ========================================

Write-Host ""
Write-Host "Scanning markdown files..." -ForegroundColor Cyan

$allMdFiles = @()
$mdFilesToProcess = @()
$projectStructure = @{}

# Current dir markdown files
$localMds = Get-ChildItem -Path . -Filter "*.md" -File -ErrorAction SilentlyContinue

foreach ($md in $localMds) {

    if ($md.Name -eq "README.md") {
        continue
    }

    $allMdFiles += $md
}

# Blog dir markdown files and project structure
if ($isRootDir -and (Test-Path "blog")) {

    # Scan subdirectories in blog/
    $blogDirs = Get-ChildItem -Path "blog" -Directory -ErrorAction SilentlyContinue

    foreach ($dir in $blogDirs) {
        $dirName = $dir.Name
        $projectStructure[$dirName] = @{
            "path" = $dir.FullName
            "files" = @()
        }

        # Scan md files in project subdirectory
        $projectMds = Get-ChildItem -Path $dir.FullName -Filter "*.md" -File -ErrorAction SilentlyContinue

        foreach ($md in $projectMds) {
            if ($md.Name -eq "README.md") {
                continue
            }

            $projectStructure[$dirName]["files"] += @{
                "name" = $md.Name
                "baseName" = $md.BaseName
                "path" = $md.FullName
                "isHomePage" = ($md.BaseName -eq $dirName)
            }

            $allMdFiles += $md
        }
    }

    # Also scan top-level blog md files (backward compatibility)
    $blogMds = Get-ChildItem -Path "blog" -Filter "*.md" -File -ErrorAction SilentlyContinue

    foreach ($md in $blogMds) {

        if ($md.Name -eq "README.md") {
            continue
        }

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

        Write-Host "Skip: $($mdFile.FullName)" -ForegroundColor Gray
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
    Write-Host "  $file" -ForegroundColor Cyan
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

    Write-Host "[$index/$($mdFilesToProcess.Count)] $($mdFile.Name)" -ForegroundColor White -NoNewline

    try {

        # Determine template based on file location
        $templateToUse = $config["templateFile"]
        if ($mdFile.FullName -like "*\blog\*") {
            $templateToUse = Join-Path $scriptPath "template-blog.html"
        } else {
            $templateToUse = Join-Path $scriptPath "template-root.html"
        }

        $args = @(
            $mdFile.FullName,
            "-o", $outFile,
            "-s",
            "--template=$templateToUse"
        )

        $useMathJax = $config["mathjax"] -and ($mdFile.FullName -like "*\blog\*")

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
# 5. Generate sidebar.html
# ========================================

Write-Host ""
Write-Host "Generating sidebar.html..." -ForegroundColor Cyan

$sidebarContent = @()
$sidebarContent += '<ul>'
$sidebarContent += '  <li>'
$sidebarContent += '    <a class="blog-nav-item" href="index.html">Blog Content</a>'
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

# Add top-level blog files (backward compatibility)
$topLevelMds = Get-ChildItem -Path "blog" -Filter "*.md" -File -ErrorAction SilentlyContinue |
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

$sidebarPath = Join-Path $scriptPath "blog\sidebar.html"
$sidebarContent -join "`n" | Out-File -FilePath $sidebarPath -Encoding UTF8

Write-Host "Sidebar generated: $sidebarPath" -ForegroundColor Green

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
