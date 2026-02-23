# HSPatcher Changelog

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
