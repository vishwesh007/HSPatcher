$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
$outFile = "C:\Users\vishw\all_tools\app_mod\HSPatcher\check_result2.txt"
$result = @()
$result += "=== Latest Amaze APKs ==="
$files = & $adb -s 41498191 shell "ls -la /sdcard/Download/HSPatched_Amaze*.apk 2>/dev/null"
$result += ($files | Select-Object -Last 3)
$result += ""
$result += "=== Device Time ==="
$result += (& $adb -s 41498191 shell date 2>&1)
$result += ""
$result += "=== Crash Check ==="
$log = & $adb -s 41498191 logcat -d 2>&1
$crashes = $log | Select-String "FATAL EXCEPTION" | ForEach-Object { $_.Line }
if ($crashes) { $result += "CRASHES FOUND:"; $result += ($crashes | Select-Object -Last 5) } else { $result += "No crashes detected" }
$result | Out-File $outFile -Force
