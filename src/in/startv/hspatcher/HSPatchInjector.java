package in.startv.hspatcher;

import java.io.*;
import java.util.*;
import java.util.regex.*;

/**
 * HSPatch Auto-Injector v3.0 — Android Edition
 * Adapted from the ApkEditor EXECUTE_DEX version for standalone use.
 * 
 * Performs all smali-level modifications:
 * 1. Generates HSPatchInit.smali consolidator
 * 2. Hooks Application.onCreate()
 * 3. Hooks URLDecoder.decode() → UrlHook.decodeAndPatch()
 * 4. Hooks OkHttp RealCall for network logging
 * 5. Auto-detects & fixes DEX method overflow (65535 limit)
 * 
 * Note: Manifest modification is skipped in standalone mode since we work
 * directly with binary APK (no text XML available). The hooks still work
 * since they're all in the DEX code. The Application.onCreate() hook reads
 * the manifest's Application class name from the binary manifest.
 */
public class HSPatchInjector {

    private String decodePath;
    private int hookCount = 0;
    private String hspatchSmaliDir = null;
    private PatchEngine.Callback cb;

    public HSPatchInjector() {}

    /**
     * Entry point for Android standalone mode.
     * @param apkPath Original APK path (for reference)
     * @param patchPath Patch directory path
     * @param decodePath Decoded smali directory root
     * @param param "auto" or specific param
     * @param callback Progress/log callback
     */
    public void inject(String apkPath, String patchPath, String decodePath,
                        String param, PatchEngine.Callback callback) {
        this.decodePath = decodePath;
        this.cb = callback;

        try {
            // Step 0: Discover smali layout
            log("=== Discovering smali layout ===");
            discoverSmaliLayout();

            // Step 1: Manifest — skip in standalone mode (binary XML not decodable)
            // The hooks work without manifest changes. Activities won't be launchable
            // but all interception hooks (URL, OkHttp, SSL) work fine.
            log("\n=== Step 1: Manifest modification (skipped — binary mode) ===");
            log("  Hooks work without manifest changes");

            // Step 2: Generate HSPatchInit.smali
            log("\n=== Step 2: Generating HSPatchInit.smali ===");
            generateHSPatchInit();

            // Step 3: Hook Application.onCreate()
            log("\n=== Step 3: Hooking Application.onCreate() ===");
            hookApplicationClass();

            // Step 4: Hook URLDecoder.decode() calls
            log("\n=== Step 4: Hooking URLDecoder.decode() calls ===");
            hookUrlDecoder();

            // Step 5: Hook OkHttp
            log("\n=== Step 5: Hooking OkHttp network calls ===");
            hookOkHttp();

            // Step 6: DEX overflow fix
            log("\n=== Step 6: DEX method overflow check ===");
            checkAndFixDexOverflow();

            log("\n✅ Injection complete! " + hookCount + " hooks applied");

        } catch (Exception e) {
            log("❌ INJECTION ERROR: " + e.getMessage());
            StringWriter sw = new StringWriter();
            e.printStackTrace(new PrintWriter(sw));
            log(sw.toString());
        }
    }

    // ===================== STEP 0: DISCOVER SMALI LAYOUT =====================

    private void discoverSmaliLayout() {
        File root = new File(decodePath);
        List<String> smaliDirs = new ArrayList<>();

        File[] rootFiles = root.listFiles();
        if (rootFiles == null) return;

        for (File dir : rootFiles) {
            if (dir.isDirectory() && dir.getName().startsWith("smali")) {
                smaliDirs.add(dir.getName());
                File hspatchDir = new File(dir, "in/startv/hotstar");
                if (hspatchDir.exists() && hspatchDir.isDirectory()) {
                    hspatchSmaliDir = dir.getName();
                    log("Found HSPatch files in: " + dir.getName() + "/in/startv/hotstar/");
                    File[] files = hspatchDir.listFiles();
                    if (files != null) log("  HSPatch smali count: " + files.length);
                }
            }
        }

        Collections.sort(smaliDirs);
        log("Smali directories found: " + smaliDirs);

        if (hspatchSmaliDir == null) {
            hspatchSmaliDir = smaliDirs.size() > 1 ? "smali_classes2" : "smali";
            log("HSPatch files not found in any dir, will use: " + hspatchSmaliDir);
        }
    }

    // ===================== STEP 2: GENERATE HSPatchInit =====================

