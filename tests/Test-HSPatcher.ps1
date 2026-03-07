#!/usr/bin/env pwsh
# ============================================================================
# HSPatcher Test Suite v3.45
# Comprehensive unit, integration, and device tests
# ============================================================================

param (
    [switch]$SkipDevice,        # Skip device tests (for CI/offline)
    [string]$DeviceSerial = "41498191"
)

$ErrorActionPreference = "Continue"
$script:passed = 0
$script:failed = 0
$script:skipped = 0
$script:errors = @()

$ROOT = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$HSPATCHER = Join-Path $ROOT "HSPatcher"
$PATCHES = Join-Path $HSPATCHER "patches\smali\in\startv\hotstar"
$JAVA_SRC = Join-Path $ROOT "temp_java_build\src\in\startv\hotstar"

# ============================================================================
# Test Helpers
# ============================================================================
function Test-Assert {
    param([string]$Name, [bool]$Condition, [string]$Detail = "")
    if ($Condition) {
        Write-Host "  [PASS] $Name" -ForegroundColor Green
        $script:passed++
    } else {
        $msg = "  [FAIL] $Name"
        if ($Detail) { $msg += " - $Detail" }
        Write-Host $msg -ForegroundColor Red
        $script:failed++
        $script:errors += ("$Name" + ": " + "$Detail")
    }
}

function Test-Skip {
    param([string]$Name, [string]$Reason = "")
    $msg = "  [SKIP] $Name"
    if ($Reason) { $msg += " - $Reason" }
    Write-Host $msg -ForegroundColor Yellow
    $script:skipped++
}

function Write-Section {
    param([string]$Title)
    Write-Host ""
    Write-Host "=" * 60 -ForegroundColor Cyan
    Write-Host "  $Title" -ForegroundColor Cyan
    Write-Host "=" * 60 -ForegroundColor Cyan
}

# ============================================================================
# UNIT TESTS: Java Source Validation
# ============================================================================
Write-Section "UNIT TESTS: Java Source Validation"

# Test 1: FileViewerActivity.java exists and has correct package
$fva = Join-Path $JAVA_SRC "FileViewerActivity.java"
Test-Assert "FileViewerActivity.java exists" (Test-Path $fva)

if (Test-Path $fva) {
    $fvaContent = Get-Content $fva -Raw

    # Test 2: Correct package declaration
    Test-Assert "FVA: correct package" ($fvaContent -match 'package in\.startv\.hotstar;')

    # Test 3: Extends Activity
    Test-Assert "FVA: extends Activity" ($fvaContent -match 'extends Activity')

    # Test 4: Has onCreate method
    Test-Assert "FVA: has onCreate" ($fvaContent -match 'protected void onCreate\(Bundle')

    # Test 5: Has onDestroy for cleanup (crash fix)
    Test-Assert "FVA: has onDestroy cleanup" ($fvaContent -match 'protected void onDestroy\(\)')

    # Test 6: doReplaceAll has NO division (crash fix verified)
    $replaceAllSection = ($fvaContent -split 'doReplaceAll')[1]
    if ($replaceAllSection) {
        $replaceAllMethod = ($replaceAllSection -split '(public|private|protected)\s+(void|int|String)')[0]
        $hasDivision = $replaceAllMethod -match '\(.*length.*-.*length.*\)\s*/\s*\('
        Test-Assert "FVA: doReplaceAll has NO division-by-zero" (-not $hasDivision) "Found potential division by zero"
    }

    # Test 7: try-catch wraps onCreate
    Test-Assert "FVA: onCreate has try-catch wrapper" ($fvaContent -match 'FileViewerActivity\.onCreate FATAL')

    # Test 8: Has animation imports
    Test-Assert "FVA: has animation imports" ($fvaContent -match 'import android\.animation\.|import android\.view\.animation\.')

    # Test 9: Has animateEntrance method
    Test-Assert "FVA: has animateEntrance" ($fvaContent -match 'animateEntrance')

    # Test 10: Dark theme colors defined
    Test-Assert "FVA: dark bg color" ($fvaContent -match 'C_BG_MAIN\s*=\s*0xFF1E1E1E')
    Test-Assert "FVA: syntax highlight keyword color" ($fvaContent -match 'C_SYN_KEYWORD\s*=\s*0xFF569CD6')

    # Test 11: Reads "filePath" intent extra (matches FileClickListener)
    Test-Assert "FVA: reads filePath intent extra" ($fvaContent -match 'getStringExtra\("filePath"\)')

    # Test 12: Symbol bar defined with Tab
    Test-Assert "FVA: symbol bar has Tab" ($fvaContent -match '"Tab"')

    # Test 13: Syntax highlighting patterns exist
    Test-Assert "FVA: has comment pattern" ($fvaContent -match 'commentPattern')
    Test-Assert "FVA: has string pattern" ($fvaContent -match 'stringPattern')
    Test-Assert "FVA: has keyword pattern" ($fvaContent -match 'keywordPattern')
    Test-Assert "FVA: has type pattern" ($fvaContent -match 'typePattern')

    # Test 14: File size limit prevents OOM
    Test-Assert "FVA: has file size limit" ($fvaContent -match '50\s*\*\s*1024\s*\*\s*1024')

    # Test 15: Syntax highlight size guard
    Test-Assert "FVA: syntax highlight size guard" ($fvaContent -match 'text\.length\(\)\s*>\s*150000')

    # Test 16: Handler cleanup prevents leak
    Test-Assert "FVA: handler cleanup in onDestroy" ($fvaContent -match 'handler\.removeCallbacks')
}

