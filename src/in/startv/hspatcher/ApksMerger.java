package in.startv.hspatcher;

import java.io.*;
import java.util.*;
import java.util.zip.*;

import com.reandroid.apk.APKLogger;
import com.reandroid.apk.ApkBundle;
import com.reandroid.apk.ApkModule;
import com.reandroid.app.AndroidManifest;
import com.reandroid.arsc.chunk.TableBlock;
import com.reandroid.arsc.chunk.xml.AndroidManifestBlock;
import com.reandroid.arsc.chunk.xml.ResXmlAttribute;
import com.reandroid.arsc.chunk.xml.ResXmlElement;
import com.reandroid.arsc.container.SpecTypePair;
import com.reandroid.arsc.model.ResourceEntry;
import com.reandroid.arsc.value.Entry;
import com.reandroid.arsc.value.ResValue;
import com.reandroid.arsc.value.ValueType;
import com.reandroid.archive.ZipEntryMap;

/**
 * ApksMerger — Merges split APKs (.apks/.xapk/.apkm) into a single APK.
 *
 * Uses REAndroid/ARSCLib (Apache 2.0 license) for the actual APK merge.
 * The split APK bundle is a ZIP archive containing multiple .apk files
 * (base.apk + config splits like config.arm64_v8a.apk, config.xxhdpi.apk, etc.)
 *
 * Merge pipeline:
 *   1. Extract all .apk files from the bundle ZIP
 *   2. Load them via ARSCLib's ApkBundle
 *   3. Merge all modules into one APK
 *   4. Clean the AndroidManifest (remove split-related attributes/metadata)
 *   5. Write the merged APK
 *
 * @see <a href="https://github.com/REAndroid/ARSCLib">REAndroid/ARSCLib</a>
 */
public class ApksMerger {

    /** Callback for progress/log reporting */
    public interface MergeCallback {
        void onLog(String msg);
        void onProgress(int pct, String step);
    }

    private final MergeCallback cb;

    public ApksMerger(MergeCallback cb) {
        this.cb = cb;
    }

    // ======================== PUBLIC API ========================

    /**
     * Check if a file is a split APK bundle (.apks, .xapk, .apkm) or a ZIP containing .apk files.
     * @param file the file to check
     * @return true if the file appears to be a split APK bundle
     */
    public static boolean isSplitApkBundle(File file) {
        String name = file.getName().toLowerCase(Locale.US);
        // Check extension first
        if (name.endsWith(".apks") || name.endsWith(".xapk") || name.endsWith(".apkm")) {
            return true;
        }
        // For .zip files, peek inside to see if it contains .apk files
        if (name.endsWith(".zip")) {
            return containsApkEntries(file);
        }
        // Even for .apk extension, check if it's actually a bundle (some tools rename)
        // Don't do this for .apk to avoid false positives on normal APKs
        return false;
    }

    /**
     * Check if a filename indicates a split APK bundle.
     * @param filename the file name (just name, not full path)
     * @return true if the extension suggests a split APK bundle
     */
    public static boolean isSplitApkByName(String filename) {
        if (filename == null) return false;
        String lower = filename.toLowerCase(Locale.US);
        return lower.endsWith(".apks") || lower.endsWith(".xapk")
            || lower.endsWith(".apkm");
    }

