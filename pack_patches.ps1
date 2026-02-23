# pack_patches.ps1 — Repack smali patches into assets/extra.zip
# Run this after modifying any file in patches/

$ErrorActionPreference = "Stop"
$root = $PSScriptRoot

$patchesDir = Join-Path $root "patches"
$extraZip = Join-Path $root "assets\extra.zip"

if (!(Test-Path (Join-Path $patchesDir "smali"))) {
    Write-Host "ERROR: patches/smali/ not found" -ForegroundColor Red
    exit 1
}

# Count files
$count = (Get-ChildItem $patchesDir -Recurse -File).Count
Write-Host "Packing $count files from patches/ into assets/extra.zip..."

# Remove old zip
if (Test-Path $extraZip) { Remove-Item $extraZip -Force }

# Create new zip from patches contents
Push-Location $patchesDir
Compress-Archive -Path "smali", "res" -DestinationPath $extraZip -CompressionLevel Optimal
Pop-Location

$size = [math]::Round((Get-Item $extraZip).Length / 1024, 1)
Write-Host "Done: extra.zip = ${size} KB ($count files)" -ForegroundColor Green
