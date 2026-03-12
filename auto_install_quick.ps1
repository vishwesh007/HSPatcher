<#
.SYNOPSIS
    Quick APK install on MIUI device with smart dialog detection + single tap.
.DESCRIPTION
    Strategy: Start adb install in a background process. Meanwhile, on the HOST
    side, poll "dumpsys window | grep mCurrentFocus" every 500ms to detect when
    the MIUI "Install via USB" dialog (AdbInstallActivity) appears. Once detected,
    wait 500ms for animation, then fire a single tap at the Install button.

    This is NOT a brute-force polling loop - it's a smart wait that detects the
    exact moment the dialog appears, then taps ONCE. No repeated taps.

    Dialog coordinates (1220x2712 screen, com.miui.securitycenter AdbInstallActivity):
      Install button:  bounds=[111,2303][591,2458]  center=(351,2380)
      Deny button:     bounds=[628,2303][1109,2458] center=(868,2380)
.PARAMETER ApkPath
    Path to the APK file to install.
.PARAMETER Serial
    ADB device serial (default: 41498191).
.EXAMPLE
    .\auto_install_quick.ps1 -ApkPath build\HSPatcher.apk
    .\auto_install_quick.ps1 -ApkPath "C:\path\to\app.apk"
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$ApkPath,
    [string]$Serial = "41498191"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $ApkPath)) {
    Write-Host "APK not found: $ApkPath" -ForegroundColor Red
    exit 1
}

# Resolve to absolute path for background process
$ApkPath = (Resolve-Path $ApkPath).Path
$apkName = Split-Path $ApkPath -Leaf
$apkSizeMB = [math]::Round((Get-Item $ApkPath).Length / 1MB, 1)

function Install-WithAutoTap {
    param(
        [string]$Apk,
        [string]$DeviceSerial
    )

    Write-Host "Installing: $apkName (${apkSizeMB}MB) on device $DeviceSerial" -ForegroundColor Cyan

    # Step 1: Start adb install as a BACKGROUND process
    $instOutFile = [System.IO.Path]::GetTempFileName()
    $instErrFile = [System.IO.Path]::GetTempFileName()

    $installProc = Start-Process -FilePath "adb" `
        -ArgumentList @("-s", $DeviceSerial, "install", "-r", "-t", $Apk) `
        -NoNewWindow -PassThru `
        -RedirectStandardOutput $instOutFile `
        -RedirectStandardError $instErrFile

    Write-Host "  Install started (PID=$($installProc.Id))" -ForegroundColor DarkGray

    # Step 2: Detect dialog via window focus, then tap ONCE
    # Poll mCurrentFocus every 500ms for up to 15 seconds
    $dialogFound = $false
    for ($i = 0; $i -lt 30; $i++) {
        Start-Sleep -Milliseconds 500

        # Check if install already finished (no dialog needed, e.g. app already installed)
        if ($installProc.HasExited) {
            Write-Host "  Install completed without dialog" -ForegroundColor DarkGray
            break
        }

        $focus = & adb -s $DeviceSerial shell "dumpsys window | grep mCurrentFocus" 2>&1 | Out-String
        if ($focus -match "AdbInstallActivity") {
            Write-Host "  Dialog detected at $($i * 500)ms" -ForegroundColor DarkGray
            Start-Sleep -Milliseconds 500  # Wait for dialog animation to complete
            & adb -s $DeviceSerial shell "input tap 351 2380" 2>&1 | Out-Null
            Write-Host "  Tapped Install button at (351,2380)" -ForegroundColor Green
            $dialogFound = $true
            break
        }
    }

    if (-not $dialogFound -and -not $installProc.HasExited) {
        Write-Host "  Dialog not detected in 15s" -ForegroundColor Yellow
    }

    # Step 3: Wait for install process to complete
    if (-not $installProc.HasExited) {
        $installProc.WaitForExit(30000) | Out-Null
    }
    if (-not $installProc.HasExited) {
        Write-Host "  Install timed out" -ForegroundColor Yellow
        $installProc.Kill()
    }

    # Step 4: Read result
    $installOutput = ""
    if (Test-Path $instOutFile) { $installOutput += Get-Content $instOutFile -Raw -ErrorAction SilentlyContinue }
    if (Test-Path $instErrFile) { $installOutput += Get-Content $instErrFile -Raw -ErrorAction SilentlyContinue }
    Remove-Item $instOutFile, $instErrFile -Force -ErrorAction SilentlyContinue

    $installTrimmed = $installOutput.Trim()
    if ($installTrimmed -match "Success") {
        Write-Host "  SUCCESS" -ForegroundColor Green
        return $true
    } else {
        Write-Host "  FAILED: $installTrimmed" -ForegroundColor Red
        return $false
    }
}

# Run the install
$result = Install-WithAutoTap -Apk $ApkPath -DeviceSerial $Serial

if ($result) {
    Write-Host "`nInstall completed successfully." -ForegroundColor Green
} else {
    Write-Host "`nInstall failed. Try:" -ForegroundColor Yellow
    Write-Host "  1. Toggle 'Install via USB' OFF then ON in Developer Options" -ForegroundColor Yellow
    Write-Host "  2. Run manually: adb -s $Serial install -r -t `"$ApkPath`"" -ForegroundColor Yellow
    exit 1
}
