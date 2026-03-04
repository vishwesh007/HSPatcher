# HSPatcher Changelog

## v3.33 — 2026-02-27: .apks Signature Fix + Advanced Hooking-Based Blocking

### Summary
- **Split APK (.apks) signature extraction**: Fixed signature detection for `.apks` bundle files. The engine now extracts `base.apk` from the bundle and reads its signature before the merge step destroys it. Multi-strategy approach: tries v1 (JAR), then v2/v3 (APK Signing Block via `apksig` library).
- **Layer 4 — Advanced Hooking-Based Blocking**: New execution-level blocking layer that complements the existing Layer 3 (URL preparation-time) hooks:
  - **OkHttp Interceptor injection**: Dynamically injects a blocking interceptor into `OkHttpClient.Builder.build()`, catching requests at the HTTP pipeline level even if URL construction hooks were bypassed. Returns a `204 No Content` response for blocked URLs.
  - **ExoPlayer DataSpec blocking**: Hooks `DataSpec` constructors (ExoPlayer2 + AndroidX Media3) to block ad/tracker media segment URLs.
  - **MediaPlayer URL blocking**: Hooks `MediaPlayer.setDataSource()` overloads to block ad media URLs.
  - **Volley RequestQueue blocking**: Hooks `RequestQueue.add()` to cancel blocked requests.
  - **Glide GlideUrl blocking**: Hooks `GlideUrl` constructor to redirect blocked image/tracking pixel URLs.
  - **TLS SNI blocking (native)**: Hooks `SSL_set_tlsext_host_name` to block connections by hostname at the TLS handshake level.
  - **RealCall fallback**: If interceptor injection fails (obfuscated OkHttp), falls back to hooking `RealCall.execute()`.
- **Layer 3 preserved as legacy**: Existing URL preparation-time hooks remain active for defense-in-depth.
- **Version bump**: 3.32 → 3.33 across manifest, patch engine marker, and Frida script.

---

## v3.32 — 2026-02-26: CA Certificate Management + MITM Proxy Support

### Summary
- **CA Certificate import**: New "CA CERT" button in the tools row lets users import a `.crt` / `.pem` / `.der` certificate file from device storage.
- **Persistent cert storage**: Imported certificate is stored in app-internal storage (`user_ca.crt`) and survives app restarts. Button turns green when a cert is loaded.
- **Cert delete option**: Long-press the CA CERT button to remove the stored certificate.
- **Automatic cert embedding**: When patching an APK, the stored CA cert is automatically embedded as `assets/user_ca.crt` inside the target APK.
- **Frida cert dump**: The Frida script now dumps `assets/user_ca.crt` to `/data/local/tmp/user_ca.crt` at app startup, making it available for MITM proxy tools (Reqable, mitmproxy, etc.).
- **Version bump**: 3.31 → 3.32 across manifest, patch engine marker, and Frida script.

---

## v3.13 — 2026-02-25: URL-Safe Rewrite Rules + Socket Log Rewrites

### Summary
- **URL-safe rewrite delimiter**: rules now support `pattern=>replacement` so full URL character-sequence rewrites like `https://...` work reliably.
- **Socket host logs reflect rewrites**: `[Socket] NEW HOST: ...` lines now pass through `UrlHook` so socket host entries show the rewritten sequence too.

---

## v3.12 — 2026-02-25: Rewrites Everywhere + Consistent Logs

### Summary
- **Rewrite rules now apply to more connection types**: rewrites are enforced not just for URL/OkHttp/WebView, but also for DNS/InetSocketAddress/socket/UDP and common TLS socket creation paths.
- **Rewrite logging matches what actually happens**: rewrites are logged after the final rewritten URL/host is computed, and are mirrored into the same file-based logger users rely on (`request_logs.txt`).

---

## v3.10 — 2026-02-25: Version Display + Zip Profiles + Uninstall Permission