    /**
     * Merge a split APK bundle into a single APK file.
     *
     * @param bundleFile the .apks/.xapk/.apkm file (ZIP of APKs)
     * @param outputApk  where to write the merged single APK
     * @param workDir    temp directory for extraction (will be created/cleaned)
     * @throws Exception on any failure
     */
    public void merge(File bundleFile, File outputApk, File workDir) throws Exception {
        long startTime = System.currentTimeMillis();

        // Step 1: Extract split APKs from bundle
        log("📦 Extracting split APKs from bundle...");
        progress(5, "Extracting splits...");

        File extractDir = new File(workDir, "splits");
        if (extractDir.exists()) deleteDir(extractDir);
        extractDir.mkdirs();

        int splitCount = extractApksFromBundle(bundleFile, extractDir);
        if (splitCount == 0) {
            throw new IOException("No .apk files found inside the bundle: " + bundleFile.getName());
        }
        log("   Found " + splitCount + " split APK(s)");

        // List extracted splits
        File[] apkFiles = extractDir.listFiles((dir, name) ->
            name.toLowerCase(Locale.US).endsWith(".apk"));
        if (apkFiles != null) {
            for (File f : apkFiles) {
                log("   • " + f.getName() + " (" + (f.length() / 1024) + " KB)");
            }
        }

        // Step 2: Load splits via ARSCLib
        log("\n🔗 Loading split modules...");
        progress(20, "Loading modules...");

        ApkBundle bundle = new ApkBundle();
        bundle.setAPKLogger(new APKLogger() {
            @Override public void logMessage(String msg) { /* suppress verbose */ }
            @Override public void logError(String msg, Throwable t) { log("   ⚠️ " + msg); }
            @Override public void logVerbose(String msg) { /* suppress */ }
        });
        bundle.loadApkDirectory(extractDir);

        int moduleCount = bundle.countModules();
        log("   Loaded " + moduleCount + " module(s)");
        for (String name : bundle.listModuleNames()) {
            log("   • " + name);
        }

        // Step 3: Merge modules
        log("\n🔀 Merging split modules...");
        progress(40, "Merging modules...");

        ApkModule merged;
        try {
            merged = bundle.mergeModules();
        } catch (Exception e) {
            // Some bundles have incompatible versions; try force merge
            log("   ⚠️ Standard merge failed, trying force merge...");
            merged = bundle.mergeModules(false);
        }
        log("   ✅ Merge complete");

        // Step 4: Clean manifest
        log("\n🧹 Sanitizing AndroidManifest...");
        progress(60, "Cleaning manifest...");
        sanitizeManifest(merged);

        // Step 5: Write merged APK
        log("\n💾 Writing merged APK...");
        progress(80, "Writing APK...");
        merged.writeApk(outputApk);
        merged.close();
        bundle.close();

        long elapsed = System.currentTimeMillis() - startTime;
        long sizeMB = outputApk.length() / (1024 * 1024);
        log("   ✅ Merged APK: " + outputApk.getName() + " (" + sizeMB + " MB)");
        log("   ⏱ Merge took " + (elapsed / 1000) + "s");

        // Clean up extracted splits
        deleteDir(extractDir);
    }

    // ======================== EXTRACTION ========================

    /**
     * Extract all .apk entries from a ZIP bundle (APKS/XAPK/APKM).
     * Handles nested directories (some XAPK bundles put APKs in subdirectories).
     * Uses ZipFile (random access) instead of ZipInputStream to handle STORED entries
     * which are common in XAPK bundles from APKPure.
     *
     * @return number of APK files extracted
     */
    private int extractApksFromBundle(File bundleZip, File outDir) throws IOException {
        int count = 0;
        try (ZipFile zf = new ZipFile(bundleZip)) {
            Enumeration<? extends ZipEntry> entries = zf.entries();
            while (entries.hasMoreElements()) {
                ZipEntry entry = entries.nextElement();
                if (entry.isDirectory()) continue;
                String name = entry.getName();
                // Only extract .apk files
                if (!name.toLowerCase(Locale.US).endsWith(".apk")) {
                    // XAPK may contain manifest.json, icon.png, obb files, etc. — skip
                    continue;
                }
                // Flatten: strip directory paths, keep just the filename
                String safeName = name;
                if (safeName.contains("/")) {
                    safeName = safeName.substring(safeName.lastIndexOf('/') + 1);
                }
                if (safeName.contains("\\")) {
                    safeName = safeName.substring(safeName.lastIndexOf('\\') + 1);
                }
                // Sanitize filename
                safeName = safeName.replaceAll("[^a-zA-Z0-9._-]", "_");
                if (safeName.isEmpty()) safeName = "split_" + count + ".apk";

                File outFile = new File(outDir, safeName);
                // Prevent zip-slip
                if (!outFile.getCanonicalPath().startsWith(outDir.getCanonicalPath() + File.separator)) {
                    throw new IOException("Zip slip detected: " + name);
                }

                try (InputStream is = zf.getInputStream(entry);
                     FileOutputStream fos = new FileOutputStream(outFile)) {
                    byte[] buf = new byte[65536];
                    int len;
                    while ((len = is.read(buf)) > 0) {
                        fos.write(buf, 0, len);
                    }
                }
                count++;
            }
        }
        return count;
    }