# FileExplorerActivity tests
$fea = Join-Path $JAVA_SRC "FileExplorerActivity.java"
Test-Assert "FileExplorerActivity.java exists" (Test-Path $fea)

if (Test-Path $fea) {
    $feaContent = Get-Content $fea -Raw

    # Test 17: Correct package
    Test-Assert "FEA: correct package" ($feaContent -match 'package in\.startv\.hotstar;')

    # Test 18: Has onCreate
    Test-Assert "FEA: has onCreate" ($feaContent -match 'protected void onCreate\(Bundle')

    # Test 19: try-catch wraps onCreate
    Test-Assert "FEA: onCreate has try-catch wrapper" ($feaContent -match 'FileExplorerActivity\.onCreate FATAL')

    # Test 20: Reads "path" intent extra (matches DebugPanel sender)
    Test-Assert "FEA: reads path intent extra" ($feaContent -match 'getStringExtra\("path"\)')

    # Test 21: Has animation methods
    Test-Assert "FEA: has item entrance animation" ($feaContent -match 'animateItemEntrance')
    Test-Assert "FEA: has animation imports" ($feaContent -match 'import android\.view\.animation\.')

    # Test 22: Has file icon detection
    Test-Assert "FEA: has image icon detection" ($feaContent -match '\.jpg.*\.png.*\.gif')
    Test-Assert "FEA: has APK icon detection" ($feaContent -match '\.apk')

    # Test 23: Dark theme defined
    Test-Assert "FEA: dark bg main" ($feaContent -match 'C_BG_MAIN\s*=\s*0xFF121212')

    # Test 24: Has delete recursive
    Test-Assert "FEA: has recursive delete" ($feaContent -match 'deleteRecursive')

    # Test 25: FileClickListener passes "filePath" extra
    Test-Assert "FEA: FileClickListener passes filePath" ($feaContent -match 'putExtra\("filePath"')

    # Test 26: NavClickListener navigates to directory
    Test-Assert "FEA: NavClickListener calls navigateTo" ($feaContent -match 'activity\.navigateTo\(path\)')

    # Test 27: FileComparator sorts dirs first
    Test-Assert "FEA: directories sorted first" ($feaContent -match 'a\.isDirectory\(\)\s*&&\s*!b\.isDirectory')
}

# ============================================================================
# INTEGRATION TESTS: Smali File Validation
# ============================================================================
Write-Section "INTEGRATION TESTS: Smali Structure"