    private void generateHSPatchInit() throws IOException {
        File targetDir = new File(decodePath, hspatchSmaliDir + "/in/startv/hotstar");
        if (!targetDir.exists()) targetDir.mkdirs();

        File initFile = new File(targetDir, "HSPatchInit.smali");
        if (initFile.exists()) {
            log("HSPatchInit.smali already exists, skipping");
            return;
        }

        String smali = 
            ".class public Lin/startv/hotstar/HSPatchInit;\n" +
            ".super Ljava/lang/Object;\n\n" +
            "# Auto-generated by HSPatch Injector v3.0\n\n" +
            ".method public static init(Landroid/content/Context;)V\n" +
            "    .locals 2\n    .param p0, \"context\"\n\n" +
            "    :try_config\n" +
            "    invoke-static {p0}, Lin/startv/hotstar/HSPatchConfig;->init(Landroid/content/Context;)V\n" +
            "    :try_config_end\n" +
            "    .catch Ljava/lang/Exception; {:try_config .. :try_config_end} :catch_config\n" +
            "    goto :after_config\n    :catch_config\n    move-exception v0\n    :after_config\n\n" +
            "    :try_profile\n" +
            "    invoke-static {p0}, Lin/startv/hotstar/ProfileManager;->applyPendingProfile(Landroid/content/Context;)V\n" +
            "    :try_profile_end\n" +
            "    .catch Ljava/lang/Exception; {:try_profile .. :try_profile_end} :catch_profile\n" +
            "    goto :after_profile\n    :catch_profile\n    move-exception v0\n    :after_profile\n\n" +
            "    :try_spoofer\n" +
            "    invoke-static {p0}, Lin/startv/hotstar/DeviceSpoofer;->init(Landroid/content/Context;)V\n" +
            "    :try_spoofer_end\n" +
            "    .catch Ljava/lang/Exception; {:try_spoofer .. :try_spoofer_end} :catch_spoofer\n" +
            "    goto :after_spoofer\n    :catch_spoofer\n    move-exception v0\n    :after_spoofer\n\n" +
            "    :try_ssl\n" +
            "    invoke-static {p0}, Lin/startv/hotstar/SSLBypass;->init(Landroid/content/Context;)V\n" +
            "    :try_ssl_end\n" +
            "    .catch Ljava/lang/Exception; {:try_ssl .. :try_ssl_end} :catch_ssl\n" +
            "    goto :after_ssl\n    :catch_ssl\n    move-exception v0\n    :after_ssl\n\n" +
            "    :try_netlog\n" +
            "    invoke-static {p0}, Lin/startv/hotstar/NetworkLogger;->init(Landroid/content/Context;)V\n" +
            "    :try_netlog_end\n" +
            "    .catch Ljava/lang/Exception; {:try_netlog .. :try_netlog_end} :catch_netlog\n" +
            "    goto :after_netlog\n    :catch_netlog\n    move-exception v0\n    :after_netlog\n\n" +
            "    :try_tracker\n" +
            "    check-cast p0, Landroid/app/Application;\n" +
            "    invoke-static {p0}, Lin/startv/hotstar/ActivityTracker;->register(Landroid/app/Application;)V\n" +
            "    :try_tracker_end\n" +
            "    .catch Ljava/lang/Exception; {:try_tracker .. :try_tracker_end} :catch_tracker\n" +
            "    goto :after_tracker\n    :catch_tracker\n    move-exception v0\n    :after_tracker\n\n" +
            "    :try_notif\n" +
            "    invoke-static {p0}, Lin/startv/hotstar/DebugNotification;->show(Landroid/content/Context;)V\n" +
            "    :try_notif_end\n" +
            "    .catch Ljava/lang/Exception; {:try_notif .. :try_notif_end} :catch_notif\n" +
            "    goto :after_notif\n    :catch_notif\n    move-exception v0\n    :after_notif\n\n" +
            "    return-void\n.end method\n";

        writeFile(initFile, smali);
        log("Generated HSPatchInit.smali (7 modules → 1 entry point)");
        hookCount++;
    }

    // ===================== STEP 3: APPLICATION CLASS HOOK =====================

