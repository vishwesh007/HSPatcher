$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
$files = & $adb -s 41498191 shell "ls -lt /sdcard/Download/HSPatched_Amaze_*.apk 2>/dev/null | head -3" 2>&1
Write-Host "=== LATEST PATCHED APKs ==="
$files | ForEach-Object { Write-Host $_ }
$logLines = & $adb -s 41498191 shell "logcat -d -s HSPatcher | grep -iE 'FAIL|error|Complete|assembly|0 error' | tail -10" 2>&1
Write-Host "`n=== PATCH LOG ==="
$logLines | ForEach-Object { Write-Host $_ }