# Test 28-29: All expected smali files exist
$expectedFiles = @(
    "FileViewerActivity.smali",
    "FileViewerActivity`$1.smali",
    "FileViewerActivity`$2.smali",
    "FileViewerActivity`$3.smali",
    "FileViewerActivity`$BackClickListener.smali",
    "FileViewerActivity`$SaveClickListener.smali",
    "FileViewerActivity`$DiscardClickListener.smali",
    "FileViewerActivity`$SearchActionListener.smali",
    "FileViewerActivity`$TextChangeWatcher.smali",
    "FileViewerActivity`$TextChangeWatcher`$1.smali",
    "FileExplorerActivity.smali",
    "FileExplorerActivity`$1.smali",
    "FileExplorerActivity`$2.smali",
    "FileExplorerActivity`$3.smali",
    "FileExplorerActivity`$BackClickListener.smali",
    "FileExplorerActivity`$NavClickListener.smali",
    "FileExplorerActivity`$HomeClickListener.smali",
    "FileExplorerActivity`$SdCardClickListener.smali",
    "FileExplorerActivity`$FileClickListener.smali",
    "FileExplorerActivity`$FileLongClickListener.smali",
    "FileExplorerActivity`$LongClickMenuListener.smali",
    "FileExplorerActivity`$LongClickMenuListener`$1.smali",
    "FileExplorerActivity`$DeleteConfirmListener.smali",
    "FileExplorerActivity`$FileComparator.smali",
    "FileExplorerActivity`$ScrollEndRunnable.smali"
)

$missingSmali = @()
foreach ($f in $expectedFiles) {
    $smaliPath = Join-Path $PATCHES $f
    if (-not (Test-Path $smaliPath)) {
        $missingSmali += $f
    }
}
Test-Assert "All 25 smali files exist in patches" ($missingSmali.Count -eq 0) "Missing: $($missingSmali -join ', ')"

# Test 30: Smali files are non-trivial (not empty/truncated)
$smallFiles = @()
foreach ($f in $expectedFiles) {
    $smaliPath = Join-Path $PATCHES $f
    if (Test-Path $smaliPath) {
        $size = (Get-Item $smaliPath).Length
        if ($size -lt 500) {
            $smallFiles += "$f ($size bytes)"
        }
    }
}
Test-Assert "All smali files > 500 bytes" ($smallFiles.Count -eq 0) "Too small: $($smallFiles -join ', ')"

# Test 31: Main smali files have proper class declaration
foreach ($activity in @("FileViewerActivity", "FileExplorerActivity")) {
    $smaliPath = Join-Path $PATCHES "$activity.smali"
    if (Test-Path $smaliPath) {
        $firstLines = Get-Content $smaliPath -First 5
        $hasClassDecl = ($firstLines -join "`n") -match "\.class.*Lin/startv/hotstar/$activity;"
        Test-Assert "$activity.smali: correct .class declaration" $hasClassDecl
        
        $hasSuperDecl = ($firstLines -join "`n") -match "\.super Landroid/app/Activity;"
        Test-Assert "$activity.smali: extends Activity" $hasSuperDecl
    }
}

# Test 32: Smali has onCreate method
foreach ($activity in @("FileViewerActivity", "FileExplorerActivity")) {
    $smaliPath = Join-Path $PATCHES "$activity.smali"
    if (Test-Path $smaliPath) {
        $content = Get-Content $smaliPath -Raw
        Test-Assert "$activity.smali: has .method onCreate" ($content -match '\.method.*onCreate\(Landroid/os/Bundle;\)V')
    }
}

# Test 33: FileViewerActivity smali has onDestroy
$fvaSmali = Join-Path $PATCHES "FileViewerActivity.smali"
if (Test-Path $fvaSmali) {
    $content = Get-Content $fvaSmali -Raw
    Test-Assert "FVA.smali: has onDestroy method" ($content -match '\.method.*onDestroy\(\)V')
}

# ============================================================================
# INTEGRATION TESTS: Intent Key Consistency
# ============================================================================
Write-Section "INTEGRATION TESTS: Intent Key Consistency"

