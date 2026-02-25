package in.startv.hspatcher;

import android.util.Base64;
import android.util.Log;
import java.io.*;
import java.security.*;
import java.security.cert.*;
import java.util.*;
import java.util.jar.JarEntry;
import java.util.jar.JarFile;
import java.util.regex.*;
import java.util.zip.*;
import javax.security.auth.x500.X500Principal;

import com.android.tools.smali.baksmali.Baksmali;
import com.android.tools.smali.baksmali.BaksmaliOptions;
import com.android.tools.smali.dexlib2.DexFileFactory;
import com.android.tools.smali.dexlib2.Opcodes;
import com.android.tools.smali.dexlib2.iface.ClassDef;
import com.android.tools.smali.dexlib2.iface.DexFile;
import com.android.tools.smali.dexlib2.iface.MultiDexContainer;
import com.android.tools.smali.dexlib2.writer.builder.DexBuilder;
import com.android.tools.smali.dexlib2.writer.io.FileDataStore;
import brut.androlib.mod.SmaliMod;

/**
 * HSPatch Engine v2 — Targeted one-click APK patching.
 *
 * Key improvement: only baksmalis the SINGLE DEX containing the hook target.
 * All other DEX files are copied byte-for-byte. This reduces memory 10-100x.
 *
 * Pipeline:
 * 1. Analyze APK — find hook target + which DEX
 * 2. Build injector DEX — compile extra.zip smali into separate DEX
 * 3. Patch hook DEX — baksmali ONE DEX, inject hook, reassemble
 * 4. Build patched APK — copy original + replace hook DEX + add injector DEX
 * 5. Sign APK — v1 JAR signing with correct digests
 */
public class PatchEngine {

    private static final String TAG = "HSPatcher";

    public interface Callback {
        void onLog(String msg);
        void onProgress(int pct, String step);
    }

    private final File inputApk;
    private final File extraZip;
    private final File fridaZip;  // optional: Frida gadget pack (may be null)
    private final File sigkillDir; // optional: SignatureKiller native libs directory
    private final File workDir;
    private final Callback cb;

    public PatchEngine(File inputApk, File extraZip, File fridaZip, File sigkillDir, File workDir, Callback cb) {
        this.inputApk = inputApk;
        this.extraZip = extraZip;
        this.fridaZip = fridaZip;
        this.sigkillDir = sigkillDir;
        this.workDir = workDir;
        this.cb = cb;
    }

    /**
     * Quick static check: is this APK already patched by HSPatcher?
     * Checks for hspatch_marker.txt asset or Frida gadget config+script.
     * Returns patch version string if patched, null if clean.
     */
    public static String isAlreadyPatched(File apk) {
        try {
            ZipFile z = new ZipFile(apk);
            try {
                ZipEntry marker = z.getEntry("assets/hspatch_marker.txt");
                if (marker != null) {
                    InputStream mis = z.getInputStream(marker);
                    ByteArrayOutputStream bos = new ByteArrayOutputStream();
                    byte[] buf = new byte[256];
                    int len;
                    while ((len = mis.read(buf)) > 0) bos.write(buf, 0, len);
                    mis.close();
                    String ver = bos.toString("UTF-8").trim();
                    return ver.isEmpty() ? "unknown" : ver;
                }
                // Fallback: check for Frida gadget artifacts
                boolean hasConfig = false, hasScript = false;
                Enumeration<? extends ZipEntry> entries = z.entries();
                while (entries.hasMoreElements()) {
                    String n = entries.nextElement().getName();
                    if (n.endsWith("/libgadget.config.so")) hasConfig = true;
                    if (n.endsWith("/libgadget.js.so")) hasScript = true;
                    if (hasConfig && hasScript) return "pre-marker";
                }
            } finally {
                z.close();
            }
        } catch (Exception ignored) {}
        return null;
    }

    public File patch() throws Exception {
        File ws = new File(workDir, "pw");
        if (ws.exists()) deleteDir(ws);
        ws.mkdirs();

        // ======== Step 1: Analyze APK ========
        progress(5, "Analyzing APK...");
        log("🔍 Step 1: Analyzing APK...");
        ApkInfo info = analyzeApk(inputApk, ws);
        log("   Package: " + info.packageName);
        log("   DEX files: " + info.dexCount);
        log("   Hook: " + info.hookClassName +
            " (" + (info.isApplication ? "Application" : "Activity") + ")");
        log("   In: " + info.hookDexName);

        // ======== Already-patched detection ========
        if (info.alreadyPatched) {
            String verMsg = info.patchVersion != null ? " (v" + info.patchVersion + ")" : "";
            log("");
            log("⚠️  THIS APK IS ALREADY PATCHED" + verMsg);
            log("   Detected HSPatch artifacts from a previous patching session.");
            log("   Re-patching may cause crashes, duplicate hooks, or bloated APK size.");
            log("");
            throw new Exception("APK_ALREADY_PATCHED" + verMsg);
        }

        // ======== DexGuard class encryption check ========
        if (info.dexguardEncrypted) {
            log("");
            log("🛡️ DexGuard class encryption detected!");
            log("   Protection library: lib" + info.dexguardLibName + ".so");
            log("   Encrypted code: assets/" + info.dexguardLibName + "/");
            log("   → ApkSignatureKillerEx will bypass signature/integrity checks");
            log("   → Original APK embedded for native open() hook redirection");
        }

        // ======== Extract original signing certificate ========
        progress(10, "Extracting signature...");
        info.originalSignatureBase64 = extractOriginalSignature(inputApk);
        if (info.originalSignatureBase64 != null) {
            log("   🔑 Original signing certificate extracted (" +
                info.originalSignatureBase64.length() + " chars base64)");
        } else {
            log("   ⚠️ Could not extract original signature (unsigned APK?)");
        }

        // ======== Step 2: Build injector DEX ========
        progress(15, "Building injector DEX...");
        log("\n📦 Step 2: Building injector DEX...");
        String injDexName = "classes" + (info.dexCount + 1) + ".dex";
        File injDex = new File(ws, injDexName);
        int modCount = buildInjectorDex(injDex, info);
        log("   ✅ " + injDexName + " (" + (injDex.length() / 1024) + " KB, " + modCount + " modules)");

        // ======== Step 3: Patch hook target DEX ========
        progress(30, "Patching hook DEX...");
        log("\n⚡ Step 3: Patching " + info.hookDexName + "...");
        File patchedDex = patchHookDex(inputApk, info, ws);
        if (patchedDex != null) {
            log("   ✅ Patched (" + (patchedDex.length() / 1024) + " KB)");
        } else {
            log("   ℹ️ DEX unchanged — ContentProvider bootstrap mode");
        }

        // ======== Step 3.5: Smali-level patches on remaining DEXes ========
        progress(50, "Smali patches...");
        log("\n🔧 Step 3.5: Smali-level patches (License hack + DexExtractor)...");
        Map<String, File> extraPatched = patchRemainingDexes(inputApk, info, ws);
        if (!extraPatched.isEmpty()) {
            log("   ✅ Patched " + extraPatched.size() + " additional DEX file(s)");
        } else {
            log("   ℹ️ No additional DEX files needed patching");
        }

        // ======== Step 4: Build patched APK ========
        progress(65, "Building APK...");
        log("\n📦 Step 4: Building patched APK...");
        File unsignedApk = new File(ws, "unsigned.apk");
        buildPatchedApk(inputApk, unsignedApk, info.hookDexName, patchedDex,
                         injDexName, injDex, info.packageName, extraPatched);
        log("   Unsigned: " + (unsignedApk.length() / 1024) + " KB");

        // ======== Step 5: Sign APK ========
        progress(85, "Signing...");
        log("\n🔑 Step 5: Signing APK (v1+v2+v3)...");
        File signedApk = new File(workDir, "patched_signed.apk");
        signApk(unsignedApk, signedApk);
        log("   ✅ Signed: " + (signedApk.length() / 1024) + " KB");

        progress(100, "Complete!");
        log("\n✅ Patching complete!");
        return signedApk;
    }

    // ======================== STEP 1: ANALYZE APK ========================

    static class ApkInfo {
        String packageName = "unknown";
        int dexCount;
        List<String> dexNames = new ArrayList<>();
        String hookClassName;
        String hookSmaliType;
        String hookDexName;
        boolean isApplication;
        boolean nativeProtected; // DexGuard/DexProtector — skip DEX patching
        boolean dexguardEncrypted; // DexGuard class encryption — abort patching
        String dexguardLibName;    // DexGuard native library base name
        String originalSignatureBase64; // Base64 of original signing cert (for signature killer)
        boolean alreadyPatched;    // APK was previously patched by HSPatcher
        String patchVersion;       // Version of HSPatcher that patched it (if marker found)
    }