### Summary
- **App version visible in UI**: HSPatcher now shows its version (e.g. "v3.10") below the subtitle on the main screen, read from `PackageInfo` at runtime.
- **`REQUEST_DELETE_PACKAGES` permission**: Added to the manifest so the in-app uninstall button can launch the system uninstall dialog on all API levels.
- **Zip-based profile export/import**: Profile export now produces a `.zip` file (Java `ZipOutputStream`) instead of `.tar.gz` (unreliable shell `tar`). Import reads `.zip` first (Java `ZipInputStream`), with `.tar.gz` legacy fallback using proper quoting and a `gzip -dc | tar xf` secondary fallback.
- **Improved import error messages**: When no profile archive is found, the toast now lists every filename and location that was searched.

---

## v3.9 — 2026-02-25: Request Log Rules + Auto-Patch Fix

### Summary
- **Request logs reflect rules**: URLs logged by `HSPatch-Net` / `request_logs.txt` are now passed through `UrlHook.decodeAndPatch()` before logging, so rewrites and `[BLOCKED]` markers are visible everywhere.
- **Blocking rules compatibility**: `blocking_hotstar.txt` now supports both `BLOCK:<pattern>` and `<pattern>:BLOCK` formats, and falls back to `/storage/emulated/0/Download/hspatch_logs/blocking_hotstar.txt` if the app-external copy isn’t present.
- **Reliable `auto_patch`**: launching with `--ez auto_patch true` now starts patching only after the APK finishes loading (fixes the “previously selected APK got patched” issue for large files).

---

## v3.8 — 2026-02-24: Profiles Import Fix + Better Export Names + Uninstall Button

### Summary
- **Import all profiles** now prefers the correct app’s export (app-specific filename) with legacy fallback.
- **Exported patched APK filename** now includes the target application name/package (instead of only a timestamp).
- Added an explicit **Uninstall target app** trigger inside HSPatcher.

---

## v3.7 — 2026-02-24: Frida-Level Request Blocking + UI Improvements

### Summary
Blocking rules from `blocking_hotstar.txt` are now enforced directly in the Frida
gadget hooks — requests are intercepted and blocked/rewritten **before they leave
the phone**, at the URL.openConnection, OkHttp3.newCall, HttpURLConnection.connect,
WebView.loadUrl, and Socket.connect levels. LogViewerActivity font size increased
significantly for better readability.

---

### New Features

#### Frida-Level Request Blocking & Rewriting
The Frida script (Section 5) now reads `blocking_hotstar.txt` at startup and applies
rules directly in the network hooks. Previously, blocking rules were only applied in
`UrlHook.smali` (smali layer) and the Frida hooks only logged traffic passively.

**How it works:**
1. On script load, reads `blocking_hotstar.txt` from the app's external files directory
2. Rules format: `pattern:replacement` (rewrite) or `pattern:BLOCK` / `pattern` (block)
3. Lines starting with `#` are treated as comments
4. Rules are re-read every 60 seconds so edits take effect without app restart
5. Blocked requests are logged to both logcat (`HSPatch-Net`) and `blocked_urls.txt`

**Hook points with blocking:**
| Hook | Block Method | Rewrite Support |
|------|-------------|-----------------|
| `URL.openConnection()` | Redirect to 127.0.0.1:1 | ✅ Creates new URL |
| `OkHttp3.newCall()` | Redirect to 127.0.0.1:1 | ✅ Rebuilds Request |
| `HttpURLConnection.connect()` | Throws IOException | ❌ (already connected) |
| `WebView.loadUrl()` | Loads about:blank | ✅ Loads rewritten URL |
| `Socket.connect()` | Throws IOException | ❌ (raw socket) |

**Logcat output examples:**
```
I HSPatch-Net: [RULES] Loading blocking rules from: /storage/.../files/blocking_hotstar.txt
I HSPatch-Net: [RULES]   BLOCK: googleads
I HSPatch-Net: [RULES]   REWRITE: bifrost -> bisfrost
I HSPatch-Net: [BLOCKED] [OkHttp3] GET https://pagead2.googlesyndication.com/... (matched: googleads)
I HSPatch-Net: [REWRITE] bifrost -> bisfrost in https://bifrost.hotstar.com/...
```