    private void hookApplicationClass() throws IOException {
        // In standalone mode, we don't have text manifest. 
        // Search all smali dirs for a class that extends Application and has onCreate.
        // The Application class is the one that android:name in manifest points to.
        // We scan for classes extending Landroid/app/Application; with .method onCreate()V.

        File rootDir = new File(decodePath);
        File appSmali = null;
        String appClassName = null;

        // Also try to read from binary manifest
        File manifest = new File(decodePath, "AndroidManifest.xml");
        if (manifest.exists()) {
            // Try to find application class name from binary manifest
            String appName = extractAppClassFromBinaryManifest(manifest);
            if (appName != null) {
                log("Found Application class from manifest: " + appName);
                String smaliPath = appName.replace('.', '/') + ".smali";
                appSmali = findSmaliFile(smaliPath);
                if (appSmali != null) {
                    appClassName = appName;
                }
            }
        }

        // Fallback: scan for Application subclass
        if (appSmali == null) {
            log("Scanning for Application subclass...");
            appSmali = findApplicationSmali(rootDir);
        }

        if (appSmali == null) {
            log("⚠️ No Application class found — falling back to launcher Activity hook");
            hookLauncherActivity();
            return;
        }

        if (appClassName == null) {
            appClassName = appSmali.getName().replace(".smali", "");
        }
        log("Found at: " + relativePath(appSmali));

        String content = readFile(appSmali);
        if (content.contains("HSPatch")) {
            log("Already hooked, skipping");
            return;
        }

        int onCreateIdx = content.indexOf(".method public onCreate()V");
        if (onCreateIdx == -1) onCreateIdx = content.indexOf(".method public final onCreate()V");
        if (onCreateIdx == -1) onCreateIdx = content.indexOf(".method public synthetic onCreate()V");
        if (onCreateIdx == -1) {
            log("❌ onCreate()V not found in " + appClassName);
            return;
        }

        int methodEnd = content.indexOf(".end method", onCreateIdx);
        int localsIdx = content.indexOf(".locals", onCreateIdx);
        boolean usesRegisters = false;
        if (localsIdx == -1 || localsIdx > methodEnd) {
            localsIdx = content.indexOf(".registers", onCreateIdx);
            usesRegisters = true;
        }
        if (localsIdx == -1 || localsIdx > methodEnd) {
            log("❌ No .locals/.registers in onCreate");
            return;
        }

        int localsLineEnd = content.indexOf('\n', localsIdx);
        String localsLine = content.substring(localsIdx, localsLineEnd).trim();
        int currentCount = Integer.parseInt(localsLine.split("\\s+")[1]);
        int neededCount = usesRegisters ? currentCount : Math.max(currentCount, 1);

        int superCallEnd = -1;
        int superCallIdx = content.indexOf("invoke-super", onCreateIdx);
        if (superCallIdx != -1 && superCallIdx < methodEnd) {
            superCallEnd = content.indexOf('\n', superCallIdx);
        }

        String hookCode = "\n" +
            "\n    # === HSPatch v3.0: Single init call ===\n" +
            "    :try_start_hspatch\n" +
            "    invoke-static {p0}, Lin/startv/hotstar/HSPatchInit;->init(Landroid/content/Context;)V\n" +
            "    :try_end_hspatch\n" +
            "    .catchall {:try_start_hspatch .. :try_end_hspatch} :catch_hspatch\n" +
            "    goto :after_hspatch\n" +
            "    :catch_hspatch\n    move-exception v0\n    :after_hspatch\n";

        String before, after;
        if (superCallEnd != -1) {
            before = content.substring(0, superCallEnd);
            after = content.substring(superCallEnd);
        } else {
            before = content.substring(0, localsLineEnd);
            after = content.substring(localsLineEnd);
        }

        String newLocalsLine = usesRegisters ?
            "    .registers " + neededCount :
            "    .locals " + neededCount;
        String result = before + hookCode + after;
        result = result.replace(localsLine, newLocalsLine);

        writeFile(appSmali, result);
        log("✅ Hooked with HSPatchInit.init() [1 cross-DEX ref]");
        hookCount++;
    }