    private ApkInfo analyzeApk(File apk, File ws) throws Exception {
        ApkInfo info = new ApkInfo();
        ZipFile zip = new ZipFile(apk);
        try {
            List<String> dexNames = new ArrayList<>();
            boolean hasGadgetConfig = false;
            boolean hasGadgetScript = false;
            boolean hasHSPatchMarker = false;
            String markerVersion = null;

            Enumeration<? extends ZipEntry> entries = zip.entries();
            while (entries.hasMoreElements()) {
                ZipEntry e = entries.nextElement();
                String eName = e.getName();
                if (eName.matches("classes\\d*\\.dex")) {
                    dexNames.add(eName);
                }
                // Detect HSPatch artifacts from prior patching
                if (eName.endsWith("/libgadget.config.so")) hasGadgetConfig = true;
                if (eName.endsWith("/libgadget.js.so")) hasGadgetScript = true;
                if (eName.equals("assets/hspatch_marker.txt")) {
                    hasHSPatchMarker = true;
                    try {
                        byte[] mb = readAllBytes(zip.getInputStream(e));
                        markerVersion = new String(mb, "UTF-8").trim();
                    } catch (Exception ignored) {}
                }
            }
            Collections.sort(dexNames);
            info.dexNames = dexNames;
            info.dexCount = dexNames.size();

            // Already-patched detection
            if (hasHSPatchMarker || (hasGadgetConfig && hasGadgetScript)) {
                info.alreadyPatched = true;
                info.patchVersion = markerVersion;
            }

            // Detect DexGuard class encryption early:
            // Pattern: lib/<abi>/lib<NAME>.so exists AND assets/<NAME>/*.odex exists
            // This means all code is encrypted in the native library — not patchable
            Set<String> soBaseNames = new HashSet<>();
            Set<String> assetOdexDirs = new HashSet<>();
            Enumeration<? extends ZipEntry> dgScan = zip.entries();
            while (dgScan.hasMoreElements()) {
                ZipEntry e = dgScan.nextElement();
                String n = e.getName();
                if (n.startsWith("lib/") && n.endsWith(".so")) {
                    int lastSlash = n.lastIndexOf('/');
                    if (lastSlash > 4) { // skip "lib/"
                        String soFile = n.substring(lastSlash + 1);
                        if (soFile.startsWith("lib") && soFile.length() > 6) {
                            soBaseNames.add(soFile.substring(3, soFile.length() - 3));
                        }
                    }
                }
                if (n.startsWith("assets/") && n.endsWith(".odex")) {
                    String[] parts = n.split("/");
                    if (parts.length >= 3) assetOdexDirs.add(parts[1]);
                }
            }
            for (String name : soBaseNames) {
                if (assetOdexDirs.contains(name) && name.length() >= 6) {
                    info.dexguardEncrypted = true;
                    info.dexguardLibName = name;
                    break;
                }
            }

            // Parse binary manifest
            ZipEntry mfEntry = zip.getEntry("AndroidManifest.xml");
            List<String> manifestStrings = new ArrayList<>();
            if (mfEntry != null) {
                byte[] mfData = readAllBytes(zip.getInputStream(mfEntry));
                manifestStrings = extractBinaryXmlStrings(mfData);

                // Package name: first string matching a Java package pattern
                // Prefer the "package" attribute which is typically one of the first strings
                // Validate: must be printable ASCII, reasonable length
                for (String s : manifestStrings) {
                    if (s.length() > 100) continue; // too long
                    if (!isPrintableAscii(s)) continue; // garbled
                    if (s.matches("[a-z][a-z0-9_]*(\\.[a-z][a-z0-9_]*)+") &&
                        !s.startsWith("android.") && !s.startsWith("http") &&
                        !s.startsWith("com.android.vending") &&
                        !s.startsWith("com.android.") && !s.contains("/")) {
                        info.packageName = s;
                        break;
                    }
                }

                // If package still unknown, try to infer from class names in manifest
                if ("unknown".equals(info.packageName)) {
                    for (String s : manifestStrings) {
                        if (s.length() > 150) continue;
                        if (!isPrintableAscii(s)) continue;
                        if (s.contains(".") && !s.contains(" ") && !s.contains("/") &&
                            !s.startsWith("android.") && !s.startsWith("http") &&
                            !s.startsWith("com.android.") && !s.startsWith("org.xmlpull") &&
                            s.matches("[a-z].*\\.[A-Z].*")) {
                            // Extract package from class name (everything before last dot)
                            int lastDot = s.lastIndexOf('.');
                            if (lastDot > 0) {
                                info.packageName = s.substring(0, lastDot);
                                log("   Package inferred from class: " + info.packageName);
                                break;
                            }
                        }
                    }
                }

                findApplicationClass(info, manifestStrings);
                if (info.hookClassName == null) {
                    findActivityClass(info, manifestStrings);
                }
            }

            if (info.hookClassName == null) {
                log("   Manifest didn't yield hook target, scanning DEX classes...");
                scanDexForHookTarget(info, zip, dexNames, ws);
            } else if (!info.isApplication) {
                // We found an Activity from manifest, but prefer Application class
                // Run DEX scan to see if there's an Application subclass
                log("   Found Activity in manifest, checking DEX for Application class...");
                ApkInfo appCheck = new ApkInfo();
                appCheck.packageName = info.packageName;
                appCheck.dexCount = info.dexCount;
                scanDexForHookTarget(appCheck, zip, dexNames, ws);
                if (appCheck.hookClassName != null && appCheck.isApplication) {
                    log("   ✅ DEX scan found Application: " + appCheck.hookClassName + " (overriding Activity)");
                    info.hookClassName = appCheck.hookClassName;
                    info.isApplication = true;
                    info.hookDexName = appCheck.hookDexName;
                }
            }

            if (info.hookClassName == null) {
                throw new Exception("Cannot find Application or Activity class to hook");
            }

            info.hookSmaliType = "L" + info.hookClassName.replace('.', '/') + ";";

            if (info.hookDexName == null) {
                info.hookDexName = findDexContainingClass(zip, dexNames, info.hookSmaliType, ws);
            }

            if (info.hookDexName == null) {
                log("   ⚠️ Hook target not in any DEX by exact match, trying partial...");
                // Try partial class name matching — the manifest may have a short name
                String shortName = info.hookClassName;
                int lastDot = shortName.lastIndexOf('.');
                if (lastDot > 0) shortName = shortName.substring(lastDot + 1);
                String foundType = findClassByShortName(zip, dexNames, shortName, ws, info);
                if (foundType != null) {
                    info.hookSmaliType = foundType;
                    info.hookClassName = foundType.substring(1, foundType.length()-1).replace('/', '.');
                    log("   Resolved via short name: " + info.hookClassName + " in " + info.hookDexName);
                } else {
                    // As last resort use classes.dex but log warning
                    log("   ⚠️ Cannot locate hook class in any DEX, using classes.dex");
                    info.hookDexName = "classes.dex";
                }
            }

            // If package still unknown, infer from hook class name
            if ("unknown".equals(info.packageName) && info.hookClassName != null &&
                info.hookClassName.contains(".")) {
                int dot = info.hookClassName.lastIndexOf('.');
                if (dot > 0) {
                    info.packageName = info.hookClassName.substring(0, dot);
                    log("   Package inferred from hook class: " + info.packageName);
                }
            }

            // Validate: if extracted package looks like a library class (e.g. google.android.*),
            // prefer the hook class's package prefix instead
            if (info.hookClassName != null && info.hookClassName.contains(".") &&
                !"unknown".equals(info.packageName)) {
                String hookPkg = info.hookClassName.substring(0, info.hookClassName.lastIndexOf('.'));
                if (!hookPkg.startsWith(info.packageName) &&
                    !info.packageName.startsWith(hookPkg.split("\\.")[0] + ".")) {
                    // Package name doesn't share a root with hook class — likely a false match
                    // from library code in the manifest. Use hook class package instead.
                    log("   Package override: " + info.packageName + " → " + hookPkg +
                        " (hook class mismatch)");
                    info.packageName = hookPkg;
                }
            }
        } finally {
            zip.close();
        }
        return info;
    }

    private void findApplicationClass(ApkInfo info, List<String> strings) {
        // Pass 1: exact class name ending with "Application" (most common pattern)
        for (String s : strings) {
            if (!isPrintableAscii(s) || s.length() > 150) continue;
            if (s.contains(".") && !s.contains(" ") && !s.contains("/") &&
                !s.startsWith("android.") && !s.startsWith("http") &&
                !s.startsWith("com.android.") && !s.startsWith("org.xmlpull") &&
                (s.endsWith("Application") || s.endsWith("App"))) {
                info.hookClassName = s;
                info.isApplication = true;
                log("   Found Application in manifest (pass 1): " + s);
                return;
            }
        }
        // Pass 2: broader regex — "Application" or "App" anywhere in class name
        for (String s : strings) {
            if (!isPrintableAscii(s) || s.length() > 150) continue;
            if (s.matches("[a-z][a-z0-9_]*(\\.[a-z][a-z0-9_]*)*\\.[A-Z]\\w*Application\\w*")) {
                info.hookClassName = s;
                info.isApplication = true;
                log("   Found Application in manifest (pass 2): " + s);
                return;
            }
        }
        // Pass 3: look for any fully-qualified class name that contains "application"
        // (case-insensitive on last segment) — catches things like "MyCustomAppClass"
        for (String s : strings) {
            if (!isPrintableAscii(s)) continue; // skip garbled strings
            if (s.length() > 150) continue; // too long for a class name
            if (s.contains(".") && !s.contains(" ") && !s.contains("/") &&
                !s.contains("\n") && !s.contains("\r") &&
                !s.startsWith("android.") && !s.startsWith("http") &&
                !s.startsWith("com.android.") && !s.startsWith("org.xmlpull") &&
                !s.startsWith("com.google.") &&
                s.matches("[a-zA-Z][a-zA-Z0-9_]*(\\.[a-zA-Z][a-zA-Z0-9_]*)+")) {
                String lastSeg = s.substring(s.lastIndexOf('.') + 1);
                if (lastSeg.length() > 0 && Character.isUpperCase(lastSeg.charAt(0)) &&
                    lastSeg.toLowerCase().contains("application")) {
                    info.hookClassName = s;
                    info.isApplication = true;
                    log("   Found Application in manifest (pass 3): " + s);
                    return;
                }
            }
        }
    }

    private void findActivityClass(ApkInfo info, List<String> strings) {
        // Pass 1: preferred launcher-style names
        String[] preferred = {"MainActivity", "LauncherActivity", "SplashActivity",
                              "HomeActivity", "StartActivity", "EntryActivity"};
        for (String pref : preferred) {
            for (String s : strings) {
                if (!isPrintableAscii(s) || s.length() > 150) continue;
                if (s.endsWith(pref) && s.contains(".") && !s.startsWith("android.") &&
                    !s.startsWith("com.android.")) {
                    info.hookClassName = s;
                    info.isApplication = false;
                    log("   Found Activity in manifest (preferred): " + s);
                    return;
                }
            }
        }
        // Pass 2: any Activity class from manifest — prefer shorter names (more likely main)
        List<String> candidates = new ArrayList<>();
        for (String s : strings) {
            if (!isPrintableAscii(s) || s.length() > 150) continue;
            if (s.matches("[a-z].*\\.[A-Z].*Activity") && !s.startsWith("android.") &&
                !s.startsWith("com.android.") && !s.startsWith("com.google.")) {
                candidates.add(s);
            }
        }
        if (!candidates.isEmpty()) {
            // Sort by length — shorter class names are more likely to be main activities
            Collections.sort(candidates, new Comparator<String>() {
                public int compare(String a, String b) { return a.length() - b.length(); }
            });
            info.hookClassName = candidates.get(0);
            info.isApplication = false;
            log("   Found Activity in manifest (shortest): " + info.hookClassName);
            return;
        }
    }

