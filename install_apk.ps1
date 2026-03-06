<#
.SYNOPSIS
    Streamlined APK install for Xiaomi/MIUI devices. Single popup, automatic retry.
.DESCRIPTION
    Addresses INSTALL_FAILED_USER_RESTRICTED on Xiaomi devices by:
    1. Using -r flag to replace existing installations (avoids uninstall popup)
    2. Auto-retrying with delays for MIUI install confirmation
    3. Using pm install as fallback
.PARAMETER ApkPath
    Path to the APK to install
.PARAMETER Serial
    ADB device serial (default: first connected device)
.PARAMETER Uninstall
    Package name to uninstall first (optional, avoid if possible)
.EXAMPLE
    .\install_apk.ps1 -ApkPath build\HSPatcher.apk
    .\install_apk.ps1 -ApkPath test.apk -Serial 41498191 -Uninstall in.startv.hotstar
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$ApkPath,
    [string]$Serial = "",
    [string]$Uninstall = ""
)

$adbCmd = if ($Serial) { "adb -s $Serial" } else { "adb" }

function Invoke-Adb {
    param([string]$Args)
    if ($Serial) {
        $result = & adb -s $Serial $Args.Split(' ') 2>&1
    } else {
        $result = & adb $Args.Split(' ') 2>&1
    }
    return $result
}

# Step 1: Uninstall if requested
if ($Uninstall) {
    Write-Host "Uninstalling $Uninstall..." -ForegroundColor Yellow
    if ($Serial) {
        & adb -s $Serial shell "pm uninstall $Uninstall" 2>&1 | Out-Null
    } else {
        & adb shell "pm uninstall $Uninstall" 2>&1 | Out-Null
    }
    Start-Sleep 2
}

# Step 2: Try adb install -r (replace) first - avoids uninstall popup
Write-Host "Installing $ApkPath..." -ForegroundColor Cyan
$maxRetries = 3
$installed = $false

for ($i = 1; $i -le $maxRetries; $i++) {
    Write-Host "  Attempt $i/$maxRetries..." -NoNewline
    
    if ($Serial) {
        $result = & adb -s $Serial install -r $ApkPath 2>&1
    } else {
        $result = & adb install -r $ApkPath 2>&1
    }
    
    if ($result -match "Success") {
        Write-Host " OK" -ForegroundColor Green
        $installed = $true
        break
    } elseif ($result -match "USER_RESTRICTED") {
        Write-Host " Blocked by MIUI" -ForegroundColor Yellow
        if ($i -lt $maxRetries) {
            Write-Host "  >> Please ACCEPT the install popup on your device <<" -ForegroundColor Magenta
            Write-Host "  Retrying in 10 seconds..."
            Start-Sleep 10
        }
    } else {
        Write-Host " Failed: $result" -ForegroundColor Red
        break
    }
}

# Step 3: Fallback - push and pm install
if (-not $installed) {
    Write-Host "`nFallback: pushing APK to device..." -ForegroundColor Yellow
    $remotePath = "/data/local/tmp/install_tmp.apk"
    if ($Serial) {
        & adb -s $Serial push $ApkPath $remotePath 2>&1 | Out-Null
        $result = & adb -s $Serial shell "pm install -r $remotePath" 2>&1
    } else {
        & adb push $ApkPath $remotePath 2>&1 | Out-Null
        $result = & adb shell "pm install -r $remotePath" 2>&1
    }
    
    if ($result -match "Success") {
        Write-Host "  Installed via pm install" -ForegroundColor Green
        $installed = $true
    } else {
        Write-Host "`n  INSTALL FAILED. Please enable 'Install via USB' in:" -ForegroundColor Red
        Write-Host "  Settings > Additional Settings > Developer Options > Install via USB" -ForegroundColor Yellow
        Write-Host "  (Requires Mi Account sign-in)" -ForegroundColor Yellow
    }
}

if ($installed) {
    # Verify
    $pkg = $ApkPath -replace '.*\\','' -replace '\.apk$',''
    Write-Host "`nInstall successful!" -ForegroundColor Green
}