    private void hookLauncherActivity() throws IOException {
        // When no Application class exists, find and hook the launcher Activity.
        File rootDir = new File(decodePath);
        File manifest = new File(decodePath, "AndroidManifest.xml");
        File activitySmali = null;
        String activityName = null;

        // Strategy: collect all candidate activities, then pick the best one
        List<String> candidateNames = new ArrayList<>();

        // Read binary manifest strings to find activity class names
        if (manifest.exists()) {
            try {
                byte[] data = readBytes(manifest);
                List<String> strings = extractBinaryXmlStrings(data);
                for (String s : strings) {
                    if (s.contains(".") && !s.contains(" ") && !s.contains("/") &&
                        !s.startsWith("android.") && !s.startsWith("http") &&
                        !s.startsWith("com.android.") && !s.startsWith("org.") &&
                        s.matches("[a-z].*\\.[A-Z].*")) {
                        // Looks like a class name
                        candidateNames.add(s);
                    }
                }
                log("  Found " + candidateNames.size() + " class-like strings in manifest");
            } catch (Exception e) {
                log("  Warning: Cannot parse manifest: " + e.getMessage());
            }
        }

        // First pass: look for MainActivity by name in manifest candidates
        for (String s : candidateNames) {
            if (s.contains("MainActivity") || s.contains("LauncherActivity") || s.contains("SplashActivity")) {
                String smaliPath = s.replace('.', '/') + ".smali";
                File found = findSmaliFile(smaliPath);
                if (found != null && hasOnCreate(found, true)) {
                    activitySmali = found;
                    activityName = s;
                    log("  Found launcher activity from manifest: " + s);
                    break;
                }
            }
        }

        // Second pass: any activity from manifest candidates
        if (activitySmali == null) {
            for (String s : candidateNames) {
                String smaliPath = s.replace('.', '/') + ".smali";
                File found = findSmaliFile(smaliPath);
                if (found != null && hasOnCreate(found, true)) {
                    activitySmali = found;
                    activityName = s;
                    log("  Found activity from manifest: " + s);
                    break;
                }
            }
        }

        // Third pass: scan smali directories for any Activity with onCreate
        if (activitySmali == null) {
            log("  Scanning smali directories for Activity classes...");
            activitySmali = findAnyActivitySmali(rootDir);
        }

        if (activitySmali == null) {
            log("❌ Cannot find any Activity to hook");
            return;
        }

        if (activityName == null) {
            activityName = activitySmali.getName().replace(".smali", "");
        }
        log("Hooking Activity: " + activityName + " at " + relativePath(activitySmali));

        String content = readFile(activitySmali);
        if (content.contains("HSPatch")) {
            log("Already hooked, skipping");
            return;
        }

        // Look for onCreate(Bundle)V
        int onCreateIdx = content.indexOf(".method public onCreate(Landroid/os/Bundle;)V");
        if (onCreateIdx == -1) onCreateIdx = content.indexOf(".method protected onCreate(Landroid/os/Bundle;)V");
        if (onCreateIdx == -1) onCreateIdx = content.indexOf(".method public final onCreate(Landroid/os/Bundle;)V");
        if (onCreateIdx == -1) {
            log("❌ onCreate(Bundle)V not found in " + activityName);
            return;
        }

        int methodEnd = content.indexOf(".end method", onCreateIdx);
        int localsIdx = content.indexOf(".locals", onCreateIdx);
        boolean usesRegisters = false;
        if (localsIdx == -1 || localsIdx > methodEnd) {
            localsIdx = content.indexOf(".registers", onCreateIdx);
            usesRegisters = true;
        }
        if (localsIdx == -1 || localsIdx > methodEnd) {
            log("❌ No .locals/.registers in Activity.onCreate");
            return;
        }

        int localsLineEnd = content.indexOf('\n', localsIdx);
        String localsLine = content.substring(localsIdx, localsLineEnd).trim();
        int currentCount = Integer.parseInt(localsLine.split("\\s+")[1]);
        int neededCount = usesRegisters ? currentCount : Math.max(currentCount, 1);

        // Find the invoke-super call (after which we inject)
        int superCallEnd = -1;
        int superCallIdx = content.indexOf("invoke-super", onCreateIdx);
        if (superCallIdx != -1 && superCallIdx < methodEnd) {
            superCallEnd = content.indexOf('\n', superCallIdx);
        }

        String hookCode = "\n" +
            "\n    # === HSPatch v3.0: Activity hook (no Application class) ===\n" +
            "    :try_start_hspatch\n" +
            "    invoke-static {p0}, Lin/startv/hotstar/HSPatchInit;->init(Landroid/content/Context;)V\n" +
            "    :try_end_hspatch\n" +
            "    .catchall {:try_start_hspatch .. :try_end_hspatch} :catch_hspatch\n" +
            "    goto :after_hspatch\n" +
            "    :catch_hspatch\n    move-exception v0\n    :after_hspatch\n";

        String before, after;
        if (superCallEnd != -1) {
            before = content.substring(0, superCallEnd);
            after = content.substring(superCallEnd);
        } else {
            before = content.substring(0, localsLineEnd);
            after = content.substring(localsLineEnd);
        }

        String newLocalsLine = usesRegisters ?
            "    .registers " + neededCount :
            "    .locals " + neededCount;
        String result = before + hookCode + after;
        result = result.replace(localsLine, newLocalsLine);

        writeFile(activitySmali, result);
        log("✅ Hooked Activity.onCreate with HSPatchInit.init()");
        hookCount++;
    }

    private File findAnyActivitySmali(File rootDir) throws IOException {
        File[] dirs = rootDir.listFiles();
        if (dirs == null) return null;
        File bestCandidate = null;
        int bestScore = -1;
        for (File dir : dirs) {
            if (!dir.isDirectory() || !dir.getName().startsWith("smali")) continue;
            File[] results = searchForActivityClasses(dir);
            for (File f : results) {
                int score = 0;
                String name = f.getName();
                if (name.contains("Main")) score += 10;
                if (name.contains("Launcher")) score += 8;
                if (name.contains("Splash")) score += 5;
                if (name.contains("Home")) score += 3;
                // Penalize library-looking paths
                String path = f.getAbsolutePath();
                if (path.contains("imageview") || path.contains("lib") || path.contains("widget")) score -= 5;
                if (score > bestScore) {
                    bestScore = score;
                    bestCandidate = f;
                }
            }
        }
        return bestCandidate;
    }

    private File[] searchForActivityClasses(File dir) throws IOException {
        List<File> results = new ArrayList<>();
        searchForActivityClassesRec(dir, results);
        return results.toArray(new File[0]);
    }

    private void searchForActivityClassesRec(File dir, List<File> results) throws IOException {
        File[] files = dir.listFiles();
        if (files == null) return;
        for (File file : files) {
            if (file.isDirectory()) {
                String name = file.getName();
                if (name.equals("android") || name.equals("androidx") || name.equals("in")) continue;
                searchForActivityClassesRec(file, results);
            } else if (file.getName().endsWith(".smali")) {
                String content = readFile(file);
                if ((content.contains(".super Landroid/app/Activity;") ||
                     content.contains(".super Landroidx/appcompat/app/AppCompatActivity;") ||
                     content.contains(".super Landroidx/fragment/app/FragmentActivity;") ||
                     content.contains(".super Landroid/support/v7/app/AppCompatActivity;") ||
                     content.contains(".super Landroid/support/v4/app/FragmentActivity;")) &&
                    content.contains("onCreate(Landroid/os/Bundle;)V")) {
                    results.add(file);
                }
            }
        }
    }