    private void scanDexForHookTarget(ApkInfo info, ZipFile zip,
                                       List<String> dexNames, File ws) {
        try {
            // Build a global superclass map: type -> superclass (across all DEX files)
            Map<String, String> superMap = new HashMap<>();
            // Also track which DEX each class is in
            Map<String, String> classToDex = new HashMap<>();

            for (String dexName : dexNames) {
                File tmp = new File(ws, "scan_" + dexName);
                try {
                    copyStream(zip.getInputStream(zip.getEntry(dexName)),
                               new FileOutputStream(tmp));
                    MultiDexContainer<? extends DexFile> c =
                        DexFileFactory.loadDexContainer(tmp, Opcodes.forApi(35));
                    for (String en : c.getDexEntryNames()) {
                        for (ClassDef cls : c.getEntry(en).getDexFile().getClasses()) {
                            String t = cls.getType();
                            String sup = cls.getSuperclass();
                            if (sup != null) superMap.put(t, sup);
                            classToDex.put(t, dexName);
                        }
                    }
                } finally { tmp.delete(); }
            }

            log("   DEX scan: " + superMap.size() + " classes indexed");

            // First pass: find any class whose inheritance chain reaches Application
            Set<String> appBases = new HashSet<>(Arrays.asList(
                "Landroid/app/Application;",
                "Landroidx/multidex/MultiDexApplication;",
                "Landroid/app/MultiDexApplication;"
            ));

            // For each class, walk up the chain (max 10 hops) to see if it extends Application
            // Skip framework classes and prefer classes with "Application" or "App" in name
            String bestAppClass = null;
            String bestAppDex = null;
            int bestScore = -1;

            for (Map.Entry<String, String> entry : superMap.entrySet()) {
                String cls = entry.getKey();
                // Skip framework classes
                if (cls.startsWith("Landroid/") || cls.startsWith("Landroidx/") ||
                    cls.startsWith("Lcom/google/") || cls.startsWith("Lkotlin/") ||
                    cls.startsWith("Lkotlinx/") || cls.startsWith("Ljava/") ||
                    cls.startsWith("Ldalvik/") || cls.startsWith("Lorg/apache/") ||
                    cls.startsWith("Lokhttp3/") || cls.startsWith("Lretrofit2/") ||
                    cls.startsWith("Lio/reactivex/") || cls.startsWith("Lcom/squareup/") ||
                    cls.startsWith("Lcom/facebook/") || cls.startsWith("Lcom/bumptech/")) {
                    continue;
                }

                // Walk inheritance chain
                String cur = cls;
                boolean isApp = false;
                for (int hop = 0; hop < 10; hop++) {
                    String sup = superMap.get(cur);
                    if (sup == null) break;
                    if (appBases.contains(sup)) { isApp = true; break; }
                    // If superclass IS Application itself
                    if (sup.equals("Landroid/app/Application;")) { isApp = true; break; }
                    cur = sup;
                }

                if (isApp) {
                    // Score: prefer classes with "Application" in name (100),
                    // then "App" in name (50), then any (1)
                    // Also add inheritance depth (deeper = more specific = better)
                    int score = 1;
                    if (cls.contains("Application")) score = 100;
                    else if (cls.endsWith("App;")) score = 50;

                    // Count inheritance depth — deeper classes are more specific
                    int depth = 0;
                    String dc = cls;
                    for (int d = 0; d < 10; d++) {
                        String ds = superMap.get(dc);
                        if (ds == null || appBases.contains(ds) ||
                            ds.equals("Landroid/app/Application;")) break;
                        depth++;
                        dc = ds;
                    }
                    score += depth; // deeper = higher score

                    if (score > bestScore) {
                        bestScore = score;
                        bestAppClass = cls;
                        bestAppDex = classToDex.get(cls);
                    }
                }
            }

            if (bestAppClass != null) {
                info.hookClassName = bestAppClass.substring(1, bestAppClass.length()-1).replace('/', '.');
                info.isApplication = true;
                info.hookDexName = bestAppDex;
                log("   Found Application (inheritance walk, score=" + bestScore + "): " + info.hookClassName);
                return;
            }

            // Second pass: Activity with Main/Launcher/Home in name
            Set<String> actBases = new HashSet<>(Arrays.asList(
                "Landroidx/appcompat/app/AppCompatActivity;",
                "Landroid/app/Activity;",
                "Landroidx/fragment/app/FragmentActivity;",
                "Landroidx/activity/ComponentActivity;"
            ));

            String bestActClass = null;
            String bestActDex = null;
            int bestActScore = -1;

            for (Map.Entry<String, String> entry : superMap.entrySet()) {
                String cls = entry.getKey();
                if (cls.startsWith("Landroid/") || cls.startsWith("Landroidx/") ||
                    cls.startsWith("Lcom/google/")) continue;

                // Walk chain to see if it extends Activity
                String cur = cls;
                boolean isAct = false;
                for (int hop = 0; hop < 10; hop++) {
                    String sup = superMap.get(cur);
                    if (sup == null) break;
                    if (actBases.contains(sup) || sup.equals("Landroid/app/Activity;")) {
                        isAct = true; break;
                    }
                    cur = sup;
                }

                if (isAct) {
                    int score = 0;
                    if (cls.contains("Main")) score += 100;
                    if (cls.contains("Launcher")) score += 80;
                    if (cls.contains("Home")) score += 60;
                    if (cls.contains("Splash")) score += 40;
                    if (cls.contains("Entry")) score += 30;
                    if (cls.contains("Start")) score += 20;
                    // Penalize names suggesting non-primary activities
                    if (cls.contains("Onboarding")) score -= 50;
                    if (cls.contains("Setting")) score -= 50;
                    if (cls.contains("Detail")) score -= 50;
                    if (cls.contains("About")) score -= 50;
                    if (cls.contains("Login")) score -= 20;
                    if (score < 0) score = 0;

                    if (score > bestActScore) {
                        bestActScore = score;
                        bestActClass = cls;
                        bestActDex = classToDex.get(cls);
                    }
                }
            }

            if (bestActClass != null) {
                info.hookClassName = bestActClass.substring(1, bestActClass.length()-1).replace('/', '.');
                info.isApplication = false;
                info.hookDexName = bestActDex;
                log("   Found Activity (DEX scan): " + info.hookClassName);
                return;
            }
        } catch (Exception e) {
            log("   ⚠️ DEX scan error: " + e.getMessage());
        }
    }

    private String findDexContainingClass(ZipFile zip, List<String> dexNames,
                                           String smaliType, File ws) {
        try {
            for (String dexName : dexNames) {
                File tmp = new File(ws, "find_" + dexName);
                try {
                    copyStream(zip.getInputStream(zip.getEntry(dexName)),
                               new FileOutputStream(tmp));
                    MultiDexContainer<? extends DexFile> c =
                        DexFileFactory.loadDexContainer(tmp, Opcodes.forApi(35));
                    for (String en : c.getDexEntryNames()) {
                        for (ClassDef cls : c.getEntry(en).getDexFile().getClasses()) {
                            if (cls.getType().equals(smaliType)) return dexName;
                        }
                    }
                } finally { tmp.delete(); }
            }
        } catch (Exception e) {
            log("   ⚠️ Class lookup error: " + e.getMessage());
        }
        return null;
    }

    /**
     * Find a class by short name (e.g. "AdguardApplication") across all DEX files.
     * Sets info.hookDexName and returns the full smali type, or null.
     */
    private String findClassByShortName(ZipFile zip, List<String> dexNames,
                                         String shortName, File ws, ApkInfo info) {
        try {
            for (String dexName : dexNames) {
                File tmp = new File(ws, "short_" + dexName);
                try {
                    copyStream(zip.getInputStream(zip.getEntry(dexName)),
                               new FileOutputStream(tmp));
                    MultiDexContainer<? extends DexFile> c =
                        DexFileFactory.loadDexContainer(tmp, Opcodes.forApi(35));
                    for (String en : c.getDexEntryNames()) {
                        for (ClassDef cls : c.getEntry(en).getDexFile().getClasses()) {
                            String t = cls.getType();
                            // Type is like "Lcom/example/MyClass;"
                            // Extract short name
                            int slash = t.lastIndexOf('/');
                            if (slash < 0) continue;
                            String sn = t.substring(slash + 1, t.length() - 1);
                            if (sn.equals(shortName)) {
                                info.hookDexName = dexName;
                                return t;
                            }
                        }
                    }
                } finally { tmp.delete(); }
            }
        } catch (Exception e) {
            log("   ⚠️ Short name lookup error: " + e.getMessage());
        }
        return null;
    }

    // ======================== STEP 2: BUILD INJECTOR DEX ========================

    private int buildInjectorDex(File outputDex, ApkInfo info) throws Exception {
        File tmpDir = new File(workDir, "inj_smali");
        if (tmpDir.exists()) deleteDir(tmpDir);
        tmpDir.mkdirs();

        ZipFile zf = new ZipFile(extraZip);
        int extracted = 0;
        Enumeration<? extends ZipEntry> entries = zf.entries();
        while (entries.hasMoreElements()) {
            ZipEntry entry = entries.nextElement();
            if (entry.isDirectory()) continue;
            if (!entry.getName().endsWith(".smali")) continue;
            File dest = new File(tmpDir, entry.getName());
            dest.getParentFile().mkdirs();
            copyStream(zf.getInputStream(entry), new FileOutputStream(dest));
            extracted++;
        }
        zf.close();
        log("   Extracted " + extracted + " smali from HSPatch module pack");

        // Substitute htc600.smali license hack placeholders with actual app info
        File htc600File = new File(tmpDir, "com/android/vending/licensing/htc600.smali");
        if (htc600File.exists()) {
            String htcContent = readFileStr(htc600File);
            htcContent = htcContent.replace("LICENSE_HACK|", info.packageName + "|");
            htcContent = htcContent.replace("LICENSE_HACK2", "1");
            writeFileStr(htc600File, htcContent);
            log("   Patched htc600.smali: package=" + info.packageName);
        }

        generateHSPatchInit(tmpDir, info);
        extracted++;
        generateBootProvider(tmpDir);
        extracted++;

        DexBuilder db = new DexBuilder(Opcodes.forApi(35));
        List<File> smaliFiles = new ArrayList<>();
        collectSmaliFiles(tmpDir, smaliFiles);

        int ok = 0, fail = 0;
        for (File sf : smaliFiles) {
            try {
                SmaliMod.assembleSmaliFile(sf, db, 35, false, false);
                ok++;
            } catch (Exception e) {
                fail++;
                if (fail <= 5) log("   ⚠️ " + sf.getName() + ": " + e.getMessage());
            }
        }

        FileDataStore fds = new FileDataStore(outputDex);
        db.writeTo(fds);
        fds.close();

        deleteDir(tmpDir);
        if (fail > 0) log("   (" + fail + " assembly errors)");
        return ok;
    }

