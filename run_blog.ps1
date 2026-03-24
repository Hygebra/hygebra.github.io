# ========================================
# PowerShell 脚本：运行 blog 虚拟环境的 Python 脚本
# 使用方法: .\run_blog.ps1 arg1 arg2 ...
# ========================================


param(
    [ValidateSet("pdf","html")]
    [string]$OutputType = "html",
    [switch]$Force  # 开关参数，如果指定就全部重新生成
)

# 1️⃣ 设置 blog 环境路径
$envPath = "C:\Users\YourName\miniconda3\envs\blog"
$pandocExe = "D:\miniconda3\envs\blog\Library\bin\pandoc.exe"

# 2️⃣ Python 脚本路径
# $scriptPath = "D:\path\to\your\script.py"

# 3️⃣ 调用 Python 可执行文件，传递所有参数
# & "$pandocPath" index.md -s -o index.html --mathjax --css style.css --include-before-body=topbar.html
# ---------- 配置 topbar 和 sidebar ----------
$rootTopbarFile = Join-Path (Get-Location) "topbar.html"
$blogTopbarFile = Join-Path (Get-Location) "blog\topbar.html"
$rootSidebarFile = Join-Path (Get-Location) "sidebar.html"
$blogSidebarFile = Join-Path (Get-Location) "blog\sidebar.html"
$rootCssFile = "style.css"
$blogCssFile = "..\style.css"
$templateFile = Join-Path (Get-Location) "template.html"
$rootAvatarFile = "favicon.html"
$blogAvatarFile = "favicon.html"

# ---------- 遍历所有 Markdown ----------
$allMdFiles = Get-ChildItem -Path . -Recurse -Filter *.md
$mdFilesToProcess = @()

foreach ($file in $allMdFiles) {
    if ($file.Name.ToLower() -eq "readme.md") { continue }

    $outFile = $file.FullName -replace '\.md$', ".html"

    # 判断是否需要重新生成
    if ($Force -or !(Test-Path $outFile) -or $file.LastWriteTime -gt (Get-Item $outFile).LastWriteTime) {
        $mdFilesToProcess += $file.FullName
    } else {
        Write-Host "Skipping (up-to-date): $($file.FullName)"
    }
}

Write-Host "`nFound $($mdFilesToProcess.Count) Markdown files to process:"

$mdFilesToProcess | ForEach-Object { Write-Host " - $_" }

# ---------- 批量 Pandoc 转换 ----------
$total = $mdFilesToProcess.Count
for ($i = 0; $i -lt $total; $i++) {
    $f = $mdFilesToProcess[$i]
    $outFile = $f -replace '\.md$', ".html"

    # 根据所在目录选择 sidebar
    if ($f -like "*\blog\*") {
        $topbarFile = $blogTopbarFile
        $sidebarFile = $blogSidebarFile
        $cssFile = $blogCssFile
    } else {
        $sidebarFile = $rootSidebarFile
        $topbarFile = $rootTopbarFile
        $cssFile = $rootCssFile
    }

    Write-Host "`nProcessing [$($i+1)/$total]: $f"

    $cmd = "`"$pandocExe`" `"$f`" -o `"$outFile`" --template=`"$templateFile`" --include-before-body `"$topbarFile`" --include-after-body `"$sidebarFile`""
    Write-Host "Executing: $cmd"

    # & "$pandocExe" $f -o $outFile --mathjax --css "$cssFile" --template="$templateFile" --include-before-body "$topbarFile" --include-before-body "$sidebarFile"
    & "$pandocExe" $f -o $outFile --mathjax --css "$cssFile" --include-before-body "$topbarFile" --include-before-body "$sidebarFile" --include-in-header "favicon.html"
}