#### LogViewerActivity Font Size Increase
- Main log content text: **15sp → 24sp** (60% larger, much more readable)
- Path bar text: **14sp → 16sp**
- Status bar text: **15sp → 16sp**

---

### Frida Script Version
- Bumped from v2.0 to v3.0

---

## v3.1 — 2026-02-23: Network Interceptor + Critical Fixes

### Summary
Added comprehensive network traffic interception across ALL Java HTTP providers.
Fixed two critical `NoClassDefFoundError` bugs that prevented `HSPatchConfig` and
`NetworkInterceptor` from loading at runtime.

---

### New Features

#### NetworkInterceptor Module (4 new smali files)
Universal HTTP traffic interception that works **regardless of which HTTP library** the
target app uses. Unlike the previous `NetworkLogger` (passive file writer only), this
module actively hooks into the Java networking stack at the system level.

**Files added:**
| File | Size | Purpose |
|------|------|---------|
| `NetworkInterceptor.smali` | ~335 lines | Main entry; hooks 5 subsystems |
| `NetworkInterceptor$LoggingResponseCache.smali` | ~174 lines | Intercepts ALL `HttpURLConnection` via `ResponseCache.get()/put()` |
| `NetworkInterceptor$LoggingProxySelector.smali` | ~169 lines | Intercepts ALL socket connections via `ProxySelector.select()` |
| `NetworkInterceptor$DumpThread.smali` | ~211 lines | Detects loaded HTTP libraries after 8s delay |

**Hook Architecture:**
1. **[1] HttpURLConnection** — `ResponseCache` wrapper intercepts ALL Java HTTP requests at OS level
   - Captures: method, URL, headers count, response status code, content type
   - Most universal hook — every Java HTTP lib using `URL.openConnection()` flows through this
2. **[2] OkHttp3** — Reflection-based field detection (skipped if OkHttp3 not present)
3. **[3] OkHttp2** — Legacy detection (skipped if not present)
4. **[4] Connection Tracker** — `ProxySelector` wrapper intercepts ALL socket connections
   - Deduplicates by host (ConcurrentHashMap-backed Set)
   - Logs new hosts to logcat + file, verbose full URLs to logcat only
5. **[5] Dump Thread** — After 8s delay, detects loaded HTTP libraries:
   - OkHttp3, OkHttp2, Retrofit2, Retrofit1, Volley, Ktor, Apache HttpClient, Cronet, Fuel

**Logcat tags:** `HSPatch-Net` (for all network interception logs)

**Log format examples:**
```
I HSPatch-Net: [URLConn] POST https://example.com/api/data
V HSPatch-Net:     Headers: 5 entries
I HSPatch-Net: [URLConn] Response 200 <- https://example.com/api/data (application/json)
I HSPatch-Net: [Socket] NEW HOST: https://example.com
```

#### Module Integration
- Added `nethook` module to `PatchEngine.generateHSPatchInit()`
- Module order: config → profile → spoofer → ssl → netlog → **nethook** → tracker → notif
- Total modules: **8** (was 7)
- Total smali files in extra.zip: **54** (was 49)

---

### Bug Fixes

#### 1. HSPatchConfig `NoClassDefFoundError` (CRITICAL)
- **Symptom:** `NoClassDefFoundError: Failed resolution of: Lin/startv/hotstar/HSPatchConfig;`
- **Root cause:** `HSPatchConfig.smali` was referenced by `PatchEngine.generateHSPatchInit()` but was
  **never included in `extra.zip`**. It existed in old build artifacts (`dex_build/`, `extra_staging/`)
  but not in `hspatch_module/extra/smali/`.
- **Fix:** Copied `HSPatchConfig.smali` (100 lines) from `dex_build/` to both:
  - `hspatch_module/extra/smali/in/startv/hotstar/HSPatchConfig.smali`
  - `HSPatcher/extra_smali/smali/in/startv/hotstar/HSPatchConfig.smali`

