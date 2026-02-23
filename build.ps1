# HSPatcher Build Script v2
# Builds the HSPatcher Android APK from source using Android SDK command-line tools.
# Usage: .\build.ps1 [-Install] [-Clean]

param(
    [switch]$Install,
    [switch]$Clean
)

$ErrorActionPreference = "Stop"

# ======================== PATHS ========================
$PROJECT     = $PSScriptRoot
$SDK         = Join-Path $env:LOCALAPPDATA "Android\Sdk"
$BT          = Join-Path $SDK "build-tools\36.1.0"
$ANDROID_JAR = Join-Path $SDK "platforms\android-36\android.jar"
$APKTOOL_JAR = Join-Path (Split-Path $PROJECT) "apktool_2.9.3.jar"
$KEYSTORE    = Join-Path $env:USERPROFILE ".android\debug.keystore"

$AAPT2       = Join-Path $BT "aapt2.exe"
$D8          = Join-Path $BT "d8.bat"
$ZIPALIGN    = Join-Path $BT "zipalign.exe"
$APKSIGNER   = Join-Path $BT "apksigner.bat"
$ARSCLIB_JAR = Join-Path $PROJECT "libs\ARSCLib-1.3.8.jar"
$APKSIG_JAR  = Join-Path $PROJECT "libs\apksig-8.7.3.jar"

$BUILD       = Join-Path $PROJECT "build"
$GEN         = Join-Path $BUILD "gen"
$OBJ         = Join-Path $BUILD "obj"
$DEX_DIR     = Join-Path $BUILD "dex"
$RES_COMPILED = Join-Path $BUILD "res_compiled"

Write-Host "=== HSPatcher Build System ===" -ForegroundColor Cyan

# ======================== CLEAN ========================
if ($Clean -or !(Test-Path $BUILD)) {
    Write-Host "Cleaning build directory..."
    if (Test-Path $BUILD) { Remove-Item -Recurse -Force $BUILD }
}
foreach ($d in @($BUILD, $GEN, $OBJ, $DEX_DIR, $RES_COMPILED)) {
    if (!(Test-Path $d)) { New-Item -ItemType Directory -Force $d | Out-Null }
}

# ======================== STEP 1: COMPILE RESOURCES ========================
Write-Host "`nStep 1: Compiling resources..."
Get-ChildItem (Join-Path $PROJECT "res") -Recurse -File | ForEach-Object {
    & $AAPT2 compile $_.FullName -o $RES_COMPILED 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "aapt2 compile failed for $($_.Name)" }
}
$flatFiles = Get-ChildItem $RES_COMPILED -Filter "*.flat"
Write-Host "  Compiled $($flatFiles.Count) resource files" -ForegroundColor Green

# ======================== STEP 2: LINK RESOURCES ========================
Write-Host "`nStep 2: Linking resources..."
$baseApk = Join-Path $BUILD "base.apk"
$rJavaDir = $GEN

$linkArgs = [System.Collections.ArrayList]@(
    "link", "--auto-add-overlay",
    "-I", $ANDROID_JAR,
    "--manifest", (Join-Path $PROJECT "AndroidManifest.xml"),
    "--java", $rJavaDir,
    "-o", $baseApk,
    "--min-sdk-version", "26",
    "--target-sdk-version", "34"
)
foreach ($f in $flatFiles) {
    $linkArgs.Add("-R") | Out-Null
    $linkArgs.Add($f.FullName) | Out-Null
}
& $AAPT2 @linkArgs 2>&1
if ($LASTEXITCODE -ne 0) { throw "aapt2 link failed" }

$rJava = Join-Path $rJavaDir "in\startv\hspatcher\R.java"
if (!(Test-Path $rJava)) { throw "R.java not generated!" }
$rSize = (Get-Item $rJava).Length
if ($rSize -lt 300) { throw "R.java is too small ($rSize bytes) - resources not linked properly!" }
Write-Host "  R.java: $rSize bytes" -ForegroundColor Green

# ======================== STEP 3: COMPILE JAVA ========================
Write-Host "`nStep 3: Compiling Java sources..."
$javaSources = @()
Get-ChildItem (Join-Path $PROJECT "src") -Recurse -Filter "*.java" | ForEach-Object { $javaSources += $_.FullName }
Get-ChildItem $GEN -Recurse -Filter "*.java" | ForEach-Object { $javaSources += $_.FullName }

$classpath = "$ANDROID_JAR;$APKTOOL_JAR;$ARSCLIB_JAR;$APKSIG_JAR"
& javac -source 8 -target 8 -Xlint:-options -classpath $classpath -d $OBJ @javaSources 2>&1
if ($LASTEXITCODE -ne 0) { throw "javac compilation failed" }
$classCount = (Get-ChildItem $OBJ -Recurse -Filter "*.class").Count
Write-Host "  Compiled $classCount classes" -ForegroundColor Green

# ======================== STEP 4: DEX COMPILATION ========================
Write-Host "`nStep 4: Creating DEX..."