    private void generateHSPatchInit(File smaliRoot, ApkInfo info) throws IOException {
        File dir = new File(smaliRoot, "smali/in/startv/hotstar");
        if (!dir.exists()) dir.mkdirs();
        File f = new File(dir, "HSPatchInit.smali");
        if (f.exists()) return;

        String[][] modules = {
            {"config",  "invoke-static {p0}, Lin/startv/hotstar/HSPatchConfig;->init(Landroid/content/Context;)V"},
            {"profile", "invoke-static {p0}, Lin/startv/hotstar/ProfileManager;->applyPendingProfile(Landroid/content/Context;)V"},
            {"spoofer", "invoke-static {p0}, Lin/startv/hotstar/DeviceSpoofer;->init(Landroid/content/Context;)V"},
            {"ssl",     "invoke-static {p0}, Lin/startv/hotstar/SSLBypass;->init(Landroid/content/Context;)V"},
            {"sigbyp",  "invoke-static {p0}, Lin/startv/hotstar/SignatureBypass;->init(Landroid/content/Context;)V"},
            {"screen",  "invoke-static {p0}, Lin/startv/hotstar/ScreenshotEnabler;->init(Landroid/content/Context;)V"},
            {"netlog",  "invoke-static {p0}, Lin/startv/hotstar/NetworkLogger;->init(Landroid/content/Context;)V"},
            {"nethook", "invoke-static {p0}, Lin/startv/hotstar/NetworkInterceptor;->init(Landroid/content/Context;)V"},
            {"tracker", "instance-of v1, p0, Landroid/app/Application;\n" +
                        "    if-eqz v1, :skip_tracker\n" +
                        "    check-cast p0, Landroid/app/Application;\n" +
                        "    invoke-static {p0}, Lin/startv/hotstar/ActivityTracker;->register(Landroid/app/Application;)V\n" +
                        "    :skip_tracker"},
            {"notif",   "invoke-static {p0}, Lin/startv/hotstar/DebugNotification;->show(Landroid/content/Context;)V"}
        };

        StringBuilder sb = new StringBuilder();
        sb.append(".class public Lin/startv/hotstar/HSPatchInit;\n");
        sb.append(".super Ljava/lang/Object;\n\n");
        sb.append("# Auto-generated by HSPatch Engine v2\n\n");
        sb.append(".method public static init(Landroid/content/Context;)V\n");
        sb.append("    .locals 3\n");
        sb.append("    .param p0, \"ctx\"\n\n");

        // Idempotency guard — use System property (survives Frida gadget classloader reloads)
        sb.append("    const-string v0, \"hspatch.initialized\"\n");
        sb.append("    invoke-static {v0}, Ljava/lang/System;->getProperty(Ljava/lang/String;)Ljava/lang/String;\n");
        sb.append("    move-result-object v0\n");
        sb.append("    if-nez v0, :already_init\n");
        sb.append("    const-string v0, \"hspatch.initialized\"\n");
        sb.append("    const-string v1, \"1\"\n");
        sb.append("    invoke-static {v0, v1}, Ljava/lang/System;->setProperty(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;\n\n");

        // Log entry
        sb.append("    const-string v0, \"HSPatch\"\n");
        sb.append("    const-string v1, \"HSPatchInit.init() ENTERED\"\n");
        sb.append("    invoke-static {v0, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I\n\n");

        // === SignatureKiller: spoof original signing certificate ===
        // MUST run before any other module to hook open() and PM before integrity checks
        if (info.originalSignatureBase64 != null) {
            sb.append("    # === SignatureKiller: hook signature + file open ===\n");
            sb.append("    :try_sigkill\n");
            sb.append("    const-string v0, \"").append(info.packageName).append("\"\n");
            sb.append("    const-string v1, \"").append(info.originalSignatureBase64).append("\"\n");
            sb.append("    invoke-static {v0, v1}, Lbin/mt/signature/KillerApplication;->init(Ljava/lang/String;Ljava/lang/String;)V\n");
            sb.append("    :try_sigkill_end\n");
            sb.append("    .catch Ljava/lang/Throwable; {:try_sigkill .. :try_sigkill_end} :catch_sigkill\n");
            sb.append("    const-string v0, \"HSPatch\"\n");
            sb.append("    const-string v1, \"  \\u2705 SignatureKiller OK\"\n");
            sb.append("    invoke-static {v0, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I\n");
            sb.append("    goto :after_sigkill\n");
            sb.append("    :catch_sigkill\n");
            sb.append("    move-exception v0\n");
            sb.append("    invoke-virtual {v0}, Ljava/lang/Throwable;->toString()Ljava/lang/String;\n");
            sb.append("    move-result-object v0\n");
            sb.append("    new-instance v2, Ljava/lang/StringBuilder;\n");
            sb.append("    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V\n");
            sb.append("    const-string v1, \"  \\u274c SignatureKiller FAIL: \"\n");
            sb.append("    invoke-virtual {v2, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;\n");
            sb.append("    invoke-virtual {v2, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;\n");
            sb.append("    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;\n");
            sb.append("    move-result-object v0\n");
            sb.append("    const-string v1, \"HSPatch\"\n");
            sb.append("    invoke-static {v1, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I\n");
            sb.append("    :after_sigkill\n\n");
        }

        // Load Frida gadget (optional — silently skipped if not embedded)
        sb.append("    # === Load Frida Gadget (if embedded) ===\n");
        sb.append("    :try_gadget\n");
        sb.append("    const-string v0, \"gadget\"\n");
        sb.append("    invoke-static {v0}, Ljava/lang/System;->loadLibrary(Ljava/lang/String;)V\n");
        sb.append("    :try_gadget_end\n");
        sb.append("    .catch Ljava/lang/Throwable; {:try_gadget .. :try_gadget_end} :catch_gadget\n");
        sb.append("    const-string v0, \"HSPatch\"\n");
        sb.append("    const-string v1, \"  \\u2705 frida gadget loaded\"\n");
        sb.append("    invoke-static {v0, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I\n");
        sb.append("    goto :after_gadget\n");
        sb.append("    :catch_gadget\n");
        sb.append("    move-exception v0\n");
        sb.append("    const-string v0, \"HSPatch\"\n");
        sb.append("    const-string v1, \"  \\u26a0\\ufe0f frida gadget not available\"\n");
        sb.append("    invoke-static {v0, v1}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I\n");
        sb.append("    :after_gadget\n\n");

        for (String[] mod : modules) {
            sb.append("    :try_").append(mod[0]).append("\n");
            sb.append("    ").append(mod[1]).append("\n");
            sb.append("    :try_").append(mod[0]).append("_end\n");
            sb.append("    .catch Ljava/lang/Throwable; {:try_").append(mod[0])
              .append(" .. :try_").append(mod[0]).append("_end} :catch_").append(mod[0]).append("\n");
            // Log success
            sb.append("    const-string v0, \"HSPatch\"\n");
            sb.append("    const-string v1, \"  ✅ ").append(mod[0]).append(" OK\"\n");
            sb.append("    invoke-static {v0, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I\n");
            sb.append("    goto :after_").append(mod[0]).append("\n");
            sb.append("    :catch_").append(mod[0]).append("\n");
            sb.append("    move-exception v0\n");
            // Log failure: get exception message, build log string
            sb.append("    invoke-virtual {v0}, Ljava/lang/Throwable;->toString()Ljava/lang/String;\n");
            sb.append("    move-result-object v0\n");
            sb.append("    new-instance v2, Ljava/lang/StringBuilder;\n");
            sb.append("    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V\n");
            sb.append("    const-string v1, \"  ❌ ").append(mod[0]).append(" FAIL: \"\n");
            sb.append("    invoke-virtual {v2, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;\n");
            sb.append("    invoke-virtual {v2, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;\n");
            sb.append("    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;\n");
            sb.append("    move-result-object v0\n");
            sb.append("    const-string v1, \"HSPatch\"\n");
            sb.append("    invoke-static {v1, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I\n");
            sb.append("    :after_").append(mod[0]).append("\n\n");
        }

        // Log completion
        sb.append("    const-string v0, \"HSPatch\"\n");
        sb.append("    const-string v1, \"HSPatchInit.init() COMPLETE\"\n");
        sb.append("    invoke-static {v0, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I\n\n");
        sb.append("    return-void\n\n");
        sb.append("    :already_init\n");
        sb.append("    const-string v0, \"HSPatch\"\n");
        sb.append("    const-string v1, \"HSPatchInit.init() already initialized, skipping\"\n");
        sb.append("    invoke-static {v0, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I\n");
        sb.append("    return-void\n.end method\n");

        writeFileStr(f, sb.toString());
        log("   Generated HSPatchInit.smali (10 modules)");
    }

    /**
     * Generate HSPatchBootProvider — a ContentProvider that bootstraps HSPatch
     * initialization. ContentProviders are created before Application.onCreate(),
     * making this the most reliable hook point, especially for DexGuard/DexProtector
     * protected apps where Application methods may be native.
     */
    private void generateBootProvider(File smaliRoot) throws IOException {
        File dir = new File(smaliRoot, "smali/in/startv/hotstar");
        if (!dir.exists()) dir.mkdirs();
        File f = new File(dir, "HSPatchBootProvider.smali");
        if (f.exists()) return;

        StringBuilder sb = new StringBuilder();
        sb.append(".class public Lin/startv/hotstar/HSPatchBootProvider;\n");
        sb.append(".super Landroid/content/ContentProvider;\n\n");
        sb.append("# Auto-generated ContentProvider bootstrap for HSPatch\n");
        sb.append("# Runs before Application.onCreate() — most reliable hook point\n\n");

        // Constructor
        sb.append(".method public constructor <init>()V\n");
        sb.append("    .locals 0\n");
        sb.append("    invoke-direct {p0}, Landroid/content/ContentProvider;-><init>()V\n");
        sb.append("    return-void\n");
        sb.append(".end method\n\n");

        // onCreate — the bootstrap entry point
        sb.append(".method public onCreate()Z\n");
        sb.append("    .locals 2\n\n");
        sb.append("    const-string v0, \"HSPatch\"\n");
        sb.append("    const-string v1, \"HSPatchBootProvider.onCreate() — bootstrap entry\"\n");
        sb.append("    invoke-static {v0, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I\n\n");
        sb.append("    :try_boot\n");
        sb.append("    invoke-virtual {p0}, Lin/startv/hotstar/HSPatchBootProvider;->getContext()Landroid/content/Context;\n");
        sb.append("    move-result-object v0\n");
        sb.append("    invoke-static {v0}, Lin/startv/hotstar/HSPatchInit;->init(Landroid/content/Context;)V\n");
        sb.append("    :try_boot_end\n");
        sb.append("    .catch Ljava/lang/Throwable; {:try_boot .. :try_boot_end} :catch_boot\n");
        sb.append("    goto :after_boot\n");
        sb.append("    :catch_boot\n");
        sb.append("    move-exception v0\n");
        sb.append("    invoke-virtual {v0}, Ljava/lang/Throwable;->toString()Ljava/lang/String;\n");
        sb.append("    move-result-object v0\n");
        sb.append("    const-string v1, \"HSPatch\"\n");
        sb.append("    invoke-static {v1, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I\n");
        sb.append("    :after_boot\n");
        sb.append("    const/4 v0, 0x1\n");
        sb.append("    return v0\n");
        sb.append(".end method\n\n");

        // Required ContentProvider stubs
        String[][] stubs = {
            {"query", ".method public query(Landroid/net/Uri;[Ljava/lang/String;Ljava/lang/String;[Ljava/lang/String;Ljava/lang/String;)Landroid/database/Cursor;\n    .locals 1\n    const/4 v0, 0x0\n    return-object v0\n.end method"},
            {"getType", ".method public getType(Landroid/net/Uri;)Ljava/lang/String;\n    .locals 1\n    const/4 v0, 0x0\n    return-object v0\n.end method"},
            {"insert", ".method public insert(Landroid/net/Uri;Landroid/content/ContentValues;)Landroid/net/Uri;\n    .locals 1\n    const/4 v0, 0x0\n    return-object v0\n.end method"},
            {"delete", ".method public delete(Landroid/net/Uri;Ljava/lang/String;[Ljava/lang/String;)I\n    .locals 1\n    const/4 v0, 0x0\n    return v0\n.end method"},
            {"update", ".method public update(Landroid/net/Uri;Landroid/content/ContentValues;Ljava/lang/String;[Ljava/lang/String;)I\n    .locals 1\n    const/4 v0, 0x0\n    return v0\n.end method"}
        };
        for (String[] stub : stubs) {
            sb.append(stub[1]).append("\n\n");
        }

        writeFileStr(f, sb.toString());
        log("   Generated HSPatchBootProvider.smali (ContentProvider bootstrap)");
    }

    // ======================== STEP 3: PATCH HOOK DEX ========================

