<#
.SYNOPSIS
    Auto-install APK on Xiaomi/MIUI devices by automatically tapping the "Install via USB" dialog.
.DESCRIPTION
    Uses uiautomator to detect the MIUI "Install via USB" dialog and automatically
    taps the Install button. Pushes a tap watcher shell script to the device, runs it
    in background via Start-Process, then runs ADB install. The watcher polls
    uiautomator for android:id/button2 (Install) and taps center (351,2380).
    
    Known MIUI dialog layout (1220x2712, com.miui.securitycenter):
      Install button:  android:id/button2  bounds=[111,2303][591,2458]  center=(351,2380)
      Deny button:     android:id/button1  bounds=[628,2303][1109,2458] center=(868,2380)
.PARAMETER ApkPath
    Path to the APK to install
.PARAMETER Serial
    ADB device serial (default: first connected device)
.PARAMETER MaxPolls
    Max poll iterations (1s each) to wait for dialog (default: 60)
.EXAMPLE
    .\auto_install.ps1 -ApkPath build\HSPatcher.apk -Serial 41498191
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$ApkPath,
    [string]$Serial = "",
    [int]$MaxPolls = 60
)

$adbArgs = if ($Serial) { @("-s", $Serial) } else { @() }

Write-Host "Installing: $(Split-Path $ApkPath -Leaf)" -ForegroundColor Cyan

# Step 1: Build tap watcher shell script and push to device
# Polls uiautomator every 1s for MIUI Install button, taps it when found
$lines = @(
    "#!/system/bin/sh"
    "for i in `$(seq 1 $MaxPolls); do"
    "  uiautomator dump /data/local/tmp/ud.xml >/dev/null 2>&1"
    "  if grep -q 'android:id/button2' /data/local/tmp/ud.xml 2>/dev/null; then"
    "    input tap 351 2380"
    "    echo TAPPED"
    "    rm -f /data/local/tmp/ud.xml"
    "    exit 0"
    "  fi"
    "  rm -f /data/local/tmp/ud.xml"
    "  sleep 1"
    "done"
    "echo TIMEOUT"
)
$tapScriptPath = "$env:TEMP\miui_auto_tap.sh"
[System.IO.File]::WriteAllText($tapScriptPath, ($lines -join "`n") + "`n")

& adb @adbArgs push $tapScriptPath /data/local/tmp/tap.sh 2>&1 | Out-Null
& adb @adbArgs shell "chmod 755 /data/local/tmp/tap.sh" 2>&1 | Out-Null

# Step 2: Start tap watcher as background process (separate ADB shell)
Write-Host "  Auto-tap watcher started..." -ForegroundColor DarkGray
$tapLogFile = "$env:TEMP\miui_tap_result.txt"
Remove-Item $tapLogFile -ErrorAction SilentlyContinue
$tapProcess = Start-Process -FilePath "adb" `
    -ArgumentList ($adbArgs + @("shell", "/data/local/tmp/tap.sh")) `
    -NoNewWindow -PassThru `
    -RedirectStandardOutput $tapLogFile `
    -RedirectStandardError "$env:TEMP\miui_tap_err.txt"

# Step 3: Run ADB install (blocks until dialog accepted/denied or timeout)
Write-Host "  ADB install running..." -ForegroundColor Cyan
$installResult = & adb @adbArgs install -r -t $ApkPath 2>&1

# Step 4: Wait for tap process to finish
if (-not $tapProcess.HasExited) {
    $tapProcess.WaitForExit(10000) | Out-Null
}
$tapResult = if (Test-Path $tapLogFile) { Get-Content $tapLogFile -Raw } else { "" }

# Step 5: Report results
Write-Host ""
$installStr = ($installResult | Out-String).Trim()
if ($installStr -match "Success") {
    Write-Host "INSTALL SUCCESSFUL" -ForegroundColor Green
} elseif ($installStr -match "USER_RESTRICTED") {
    Write-Host "INSTALL FAILED - MIUI blocked" -ForegroundColor Red
    Write-Host "  Enable 'Install via USB' in Developer Options" -ForegroundColor Yellow
} else {
    Write-Host "RESULT: $installStr" -ForegroundColor Yellow
}

$tapTrimmed = $tapResult.Trim()
if ($tapTrimmed) {
    Write-Host "  Auto-tap: $tapTrimmed" -ForegroundColor DarkGray
}

# Cleanup
& adb @adbArgs shell "rm -f /data/local/tmp/tap.sh /data/local/tmp/ud.xml" 2>&1 | Out-Null
Remove-Item $tapScriptPath, $tapLogFile, "$env:TEMP\miui_tap_err.txt" -ErrorAction SilentlyContinue
