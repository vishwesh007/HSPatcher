# HSPatcher — AI Coding Agent Instructions

## Architecture Overview

HSPatcher is a **standalone Android APK patcher** built without Gradle — it uses raw Android SDK tools (`aapt2`, `javac`, `d8`, `apksigner`) orchestrated by PowerShell scripts. It has two distinct codebases that ship together:

1. **Patcher App** (`src/`) — Java Android app that decompiles, injects, and re-signs target APKs on-device
2. **Injected Payload** — Smali patches (`patches/smali/`) + Frida gadget script (`assets/frida/libgadget.js.so`) that get bundled into every patched APK

The patcher app extracts `assets/extra.zip` (containing smali modules) and `assets/frida_gadgets.zip` (containing native Frida gadgets + JS script) into target APKs at patch time.

## Build & Deploy Workflow

```powershell
# 1. After editing smali patches, ALWAYS repack first:
pwsh -ExecutionPolicy Bypass -File pack_patches.ps1

# 2. Build the patcher APK:
pwsh -ExecutionPolicy Bypass -File build.ps1

# 3. Install to device:
adb install -r build/HSPatcher.apk
```

**Critical:** `pack_patches.ps1` must run before `build.ps1` whenever any file under `patches/` changes. The build script does NOT auto-repack patches. Output is `build/HSPatcher.apk`.

## Key File Relationships

| File | Role | When to modify |
|------|------|----------------|
| `src/.../PatchEngine.java` | Core patching pipeline (DEX injection, hook class detection) | Adding new injection targets |
| `src/.../MainActivity.java` | UI + install flow (~980 lines) | UI changes, version display |
| `src/.../ManifestPatcher.java` | Binary AXML manifest injection | Adding permissions/activities |
| `patches/smali/.../HSPatchConfig.smali` | Singleton config for injected modules; `getFilePath()`, `getBlockingFileName()`, `getBlockingFilePath()` | Adding shared state/helpers |
| `patches/smali/.../UrlHook.smali` | Java-side URL rewriting + blocking | Modifying URL-level interception |
| `patches/smali/.../DebugPanelActivity.smali` | In-app debug panel (925+ lines) | Adding debug UI features |
| `assets/frida/libgadget.js.so` | Frida gadget JS — 5 sections: SSL bypass, Signature bypass, Piracy bypass, Screenshot bypass, Network blocking | Runtime hook changes |
| `AndroidManifest.xml` | Patcher app manifest — bump `versionCode`/`versionName` for each release | Every release |

## Smali Conventions

- All injected smali lives under `patches/smali/in/startv/hotstar/` (package `in.startv.hotstar`)
- Inner classes use `$` naming: `DebugPanelActivity$SaveRulesListener.smali`
- `.locals N` must account for all registers used in the method — increase when adding code
- Use `ActivityThread.currentApplication()` to get Context in static methods without a Context parameter
- `HSPatchConfig.getFilePath(filename)` builds `filesDir + "/" + filename` — always use this, never hardcode paths
- Per-app blocking files follow the pattern: `blocking_<packageName>.txt` → `blocking_rules.txt` → `blocking_hotstar.txt` (legacy)

## Frida Script Structure (`libgadget.js.so`)

The script runs inside `setTimeout → Java.perform` and has 5 ordered sections:
1. **SSL Bypass** — TrustManagerImpl, OpenSSLSocketImpl, OkHttp CertificatePinner, HttpsURLConnection
2. **Signature Bypass** — PackageManager.getPackageInfo hooks
3. **Piracy Bypass** — LicenseChecker, installer name spoof, root/debug detection
4. **Screenshot Bypass** — Window.setFlags, SurfaceView.setSecure
5. **Network Blocking** — `loadBlockingRules()`, `shouldBlock()`, `applyRewrites()`, then hooks for URL.openConnection, OkHttp3.newCall, HttpURLConnection.connect, WebView.loadUrl, Socket (×2), SocketChannel (×2), DatagramSocket (×2), SSLSocketFactory

Each hook is wrapped in `try { } catch (err) { }` so failures in one don't break others.

## Per-App Blocking File System

Blocking rules are loaded from the first file found in this priority order:
1. `blocking_<packageName>.txt` in app's external files dir
2. `blocking_<packageName>.txt` in `/storage/emulated/0/Download/hspatch_logs/`
3. `blocking_rules.txt` (same search paths)
4. `blocking_hotstar.txt` (legacy, same search paths)

This logic exists in **three places** that must stay in sync:
- `HSPatchConfig.getBlockingFilePath()` (smali) — used by UrlHook + DebugPanel
- `HSPatchConfig.getBlockingFileName()` (smali) — used by SaveRulesListener
- `loadBlockingRules()` in `libgadget.js.so` (Frida) — runtime blocking

## Testing Checklist

Test device: POCO F1 (serial `9fa23325`). After any change:
1. Verify HSPatcher installs and launches: `adb shell am start -n in.startv.hspatcher/.MainActivity`
2. Check version display: `adb shell "dumpsys activity top | grep version_text"`
3. Patch a target APK through the UI and verify it installs
4. Check injected hooks via logcat: `adb logcat -s HSPatch-Frida HSPatch-Net HSPatch`
5. For blocking changes: verify `[RULES] Loading blocking rules from:` appears in logcat
6. For UI changes in debug panel: open via the persistent notification in the patched app

## Version Bumping

Update `android:versionCode` and `android:versionName` in `AndroidManifest.xml` for every release. Convention: versionCode = major×100 + minor (e.g., v3.11 → 311). Add a section to `CHANGELOG.md`.
