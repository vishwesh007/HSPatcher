$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
$files = & $adb -s 41498191 shell "ls -la /sdcard/Download/HSPatched_Amaze*.apk 2>/dev/null"
$files | Select-Object -Last 3
# Check patch log
$log = & $adb -s 41498191 logcat -d -s HSPatcher 2>&1
$log | Select-String "compiled|FAILED|complete" | Select-Object -Last 5