    private File patchHookDex(File apk, ApkInfo info, File ws) throws Exception {
        File origDex = new File(ws, "orig_" + info.hookDexName);
        extractFileFromApk(apk, info.hookDexName, origDex);

        File smaliDir = new File(ws, "hook_smali");
        smaliDir.mkdirs();

        log("   Disassembling " + info.hookDexName + "...");
        MultiDexContainer<? extends DexFile> container =
            DexFileFactory.loadDexContainer(origDex, Opcodes.forApi(35));
        for (String en : container.getDexEntryNames()) {
            BaksmaliOptions opts = new BaksmaliOptions();
            opts.apiLevel = 35;
            Baksmali.disassembleDexFile(container.getEntry(en).getDexFile(), smaliDir, 4, opts);
        }
        container = null;
        System.gc();

        int smaliCount = countFiles(smaliDir, ".smali");
        log("   " + smaliCount + " classes disassembled");

        // Direct path computation: className like "com.example.MyClass" -> "com/example/MyClass.smali"
        String smaliRel = info.hookClassName.replace('.', '/') + ".smali";
        File targetSmali = new File(smaliDir, smaliRel);

        if (!targetSmali.exists()) {
            // Sometimes baksmali puts classes in subdirectories differently
            // Try with lowercase first letter of each package segment
            log("   Direct path not found: " + smaliRel);
            log("   Trying type-based lookup for " + info.hookSmaliType + "...");

            // Build a map of type -> file from the smali dir, efficiently
            // Instead of reading file contents, use the directory structure
            // Baksmali outputs files at: <dir>/<type_without_L_and_semicolon>.smali
            // e.g. Lcom/example/MyClass; -> com/example/MyClass.smali
            String typeAsPath = info.hookSmaliType;
            if (typeAsPath.startsWith("L") && typeAsPath.endsWith(";")) {
                typeAsPath = typeAsPath.substring(1, typeAsPath.length() - 1);
            }
            File typeSmali = new File(smaliDir, typeAsPath + ".smali");
            if (typeSmali.exists()) {
                targetSmali = typeSmali;
                log("   Found via type path: " + typeAsPath + ".smali");
            } else {
                // Last resort: scan files — but limit to first match
                log("   Scanning " + smaliCount + " files (last resort)...");
                targetSmali = findSmaliByType(smaliDir, info.hookSmaliType);
            }
        }
        if (targetSmali == null || !targetSmali.exists()) {
            throw new Exception("Cannot find smali for: " + info.hookClassName +
                " (type: " + info.hookSmaliType + ") in " + info.hookDexName);
        }
        log("   Found: " + targetSmali.getName());

        injectHook(targetSmali, info.isApplication, info.dexguardEncrypted);

        // Apply smali-level patches (License hack + DexExtractor)
        int smpCount = applySmaliPatches(smaliDir, info);
        if (smpCount > 0) {
            log("   🔧 Applied smali patches to " + smpCount + " files");
        }

        log("   Reassembling DEX...");
        DexBuilder db = new DexBuilder(Opcodes.forApi(35));
        List<File> allSmali = new ArrayList<>();
        collectSmaliFiles(smaliDir, allSmali);

        int ok = 0, fail = 0;
        for (File sf : allSmali) {
            try {
                SmaliMod.assembleSmaliFile(sf, db, 35, false, false);
                ok++;
            } catch (Exception e) {
                fail++;
                if (fail <= 5) log("   ⚠️ " + relativePath(smaliDir, sf) + ": " + e.getMessage());
            }
        }

        File outDex = new File(ws, info.hookDexName);
        FileDataStore fds = new FileDataStore(outDex);
        db.writeTo(fds);
        fds.close();

        log("   Assembled " + ok + " classes" + (fail > 0 ? " (" + fail + " errors)" : ""));

        origDex.delete();
        deleteDir(smaliDir);
        return outDex;
    }

    private void injectHook(File smaliFile, boolean isApp, boolean dexguardEncrypted) throws IOException {
        log("   injectHook: reading " + smaliFile.getName() + " (" + (smaliFile.length()/1024) + " KB)...");
        String content = readFileStr(smaliFile);
        if (content.contains("HSPatchInit")) { log("   Already hooked"); return; }

        log("   injectHook: searching for hook point...");
        String sig = findOnCreate(content, isApp);

        // === Extract the smali type for this class (needed for native wrapping) ===
        String thisType = null;
        int classIdx = content.indexOf(".class ");
        if (classIdx >= 0) {
            int classEnd = content.indexOf('\n', classIdx);
            String classLine = content.substring(classIdx, classEnd).trim();
            thisType = classLine.substring(classLine.lastIndexOf(' ') + 1);
        }

        boolean usingAttachBase = false;
        if (sig == null && isApp) {
            // === Handle native onCreate() ===
            String nativeSig = findNativeMethod(content, "onCreate()V");
            if (nativeSig != null && dexguardEncrypted) {
                // DexGuard registers native methods by name via JNI RegisterNatives.
                // Renaming the native method breaks registration → NoSuchMethodError.
                // Skip wrapping and fall through to attachBaseContext hook instead.
                log("   ⚠️ native onCreate() detected + DexGuard — skipping wrap (RegisterNatives)");
                log("   → Will use attachBaseContext as hook point instead");
            } else if (nativeSig != null) {
                log("   \u26a0\ufe0f native onCreate() detected — wrapping instead of skipping");
                content = wrapNativeMethod(content, nativeSig, "onCreate", "()V", thisType, true);
                writeFileStr(smaliFile, content);
                sig = ".method public onCreate()V";
                log("   ✅ Native onCreate() renamed → _hsp_orig_onCreate(), Java wrapper created");
            }

            if (sig == null) {
                // Try attachBaseContext as alternative (fires before onCreate)
                sig = findAttachBaseContext(content);
                if (sig != null) {
                    log("   Using attachBaseContext as hook point");
                    usingAttachBase = true;
                }
            }

            if (sig == null) {
                // Handle native attachBaseContext — rename + wrap
                String nativeABC = findNativeMethod(content, "attachBaseContext(Landroid/content/Context;)V");
                if (nativeABC != null && dexguardEncrypted) {
                    // DexGuard: don't rename native attachBaseContext either
                    log("   ⚠️ native attachBaseContext() + DexGuard — skipping wrap");
                    log("   → Will add fresh attachBaseContext as hook point");
                } else if (nativeABC != null) {
                    log("   \u26a0\ufe0f native attachBaseContext() detected — wrapping");
                    content = wrapNativeMethod(content, nativeABC,
                        "attachBaseContext", "(Landroid/content/Context;)V", thisType, false);
                    writeFileStr(smaliFile, content);
                    sig = findAttachBaseContext(content);
                    usingAttachBase = true;
                    log("   ✅ Native attachBaseContext() wrapped");
                }
            }

            if (sig == null) {
                // No usable hook point — add a fresh method
                String superClass = extractSuperClass(content);
                if (superClass == null) superClass = "Landroid/app/Application;";

                if (dexguardEncrypted) {
                    // DexGuard: native onCreate exists, can't touch it.
                    // Add a fresh attachBaseContext (fires BEFORE native onCreate).
                    log("   Adding attachBaseContext for DexGuard hook...");
                    String newMethod =
                        "\n.method protected attachBaseContext(Landroid/content/Context;)V\n" +
                        "    .locals 2\n" +
                        "    .param p1, \"base\"\n\n" +
                        "    invoke-super {p0, p1}, " + superClass + "->attachBaseContext(Landroid/content/Context;)V\n\n" +
                        "    return-void\n" +
                        ".end method\n";
                    content = content + newMethod;
                    writeFileStr(smaliFile, content);
                    sig = ".method protected attachBaseContext(Landroid/content/Context;)V";
                    usingAttachBase = true;
                    log("   ✅ Fresh attachBaseContext added (DexGuard-safe hook point)");
                } else {
                    // Normal app: add a fresh onCreate
                    log("   Adding onCreate method to Application class...");
                    String newMethod =
                        "\n.method public onCreate()V\n" +
                        "    .locals 2\n\n" +
                        "    invoke-super {p0}, " + superClass + "->onCreate()V\n\n" +
                        "    return-void\n" +
                        ".end method\n";
                    content = content + newMethod;
                    writeFileStr(smaliFile, content);
                    sig = ".method public onCreate()V";
                }
            }
        }
        if (sig == null && !isApp) {
            // Handle native Activity.onCreate(Bundle)
            String nativeSig = findNativeMethod(content, "onCreate(Landroid/os/Bundle;)V");
            if (nativeSig != null && dexguardEncrypted) {
                // DexGuard: don't rename, add fresh onCreate that calls super
                log("   ⚠️ native Activity.onCreate() + DexGuard — adding fresh wrapper");
                String superClass = extractSuperClass(content);
                if (superClass == null) superClass = "Landroidx/appcompat/app/AppCompatActivity;";
                // Remove the native declaration and add a Java version
                // Actually: we can't remove it (DexGuard needs it). Add a separate hook method.
                // Use a ContentProvider-style approach: skip this, hook via provider bootstrap.
                log("   → DexGuard Activity — will use ContentProvider bootstrap");
            } else if (nativeSig != null) {
                log("   \u26a0\ufe0f native Activity.onCreate() detected — wrapping");
                content = wrapNativeMethod(content, nativeSig,
                    "onCreate", "(Landroid/os/Bundle;)V", thisType, false);
                writeFileStr(smaliFile, content);
                sig = ".method public onCreate(Landroid/os/Bundle;)V";
                log("   ✅ Native Activity.onCreate() wrapped");
            }

            if (sig == null) {
                log("   Adding onCreate method to Activity class...");
                String superClass = extractSuperClass(content);
                if (superClass == null) superClass = "Landroidx/appcompat/app/AppCompatActivity;";
                String newMethod =
                    "\n.method public onCreate(Landroid/os/Bundle;)V\n" +
                    "    .locals 2\n" +
                    "    .param p1, \"savedInstanceState\"\n\n" +
                    "    invoke-super {p0, p1}, " + superClass + "->onCreate(Landroid/os/Bundle;)V\n\n" +
                    "    return-void\n" +
                    ".end method\n";
                content = content + newMethod;
                writeFileStr(smaliFile, content);
                sig = ".method public onCreate(Landroid/os/Bundle;)V";
            }
        }
        if (sig == null) throw new IOException("Cannot find hook point in " + smaliFile.getName());
        log("   injectHook: found signature: " + sig);

        int mStart = content.indexOf(sig);
        int mEnd = content.indexOf(".end method", mStart);

        int locIdx = content.indexOf(".locals", mStart);
        boolean useRegs = false;
        if (locIdx == -1 || locIdx > mEnd) {
            locIdx = content.indexOf(".registers", mStart);
            useRegs = true;
        }
        if (locIdx == -1 || locIdx > mEnd) throw new IOException("No .locals/.registers");

        int locEnd = content.indexOf('\n', locIdx);
        String locLine = content.substring(locIdx, locEnd).trim();
        int curN = Integer.parseInt(locLine.split("\\s+")[1]);
        // Allocate 2 EXTRA registers beyond what the original method uses.
        // Use those dedicated registers for hook code — never touch original v0,v1.
        // This prevents VerifyError from register type conflicts.
        // paramCount: onCreate()V on App=1(p0), attachBaseContext(Context)V=2(p0,p1),
        //             onCreate(Bundle)V on Activity=2(p0,p1)
        int paramCount = (isApp && !usingAttachBase) ? 1 : 2;
        int origLocals;
        if (useRegs) {
            origLocals = curN - paramCount;
        } else {
            origLocals = curN;
        }
        int hv0 = origLocals;      // hook-private register 0
        int hv1 = origLocals + 1;  // hook-private register 1
        int newN = (useRegs) ? curN + 2 : curN + 2;  // always add 2 extra
        log("   Registers: orig=" + curN + (useRegs ? " .registers" : " .locals") +
            " → " + newN + " (hook uses v" + hv0 + ",v" + hv1 + ")");

        int insertAt;
        int superIdx = content.indexOf("invoke-super", mStart);
        if (superIdx != -1 && superIdx < mEnd) {
            int nl = content.indexOf('\n', superIdx);
            String after = content.substring(nl + 1).trim();
            if (after.startsWith("move-result")) nl = content.indexOf('\n', nl + 1);
            insertAt = nl;
        } else {
            insertAt = locEnd;
        }

        String hook =
            "\n\n    # === HSPatch v4: init hook (v" + hv0 + ",v" + hv1 + " dedicated) ===\n" +
            "    const-string v" + hv0 + ", \"HSPatch\"\n" +
            "    const-string v" + hv1 + ", \">>> Hook reached in onCreate\"\n" +
            "    invoke-static {v" + hv0 + ", v" + hv1 + "}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I\n" +
            "    :try_hsp\n" +
            "    invoke-static {p0}, Lin/startv/hotstar/HSPatchInit;->init(Landroid/content/Context;)V\n" +
            "    :try_hsp_end\n" +
            "    .catchall {:try_hsp .. :try_hsp_end} :catch_hsp\n" +
            "    goto :after_hsp\n" +
            "    :catch_hsp\n" +
            "    move-exception v" + hv0 + "\n" +
            "    :after_hsp\n";

        String result = content.substring(0, insertAt) + hook + content.substring(insertAt);
        String newLoc = useRegs ? "    .registers " + newN : "    .locals " + newN;
        result = result.replace(locLine, newLoc);

        writeFileStr(smaliFile, result);
        log("   ✅ Injected HSPatchInit.init() hook");
    }