    /**
     * Quick check: does this ZIP file contain any .apk entries?
     */
    private static boolean containsApkEntries(File file) {
        try (ZipInputStream zis = new ZipInputStream(
                new BufferedInputStream(new FileInputStream(file)))) {
            ZipEntry entry;
            while ((entry = zis.getNextEntry()) != null) {
                if (!entry.isDirectory() &&
                    entry.getName().toLowerCase(Locale.US).endsWith(".apk")) {
                    return true;
                }
            }
        } catch (Exception e) {
            // Not a valid ZIP or I/O error — not a bundle
        }
        return false;
    }

    // ======================== MANIFEST CLEANUP ========================

    /**
     * Remove split-related attributes and metadata from the AndroidManifest.
     * This is critical: if a non-split APK still contains split info,
     * Android will refuse to install it ("App not installed" error).
     *
     * Mirrors the cleanup logic from REAndroid/APKEditor and AntiSplit-M.
     */
    private void sanitizeManifest(ApkModule module) {
        if (!module.hasAndroidManifest()) {
            log("   ⚠️ No AndroidManifest found — skipping cleanup");
            return;
        }

        AndroidManifestBlock manifest = module.getAndroidManifest();
        ResXmlElement manifestElement = manifest.getManifestElement();
        int cleaned = 0;

        // Remove split-related attributes from <manifest> element by resource ID
        cleaned += removeAttrById(manifestElement, AndroidManifest.ID_requiredSplitTypes,
            "requiredSplitTypes");
        cleaned += removeAttrById(manifestElement, AndroidManifest.ID_splitTypes,
            "splitTypes");

        // Remove by name as well (some manifests use name-only attributes)
        cleaned += removeAttrByName(manifestElement, AndroidManifest.NAME_requiredSplitTypes);
        cleaned += removeAttrByName(manifestElement, AndroidManifest.NAME_splitTypes);
        cleaned += removeAttrByName(manifestElement, "split");

        // Remove isSplitRequired and extractNativeLibs from both <manifest> and <application>
        ResXmlElement application = manifest.getApplicationElement();
        if (application != null) {
            cleaned += removeAttrById(application, AndroidManifest.ID_isSplitRequired,
                "isSplitRequired");
            cleaned += removeAttrById(application, AndroidManifest.ID_extractNativeLibs,
                "extractNativeLibs");
            cleaned += removeAttrByName(application, AndroidManifest.NAME_isSplitRequired);
            cleaned += removeAttrByName(application, AndroidManifest.NAME_extractNativeLibs);

            // Remove isFeatureSplit from <manifest>
            cleaned += removeAttrById(manifestElement, AndroidManifest.ID_isFeatureSplit,
                "isFeatureSplit");

            // Remove split metadata elements from <application>
            cleaned += removeSplitMetadata(module, application);
        }

        cleaned += removeAttrById(manifestElement, AndroidManifest.ID_isSplitRequired,
            "isSplitRequired");
        cleaned += removeAttrById(manifestElement, AndroidManifest.ID_extractNativeLibs,
            "extractNativeLibs");

        manifest.refresh();
        log("   Cleaned " + cleaned + " split-related attribute(s)/element(s)");
    }