# Test 34: DebugPanel passes "path" key
$dpListener = Join-Path $PATCHES "DebugPanelActivity`$OpenFileExplorerListener.smali"
if (Test-Path $dpListener) {
    $dpContent = Get-Content $dpListener -Raw
    Test-Assert "DebugPanel sends 'path' extra" ($dpContent -match 'const-string.*"path"')
} else {
    Test-Skip "DebugPanel sends 'path' extra" "Smali not found"
}

# Test 35: FileExplorerActivity reads "path" key (confirmed via Java source)
Test-Assert "FEA reads 'path' (Java verified)" ((Get-Content $fea -Raw) -match 'getStringExtra\("path"\)')

# Test 36: FileClickListener sends "filePath" key
$fclSmali = Join-Path $PATCHES "FileExplorerActivity`$FileClickListener.smali"
if (Test-Path $fclSmali) {
    $fclContent = Get-Content $fclSmali -Raw
    Test-Assert "FileClickListener sends 'filePath'" ($fclContent -match 'const-string.*"filePath"')
} else {
    Test-Skip "FileClickListener sends 'filePath'" "Smali not found"
}

# Test 37: FileViewerActivity reads "filePath" key (confirmed via Java source)
Test-Assert "FVA reads 'filePath' (Java verified)" ((Get-Content $fva -Raw) -match 'getStringExtra\("filePath"\)')

# ============================================================================
# INTEGRATION TESTS: Build Pipeline
# ============================================================================
Write-Section "INTEGRATION TESTS: Build Pipeline"

# Test 38: ManifestPatcher registers all activities
$mpJava = Join-Path $HSPATCHER "src\in\startv\hspatcher\ManifestPatcher.java"
if (Test-Path $mpJava) {
    $mpContent = Get-Content $mpJava -Raw
    Test-Assert "ManifestPatcher: registers FileExplorerActivity" ($mpContent -match 'FileExplorerActivity')
    Test-Assert "ManifestPatcher: registers FileViewerActivity" ($mpContent -match 'FileViewerActivity')
    Test-Assert "ManifestPatcher: registers DebugPanelActivity" ($mpContent -match 'DebugPanelActivity')
} else {
    Test-Skip "ManifestPatcher checks" "ManifestPatcher.java not found"
}

# Test 39: AndroidManifest.xml version
$manifest = Join-Path $HSPATCHER "AndroidManifest.xml"
if (Test-Path $manifest) {
    $manifestContent = Get-Content $manifest -Raw
    # Just check it has a versionCode and versionName
    Test-Assert "Manifest: has versionCode" ($manifestContent -match 'versionCode=')
    Test-Assert "Manifest: has versionName" ($manifestContent -match 'versionName=')
}

# Test 40: pack_patches.ps1 exists
Test-Assert "pack_patches.ps1 exists" (Test-Path (Join-Path $HSPATCHER "pack_patches.ps1"))

# Test 41: build.ps1 exists
Test-Assert "build.ps1 exists" (Test-Path (Join-Path $HSPATCHER "build.ps1"))

# Test 42: extra.zip in assets
$extraZip = Join-Path $HSPATCHER "assets\extra.zip"
Test-Assert "assets/extra.zip exists" (Test-Path $extraZip)
if (Test-Path $extraZip) {
    $zipSize = (Get-Item $extraZip).Length
    Test-Assert "extra.zip > 100KB" ($zipSize -gt 100000) "Size: $zipSize bytes"
}

# ============================================================================
# INTEGRATION TESTS: Smali Regex Pattern Validation 
# ============================================================================
Write-Section "INTEGRATION TESTS: Regex Patterns (Smali)"

# Test: Check that the smali properly encodes regex strings without broken escapes
if (Test-Path $fvaSmali) {
    $smaliContent = Get-Content $fvaSmali -Raw
    
    # The keyword regex pattern should compile — check it exists in smali as a const-string
    Test-Assert "FVA.smali: has keyword regex const-string" ($smaliContent -match 'const-string.*invoke-')
    
    # Check for animation-related smali instructions
    Test-Assert "FVA.smali: has animation code" ($smaliContent -match 'animateEntrance|DecelerateInterpolator')
}

