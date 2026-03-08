$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
$log = & $adb -s 41498191 logcat -d -s "AndroidRuntime:E" 2>&1
$log | Out-File "C:\Users\vishw\all_tools\app_mod\HSPatcher\crash_log.txt" -Encoding UTF8
Write-Host "=== CRASH LOG: $($log.Count) lines ==="