# Strip android.* stubs from ARSCLib to avoid duplicate class conflict with apktool
$ARSCLIB_CLEAN = Join-Path $BUILD "ARSCLib-clean.jar"
if (!(Test-Path $ARSCLIB_CLEAN)) {
    Write-Host "  Stripping android.* stubs from ARSCLib..."
    $arsclibTmp = Join-Path $BUILD "arsclib_tmp"
    if (Test-Path $arsclibTmp) { Remove-Item -Recurse -Force $arsclibTmp }
    New-Item -ItemType Directory -Force $arsclibTmp | Out-Null
    Push-Location $arsclibTmp
    & jar xf $ARSCLIB_JAR 2>&1
    # Remove conflicting Android framework stubs and xmlpull (already in apktool)
    if (Test-Path "android") { Remove-Item -Recurse -Force "android" }
    if (Test-Path "org/xmlpull") { Remove-Item -Recurse -Force "org/xmlpull" }
    & jar cf $ARSCLIB_CLEAN -C . . 2>&1
    Pop-Location
    Remove-Item -Recurse -Force $arsclibTmp
    Write-Host "  ARSCLib cleaned: $([math]::Round((Get-Item $ARSCLIB_CLEAN).Length/1024)) KB" -ForegroundColor Green
}

$ourJar = Join-Path $BUILD "hspatcher_classes.jar"
Push-Location $OBJ
& jar cf $ourJar -C . . 2>&1
Pop-Location

& $D8 --min-api 26 --output $DEX_DIR $ourJar $APKTOOL_JAR $ARSCLIB_CLEAN $APKSIG_JAR 2>&1
if ($LASTEXITCODE -ne 0) { throw "d8 failed" }
$dexFiles = Get-ChildItem $DEX_DIR -Filter "*.dex"
foreach ($dex in $dexFiles) {
    Write-Host "  $($dex.Name): $([math]::Round($dex.Length/1024)) KB" -ForegroundColor Green
}

# ======================== STEP 5: BUILD APK ========================
Write-Host "`nStep 5: Building APK..."
$unsignedApk = Join-Path $BUILD "unsigned.apk"
Copy-Item $baseApk $unsignedApk -Force

# Add DEX files
Push-Location $DEX_DIR
foreach ($dex in $dexFiles) { & jar -uf $unsignedApk $dex.Name 2>&1 }
Pop-Location

# Add assets
$assetsDir = Join-Path $PROJECT "assets"
if (Test-Path $assetsDir) {
    Push-Location $PROJECT
    & jar -uf $unsignedApk "assets/extra.zip" 2>&1
    Write-Host "  Added assets/extra.zip" -ForegroundColor Green

    # Create Frida gadgets zip from local gadget files
    $gadgetArm64 = Join-Path (Split-Path $PROJECT) "decompiled\lib\arm64-v8a\libgadget.so"
    $gadgetArm   = Join-Path (Split-Path $PROJECT) "decompiled\lib\armeabi-v7a\libgadget.so"
    $fridaConfig = Join-Path $PROJECT "assets\frida\libgadget.config.so"
    $fridaScript = Join-Path $PROJECT "assets\frida\libgadget.js.so"
    $fridaZip    = Join-Path $assetsDir "frida_gadgets.zip"

    if ((Test-Path $gadgetArm64) -and (Test-Path $fridaConfig) -and (Test-Path $fridaScript)) {
        Write-Host "  Creating Frida gadgets zip..."
        $fridaTmp = Join-Path $BUILD "frida_tmp"
        if (Test-Path $fridaTmp) { Remove-Item -Recurse -Force $fridaTmp }
        New-Item -ItemType Directory -Force "$fridaTmp\arm64-v8a" | Out-Null

        Copy-Item $gadgetArm64 "$fridaTmp\arm64-v8a\libgadget.so"
        if (Test-Path $gadgetArm) {
            New-Item -ItemType Directory -Force "$fridaTmp\armeabi-v7a" | Out-Null
            Copy-Item $gadgetArm "$fridaTmp\armeabi-v7a\libgadget.so"
        }
        Copy-Item $fridaConfig "$fridaTmp\libgadget.config.so"
        Copy-Item $fridaScript "$fridaTmp\libgadget.js.so"

        if (Test-Path $fridaZip) { Remove-Item $fridaZip }
        Push-Location $fridaTmp
        & jar cf $fridaZip * 2>&1
        Pop-Location

        & jar -uf $unsignedApk "assets/frida_gadgets.zip" 2>&1
        $fridaSizeMB = [math]::Round((Get-Item $fridaZip).Length / 1MB, 1)
        Write-Host "  Added assets/frida_gadgets.zip ($fridaSizeMB MB)" -ForegroundColor Green
        Remove-Item -Recurse -Force $fridaTmp
    } else {
        Write-Host "  Frida gadget files not found — skipping (optional)" -ForegroundColor Yellow
    }

    Pop-Location
}

# ======================== STEP 6: ZIPALIGN ========================
Write-Host "`nStep 6: Zipalign..."
$alignedApk = Join-Path $BUILD "aligned.apk"
& $ZIPALIGN -f 4 $unsignedApk $alignedApk 2>&1
if ($LASTEXITCODE -ne 0) { throw "zipalign failed" }

# ======================== STEP 7: SIGN ========================
Write-Host "`nStep 7: Signing..."
$signedApk = Join-Path $BUILD "HSPatcher.apk"
& $APKSIGNER sign --v1-signing-enabled true --v2-signing-enabled true --v3-signing-enabled true --ks $KEYSTORE --ks-pass pass:android --ks-key-alias androiddebugkey --key-pass pass:android --out $signedApk $alignedApk 2>&1
if ($LASTEXITCODE -ne 0) { throw "apksigner failed" }

# ======================== DONE ========================
$finalSize = [math]::Round((Get-Item $signedApk).Length / 1024)
$sizeStr = "$finalSize"
Write-Host "`n=== BUILD SUCCESSFUL: HSPatcher.apk ($sizeStr K) ===" -ForegroundColor Green

if ($Install) {
    Write-Host "`nInstalling..."
    & adb install -r $signedApk 2>&1
}