    /**
     * Remove split-related <meta-data> elements (like com.android.vending.splits,
     * com.android.vending.derived.apk.id, com.android.stamp.*, etc.)
     */
    private int removeSplitMetadata(ApkModule module, ResXmlElement application) {
        int removed = 0;
        List<ResXmlElement> toRemove = new ArrayList<>();

        Iterator<ResXmlElement> elements = application.getElements("meta-data");
        while (elements.hasNext()) {
            ResXmlElement meta = elements.next();
            ResXmlAttribute nameAttr = meta.searchAttributeByResourceId(AndroidManifest.ID_name);
            if (nameAttr == null) continue;

            String metaName = nameAttr.getValueAsString();
            if (metaName == null) continue;

            if (metaName.equals("com.android.vending.splits") ||
                metaName.equals("com.android.vending.splits.required") ||
                metaName.equals("com.android.vending.derived.apk.id") ||
                metaName.startsWith("com.android.stamp.") ||
                metaName.equals("com.android.dynamic.apk.fused.modules")) {

                // If the meta-data references a resource (splits table), clean it
                if (metaName.equals("com.android.vending.splits")) {
                    cleanSplitsResource(module, meta);
                }

                toRemove.add(meta);
                log("   Removed <meta-data> name=\"" + metaName + "\"");
                removed++;
            }
        }

        for (ResXmlElement el : toRemove) {
            application.removeElementsIf(e -> e == el);
        }

        return removed;
    }

    /**
     * If com.android.vending.splits references a resource table entry,
     * clean up the referenced splits from the resource table.
     */
    private void cleanSplitsResource(ApkModule module, ResXmlElement meta) {
        try {
            ResXmlAttribute valueAttr = meta.searchAttributeByResourceId(AndroidManifest.ID_value);
            if (valueAttr == null) {
                valueAttr = meta.searchAttributeByResourceId(AndroidManifest.ID_resource);
            }
            if (valueAttr == null || valueAttr.getValueType() != ValueType.REFERENCE) return;
            if (!module.hasTableBlock()) return;

            TableBlock tableBlock = module.getTableBlock();
            ResourceEntry resourceEntry = tableBlock.getResource(valueAttr.getData());
            if (resourceEntry == null) return;

            ZipEntryMap zipEntryMap = module.getZipEntryMap();
            for (Entry entry : resourceEntry) {
                if (entry == null) continue;
                ResValue resValue = entry.getResValue();
                if (resValue == null) continue;
                String path = resValue.getValueAsString();
                if (path != null) {
                    zipEntryMap.remove(path);
                }
                entry.setNull(true);
                SpecTypePair specTypePair = entry.getTypeBlock().getParentSpecTypePair();
                specTypePair.removeNullEntries(entry.getId());
            }
        } catch (Exception e) {
            // Non-critical — log and continue
            log("   ⚠️ Could not clean splits resource: " + e.getMessage());
        }
    }

    private int removeAttrById(ResXmlElement element, int resId, String logName) {
        if (element.removeAttributesWithId(resId)) {
            log("   Removed @" + logName + " (id=0x" + Integer.toHexString(resId) + ")");
            return 1;
        }
        return 0;
    }

    private int removeAttrByName(ResXmlElement element, String name) {
        if (element.removeAttributesWithName(name)) {
            return 1;
        }
        return 0;
    }

    // ======================== UTILITIES ========================

    private void deleteDir(File dir) {
        if (dir == null) return;
        if (dir.isDirectory()) {
            File[] children = dir.listFiles();
            if (children != null) {
                for (File c : children) deleteDir(c);
            }
        }
        dir.delete();
    }

    private void log(String msg) {
        if (cb != null) cb.onLog(msg);
    }

    private void progress(int pct, String step) {
        if (cb != null) cb.onProgress(pct, step);
    }
}