#### 2. NetworkInterceptor `NoClassDefFoundError`
- **Symptom:** `NoClassDefFoundError: Failed resolution of: Lin/startv/hotstar/NetworkInterceptor;`
- **Root causes (2 issues):**
  1. **Misplaced `.field` declarations** — `okhttp3InterceptorsField` and `okhttp3NetworkInterceptorsField`
     were declared at lines 228-229 (AFTER method definitions). In smali, ALL field declarations MUST
     come before ANY method.
     **Fix:** Moved both field declarations to the top of the file with other static fields.
  2. **Invalid `.end class` directive** — All 4 NetworkInterceptor smali files ended with `.end class`,
     which is NOT valid smali syntax (smali files don't use `.end class`).
     **Fix:** Removed `.end class` from all 4 files.

---

### Testing Results

Tested on 3 different apps with different HTTP stacks:

| App | Size | HTTP Stack | All 8 Modules | Network Capture | Notes |
|-----|------|-----------|----------------|-----------------|-------|
| **NetGuard** v2.334 | 20 MB | HttpURLConnection | ✅ ALL OK | ✅ Firebase logs captured | 0 HTTP libs detected (raw sockets) |
| **AdGuard** | 63 MB | HttpURLConnection | ✅ ALL OK | ✅ AdTidy API captured | 0 HTTP libs detected |
| **PikaShows** V86 | 33 MB | Apache HttpClient (native) | ✅ ALL OK | ⚠️ Java-only (NativeActivity) | Apache HttpClient detected |

**Module status for all 3 apps:**
```
✅ frida gadget loaded
✅ config OK           ← Was NoClassDefFoundError, now FIXED
✅ profile OK
✅ spoofer OK
✅ ssl OK
✅ netlog OK
✅ nethook OK          ← Was NoClassDefFoundError, now FIXED
✅ tracker OK
✅ notif OK
```

**Network traffic captured (examples):**
- `[URLConn] POST https://firebaselogging.googleapis.com/v0cc/log/batch?format=json_proto3`
- `[URLConn] Response 200 <- ... (application/json; charset=UTF-8)`
- `[URLConn] POST https://sb.adtidy.org/sfbrdata.html`
- `[Socket] NEW HOST: https://firebaselogging.googleapis.com`

---

### Build Details
- **HSPatcher APK:** 17,949 KB (13 Java classes)
- **extra.zip:** 82,821 bytes (54 smali + 1 XML)
- **Injector DEX:** 68 KB (55 modules)
- **Build tool:** `build.ps1 -Clean -Install`

### Known Limitations
- Java-level hooks only capture Java HTTP traffic; native code (C/C++, Unity, Flutter engine)
  uses its own network stack and is NOT intercepted by ResponseCache/ProxySelector
- x86/x86_64 Frida gadgets not bundled (emulator-only ABIs)
- Package name detection may show truncated names for some apps (e.g., NetGuard shows
  "google.android.datatransport.runtime.schedulin")

---

### File Inventory (54 smali files in extra.zip)

**Core modules:**
- `HSPatchConfig.smali` — Central configuration (filesDir)
- `ProfileManager.smali` — Multi-profile system
- `DeviceSpoofer.smali` — Device fingerprint spoofing
- `SSLBypass.smali` + inner classes — SSL pinning bypass
- `NetworkLogger.smali` + `MonitorThread` — Passive network logging
- `NetworkInterceptor.smali` + 3 inner classes — **Active HTTP interception (NEW)**
- `ActivityTracker.smali` — Activity lifecycle tracking
- `UrlHook.smali` — URL rewriting

**UI components:**
- `DebugPanelActivity.smali` + 16 listeners — Debug panel
- `DebugNotification.smali` — Persistent notification
- `FileExplorerActivity.smali` + 10 inner classes — File browser
- `FileViewerActivity.smali` + 5 inner classes — File viewer/editor
- `LogViewerActivity.smali` + 2 inner classes — Live log viewer