    private String extractAppClassFromBinaryManifest(File manifest) {
        // Binary Android manifest has the application class name as a string.
        // We search for it by looking for known patterns.
        try {
            byte[] data = readBytes(manifest);
            // The string pool is at the beginning of the file.
            // We look for strings that look like fully-qualified class names
            // and appear near "application" context.
            // Simple heuristic: find all strings, look for ones ending in Application
            List<String> strings = extractBinaryXmlStrings(data);
            
            // Find the application class name
            // It's typically a string that contains dots and matches a class pattern
            // and appears near the "application" tag
            for (String s : strings) {
                if (s.contains(".") && !s.contains(" ") && !s.contains("/") &&
                    !s.startsWith("android.") && !s.startsWith("http") &&
                    !s.startsWith("com.android.") &&
                    (s.endsWith("Application") || s.endsWith("App"))) {
                    return s;
                }
            }
            // Broader search: any class-like name pattern
            for (String s : strings) {
                if (s.matches("[a-z][a-z0-9_]*(\\.[a-z][a-z0-9_]*)*\\.[A-Z][a-zA-Z0-9]*Application[a-zA-Z0-9]*")) {
                    return s;
                }
            }
        } catch (Exception e) {
            log("  Warning: Cannot parse binary manifest: " + e.getMessage());
        }
        return null;
    }

    private List<String> extractBinaryXmlStrings(byte[] data) {
        List<String> result = new ArrayList<>();
        if (data.length < 12) return result;

        // Binary XML format:
        // Offset 0: magic (0x00080003)
        // Offset 4: file size
        // Offset 8: string pool chunk header (0x001C0001)
        int offset = 8;
        if (offset + 8 > data.length) return result;

        int chunkType = readShort(data, offset);
        if (chunkType != 0x0001) return result; // Not string pool

        int chunkSize = readInt(data, offset + 4);
        int stringCount = readInt(data, offset + 8);
        int styleCount = readInt(data, offset + 12);
        int flags = readInt(data, offset + 16);
        int stringsOffset = readInt(data, offset + 20) + offset + 8;
        boolean isUtf8 = (flags & (1 << 8)) != 0;

        int[] stringOffsets = new int[stringCount];
        for (int i = 0; i < stringCount; i++) {
            stringOffsets[i] = readInt(data, offset + 28 + i * 4);
        }

        for (int i = 0; i < stringCount; i++) {
            int strOffset = stringsOffset + stringOffsets[i];
            if (strOffset >= data.length) continue;

            try {
                if (isUtf8) {
                    // UTF-8: first byte(s) = char count, then byte count, then string
                    int charCount = data[strOffset] & 0xFF;
                    if ((charCount & 0x80) != 0) {
                        charCount = ((charCount & 0x7F) << 8) | (data[strOffset + 1] & 0xFF);
                        strOffset++;
                    }
                    strOffset++;
                    int byteCount = data[strOffset] & 0xFF;
                    if ((byteCount & 0x80) != 0) {
                        byteCount = ((byteCount & 0x7F) << 8) | (data[strOffset + 1] & 0xFF);
                        strOffset++;
                    }
                    strOffset++;
                    if (strOffset + byteCount <= data.length) {
                        result.add(new String(data, strOffset, byteCount, "UTF-8"));
                    }
                } else {
                    // UTF-16
                    int charCount = readShort(data, strOffset);
                    if ((charCount & 0x8000) != 0) {
                        charCount = ((charCount & 0x7FFF) << 16) | readShort(data, strOffset + 2);
                        strOffset += 4;
                    } else {
                        strOffset += 2;
                    }
                    if (strOffset + charCount * 2 <= data.length) {
                        result.add(new String(data, strOffset, charCount * 2, "UTF-16LE"));
                    }
                }
            } catch (Exception e) {
                // Skip malformed strings
            }
        }
        return result;
    }

    private int readShort(byte[] data, int offset) {
        return (data[offset] & 0xFF) | ((data[offset + 1] & 0xFF) << 8);
    }

    private int readInt(byte[] data, int offset) {
        return (data[offset] & 0xFF) | ((data[offset + 1] & 0xFF) << 8) |
               ((data[offset + 2] & 0xFF) << 16) | ((data[offset + 3] & 0xFF) << 24);
    }

    private byte[] readBytes(File file) throws IOException {
        FileInputStream fis = new FileInputStream(file);
        byte[] data = new byte[(int) file.length()];
        int offset = 0;
        while (offset < data.length) {
            int read = fis.read(data, offset, data.length - offset);
            if (read == -1) break;
            offset += read;
        }
        fis.close();
        return data;
    }

    private File findApplicationSmali(File rootDir) throws IOException {
        File[] dirs = rootDir.listFiles();
        if (dirs == null) return null;

        for (File dir : dirs) {
            if (!dir.isDirectory() || !dir.getName().startsWith("smali")) continue;
            File found = searchForAppClass(dir);
            if (found != null) return found;
        }
        return null;
    }