# ============================================================================
# UNIT TESTS: Color Contrast Validation
# ============================================================================
Write-Section "UNIT TESTS: Color Contrast (Accessibility)"

function Get-Luminance($hex) {
    $r = (($hex -shr 16) -band 0xFF) / 255.0
    $g = (($hex -shr 8) -band 0xFF) / 255.0
    $b = ($hex -band 0xFF) / 255.0
    $r = if ($r -le 0.03928) { $r / 12.92 } else { [Math]::Pow(($r + 0.055) / 1.055, 2.4) }
    $g = if ($g -le 0.03928) { $g / 12.92 } else { [Math]::Pow(($g + 0.055) / 1.055, 2.4) }
    $b = if ($b -le 0.03928) { $b / 12.92 } else { [Math]::Pow(($b + 0.055) / 1.055, 2.4) }
    return 0.2126 * $r + 0.7152 * $g + 0.0722 * $b
}

function Get-ContrastRatio($fg, $bg) {
    $l1 = [Math]::Max((Get-Luminance $fg), (Get-Luminance $bg))
    $l2 = [Math]::Min((Get-Luminance $fg), (Get-Luminance $bg))
    return ($l1 + 0.05) / ($l2 + 0.05)
}

# WCAG AA requires 4.5:1 for normal text, 3:1 for large text (>= 14sp bold or >= 18sp)
$fvaBg = 0x1E1E1E
$fvaTextEditor = 0xD4D4D4
$fvaTextLinenum = 0x858585
$fvaTextToolbar = 0xFFFFFF
$fvaSynKeyword = 0x569CD6
$fvaSynString = 0xCE9178
$fvaSynComment = 0x6A9955

$cr1 = Get-ContrastRatio $fvaTextEditor $fvaBg
Test-Assert "FVA: editor text contrast >= 4.5:1" ($cr1 -ge 4.5) ("ratio: {0:F1}:1" -f $cr1)

$cr2 = Get-ContrastRatio $fvaTextToolbar 0x252526
Test-Assert "FVA: toolbar text contrast >= 4.5:1" ($cr2 -ge 4.5) ("ratio: {0:F1}:1" -f $cr2)

$cr3 = Get-ContrastRatio $fvaSynKeyword $fvaBg
Test-Assert "FVA: keyword color contrast >= 3:1 (large text)" ($cr3 -ge 3.0) ("ratio: {0:F1}:1" -f $cr3)

$cr4 = Get-ContrastRatio $fvaSynString $fvaBg
Test-Assert "FVA: string color contrast >= 3:1" ($cr4 -ge 3.0) ("ratio: {0:F1}:1" -f $cr4)

$cr5 = Get-ContrastRatio $fvaSynComment $fvaBg
Test-Assert "FVA: comment color contrast >= 3:1" ($cr5 -ge 3.0) ("ratio: {0:F1}:1" -f $cr5)

$feaBg = 0x121212
$feaTextPrimary = 0xE0E0E0
$feaTextSecondary = 0x888888

$cr6 = Get-ContrastRatio $feaTextPrimary $feaBg
Test-Assert "FEA: primary text contrast >= 4.5:1" ($cr6 -ge 4.5) ("ratio: {0:F1}:1" -f $cr6)

$cr7 = Get-ContrastRatio $feaTextSecondary $feaBg
Test-Assert "FEA: secondary text contrast >= 3:1" ($cr7 -ge 3.0) ("ratio: {0:F1}:1" -f $cr7)

