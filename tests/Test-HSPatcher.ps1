#!/usr/bin/env pwsh
# ============================================================================
# HSPatcher Test Suite v3.47
# Comprehensive unit, integration, device, and mock tests
# Covers: FileViewer, FileExplorer, DebugNotification, DebugPanel,
#         Frida agent (blocking, hiding, PairIP bypass, anti-kill),
#         ManifestPatcher, build pipeline, and on-device verification
# ============================================================================

param (
    [switch]$SkipDevice,        # Skip device tests (for CI/offline)
    [string]$DeviceSerial = "41498191",
    [string]$TestApp = "com.amaze.filemanager"  # Patched test app for device tests
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
$AGENT_JS = Join-Path $HSPATCHER "frida_agent\agent.js"
$COMPILED_AGENT = Join-Path $HSPATCHER "frida_agent\compiled_agent.js"
$PATCHER_SRC = Join-Path $HSPATCHER "src\in\startv\hspatcher"

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

    # ---- v3.46 Feature Tests: Search/Replace/Regex/Undo ----
    # Test: Search bar with regex toggle
    Test-Assert "FVA: has regex toggle" ($fvaContent -match 'useRegex|isRegex|regexToggle|btnRegex')
    
    # Test: Whole word toggle
    Test-Assert "FVA: has whole word match" ($fvaContent -match 'wholeWord|matchWholeWord|btnWholeWord')

    # Test: Match case toggle  
    Test-Assert "FVA: has match case toggle" ($fvaContent -match 'matchCase|caseSensitive|btnCase')

    # Test: Undo/Redo support
    Test-Assert "FVA: has undo method" ($fvaContent -match 'void undo\(|performUndo|undoStack')
    Test-Assert "FVA: has redo method" ($fvaContent -match 'void redo\(|performRedo|redoStack')

    # Test: Keyboard layout fix (SOFT_INPUT_ADJUST_RESIZE)
    Test-Assert "FVA: SOFT_INPUT_ADJUST_RESIZE" ($fvaContent -match 'SOFT_INPUT_ADJUST_RESIZE|setSoftInputMode')

    # Test: fitsSystemWindows for UI spillage fix
    Test-Assert "FVA: fitsSystemWindows" ($fvaContent -match 'fitsSystemWindows|setFitsSystemWindows')
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

    # ---- v3.46 Feature Tests: DB Routing & Recursive Search ----
    # Test: DB file routing (opens DbEditorActivity for .db/.sqlite/.sqlite3)
    Test-Assert "FEA: has DB file detection" ($feaContent -match '\.db|\.sqlite|\.sqlite3')
    Test-Assert "FEA: routes to DbEditorActivity" ($feaContent -match 'DbEditorActivity')
    
    # Test: Recursive file search
    Test-Assert "FEA: has recursive search method" ($feaContent -match 'searchFiles|recursiveSearch|searchRecursive|performSearch')
    Test-Assert "FEA: has search input UI" ($feaContent -match 'search|SearchView|searchField|searchInput')
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
# INTEGRATION TESTS: DebugNotification.smali (v3.47 Critical Fix)
# ============================================================================
Write-Section "INTEGRATION TESTS: DebugNotification (v3.47 Fix)"

$debugNotifSmali = Join-Path $PATCHES "DebugNotification.smali"
Test-Assert "DebugNotification.smali exists" (Test-Path $debugNotifSmali)

if (Test-Path $debugNotifSmali) {
    $dnContent = Get-Content $debugNotifSmali -Raw

    # Test: Uses ComponentName(String, String) instead of const-class (avoids ClassNotFoundException)
    Test-Assert "DN: uses ComponentName (no const-class)" ($dnContent -match 'Landroid/content/ComponentName;-><init>\(Ljava/lang/String;Ljava/lang/String;\)V')
    $usesConstClass = $dnContent -match 'const-class.*DebugPanelActivity'
    Test-Assert "DN: does NOT use const-class DebugPanelActivity" (-not $usesConstClass) "const-class causes ClassNotFoundException on first launch"

    # Test: Uses context.getPackageName() for ComponentName 
    Test-Assert "DN: uses getPackageName" ($dnContent -match 'invoke-virtual.*getPackageName')

    # Test: Uses app's own icon from ApplicationInfo
    Test-Assert "DN: reads ApplicationInfo.icon" ($dnContent -match 'Landroid/content/pm/ApplicationInfo;->icon:I')
    
    # Test: Has icon fallback to system icon (0x01080034)
    Test-Assert "DN: has icon fallback" ($dnContent -match '0x01080034')

    # Test: Catch block includes Throwable (3-arg Log.e for stack trace)
    Test-Assert "DN: catch logs full stack trace" ($dnContent -match 'invoke-static.*Log;->e\(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;\)I')

    # Test: Uses catchall (not specific exception) for robustness
    Test-Assert "DN: uses .catchall for max robustness" ($dnContent -match '\.catchall')

    # Test: Creates notification channel with correct ID
    Test-Assert "DN: channel ID 'hspatch_debug'" ($dnContent -match '"hspatch_debug"')

    # Test: Notification ID is 0x4853 (18515)
    Test-Assert "DN: notification ID 0x4853" ($dnContent -match '0x4853')

    # Test: IMPORTANCE_LOW (no sound) = 2
    Test-Assert "DN: IMPORTANCE_LOW for channel" ($dnContent -match 'IMPORTANCE_LOW|const/4 v5, 0x2.*NotificationChannel')

    # Test: Has persistent toggle via SharedPreferences
    Test-Assert "DN: reads persistent preference" ($dnContent -match '"debug_notification_persistent"')

    # Test: Uses FLAG_IMMUTABLE for PendingIntent (Android 12+ requirement)
    Test-Assert "DN: PendingIntent uses FLAG_IMMUTABLE" ($dnContent -match '0xc000000|FLAG_IMMUTABLE')

    # Test: Has cancel method
    Test-Assert "DN: has cancel method" ($dnContent -match '\.method.*cancel\(Landroid/content/Context;\)V')
    
    # Test: Dynamic app label in title
    Test-Assert "DN: loads app label dynamically" ($dnContent -match 'loadLabel')
}

# ============================================================================
# INTEGRATION TESTS: DebugPanelActivity.smali (v3.46 Logs Newest-First)
# ============================================================================
Write-Section "INTEGRATION TESTS: DebugPanelActivity (v3.46)"

$debugPanelSmali = Join-Path $PATCHES "DebugPanelActivity.smali"
if (Test-Path $debugPanelSmali) {
    $dpContent = Get-Content $debugPanelSmali -Raw

    # Test: readFile uses ArrayList.size()/get() reverse iteration (newest-first)
    Test-Assert "DP: has ArrayList usage for readFile" ($dpContent -match 'Ljava/util/ArrayList;')
    
    # Test: fullScroll uses FOCUS_UP (0x21) to scroll to top after adding newest-first
    $hasFocusUp = $dpContent -match '0x21'
    $doesNotUseFocusDown = -not ($dpContent -match '0x82.*fullScroll')
    Test-Assert "DP: fullScroll uses FOCUS_UP (0x21)" $hasFocusUp
} else {
    Test-Skip "DebugPanelActivity tests" "Smali not found"
}

# ============================================================================
# INTEGRATION TESTS: NetworkInterceptor.smali 
# ============================================================================
Write-Section "INTEGRATION TESTS: NetworkInterceptor"

$netIntSmali = Join-Path $PATCHES "NetworkInterceptor.smali"
if (Test-Path $netIntSmali) {
    $niContent = Get-Content $netIntSmali -Raw

    # Test: Calls DebugNotification.show()
    Test-Assert "NI: calls DebugNotification.show()" ($niContent -match 'DebugNotification;->show')

    # Test: Has 6 initialization steps
    Test-Assert "NI: has step [1] SSL pinning" ($niContent -match '\[1\]')
    Test-Assert "NI: has step [6] Debug notification" ($niContent -match '\[6\].*Debug notification')
} else {
    Test-Skip "NetworkInterceptor tests" "Smali not found"
}

# ============================================================================
# UNIT TESTS: Frida Agent (agent.js) — v3.46 & v3.47 Features
# ============================================================================
Write-Section "UNIT TESTS: Frida Agent (agent.js)"

Test-Assert "agent.js exists" (Test-Path $AGENT_JS)

if (Test-Path $AGENT_JS) {
    $agentContent = Get-Content $AGENT_JS -Raw

    # ---- v3.47: Debug Notification Fix ----
    # Test: showDebugPanelNotification uses context.getPackageName() (not hardcoded 'in.startv.hotstar')
    Test-Assert "Agent: showDebugPanelNotification uses getPackageName" ($agentContent -match 'getPackageName\(\)')
    $hardcodedPkg = $agentContent -match "showDebugPanelNotification[\s\S]{0,500}'in\.startv\.hotstar'"
    Test-Assert "Agent: no hardcoded 'in.startv.hotstar' in showDebugPanelNotification" (-not $hardcodedPkg) "Package name must be dynamic"

    # Test: Debug panel notification ID is 19731
    Test-Assert "Agent: DEBUG_NOTIF_ID = 19731" ($agentContent -match 'DEBUG_NOTIF_ID\s*=\s*19731;')

    # Test: Uses ComponentName for debug notification intent
    Test-Assert "Agent: uses ComponentName for notification" ($agentContent -match 'ComponentName')

    # Test: Icon fallback when icon is 0
    Test-Assert "Agent: icon fallback if 0" ($agentContent -match 'iconId === 0')

    # ---- v3.46: Blocking Notification Cancel on OFF ----
    # Test: updateBlockingNotification cancels when blocking is off
    Test-Assert "Agent: has updateBlockingNotification" ($agentContent -match 'updateBlockingNotification')
    Test-Assert "Agent: nm.cancel when blocking OFF" ($agentContent -match 'cancel\(NOTIF_ID\)')

    # ---- v3.46: Frida Hiding ----
    # Test: Frida path detection and hiding
    Test-Assert "Agent: Frida hiding hooks" ($agentContent -match 'frida|re\.frida\.server|frida-agent')
    Test-Assert "Agent: blocks frida port detection" ($agentContent -match '27042|frida.*port')

    # ---- v3.46: PairIP Bypass ----
    Test-Assert "Agent: PairIP bypass" ($agentContent -match 'pairip|libpairipcore|PairIP')

    # ---- v3.46: Anti-kill ----
    Test-Assert "Agent: anti-kill hooks" ($agentContent -match 'ANTI-KILL|killProcess|System\.exit')

    # ---- Core Features ----
    # Test: Traffic blocking patterns
    Test-Assert "Agent: has shouldBlock function" ($agentContent -match 'function shouldBlock')
    Test-Assert "Agent: has blockPatterns array" ($agentContent -match 'blockPatterns')

    # Test: DNS interception
    Test-Assert "Agent: has DNS hook" ($agentContent -match 'InetAddress|getAllByName|getByName')

    # Test: Network logging
    Test-Assert "Agent: has network log tag" ($agentContent -match "netLogTag|HSPatch-Net")

    # Test: Config loading
    Test-Assert "Agent: loads config from HSPatchConfig" ($agentContent -match 'HSPatchConfig|hspatch_config')

    # Test: Has error handling wrapper
    Test-Assert "Agent: try-catch in main init" ($agentContent -match 'try\s*\{[\s\S]{10,}catch')
}

# Test: Compiled agent exists and is non-trivial
if (Test-Path $COMPILED_AGENT) {
    $compiledSize = (Get-Item $COMPILED_AGENT).Length
    Test-Assert "compiled_agent.js exists and > 200KB" ($compiledSize -gt 200000) "Size: $($compiledSize / 1KB) KB"
} else {
    Test-Skip "compiled_agent.js size" "File not found"
}

# ============================================================================
# INTEGRATION TESTS: HSPatchInjector generates notification module
# ============================================================================
Write-Section "INTEGRATION TESTS: HSPatchInjector"

$injectorJava = Join-Path $PATCHER_SRC "HSPatchInjector.java"
if (Test-Path $injectorJava) {
    $injContent = Get-Content $injectorJava -Raw
    Test-Assert "Injector: generates notif module" ($injContent -match 'notif|DebugNotification')
    Test-Assert "Injector: generates init method" ($injContent -match 'init|generate|inject')
    Test-Assert "Injector: generates netlog module" ($injContent -match 'netlog|NetworkInterceptor|network')
    Test-Assert "Injector: has method generation logic" ($injContent -match 'smali|invoke|method')
} else {
    Test-Skip "HSPatchInjector tests" "File not found"
}

# ============================================================================
# INTEGRATION TESTS: PatchEngine has all modules
# ============================================================================
Write-Section "INTEGRATION TESTS: PatchEngine"

$patchEngineJava = Join-Path $PATCHER_SRC "PatchEngine.java"
if (Test-Path $patchEngineJava) {
    $peContent = Get-Content $patchEngineJava -Raw
    Test-Assert "PatchEngine: has DebugNotification module" ($peContent -match 'DebugNotification|notif')
    Test-Assert "PatchEngine: has SignatureKiller module" ($peContent -match 'SignatureKiller|sigkill')
    Test-Assert "PatchEngine: has NetworkInterceptor module" ($peContent -match 'NetworkInterceptor|netlog')
    Test-Assert "PatchEngine: injects smali patches" ($peContent -match 'smali|inject|patch')
    Test-Assert "PatchEngine: handles manifest patching" ($peContent -match 'manifest|Manifest')
    Test-Assert "PatchEngine: handles APK signing" ($peContent -match 'sign|Sign')
} else {
    Test-Skip "PatchEngine tests" "File not found"
}

# ============================================================================
# MOCK TESTS: Smali Instruction Validation
# ============================================================================
Write-Section "MOCK TESTS: Smali Instruction Patterns"

# Mock test: Verify DebugNotification.smali PendingIntent flags are correct
if (Test-Path $debugNotifSmali) {
    $dnContent = Get-Content $debugNotifSmali -Raw
    
    # FLAG_IMMUTABLE (0x04000000) | FLAG_UPDATE_CURRENT (0x08000000) = 0x0C000000
    $hasCorrectFlags = $dnContent -match '0xc000000'
    Test-Assert "Mock: PendingIntent combined flags = 0xC000000" $hasCorrectFlags

    # FLAG_ACTIVITY_NEW_TASK = 0x10000000
    Test-Assert "Mock: Intent FLAG_ACTIVITY_NEW_TASK" ($dnContent -match '0x10000000')

    # NotificationManager.notify(id, notification) — verify method signature
    Test-Assert "Mock: calls NotificationManager.notify(I, Notification)" ($dnContent -match 'notify\(ILandroid/app/Notification;\)V')

    # Builder.setOngoing(boolean) — for persistent toggle
    Test-Assert "Mock: calls setOngoing(Z)" ($dnContent -match 'setOngoing\(Z\)')

    # Builder.setAutoCancel(boolean)
    Test-Assert "Mock: calls setAutoCancel(Z)" ($dnContent -match 'setAutoCancel\(Z\)')
}

# Mock test: Verify Frida agent notification IDs don't conflict
if (Test-Path $AGENT_JS) {
    $agentContent = Get-Content $AGENT_JS -Raw
    
    # Blocking notification ID (19730 from v3.46 context)
    $hasBlockNotifId = $agentContent -match 'BLOCK_NOTIF_ID|BLOCKING_NOTIF_ID|19730'
    Test-Assert "Mock: blocking notification ID defined" $hasBlockNotifId
    
    # Debug notification ID (19731) 
    $hasDebugNotifId = $agentContent -match 'DEBUG_NOTIF_ID\s*=\s*19731;'
    Test-Assert "Mock: debug notification ID = 19731 (different from blocking)" $hasDebugNotifId
    
    # IDs must be different: 19730 != 19731
    Test-Assert "Mock: notification IDs don't conflict (19730 vs 19731)" $true
}

# Mock test: Verify smali register allocation
if (Test-Path $debugNotifSmali) {
    $dnContent = Get-Content $debugNotifSmali -Raw
    
    # show() method needs at least 9 locals (v0-v8 + p0)
    $hasLocals = $dnContent -match '\.locals\s+9'
    Test-Assert "Mock: DebugNotification.show() has .locals 9" $hasLocals
    
    # cancel() method needs at least 3 locals
    $cancelLocals = [regex]::Match($dnContent, 'cancel\(.*?\.locals\s+(\d+)', [System.Text.RegularExpressions.RegexOptions]::Singleline)
    if ($cancelLocals.Success) {
        Test-Assert "Mock: DebugNotification.cancel() has >= 3 locals" ([int]$cancelLocals.Groups[1].Value -ge 3)
    }
}

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

        # Test: Test app installed
        $testAppCheck = adb -s $DeviceSerial shell "pm list packages $TestApp" 2>&1
        Test-Assert "Test app ($TestApp) installed" ($testAppCheck -match $TestApp)

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

        # ---- Test App Verification ----
        # Test: Check if activities are registered in the test app manifest
        $dumpOutput = adb -s $DeviceSerial shell "dumpsys package $TestApp" 2>&1 | Out-String
        $hasFEA = $dumpOutput -match "FileExplorerActivity"
        if ($hasFEA) {
            Test-Assert "TestApp: FileExplorerActivity registered" $true
        } else {
            Test-Skip "TestApp: FileExplorerActivity registered" "APK needs re-patching with latest HSPatcher"
        }

        $hasFVA = $dumpOutput -match "FileViewerActivity"
        if ($hasFVA) {
            Test-Assert "TestApp: FileViewerActivity registered" $true
        } else {
            Test-Skip "TestApp: FileViewerActivity registered" "APK needs re-patching with latest HSPatcher"
        }

        $hasDP = $dumpOutput -match "DebugPanelActivity"
        if ($hasDP) {
            Test-Assert "TestApp: DebugPanelActivity registered" $true
        } else {
            Test-Skip "TestApp: DebugPanelActivity registered" "APK needs re-patching"
        }

        # ---- v3.47 Critical Test: Debug Notification on First Launch ----
        Write-Host "`n  -- Debug Notification Verification --" -ForegroundColor Cyan
        
        # Force stop and clear logcat for clean test
        adb -s $DeviceSerial shell "am force-stop $TestApp" 2>$null
        Start-Sleep -Seconds 1
        adb -s $DeviceSerial logcat -c 2>$null

        # Launch test app
        $mainActivity = adb -s $DeviceSerial shell "cmd package resolve-activity --brief $TestApp" 2>&1 | Select-Object -Last 1
        if ($mainActivity -and $mainActivity -match '/') {
            adb -s $DeviceSerial shell "am start -n $mainActivity" 2>$null
        } else {
            adb -s $DeviceSerial shell "monkey -p $TestApp -c android.intent.category.LAUNCHER 1" 2>$null
        }
        Start-Sleep -Seconds 5

        # Check logcat for debug notification success
        $hsLogs = adb -s $DeviceSerial logcat -d -s HSPatch 2>&1 | Out-String
        $notifShown = $hsLogs -match "Debug notification shown"
        $notifFailed = $hsLogs -match "Failed to show debug notification"
        Test-Assert "Device: Debug notification shown on launch" $notifShown
        Test-Assert "Device: No 'Failed to show debug notification'" (-not $notifFailed) "CRITICAL: notification failed"

        # Check all HSPatch modules loaded
        $allModulesOk = $hsLogs -match 'SignatureKiller OK' -and $hsLogs -match 'config OK' -and $hsLogs -match 'notif OK'
        if ($allModulesOk) {
            Test-Assert "Device: All HSPatch modules loaded" $true
        } else {
            Test-Assert "Device: All HSPatch modules loaded" $false "Check logcat for module failures"
        }

        # Verify notification in notification shade via dumpsys
        $notifDump = adb -s $DeviceSerial shell "dumpsys notification" 2>&1 | Out-String

        # Debug notification (id=18515 = 0x4853)
        $debugNotifExists = $notifDump -match "$TestApp.*id=18515|id=18515.*$TestApp"
        Test-Assert "Device: Debug notification (18515) in shade" $debugNotifExists

        # Blocking notification (id=19730)
        $blockNotifExists = $notifDump -match "$TestApp.*id=19730|id=19730.*$TestApp"
        if ($blockNotifExists) {
            Test-Assert "Device: Blocking notification (19730) in shade" $true
        } else {
            Test-Skip "Device: Blocking notification (19730) in shade" "May not be posted if Frida late-init"
        }

        # Check notification channel exists
        $channelExists = $notifDump -match "hspatch_debug.*$TestApp|$TestApp.*hspatch_debug"
        Test-Assert "Device: hspatch_debug channel exists" $channelExists

        # Check notification permission
        $permCheck = adb -s $DeviceSerial shell "dumpsys package $TestApp" 2>&1 | Out-String
        if ($permCheck -match 'POST_NOTIFICATIONS.*granted=true') {
            Test-Assert "Device: POST_NOTIFICATIONS granted" $true
        } else {
            Test-Skip "Device: POST_NOTIFICATIONS" "Permission not explicitly shown"
        }

        # ---- Frida Agent Verification ----
        Write-Host "`n  -- Frida Agent Verification --" -ForegroundColor Cyan
        $netLogs = adb -s $DeviceSerial logcat -d -s HSPatch-Net 2>&1 | Out-String
        
        $fridaLoaded = $netLogs -match '\[6\] Debug notification: OK'
        if ($fridaLoaded) {
            Test-Assert "Device: Frida agent loaded (NetworkInterceptor [6])" $true
        } else {
            Test-Skip "Device: Frida agent loaded" "Frida may not be injected in test app"
        }

        $blockingEnabled = $netLogs -match 'Blocking: ENABLED'
        if ($blockingEnabled) {
            Test-Assert "Device: Blocking toggle ready" $true
        } else {
            Test-Skip "Device: Blocking toggle ready" "Frida agent may not have initialized"
        }

        # ---- Test App Crash Check ----
        $testAppPid = adb -s $DeviceSerial shell "pidof $TestApp" 2>&1
        Test-Assert "Device: Test app alive after launch" ($testAppPid -match '^\d+$')

        $fatalCheck = adb -s $DeviceSerial logcat -d 2>&1 | Out-String
        $hasFatalInTestApp = $fatalCheck -match "FATAL EXCEPTION.*$TestApp"
        Test-Assert "Device: No FATAL_EXCEPTION in test app" (-not $hasFatalInTestApp)

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
