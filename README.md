# ⚡ HSPatcher

**One-Click Universal Android APK Patcher**

HSPatcher is a standalone Android app that patches any APK with a comprehensive suite of runtime modifications — no root, no PC, no Xposed required.

![HSPatcher](screenshot_view.png)

## ✨ Features

### Core Patching
- **One-click patching** — Select APK → Patch → Install
- **Split APK support** — Automatically merges `.apks` / `.xapk` / `.apkm` bundles
- **APK extraction** — Extract APKs from installed apps directly
- **Universal signing** — v1 + v2 + v3 APK signatures via Google's apksig library
- **Manifest injection** — Injects debug activities, permissions, and network security config

### Injected Modules (10 modules)
| Module | Description |
|--------|-------------|
| **HSPatchConfig** | Central configuration singleton with settings persistence |
| **ProfileManager** | Multi-device-profile system with export/import |
| **DeviceSpoofer** | Full device fingerprint spoofing (Android ID, IMEI, model, etc.) |
| **SSLBypass** | SSL certificate pinning bypass (TrustManager + OkHttp) |
| **SignatureBypass** | APK signature verification bypass via IPackageManager proxy |
| **ScreenshotEnabler** | Removes FLAG_SECURE from all windows (screenshots/recording) |
| **NetworkLogger** | HTTP/HTTPS traffic logging to logcat |
| **NetworkInterceptor** | Deep network stack hooks (ProxySelector, ResponseCache) |
| **ActivityTracker** | Activity lifecycle tracking for debugging |
| **DebugNotification** | Persistent notification with quick access to debug panel |

### Frida Gadget Integration
- Embedded Frida gadget (arm64 + arm32) with comprehensive script:
  - **SSL Pinning Bypass** — TrustManagerImpl, OkHttp3, HttpsURLConnection
  - **Signature Verification** — Runtime PackageManager hooks
  - **Anti-Piracy Removal** — License checker, installer spoof, root/debug detection
  - **Screenshot Enablement** — Window.setFlags and SurfaceView.setSecure bypass
  - **Network Monitoring** — URL, OkHttp, WebView, Socket traffic capture

### Debug Panel
- In-app debug panel accessible via notification
- Live log viewers with filtering
- Network traffic monitor with capture/export
- File explorer for app internals
- Profile management (create, save, load, import, export)
- Device fingerprint controls

## 🛠️ Build Requirements

- **Android SDK** — Build tools 36.1.0, Platform android-36
- **PowerShell 7+** (`pwsh`)
- **Java 17+** (JDK)
- **Frida gadgets** (optional) — Place `libgadget.so` for arm64-v8a/armeabi-v7a

### Dependencies (included in `libs/`)
- [apksig 8.7.3](https://android.googlesource.com/platform/tools/apksig/) — APK signing
- [ARSCLib 1.3.8](https://github.com/AabResGuard/ARSCLib) — Split APK merging

## 🏗️ Building

```powershell
# Full clean build
pwsh -ExecutionPolicy Bypass -File build.ps1 -Clean

# Output: build/HSPatcher.apk
```

### Build Pipeline
1. **aapt2** — Compile & link resources
2. **javac** — Compile Java sources
3. **d8** — DEX conversion
4. **Package** — APK assembly with assets (extra.zip, frida_gadgets.zip)
5. **zipalign** — Optimize APK alignment
6. **apksigner** — Sign with v1+v2+v3

## 📚 Gradle Import

HSPatcher now also includes a Gradle library wrapper so another Android app can import the existing codebase instead of shelling out to the custom PowerShell build.

### What the Gradle wrapper does
- Builds HSPatcher as an Android library (`AAR`)
- Reuses the existing `src/`, `res/`, `assets/`, and `libs/` folders without relocating files
- Uses `AndroidManifest.importable.xml` so host apps do not inherit HSPatcher's standalone launcher, icon, label, or app theme
- Publishes a local Maven repository under `build/repo`

### Standalone Gradle tasks

```powershell
# Build the importable release AAR
gradle assembleRelease

# Publish to a local Maven-style repository at build/repo
gradle publishReleasePublicationToLocalHspatcherRepository
```

### Import into another Gradle app

Option 1: include HSPatcher as a project dependency

```groovy
include(":hspatcher")
project(":hspatcher").projectDir = file("../HSPatcher")
```

```groovy
dependencies {
  implementation project(":hspatcher")
}
```

Option 2: publish and consume the AAR

```groovy
repositories {
  maven { url = uri("../HSPatcher/build/repo") }
}

dependencies {
  implementation "in.startv:hspatcher:3.61.1"
}
```

### Host-app integration notes
- The importable manifest uses `${applicationId}.provider` and `${applicationId}.INSTALL_STATUS`, so the module adapts to the host app package automatically.
- `MainActivity` is registered without a launcher intent filter in the importable manifest. Host apps should open it explicitly.
- The original `AndroidManifest.xml` and `build.ps1` flow are still intact for the standalone APK build.

## 📁 Project Structure

```
HSPatcher/
├── AndroidManifest.xml          # App manifest
├── build.ps1                    # Build script
├── src/                         # Java source code
│   └── in/startv/hspatcher/
│       ├── MainActivity.java    # Main UI + install flow
│       ├── PatchEngine.java     # Core patching pipeline
│       ├── ManifestPatcher.java # Binary AXML manifest injection
│       ├── HSPatchInjector.java # DEX/smali injector
│       ├── ApksMerger.java      # Split APK merger
│       ├── AppListActivity.java # Installed app browser
│       ├── AppExtractor.java    # APK extraction
│       ├── CertBuilder.java     # Self-signed cert generator
│       └── HspFileProvider.java # Content provider for APK install
├── res/                         # Android resources
├── assets/
│   ├── extra.zip                # Packed smali patch modules
│   └── frida/                   # Frida gadget config + script
├── libs/                        # Build dependencies
│   ├── apksig-8.7.3.jar
│   └── ARSCLib-1.3.8.jar
└── patches/                     # Smali patch source files
    ├── smali/in/startv/hotstar/ # 66 smali module files
    └── res/xml/                 # Network security config
```

## 📦 Modifying Patches

The smali modules in `patches/` are injected into every patched APK. To modify:

1. Edit files in `patches/smali/in/startv/hotstar/`
2. Repack: `Compress-Archive -Path patches/smali, patches/res -DestinationPath assets/extra.zip -Force`
3. Rebuild: `pwsh -ExecutionPolicy Bypass -File build.ps1 -Clean`

## 📲 Install Flow

HSPatcher includes a robust install flow:
1. **Permission check** — Requests "Install from unknown sources" if not granted
2. **Signature verification** — Compares patched APK signature with installed version
3. **Mismatch handling** — Offers to uninstall existing app if signatures differ
4. **Dual install method** — FileProvider content URI (primary) + PackageInstaller session (fallback)

## 📄 License

This project is for educational and research purposes only. Use responsibly.