    private String findOnCreate(String content, boolean isApp) {
        String[] sigs = isApp ?
            new String[]{".method public onCreate()V",
                         ".method public final onCreate()V",
                         ".method public synthetic onCreate()V"} :
            new String[]{".method public onCreate(Landroid/os/Bundle;)V",
                         ".method protected onCreate(Landroid/os/Bundle;)V",
                         ".method public final onCreate(Landroid/os/Bundle;)V"};
        for (String s : sigs) if (content.contains(s)) return s;
        return null;
    }

    private String findAttachBaseContext(String content) {
        String[] sigs = {
            ".method protected attachBaseContext(Landroid/content/Context;)V",
            ".method public attachBaseContext(Landroid/content/Context;)V"
        };
        for (String s : sigs) if (content.contains(s)) return s;
        return null;
    }

    private String extractSuperClass(String content) {
        int idx = content.indexOf(".super ");
        if (idx < 0) return null;
        int end = content.indexOf('\n', idx);
        if (end < 0) end = content.length();
        return content.substring(idx + 7, end).trim();
    }

    /**
     * Find a native method declaration matching the given suffix (e.g. "onCreate()V").
     * Handles various access modifiers: public, protected, public final, etc.
     * Returns the full ".method ... native <suffix>" line, or null if not found.
     */
    private String findNativeMethod(String content, String methodSuffix) {
        // Build candidate patterns with different access modifiers
        String[] prefixes = {
            ".method public native ",
            ".method public final native ",
            ".method protected native ",
            ".method protected final native ",
            ".method private native ",
            ".method public static native ",
            ".method public abstract native ",
        };
        for (String prefix : prefixes) {
            String candidate = prefix + methodSuffix;
            if (content.contains(candidate)) return candidate;
        }
        // Fallback: scan line-by-line for any native method with this suffix
        for (String line : content.split("\n")) {
            String trimmed = line.trim();
            if (trimmed.startsWith(".method ") && trimmed.contains(" native ") &&
                trimmed.endsWith(methodSuffix)) {
                return trimmed;
            }
        }
        return null;
    }

    /**
     * Wrap a native method: rename original to _hsp_orig_<name>, create a Java
     * wrapper method with the original name that calls HSPatchInit.init(p0) first,
     * then delegates to the renamed native method.
     *
     * @param content      full smali file content
     * @param nativeSig    the exact ".method ... native <name>(...)" line found
     * @param methodName   e.g. "onCreate", "attachBaseContext"
     * @param descriptor   e.g. "()V", "(Landroid/content/Context;)V", "(Landroid/os/Bundle;)V"
     * @param thisType     e.g. "Lcom/rsa/securidapp/RsaApplication;"
     * @param isNoArgVoid  true for "()V" methods (no params beyond p0)
     * @return modified content with renamed native + new wrapper method
     */
    private String wrapNativeMethod(String content, String nativeSig,
                                     String methodName, String descriptor,
                                     String thisType, boolean isNoArgVoid) {
        // Step 1: Rename the native method — insert _hsp_orig_ prefix
        String renamedSig = nativeSig.replace(
            " " + methodName + "(", " _hsp_orig_" + methodName + "(");
        content = content.replace(nativeSig, renamedSig);

        // Step 2: Determine access modifier for the wrapper (strip 'native' keyword)
        // e.g. ".method public final native onCreate()V" → ".method public final onCreate()V"
        String wrapperSig = nativeSig.replace(" native ", " ");

        // Step 3: Build super call to renamed native
        // thisType like "Lcom/example/App;" → invoke on this type
        String nativeInvoke;
        if (isNoArgVoid) {
            // No params: just p0
            nativeInvoke =
                "    invoke-virtual {p0}, " + thisType + "->_hsp_orig_" + methodName + descriptor;
        } else {
            // One param: p0, p1 (covers Context, Bundle, etc.)
            nativeInvoke =
                "    invoke-virtual {p0, p1}, " + thisType + "->_hsp_orig_" + methodName + descriptor;
        }

        // Step 4: Build the wrapper method body
        // NOTE: We do NOT add HSPatchInit.init() here — the regular injectHook()
        // code will inject the hook into this wrapper method (finds the sig, adds hook).
        // This prevents double-init calls.
        int localsCount = isNoArgVoid ? 0 : 0;
        StringBuilder wrapper = new StringBuilder();
        wrapper.append("\n").append(wrapperSig).append("\n");
        wrapper.append("    .locals ").append(localsCount).append("\n\n");
        // Delegate to the original renamed native method
        wrapper.append(nativeInvoke).append("\n\n");
        wrapper.append("    return-void\n");
        wrapper.append(".end method\n");

        // Insert the wrapper method at the end of the file
        content = content + wrapper.toString();

        return content;
    }

    // ======================== STEP 4: BUILD PATCHED APK ========================

    private void buildPatchedApk(File original, File output,
                                  String hookDexName, File hookDex,
                                  String injDexName, File injDex,
                                  String packageName,
                                  Map<String, File> extraPatched) throws Exception {
        ZipFile origZip = new ZipFile(original);
        ZipOutputStream zos = new ZipOutputStream(
            new BufferedOutputStream(new FileOutputStream(output)));

        // Detect native ABIs from original APK (for Frida gadget matching)
        Set<String> nativeAbis = new LinkedHashSet<>();
        Enumeration<? extends ZipEntry> abiScan = origZip.entries();
        while (abiScan.hasMoreElements()) {
            ZipEntry e = abiScan.nextElement();
            String n = e.getName();
            if (n.startsWith("lib/") && n.endsWith(".so")) {
                String[] parts = n.split("/");
                if (parts.length >= 3) nativeAbis.add(parts[1]);
            }
        }
        if (!nativeAbis.isEmpty()) log("   Native ABIs: " + nativeAbis);

        int copied = 0;
        Enumeration<? extends ZipEntry> entries = origZip.entries();
        while (entries.hasMoreElements()) {
            ZipEntry entry = entries.nextElement();
            String name = entry.getName();
            // Strip ONLY JAR-signature files from META-INF/
            // Preserve services/, kotlin version files, gradle metadata, etc.
            if (name.startsWith("META-INF/")) {
                String fn = name.substring("META-INF/".length());
                // Remove: MANIFEST.MF, *.SF, *.RSA, *.DSA, *.EC, SIG-*
                if (fn.equals("MANIFEST.MF") ||
                    fn.endsWith(".SF") || fn.endsWith(".RSA") ||
                    fn.endsWith(".DSA") || fn.endsWith(".EC") ||
                    fn.startsWith("SIG-")) {
                    continue;
                }
            }
            // Skip hook DEX only if we have a patched replacement
            if (hookDex != null && name.equals(hookDexName)) continue;
            // Skip DEXes that have smali-patched replacements
            if (extraPatched != null && extraPatched.containsKey(name)) continue;

            // Intercept manifest for activity + provider registration
            if (name.equals("AndroidManifest.xml")) {
                byte[] mfBytes = readAllBytes(origZip.getInputStream(entry));
                byte[] patched = ManifestPatcher.patch(mfBytes, packageName);
                ZipEntry ne = new ZipEntry("AndroidManifest.xml");
                ne.setMethod(ZipEntry.DEFLATED);
                zos.putNextEntry(ne);
                zos.write(patched);
                zos.closeEntry();
                if (patched.length != mfBytes.length) {
                    log("   📋 Manifest patched: registered HSPatch components");
                }
                copied++;
                continue;
            }

            ZipEntry ne = cloneEntry(entry);
            zos.putNextEntry(ne);
            copyStream(origZip.getInputStream(entry), zos, false);
            zos.closeEntry();
            copied++;
        }

        if (hookDex != null) {
            addToZip(zos, hookDexName, hookDex);
            log("   Replaced: " + hookDexName + " (" + (hookDex.length() / 1024) + " KB)");
        } else {
            log("   Original " + hookDexName + " preserved (native protection)");
        }

        addToZip(zos, injDexName, injDex);
        log("   Added: " + injDexName + " (" + (injDex.length() / 1024) + " KB)");

        // Add smali-patched DEXes
        if (extraPatched != null) {
            for (Map.Entry<String, File> ep : extraPatched.entrySet()) {
                addToZip(zos, ep.getKey(), ep.getValue());
                log("   Replaced: " + ep.getKey() + " (smali patches, " +
                    (ep.getValue().length() / 1024) + " KB)");
            }
        }

        // Embed Frida gadget if available
        if (fridaZip != null && fridaZip.exists()) {
            embedFridaGadget(zos, nativeAbis);
        }

        // Embed SignatureKiller: native libs + origin.apk (original APK for open() hook)
        if (sigkillDir != null && sigkillDir.exists()) {
            embedSignatureKiller(zos, nativeAbis, original);
        }

        // Write HSPatch marker asset (for already-patched detection)
        try {
            String version = "3.12";
            byte[] markerData = version.getBytes("UTF-8");
            ZipEntry markerEntry = new ZipEntry("assets/hspatch_marker.txt");
            markerEntry.setMethod(ZipEntry.DEFLATED);
            zos.putNextEntry(markerEntry);
            zos.write(markerData);
            zos.closeEntry();
            log("   📌 HSPatch marker written (v" + version + ")");
        } catch (Exception e) {
            log("   ⚠️ Marker write failed: " + e.getMessage());
        }

        zos.close();
        origZip.close();
        log("   Copied " + copied + " original entries");
    }

    /** Clone a ZipEntry preserving method, size, CRC, and timestamp. */
    private ZipEntry cloneEntry(ZipEntry src) {
        ZipEntry ne = new ZipEntry(src.getName());
        ne.setMethod(src.getMethod());
        if (src.getMethod() == ZipEntry.STORED) {
            ne.setSize(src.getSize());
            ne.setCompressedSize(src.getCompressedSize());
            ne.setCrc(src.getCrc());
        }
        if (src.getTime() != -1) ne.setTime(src.getTime());
        return ne;
    }

    private void addToZip(ZipOutputStream zos, String name, File file) throws Exception {
        ZipEntry e = new ZipEntry(name);

        if (name.endsWith(".dex") || name.endsWith(".so")) {
            // DEX and native libs MUST be stored uncompressed on Android 12+
            // (INSTALL_FAILED_INVALID_APK: dex not uncompressed and aligned)
            byte[] data = readAllBytes(new FileInputStream(file));
            java.util.zip.CRC32 crc = new java.util.zip.CRC32();
            crc.update(data);
            e.setMethod(ZipEntry.STORED);
            e.setSize(data.length);
            e.setCompressedSize(data.length);
            e.setCrc(crc.getValue());
            zos.putNextEntry(e);
            zos.write(data);
        } else {
            e.setMethod(ZipEntry.DEFLATED);
            zos.putNextEntry(e);
            FileInputStream fis = new FileInputStream(file);
            copyStream(fis, zos, false);
            fis.close();
        }
        zos.closeEntry();
    }

