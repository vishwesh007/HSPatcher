$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
$instrFile = "C:\Users\vishw\all_tools\app_mod\INSTRUCTIONS.txt"
$resultFile = "C:\Users\vishw\all_tools\app_mod\HSPatcher\poll_result.txt"
$marker = "Write your results below this line:"
$maxWait = 300  # 5 minutes
$interval = 30  # 30 seconds
$elapsed = 0
$result = @()

while ($elapsed -lt $maxWait) {
    Start-Sleep -Seconds $interval
    $elapsed += $interval
    
    # Check for crashes
    $log = & $adb -s 41498191 logcat -d 2>&1
    $crashes = $log | Select-String "FATAL EXCEPTION" | ForEach-Object { $_.Line }
    $amazeCrashes = $log | Select-String "amaze.*NoSuchMethod|amaze.*NoSuchField|amaze.*VerifyError|amaze.*FATAL" | ForEach-Object { $_.Line }
    
    # Check instructions file
    $content = Get-Content $instrFile -Raw
    $markerPos = $content.IndexOf($marker)
    if ($markerPos -ge 0) {
        $afterMarker = $content.Substring($markerPos + $marker.Length).Trim()
        # Check the last separator line
        $sepPos = $afterMarker.IndexOf("---")
        if ($sepPos -ge 0) {
            $userText = $afterMarker.Substring($sepPos + 3).Trim()
            if ($userText.Length -gt 0) {
                $result += "=== User Response Found at ${elapsed}s ==="
                $result += $userText
                $result += ""
                break
            }
        }
    }
    
    if ($amazeCrashes) {
        $result += "=== AMAZE CRASH DETECTED at ${elapsed}s ==="
        $result += $amazeCrashes
        # Get full stacktrace
        $stacktrace = $log | Select-String "AndroidRuntime" | ForEach-Object { $_.Line } | Select-Object -Last 30
        $result += $stacktrace
        break
    }
    
    $result += "[${elapsed}s] No user response, no Amaze crashes"
}

if ($elapsed -ge $maxWait -and $result.Count -eq 0) {
    $result += "=== Timeout after ${maxWait}s ==="
    $result += "No user response and no crashes detected"
}

$result | Out-File $resultFile -Force
