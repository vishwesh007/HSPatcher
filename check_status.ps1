$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
$outFile = "C:\Users\vishw\all_tools\app_mod\HSPatcher\check_result.txt"
$result = @()
$result += "=== Latest Amaze APKs ==="
$files = & $adb -s 41498191 shell "ls -la /sdcard/Download/HSPatched_Amaze*.apk 2>/dev/null"
$result += ($files | Select-Object -Last 5)
$result += ""
$result += "=== Device Time ==="
$result += (& $adb -s 41498191 shell date 2>&1)
$result += ""
$result += "=== Patch Log ==="
$log = & $adb -s 41498191 logcat -d 2>&1
$compiled = $log | Select-String "compiled|FAILED|Patching complete|SMALI" | ForEach-Object { $_.Line }
if ($compiled) { $result += ($compiled | Select-Object -Last 10) } else { $result += "No patch log entries found" }
$result += ""
$result += "=== Crash Check ==="
$crashes = $log | Select-String "FATAL|NoSuchMethod|NoSuchField|VerifyError" | ForEach-Object { $_.Line }
if ($crashes) { $result += ($crashes | Select-Object -Last 10) } else { $result += "No crashes detected" }
$result | Out-File $outFile -Force