    /**
     * Embed Frida gadget native libraries into the patched APK.
     * Reads from fridaZip which contains:
     *   arm64-v8a/libgadget.so   — Frida gadget for arm64
     *   armeabi-v7a/libgadget.so — Frida gadget for arm
     *   libgadget.config.so      — Gadget config (script mode)
     *   libgadget.js.so           — SSL bypass script
     */
    private void embedFridaGadget(ZipOutputStream zos, Set<String> nativeAbis) {
        try {
            ZipFile fz = new ZipFile(fridaZip);

            // If APK has no native libs, default to arm64-v8a
            Set<String> targetAbis;
            if (nativeAbis.isEmpty()) {
                targetAbis = new LinkedHashSet<>();
                targetAbis.add("arm64-v8a");
            } else {
                targetAbis = nativeAbis;
            }

            int added = 0;
            for (String abi : targetAbis) {
                ZipEntry gadgetEntry = fz.getEntry(abi + "/libgadget.so");
                if (gadgetEntry == null) {
                    log("   ⚠️ No Frida gadget for ABI: " + abi);
                    continue;
                }

                // Add libgadget.so
                addZipEntry(zos, fz.getInputStream(gadgetEntry), "lib/" + abi + "/libgadget.so");

                // Add config (shared file, placed per-ABI)
                ZipEntry cfgEntry = fz.getEntry("libgadget.config.so");
                if (cfgEntry != null) {
                    addZipEntry(zos, fz.getInputStream(cfgEntry), "lib/" + abi + "/libgadget.config.so");
                }

                // Add SSL bypass script (shared file, placed per-ABI)
                ZipEntry jsEntry = fz.getEntry("libgadget.js.so");
                if (jsEntry != null) {
                    addZipEntry(zos, fz.getInputStream(jsEntry), "lib/" + abi + "/libgadget.js.so");
                }

                long sizeMB = gadgetEntry.getSize() / (1024 * 1024);
                log("   🔧 Frida gadget added for " + abi +
                    " (" + (sizeMB > 0 ? sizeMB + " MB" : (gadgetEntry.getSize()/1024) + " KB") + ")");
                added++;
            }

            fz.close();
            if (added > 0) {
                log("   ✅ Frida gadget embedded for " + added + " ABI(s)");
            }
        } catch (Exception e) {
            log("   ⚠️ Frida gadget embedding failed: " + e.getMessage());
        }
    }

    private void addZipEntry(ZipOutputStream zos, InputStream is, String name) throws Exception {
        byte[] data = readAllBytes(is);
        ZipEntry e = new ZipEntry(name);

        if (name.endsWith(".so") || name.endsWith(".dex")) {
            // Native libs and DEX must be stored uncompressed on Android 12+
            java.util.zip.CRC32 crc = new java.util.zip.CRC32();
            crc.update(data);
            e.setMethod(ZipEntry.STORED);
            e.setSize(data.length);
            e.setCompressedSize(data.length);
            e.setCrc(crc.getValue());
        } else {
            e.setMethod(ZipEntry.DEFLATED);
        }
        zos.putNextEntry(e);
        zos.write(data);
        zos.closeEntry();
    }

    // ======================== SMALI-LEVEL PATCHES (License hack + DexExtractor) ========================

    /**
     * Apply regex-based smali patches to all .smali files in a directory.
     * Patches: Signature.verify→true, getInstallerPackageName→"com.android.vending",
     * LicenseValidator nonce bypass, and DexExtractor Method.invoke wrapping (for DexGuard).
     * Returns the number of files that were modified.
     */
    private int applySmaliPatches(File smaliDir, ApkInfo info) {
        int patchCount = 0;
        List<File> smaliFiles = new ArrayList<>();
        collectSmaliFiles(smaliDir, smaliFiles);

        for (File f : smaliFiles) {
            try {
                String content = readFileStr(f);
                String original = content;
                content = applyLicensePatches(content);
                if (info.dexguardEncrypted) {
                    content = applyDexExtractorPatches(content);
                }
                if (!content.equals(original)) {
                    writeFileStr(f, content);
                    patchCount++;
                }
            } catch (Exception e) {
                // Ignore individual file errors
            }
        }
        return patchCount;
    }

    /**
     * Apply license-related smali patches (from License_hack patch format).
     * 1. Signature.verify() → always return true
     * 2. getInstallerPackageName() → return "com.android.vending"
     * 3. LicenseValidator nonce check → bypass (if-eq → goto)
     */
    private String applyLicensePatches(String content) {
        // === 1. Signature.verify([B)Z → always true ===
        // Before: invoke-virtual {vX, vY}, Ljava/security/Signature;->verify([B)Z
        //         move-result vZ
        // After:  invoke-virtual {vX, vY}, Ljava/security/Signature;->verify([B)Z
        //         const/4 vZ, 0x1
        content = Pattern.compile(
            "(invoke-virtual \\{[vp]\\d+, [vp]\\d+\\}, Ljava/security/Signature;->verify\\(\\[B\\)Z)" +
            "\n\n(\\s+)move-result ([vp]\\d+)"
        ).matcher(content).replaceAll(
            "$1\n\n$2const/4 $3, 0x1"
        );

        // === 2a. getInstallerPackageName → "com.android.vending" (simple variant) ===
        // Before: invoke-virtual {vX, vY}, ...PackageManager;->getInstallerPackageName(...)
        //         move-result-object vZ
        // After:  ...same invoke...
        //         const-string vZ, "com.android.vending"
        content = Pattern.compile(
            "(invoke-virtual \\{[pv]\\d+, [pv]\\d+\\}, Landroid/content/pm/PackageManager;->" +
            "(?:getInstallerPackageName|InstallerPackageName)\\(Ljava/lang/String;\\)Ljava/lang/String;)" +
            "\n\n(\\s+)move-result-object ([pv]\\d+)"
        ).matcher(content).replaceAll(
            "$1\n\n$2const-string $3, \"com.android.vending\""
        );

        // === 2b. getInstallerPackageName → "com.android.vending" (with try/catch) ===
        content = Pattern.compile(
            "(invoke-virtual \\{[pv]\\d+, [pv]\\d+\\}, Landroid/content/pm/PackageManager;->" +
            "(?:getInstallerPackageName|InstallerPackageName)\\(Ljava/lang/String;\\)Ljava/lang/String;" +
            "\n\\s+:try_end_\\S+\n\\s+\\.catch \\S+; \\{:try_start_\\S+ \\.\\. :try_end_\\S+\\} :catch_\\S+)" +
            "\n\n(\\s+)move-result-object ([pv]\\d+)"
        ).matcher(content).replaceAll(
            "$1\n\n$2const-string $3, \"com.android.vending\""
        );

        // === 3. LicenseValidator nonce bypass: if-eq → goto ===
        // Multiple variants — all change conditional jump to unconditional goto
        // Variant: if-eq rA, rB, :cond_X  followed by "LicenseValidator" string
        content = Pattern.compile(
            "if-eq ([pv]\\d+), ([pv]\\d+), (:cond_\\S+)" +
            "(\n\n\\s+const-string [pv]\\d+, \"LicenseValidator\")"
        ).matcher(content).replaceAll(
            "goto $3$4"
        );

        // Variant: if-eq followed by "Nonce doesn" string (with optional .line directive)
        content = Pattern.compile(
            "if-eq ([pv]\\d+), ([pv]\\d+), (:cond_\\S+)" +
            "(\n\n\\s+(?:\\.line \\d+\n\\s+)?const-string [pv]\\d+, \"Nonce doesn)"
        ).matcher(content).replaceAll(
            "goto $3$4"
        );

        return content;
    }

    /**
     * Apply DexExtractor patches — wrap Method.invoke() calls with reflection interceptor.
     * Only applied when DexGuard encryption is detected, as DexGuard dispatches
     * encrypted methods via reflection. The wrapper logs each reflected call.
     */
    private String applyDexExtractorPatches(String content) {
        // Before: invoke-virtual {vM, vT, vA}, Ljava/lang/reflect/Method;->invoke(...)Ljava/lang/Object;
        // After:  invoke-static {vM, vT, vA}, Lcom/anymy/ref;->invoke(Object,Object,[Object)V
        //         invoke-virtual {vM, vT, vA}, Ljava/lang/reflect/Method;->invoke(...)Ljava/lang/Object;
        content = Pattern.compile(
            "(invoke-virtual \\{([vp]\\d+), ([vp]\\d+), ([vp]\\d+)\\}, " +
            "Ljava/lang/reflect/Method;->invoke\\(Ljava/lang/Object;\\[Ljava/lang/Object;\\)Ljava/lang/Object;)"
        ).matcher(content).replaceAll(
            "invoke-static {$2, $3, $4}, Lcom/anymy/ref;->invoke(Ljava/lang/Object;Ljava/lang/Object;[Ljava/lang/Object;)V\n\n    $1"
        );

        return content;
    }

    /**
     * Process all DEX files EXCEPT the hook DEX: baksmali, apply regex patches, reassemble.
     * Quick-scans raw DEX bytes first to skip DEXes that don't contain patchable patterns.
     * Returns a map of dexName → patchedFile for DEXes that were modified.
     */
    private Map<String, File> patchRemainingDexes(File apk, ApkInfo info, File ws) throws Exception {
        Map<String, File> patched = new LinkedHashMap<>();
        for (String dexName : info.dexNames) {
            if (dexName.equals(info.hookDexName)) continue; // Already handled in patchHookDex

            File origDex = new File(ws, "sp_" + dexName);
            extractFileFromApk(apk, dexName, origDex);

            // Quick check: does this DEX contain any patchable patterns?
            byte[] dexBytes = readAllBytes(new FileInputStream(origDex));
            String dexStr = new String(dexBytes, "ISO-8859-1");
            boolean hasLicensePatterns = dexStr.contains("Ljava/security/Signature;") ||
                dexStr.contains("getInstallerPackageName") ||
                dexStr.contains("LicenseValidator") ||
                dexStr.contains("ILicenseResultListener");
            boolean hasReflectPatterns = info.dexguardEncrypted &&
                dexStr.contains("Ljava/lang/reflect/Method;");
            dexBytes = null;
            dexStr = null;

            if (!hasLicensePatterns && !hasReflectPatterns) {
                origDex.delete();
                continue;
            }

            log("   " + dexName + ": patchable patterns found, disassembling...");

            // Baksmali
            File smaliDir = new File(ws, "sp_smali_" + dexName.replace(".dex", ""));
            smaliDir.mkdirs();
            MultiDexContainer<? extends DexFile> container =
                DexFileFactory.loadDexContainer(origDex, Opcodes.forApi(35));
            for (String en : container.getDexEntryNames()) {
                BaksmaliOptions opts = new BaksmaliOptions();
                opts.apiLevel = 35;
                Baksmali.disassembleDexFile(container.getEntry(en).getDexFile(), smaliDir, 4, opts);
            }
            container = null;
            System.gc();

            // Apply patches
            int patches = applySmaliPatches(smaliDir, info);

            if (patches > 0) {
                log("   " + dexName + ": " + patches + " files patched, reassembling...");
                DexBuilder db = new DexBuilder(Opcodes.forApi(35));
                List<File> allSmali = new ArrayList<>();
                collectSmaliFiles(smaliDir, allSmali);
                int ok = 0, fail = 0;
                for (File sf : allSmali) {
                    try {
                        SmaliMod.assembleSmaliFile(sf, db, 35, false, false);
                        ok++;
                    } catch (Exception e) {
                        fail++;
                    }
                }
                File outDex = new File(ws, dexName);
                FileDataStore fds = new FileDataStore(outDex);
                db.writeTo(fds);
                fds.close();
                patched.put(dexName, outDex);
                log("   " + dexName + ": assembled " + ok + " classes" +
                    (fail > 0 ? " (" + fail + " errors)" : ""));
            } else {
                log("   " + dexName + ": no patterns matched");
            }

            origDex.delete();
            deleteDir(smaliDir);
        }
        return patched;
    }