    private File searchForAppClass(File dir) throws IOException {
        File[] files = dir.listFiles();
        if (files == null) return null;

        for (File file : files) {
            if (file.isDirectory()) {
                // Skip HSPatch dir and android framework dirs
                String name = file.getName();
                if (name.equals("android") || name.equals("androidx") || name.equals("in")) continue;
                File found = searchForAppClass(file);
                if (found != null) return found;
            } else if (file.getName().endsWith(".smali")) {
                String content = readFile(file);
                if (content.contains(".super Landroid/app/Application;") ||
                    content.contains(".super Landroidx/multidex/MultiDexApplication;") ||
                    content.contains(".super Landroid/app/MultiDexApplication;")) {
                    if (content.contains(".method public onCreate()V") ||
                        content.contains(".method public final onCreate()V")) {
                        return file;
                    }
                }
            }
        }
        return null;
    }

    // ===================== STEP 4: URL DECODER HOOK =====================

    private void hookUrlDecoder() throws IOException {
        File rootDir = new File(decodePath);
        int count = 0;
        File[] rootFiles = rootDir.listFiles();
        if (rootFiles == null) return;

        for (File dir : rootFiles) {
            if (dir.isDirectory() && dir.getName().startsWith("smali")) {
                count += hookUrlDecoderInDir(dir);
            }
        }
        log("URLDecoder hooks applied in " + count + " files");
        hookCount += count;
    }

    private int hookUrlDecoderInDir(File dir) throws IOException {
        int count = 0;
        File[] files = dir.listFiles();
        if (files == null) return 0;

        for (File file : files) {
            if (file.isDirectory()) {
                count += hookUrlDecoderInDir(file);
            } else if (file.getName().endsWith(".smali")) {
                if (file.getAbsolutePath().replace('\\', '/').contains("in/startv/hotstar/")) continue;
                String content = readFile(file);
                String target = "Ljava/net/URLDecoder;->decode(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;";
                if (content.contains(target)) {
                    String newContent = content.replace(target,
                        "Lin/startv/hotstar/UrlHook;->decodeAndPatch(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;");
                    if (!newContent.equals(content)) {
                        writeFile(file, newContent);
                        log("  Hooked URLDecoder in: " + relativePath(file));
                        count++;
                    }
                }
            }
        }
        return count;
    }

    // ===================== STEP 5: OKHTTP HOOK =====================

    private void hookOkHttp() throws IOException {
        File rootDir = new File(decodePath);
        File[] rootFiles = rootDir.listFiles();
        if (rootFiles == null) return;

        for (File dir : rootFiles) {
            if (dir.isDirectory() && dir.getName().startsWith("smali")) {
                if (hookOkHttpInDir(dir)) return;
            }
        }
        log("OkHttp: Could not auto-detect RealCall class");
    }

    private boolean hookOkHttpInDir(File dir) throws IOException {
        File[] files = dir.listFiles();
        if (files == null) return false;

        for (File file : files) {
            if (file.isDirectory()) {
                if (hookOkHttpInDir(file)) return true;
            } else if (file.getName().endsWith(".smali")) {
                if (file.getAbsolutePath().replace('\\', '/').contains("in/startv/hotstar/")) continue;
                String content = readFile(file);

                if (content.contains("\"Already Executed\"") || content.contains("\"already executed\"")) {
                    log("Found OkHttp RealCall: " + relativePath(file));
                    if (content.contains("HSPatch")) { log("  Already hooked"); return true; }

                    String[] methods = content.split("\\.method ");
                    StringBuilder newContent = new StringBuilder();
                    boolean hooked = false;

                    for (int i = 0; i < methods.length; i++) {
                        if (i > 0) newContent.append(".method ");
                        String method = methods[i];

                        if (!hooked && method.contains("\"Already Executed\"") && method.contains(".end method")) {
                            Pattern reqPattern = Pattern.compile("iget-object (v\\d+), p0, (L[^;]+;->\\w+):(L[^;]+;)");
                            Matcher reqMatcher = reqPattern.matcher(method);
                            String requestField = null;
                            while (reqMatcher.find()) { requestField = reqMatcher.group(2) + ":" + reqMatcher.group(3); break; }

                            if (requestField != null) {
                                int locIdx = method.indexOf(".locals");
                                if (locIdx == -1) locIdx = method.indexOf(".registers");
                                if (locIdx != -1) {
                                    int locEnd = method.indexOf('\n', locIdx);
                                    String locLine = method.substring(locIdx, locEnd).trim();
                                    int locals = Integer.parseInt(locLine.split("\\s+")[1]);

                                    String hookBlock = "\n" +
                                        "    # === HSPatch: Log network request ===\n" +
                                        "    :try_start_hspatch\n" +
                                        "    iget-object v0, p0, " + requestField + "\n" +
                                        "    invoke-virtual {v0}, Ljava/lang/Object;->toString()Ljava/lang/String;\n" +
                                        "    move-result-object v1\n" +
                                        "    const-string v0, \"GET\"\n" +
                                        "    invoke-static {v0, v1}, Lin/startv/hotstar/NetworkLogger;->logConnection(Ljava/lang/String;Ljava/lang/String;)V\n" +
                                        "    :try_end_hspatch\n" +
                                        "    .catchall {:try_start_hspatch .. :try_end_hspatch} :catch_hspatch\n" +
                                        "    goto :after_hspatch\n" +
                                        "    :catch_hspatch\n    move-exception v0\n    :after_hspatch\n";

                                    method = method.substring(0, locIdx) + "    .locals " + Math.max(locals, 3) + hookBlock + method.substring(locEnd);
                                    hooked = true;
                                    hookCount++;
                                    log("  ✅ Injected NetworkLogger hook");
                                }
                            }
                        }
                        newContent.append(method);
                    }
                    if (hooked) { writeFile(file, newContent.toString()); log("OkHttp hooked successfully"); return true; }
                }
            }
        }
        return false;
    }

