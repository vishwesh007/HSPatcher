# download_from_play.ps1 — Download APK from Google Play and optionally patch + install
# Uses gplaydl (pip install gplaydl) for anonymous Play Store downloads
# Usage:
#   .\download_from_play.ps1 -Package "com.example.app"
#   .\download_from_play.ps1 -Package "com.example.app" -Patch -Install
#   .\download_from_play.ps1 -Search "file manager"

param(
    [string]$Package,
    [string]$Search,
    [string]$Arch = "arm64",
    [string]$OutputDir = "",
    [switch]$Patch,
    [switch]$Install,
    [switch]$NoSplits,
    [switch]$Info
)

$ErrorActionPreference = "Stop"
$PROJECT = $PSScriptRoot

Write-Host "=== Play Store Downloader (gplaydl) ===" -ForegroundColor Cyan

# Verify gplaydl is installed
try {
    $null = & python -m gplaydl --help 2>&1
} catch {
    Write-Host "ERROR: gplaydl not installed. Run: pip install gplaydl" -ForegroundColor Red
    exit 1
}

# Search mode
if ($Search) {
    Write-Host "`nSearching Play Store for: $Search" -ForegroundColor Yellow
    & python -m gplaydl search $Search --limit 10
    exit 0
}

# Info mode
if ($Info -and $Package) {
    Write-Host "`nFetching info for: $Package" -ForegroundColor Yellow
    & python -m gplaydl info $Package
    exit 0
}

if (-not $Package) {
    Write-Host "Usage: .\download_from_play.ps1 -Package <com.example.app> [-Patch] [-Install]" -ForegroundColor Yellow
    Write-Host "       .\download_from_play.ps1 -Search <query>" -ForegroundColor Yellow
    Write-Host "       .\download_from_play.ps1 -Package <pkg> -Info" -ForegroundColor Yellow
    exit 1
}

# Ensure auth token
Write-Host "`nEnsuring auth token ($Arch)..." -ForegroundColor Yellow
& python -m gplaydl auth --arch $Arch
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to authenticate with Play Store" -ForegroundColor Red
    exit 1
}

# Set output directory
if (-not $OutputDir) {
    $OutputDir = Join-Path $PROJECT "play_downloads\$Package"
}
if (!(Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Force $OutputDir | Out-Null
}

# Download
Write-Host "`nDownloading $Package to $OutputDir..." -ForegroundColor Green
$dlArgs = @("download", $Package, "-o", $OutputDir, "-a", $Arch)
if ($NoSplits) { $dlArgs += "--no-splits" }

& python -m gplaydl @dlArgs
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Download failed" -ForegroundColor Red
    exit 1
}

# Find downloaded APK(s)
$apks = Get-ChildItem $OutputDir -Filter "*.apk" | Sort-Object Name
if ($apks.Count -eq 0) {
    Write-Host "ERROR: No APK files found in $OutputDir" -ForegroundColor Red
    exit 1
}

$baseApk = $apks | Where-Object { $_.Name -notmatch "config\." -and $_.Name -notmatch "asset" } | Select-Object -First 1
if (-not $baseApk) { $baseApk = $apks[0] }

Write-Host "`n✅ Downloaded $($apks.Count) file(s):" -ForegroundColor Green
foreach ($a in $apks) {
    $sizeMB = [math]::Round($a.Length / 1MB, 1)
    Write-Host "   $($a.Name) ($sizeMB MB)" -ForegroundColor White
}

# If multiple APKs (split bundle), create a combined ZIP for HSPatcher
$targetFile = $baseApk.FullName
if ($apks.Count -gt 1) {
    $bundlePath = Join-Path $OutputDir "$Package.apks"
    Write-Host "`nCreating split bundle: $($Package).apks..." -ForegroundColor Yellow
    Compress-Archive -Path ($apks | ForEach-Object { $_.FullName }) -DestinationPath $bundlePath -Force
    $targetFile = $bundlePath
    Write-Host "   Bundle created: $([math]::Round((Get-Item $bundlePath).Length / 1MB, 1)) MB" -ForegroundColor Green
}

# Patch mode — push to device and auto-patch with HSPatcher
if ($Patch) {
    Write-Host "`nPushing to device for patching..." -ForegroundColor Yellow
    $devicePath = "/sdcard/Download/" + (Split-Path $targetFile -Leaf)
    & adb push $targetFile $devicePath
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: adb push failed" -ForegroundColor Red
        exit 1
    }

    Write-Host "Launching HSPatcher with auto-patch..." -ForegroundColor Green
    & adb shell am start -n "in.startv.hspatcher/.MainActivity" `
        --es "apk_path" $devicePath `
        --ez "auto_patch" true
    if ($LASTEXITCODE -ne 0) {
        Write-Host "WARNING: Could not launch HSPatcher" -ForegroundColor Yellow
    }
}

# Install mode — install directly via adb
if ($Install -and -not $Patch) {
    if ($apks.Count -gt 1) {
        Write-Host "`nInstalling split APKs via adb install-multiple..." -ForegroundColor Yellow
        $apkPaths = $apks | ForEach-Object { $_.FullName }
        & adb install-multiple @apkPaths
    } else {
        Write-Host "`nInstalling via adb..." -ForegroundColor Yellow
        & adb install -r $baseApk.FullName
    }
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Installation failed" -ForegroundColor Red
        exit 1
    }
    Write-Host "✅ Installed successfully" -ForegroundColor Green
}

Write-Host "`n=== Done ===" -ForegroundColor Cyan
Write-Host "APK location: $targetFile" -ForegroundColor White