    // ======================== SIGNATURE EXTRACTION ========================

    /**
     * Extract the original APK signing certificate as base64-encoded DER.
     * This is used by SignatureKiller to spoof the original signature at runtime.
     */
    private String extractOriginalSignature(File apk) {
        try {
            // Read the cert from META-INF/*.RSA/DSA/EC using JarFile verification
            JarFile jar = new JarFile(apk, true);
            JarEntry entry = jar.getJarEntry("AndroidManifest.xml");
            if (entry == null) entry = jar.getJarEntry("classes.dex");
            if (entry == null) {
                jar.close();
                return null;
            }
            // Must read entry fully to trigger JAR signature verification
            InputStream is = jar.getInputStream(entry);
            byte[] buf = new byte[8192];
            while (is.read(buf) > 0) {}
            is.close();

            java.security.cert.Certificate[] certs = entry.getCertificates();
            jar.close();
            if (certs == null || certs.length == 0) {
                log("   ⚠️ APK has no signing certificates");
                return null;
            }
            byte[] certDer = certs[0].getEncoded();
            return Base64.encodeToString(certDer, Base64.NO_WRAP);
        } catch (Exception e) {
            log("   ⚠️ Signature extraction failed: " + e.getMessage());
            return null;
        }
    }

    // ======================== SIGNATURE KILLER EMBEDDING ========================

    /**
     * Embed SignatureKiller native libraries and the original APK into the patched APK.
     * - lib/<abi>/libSignatureKiller.so — PLT hook library (xhook)
     * - assets/SignatureKiller/origin.apk — copy of original APK (for open() redirect)
     */
    private void embedSignatureKiller(ZipOutputStream zos, Set<String> nativeAbis,
                                       File originalApk) {
        try {
            // Map ABI names to .so file names in sigkillDir
            // Files are named: arm64-v8a_libSignatureKiller.so, armeabi-v7a_libSignatureKiller.so
            Set<String> targetAbis;
            if (nativeAbis.isEmpty()) {
                targetAbis = new LinkedHashSet<>();
                targetAbis.add("arm64-v8a");
            } else {
                targetAbis = nativeAbis;
            }

            int soAdded = 0;
            for (String abi : targetAbis) {
                File soFile = new File(sigkillDir, abi + "_libSignatureKiller.so");
                if (!soFile.exists()) {
                    log("   ⚠️ No SignatureKiller .so for ABI: " + abi);
                    continue;
                }
                byte[] soData = readAllBytes(new FileInputStream(soFile));
                addZipEntry(zos, new ByteArrayInputStream(soData),
                           "lib/" + abi + "/libSignatureKiller.so");
                log("   🔒 SignatureKiller .so added for " + abi +
                    " (" + (soData.length / 1024) + " KB)");
                soAdded++;
            }

            // Embed original APK as assets/SignatureKiller/origin.apk
            // This is read by killOpen() at runtime — native open() calls are
            // redirected to this copy so integrity checks see the original APK.
            byte[] originData = readAllBytes(new FileInputStream(originalApk));
            ZipEntry originEntry = new ZipEntry("assets/SignatureKiller/origin.apk");
            originEntry.setMethod(ZipEntry.DEFLATED); // compress to save space
            zos.putNextEntry(originEntry);
            zos.write(originData);
            zos.closeEntry();
            log("   📦 Original APK embedded as origin.apk (" +
                (originData.length / 1024 / 1024) + " MB)");

            if (soAdded > 0) {
                log("   ✅ SignatureKiller embedded for " + soAdded + " ABI(s)");
            }
        } catch (Exception e) {
            log("   ⚠️ SignatureKiller embedding failed: " + e.getMessage());
        }
    }

    // ======================== STEP 5: SIGN APK (v1+v2+v3 via Google apksig) ========================

    private void signApk(File unsigned, File signed) throws Exception {
        KeyPairGenerator kpg = KeyPairGenerator.getInstance("RSA");
        kpg.initialize(2048);
        KeyPair kp = kpg.generateKeyPair();

        X500Principal sub = new X500Principal("CN=HSPatch, O=HSPatch");
        long now = System.currentTimeMillis();
        byte[] certDer = CertBuilder.buildSelfSigned(kp.getPublic(), kp.getPrivate(), sub,
            new Date(now), new Date(now + 365L * 24 * 60 * 60 * 1000 * 25));

        CertificateFactory cf = CertificateFactory.getInstance("X.509");
        X509Certificate cert = (X509Certificate)
            cf.generateCertificate(new ByteArrayInputStream(certDer));

        // Use Google's apksig library for v1+v2+v3 signing (Apache 2.0)
        com.android.apksig.ApkSigner.SignerConfig signerConfig =
            new com.android.apksig.ApkSigner.SignerConfig.Builder(
                "CERT", kp.getPrivate(), java.util.Collections.singletonList(cert)
            ).build();

        com.android.apksig.ApkSigner signer = new com.android.apksig.ApkSigner.Builder(
                java.util.Collections.singletonList(signerConfig))
            .setInputApk(unsigned)
            .setOutputApk(signed)
            .setV1SigningEnabled(true)   // JAR signing — all devices
            .setV2SigningEnabled(true)   // APK Sig Scheme v2 — Android 7.0+
            .setV3SigningEnabled(true)   // APK Sig Scheme v3 — Android 9.0+
            .setV4SigningEnabled(false)  // v4 needs .idsig file, skip for simplicity
            .setCreatedBy("HSPatcher")
            .build();

        signer.sign();
        log("   ✅ Signed with v1 + v2 + v3 signatures (all Android versions)");
    }

    // ======================== BINARY MANIFEST ========================

    private List<String> extractBinaryXmlStrings(byte[] data) {
        List<String> result = new ArrayList<>();
        if (data.length < 12) return result;
        int off = 8;
        if (off + 28 > data.length) return result;
        int ct = readShort(data, off);
        if (ct != 0x0001) return result;
        int sc = readInt(data, off + 8);
        int fl = readInt(data, off + 16);
        int ss = readInt(data, off + 20) + off + 8;
        boolean utf8 = (fl & (1 << 8)) != 0;
        if (sc > 50000) return result;

        int[] ofs = new int[sc];
        for (int i = 0; i < sc; i++) ofs[i] = readInt(data, off + 28 + i * 4);

        for (int i = 0; i < sc; i++) {
            int so = ss + ofs[i];
            if (so >= data.length) continue;
            try {
                if (utf8) {
                    int cc = data[so] & 0xFF;
                    if ((cc & 0x80) != 0) { cc = ((cc & 0x7F) << 8) | (data[so+1] & 0xFF); so++; }
                    so++;
                    int bc = data[so] & 0xFF;
                    if ((bc & 0x80) != 0) { bc = ((bc & 0x7F) << 8) | (data[so+1] & 0xFF); so++; }
                    so++;
                    if (so + bc <= data.length) result.add(new String(data, so, bc, "UTF-8"));
                } else {
                    int cc = readShort(data, so);
                    if ((cc & 0x8000) != 0) { cc = ((cc & 0x7FFF) << 16) | readShort(data, so+2); so += 4; }
                    else so += 2;
                    if (so + cc * 2 <= data.length) result.add(new String(data, so, cc * 2, "UTF-16LE"));
                }
            } catch (Exception e) { /* skip */ }
        }
        return result;
    }

    private int readShort(byte[] d, int o) { return (d[o]&0xFF) | ((d[o+1]&0xFF)<<8); }
    private int readInt(byte[] d, int o) {
        return (d[o]&0xFF) | ((d[o+1]&0xFF)<<8) | ((d[o+2]&0xFF)<<16) | ((d[o+3]&0xFF)<<24);
    }

    // ======================== UTILITIES ========================

    private boolean isPrintableAscii(String s) {
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            if (c < 0x20 || c > 0x7E) return false;
        }
        return true;
    }

    private void extractFileFromApk(File apk, String name, File dest) throws Exception {
        ZipFile z = new ZipFile(apk);
        ZipEntry e = z.getEntry(name);
        if (e != null) { dest.getParentFile().mkdirs(); copyStream(z.getInputStream(e), new FileOutputStream(dest)); }
        z.close();
    }

    private File findSmaliByType(File dir, String type) {
        File[] files = dir.listFiles();
        if (files == null) return null;
        for (File f : files) {
            if (f.isDirectory()) { File r = findSmaliByType(f, type); if (r != null) return r; }
            else if (f.getName().endsWith(".smali")) {
                try { BufferedReader br = new BufferedReader(new FileReader(f));
                    String l = br.readLine(); br.close();
                    if (l != null && l.contains(type)) return f;
                } catch (Exception e) { /* skip */ }
            }
        }
        return null;
    }

    private String relativePath(File base, File file) {
        String bp = base.getAbsolutePath().replace('\\', '/');
        String fp = file.getAbsolutePath().replace('\\', '/');
        return fp.startsWith(bp) ? fp.substring(bp.length() + 1) : file.getName();
    }

    private void deleteDir(File d) {
        if (d.isDirectory()) { File[] c = d.listFiles(); if (c != null) for (File f : c) deleteDir(f); }
        d.delete();
    }

    private void copyStream(InputStream is, OutputStream os) throws Exception { copyStream(is, os, true); }

    private void copyStream(InputStream is, OutputStream os, boolean close) throws Exception {
        byte[] buf = new byte[65536]; int len;
        while ((len = is.read(buf)) > 0) os.write(buf, 0, len);
        if (close) { is.close(); os.close(); }
    }

    private byte[] readAllBytes(InputStream is) throws Exception {
        ByteArrayOutputStream bos = new ByteArrayOutputStream();
        byte[] buf = new byte[8192]; int len;
        while ((len = is.read(buf)) > 0) bos.write(buf, 0, len);
        is.close();
        return bos.toByteArray();
    }

    private String readFileStr(File f) throws IOException {
        StringBuilder sb = new StringBuilder((int) f.length());
        BufferedReader br = new BufferedReader(new FileReader(f));
        char[] buf = new char[8192]; int len;
        while ((len = br.read(buf)) > 0) sb.append(buf, 0, len);
        br.close();
        return sb.toString();
    }

    private void writeFileStr(File f, String c) throws IOException {
        BufferedWriter bw = new BufferedWriter(new FileWriter(f));
        bw.write(c); bw.close();
    }

    private int countFiles(File dir, String ext) {
        int c = 0; File[] fs = dir.listFiles(); if (fs == null) return 0;
        for (File f : fs) { if (f.isDirectory()) c += countFiles(f, ext); else if (f.getName().endsWith(ext)) c++; }
        return c;
    }

    private void collectSmaliFiles(File dir, List<File> out) {
        File[] fs = dir.listFiles(); if (fs == null) return;
        for (File f : fs) { if (f.isDirectory()) collectSmaliFiles(f, out); else if (f.getName().endsWith(".smali")) out.add(f); }
    }

    private void log(String msg) {
        Log.d(TAG, msg);
        if (cb != null) cb.onLog(msg);
    }

    private void progress(int pct, String step) {
        Log.d(TAG, "[" + pct + "%] " + step);
        if (cb != null) cb.onProgress(pct, step);
    }
}