    // ===================== STEP 6: DEX OVERFLOW FIX =====================

    private void checkAndFixDexOverflow() throws IOException {
        File root = new File(decodePath);
        List<File> smaliDirs = new ArrayList<>();

        File[] rootFiles = root.listFiles();
        if (rootFiles == null) return;

        for (File dir : rootFiles) {
            if (dir.isDirectory() && dir.getName().startsWith("smali")) {
                smaliDirs.add(dir);
            }
        }
        Collections.sort(smaliDirs, Comparator.comparing(File::getName));

        int originalCount = smaliDirs.size();
        for (int i = 0; i < originalCount; i++) {
            File smaliDir = smaliDirs.get(i);
            int methodRefs = countMethodRefsInDir(smaliDir);
            int fileCount = countSmaliFiles(smaliDir);
            log("  " + smaliDir.getName() + ": ~" + methodRefs + " refs, " + fileCount + " files");

            if (methodRefs > 62000) {
                log("  ⚠️ " + smaliDir.getName() + " near DEX limit (" + methodRefs + "/65535)!");
                fixOverflowDir(smaliDir, smaliDirs);
                methodRefs = countMethodRefsInDir(smaliDir);
                log("  After fix: ~" + methodRefs + " refs");
            }
        }
    }

    private int countMethodRefsInDir(File dir) {
        Set<String> refs = new HashSet<>();
        collectMethodRefs(dir, refs);
        return refs.size();
    }

    private void collectMethodRefs(File dir, Set<String> refs) {
        File[] files = dir.listFiles();
        if (files == null) return;
        for (File file : files) {
            if (file.isDirectory()) { collectMethodRefs(file, refs); continue; }
            if (!file.getName().endsWith(".smali")) continue;
            try {
                BufferedReader br = new BufferedReader(new FileReader(file));
                String line;
                while ((line = br.readLine()) != null) {
                    line = line.trim();
                    if (line.startsWith("invoke-")) {
                        int ms = line.indexOf("},");
                        if (ms != -1) refs.add(line.substring(ms + 2).trim());
                    } else if (line.startsWith("sget") || line.startsWith("sput") ||
                               line.startsWith("iget") || line.startsWith("iput")) {
                        int rs = line.lastIndexOf(", ");
                        if (rs != -1) refs.add("F:" + line.substring(rs + 2).trim());
                    }
                }
                br.close();
            } catch (IOException e) { /* ignore */ }
        }
    }

    private void fixOverflowDir(File overflowDir, List<File> allSmaliDirs) throws IOException {
        List<String[]> movable = new ArrayList<>();
        collectMovablePackages(overflowDir, overflowDir, movable, 55000);

        if (movable.isEmpty()) { log("  No movable packages found"); return; }

        Collections.sort(movable, (a, b) -> Integer.parseInt(b[2]) - Integer.parseInt(a[2]));

        File targetDir = createNewSmaliDir(allSmaliDirs);
        int targetRefs = 0, movedRefs = 0;
        int overflowRefs = countMethodRefsInDir(overflowDir);

        for (String[] pkg : movable) {
            if (overflowRefs - movedRefs <= 58000) break;
            int pkgRefs = Integer.parseInt(pkg[2]);

            if (targetRefs > 0 && targetRefs + pkgRefs > 55000) {
                targetDir = createNewSmaliDir(allSmaliDirs);
                targetRefs = 0;
            }

            File srcDir = new File(pkg[0]);
            if (!srcDir.exists()) continue;

            File destDir = new File(targetDir, pkg[1]);
            destDir.getParentFile().mkdirs();

            if (!srcDir.renameTo(destDir)) {
                copyDirectory(srcDir, destDir);
                deleteDirectory(srcDir);
            }

            targetRefs += pkgRefs;
            movedRefs += pkgRefs;
            log("  MOVED: " + pkg[1] + " (~" + pkgRefs + " refs) → " + targetDir.getName());
            hookCount++;
        }
        cleanEmptyDirs(overflowDir);
    }