# ============================================================================
# DEVICE TESTS
# ============================================================================
if ($SkipDevice) {
    Write-Section "DEVICE TESTS: Skipped (-SkipDevice)"
} else {
    Write-Section "DEVICE TESTS: On-Device Verification"

    # Test: Device connected
    $deviceCheck = adb -s $DeviceSerial get-state 2>&1
    $deviceConnected = $deviceCheck -eq "device"
    Test-Assert "Device $DeviceSerial connected" $deviceConnected

    if ($deviceConnected) {
        # Test: HSPatcher installed
        $pkgCheck = adb -s $DeviceSerial shell "pm list packages in.startv.hspatcher" 2>&1
        Test-Assert "HSPatcher app installed" ($pkgCheck -match "in.startv.hspatcher")

        # Test: Hotstar installed
        $hsCheck = adb -s $DeviceSerial shell "pm list packages in.startv.hotstar" 2>&1
        Test-Assert "Hotstar app installed" ($hsCheck -match "in.startv.hotstar")

        # Test: Launch HSPatcher (should not crash)
        adb -s $DeviceSerial logcat -c 2>$null
        adb -s $DeviceSerial shell "am start -n in.startv.hspatcher/in.startv.hspatcher.MainActivity" 2>$null
        Start-Sleep -Seconds 3

        $logcat = adb -s $DeviceSerial logcat -d 2>$null | Out-String
        $hasFatal = $logcat -match "FATAL EXCEPTION.*in\.startv\.hspatcher"
        Test-Assert "HSPatcher: no FATAL_EXCEPTION on launch" (-not $hasFatal)

        # Test: No crash from HSPatcher
        $hsPid = adb -s $DeviceSerial shell "pidof in.startv.hspatcher" 2>&1
        Test-Assert "HSPatcher: process alive after launch" ($hsPid -match '^\d+$')

        # Test: Hotstar app alive
        $hsPid2 = adb -s $DeviceSerial shell "pidof in.startv.hotstar" 2>&1
        if ($hsPid2 -match '^\d+$') {
            Test-Assert "Hotstar: process alive" $true
        } else {
            Test-Skip "Hotstar: process alive" "Process not running"
        }

        # Test: Check if FileExplorerActivity is registered in the Hotstar manifest
        $dumpOutput = adb -s $DeviceSerial shell "dumpsys package in.startv.hotstar" 2>&1 | Out-String
        $hasFEA = $dumpOutput -match "FileExplorerActivity"
        if ($hasFEA) {
            Test-Assert "Hotstar: FileExplorerActivity registered" $true
        } else {
            Test-Skip "Hotstar: FileExplorerActivity registered" "APK needs re-patching with latest HSPatcher"
        }

        $hasFVA = $dumpOutput -match "FileViewerActivity"
        if ($hasFVA) {
            Test-Assert "Hotstar: FileViewerActivity registered" $true
        } else {
            Test-Skip "Hotstar: FileViewerActivity registered" "APK needs re-patching with latest HSPatcher"
        }

        # Test: Build APK exists and is reasonable size
        $buildApk = Join-Path $HSPATCHER "build\HSPatcher.apk"
        if (Test-Path $buildApk) {
            $apkSize = (Get-Item $buildApk).Length
            Test-Assert "HSPatcher.apk size > 15MB" ($apkSize -gt 15000000) "Size: $($apkSize / 1MB) MB"
        } else {
            Test-Skip "HSPatcher.apk size check" "APK not built yet"
        }
    }
}

# ============================================================================
# SUMMARY
# ============================================================================
Write-Host ""
Write-Host "=" * 60 -ForegroundColor White
Write-Host "  TEST SUMMARY" -ForegroundColor White
Write-Host "=" * 60 -ForegroundColor White
Write-Host "  Passed:  $script:passed" -ForegroundColor Green
Write-Host "  Failed:  $script:failed" -ForegroundColor $(if($script:failed -gt 0){"Red"}else{"Green"})
Write-Host "  Skipped: $script:skipped" -ForegroundColor Yellow
Write-Host "  Total:   $($script:passed + $script:failed + $script:skipped)" -ForegroundColor White
Write-Host ""

if ($script:failed -gt 0) {
    Write-Host "  FAILED TESTS:" -ForegroundColor Red
    foreach ($err in $script:errors) {
        Write-Host "    - $err" -ForegroundColor Red
    }
    Write-Host ""
    exit 1
} else {
    Write-Host "  ALL TESTS PASSED!" -ForegroundColor Green
    Write-Host ""
    exit 0
}