    private void collectMovablePackages(File baseDir, File currentDir, List<String[]> result, int maxRefs) {
        File[] children = currentDir.listFiles();
        if (children == null) return;

        for (File child : children) {
            if (!child.isDirectory()) continue;
            if (child.getName().equals("in") && new File(child, "startv/hotstar").exists()) continue;

            int refs = countMethodRefsInDir(child);
            if (refs == 0) continue;

            String absPath = child.getAbsolutePath();
            String basePath = baseDir.getAbsolutePath();
            String relPath = absPath.substring(basePath.length() + 1).replace('\\', '/');

            if (refs <= maxRefs) {
                result.add(new String[]{ absPath, relPath, String.valueOf(refs) });
            } else {
                log("  Splitting " + relPath + "/ (~" + refs + " refs > " + maxRefs + " limit)");
                collectMovablePackages(baseDir, child, result, maxRefs);
            }
        }
    }

    private File createNewSmaliDir(List<File> allSmaliDirs) {
        int maxN = 0;
        for (File d : allSmaliDirs) {
            String name = d.getName();
            if (name.equals("smali")) continue;
            try { maxN = Math.max(maxN, Integer.parseInt(name.replace("smali_classes", ""))); }
            catch (NumberFormatException e) {}
        }
        String newName = "smali_classes" + (maxN + 1);
        File newDir = new File(decodePath, newName);
        newDir.mkdirs();
        allSmaliDirs.add(newDir);
        log("  Created: " + newName);
        return newDir;
    }

    private void cleanEmptyDirs(File dir) {
        File[] children = dir.listFiles();
        if (children == null) return;
        for (File child : children) {
            if (child.isDirectory()) {
                cleanEmptyDirs(child);
                String[] remaining = child.list();
                if (remaining != null && remaining.length == 0) child.delete();
            }
        }
    }

    // ===================== UTILITIES =====================

    private File findSmaliFile(String relativePath) {
        File root = new File(decodePath);
        File[] rootFiles = root.listFiles();
        if (rootFiles == null) return null;
        for (File dir : rootFiles) {
            if (dir.isDirectory() && dir.getName().startsWith("smali")) {
                File target = new File(dir, relativePath);
                if (target.exists()) return target;
            }
        }
        return null;
    }

    private boolean hasOnCreate(File smaliFile, boolean isActivity) throws IOException {
        String content = readFile(smaliFile);
        if (isActivity) {
            return content.contains("onCreate(Landroid/os/Bundle;)V") &&
                   (content.contains("Landroid/app/Activity;") ||
                    content.contains("Landroidx/appcompat/app/AppCompatActivity;") ||
                    content.contains("Landroidx/fragment/app/FragmentActivity;") ||
                    content.contains("Landroid/support/v7/app/AppCompatActivity;") ||
                    content.contains("Landroid/support/v4/app/FragmentActivity;"));
        } else {
            return content.contains("onCreate()V") &&
                   (content.contains("Landroid/app/Application;") ||
                    content.contains("Landroidx/multidex/MultiDexApplication;"));
        }
    }

    private String readFile(File file) throws IOException {
        StringBuilder sb = new StringBuilder((int) file.length());
        BufferedReader br = new BufferedReader(new FileReader(file));
        String line;
        while ((line = br.readLine()) != null) sb.append(line).append('\n');
        br.close();
        return sb.toString();
    }

    private void writeFile(File file, String content) throws IOException {
        BufferedWriter bw = new BufferedWriter(new FileWriter(file));
        bw.write(content);
        bw.close();
    }

    private int countSmaliFiles(File dir) {
        int count = 0;
        File[] files = dir.listFiles();
        if (files == null) return 0;
        for (File f : files) {
            if (f.isDirectory()) count += countSmaliFiles(f);
            else if (f.getName().endsWith(".smali")) count++;
        }
        return count;
    }

    private String relativePath(File file) {
        String full = file.getAbsolutePath().replace('\\', '/');
        String base = decodePath.replace('\\', '/');
        if (full.startsWith(base)) return full.substring(base.length() + 1);
        return file.getName();
    }

    private void copyDirectory(File source, File dest) throws IOException {
        dest.mkdirs();
        File[] files = source.listFiles();
        if (files == null) return;
        for (File f : files) {
            File d = new File(dest, f.getName());
            if (f.isDirectory()) copyDirectory(f, d);
            else { FileInputStream in = new FileInputStream(f); FileOutputStream out = new FileOutputStream(d);
                byte[] buf = new byte[8192]; int len;
                while ((len = in.read(buf)) > 0) out.write(buf, 0, len);
                in.close(); out.close(); }
        }
    }

    private void deleteDirectory(File dir) {
        File[] files = dir.listFiles();
        if (files != null) { for (File f : files) { if (f.isDirectory()) deleteDirectory(f); else f.delete(); } }
        dir.delete();
    }

    private void log(String msg) {
        if (cb != null) cb.onLog("  [Injector] " + msg);
    }
}
