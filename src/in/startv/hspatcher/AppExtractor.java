package in.startv.hspatcher;

import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.graphics.drawable.Drawable;
import android.util.Log;

import java.io.*;
import java.util.*;

/**
 * APK Extractor — extracts APK files from installed apps.
 * Inspired by nkalra0123/splitapkinstall (Apache 2.0) for the PackageManager approach.
 * Handles both single APK and split APK apps.
 */
public class AppExtractor {

    private static final String TAG = "HSPatcher";

    /** Info about an installed app */
    public static class AppInfo {
        public String packageName;
        public String label;
        public String version;
        public Drawable icon;
        public String sourceDir;         // base APK path
        public String[] splitSourceDirs; // split APK paths (null if not split)
        public long totalSize;
        public boolean isSplit;
        public boolean isSystem;
        public String patchVersion;

        public String getSizeStr() {
            if (totalSize > 1024 * 1024) return (totalSize / (1024 * 1024)) + " MB";
            return (totalSize / 1024) + " KB";
        }
    }

    /**
     * Get list of all user-installed apps (excluding system apps)
     * sorted by label.
     */
    public static List<AppInfo> getInstalledApps(Context ctx, boolean includeSystem) {
        return getInstalledApps(ctx, includeSystem, false);
    }

    /**
     * Get installed apps, optionally filtering to APKs previously patched by HSPatcher.
     */
    public static List<AppInfo> getInstalledApps(Context ctx, boolean includeSystem, boolean patchedOnly) {
        PackageManager pm = ctx.getPackageManager();
        List<PackageInfo> packages = pm.getInstalledPackages(0);
        List<AppInfo> result = new ArrayList<>();

        for (PackageInfo pi : packages) {
            ApplicationInfo ai = pi.applicationInfo;
            if (ai == null) continue;

            // Skip system apps unless requested
            boolean isSystem = (ai.flags & ApplicationInfo.FLAG_SYSTEM) != 0;
            if (isSystem && !includeSystem) continue;

            // Skip ourselves
            if (ai.packageName.equals(ctx.getPackageName())) continue;

            AppInfo info = new AppInfo();
            info.packageName = ai.packageName;
            info.label = ai.loadLabel(pm).toString();
            info.version = pi.versionName != null ? pi.versionName : "?";
            info.sourceDir = ai.publicSourceDir;
            info.splitSourceDirs = ai.splitPublicSourceDirs;
            info.isSplit = (ai.splitPublicSourceDirs != null && ai.splitPublicSourceDirs.length > 0);
            info.isSystem = isSystem;

            try {
                info.icon = ai.loadIcon(pm);
            } catch (Exception e) {
                // ignore
            }

            // Calculate total size
            info.totalSize = new File(ai.publicSourceDir).length();
            if (info.isSplit) {
                for (String split : ai.splitPublicSourceDirs) {
                    info.totalSize += new File(split).length();
                }
            }

            if (patchedOnly) {
                info.patchVersion = detectPatchVersion(ai.publicSourceDir);
                if (info.patchVersion == null) continue;
            }

            result.add(info);
        }

        // Sort by label (case-insensitive)
        Collections.sort(result, (a, b) -> a.label.compareToIgnoreCase(b.label));
        return result;
    }

    private static String detectPatchVersion(String sourceDir) {
        if (sourceDir == null || sourceDir.trim().isEmpty()) return null;
        try {
            return PatchEngine.isAlreadyPatched(new File(sourceDir));
        } catch (Throwable t) {
            Log.w(TAG, "Patched-app detection failed for " + sourceDir + ": " + t.getMessage());
            return null;
        }
    }

    /**
     * Extract an app's APK(s) to a destination directory.
     * For single APK apps, copies the base APK.
     * For split APK apps, copies base + all splits.
     *
     * @return the base APK file (for single APK apps) or a merged single APK
     */
    public static File extractApp(AppInfo app, File destDir, ExtractCallback cb) throws IOException {
        destDir.mkdirs();

        if (!app.isSplit) {
            // Single APK — just copy
            String safeName = app.packageName.replace('.', '_') + ".apk";
            File dest = new File(destDir, safeName);
            if (cb != null) cb.onLog("📦 Extracting: " + app.label + " (single APK)");
            copyFile(new File(app.sourceDir), dest);
            if (cb != null) cb.onLog("   ✅ Extracted: " + safeName + " (" + app.getSizeStr() + ")");
            return dest;
        } else {
            // Split APK app — copy base + all splits into a temp dir
            // Then caller can merge via ApksMerger or just use base
            if (cb != null) cb.onLog("📦 Extracting: " + app.label + " (split APK, " +
                (app.splitSourceDirs.length + 1) + " parts)");

            File splitDir = new File(destDir, "splits");
            splitDir.mkdirs();

            // Copy base APK
            File baseDest = new File(splitDir, "base.apk");
            copyFile(new File(app.sourceDir), baseDest);
            if (cb != null) cb.onLog("   base.apk (" + (baseDest.length() / 1024) + " KB)");

            // Copy split APKs
            for (int i = 0; i < app.splitSourceDirs.length; i++) {
                File src = new File(app.splitSourceDirs[i]);
                String splitName = src.getName();
                if (!splitName.endsWith(".apk")) splitName = "split_" + i + ".apk";
                File splitDest = new File(splitDir, splitName);
                copyFile(src, splitDest);
                if (cb != null) cb.onLog("   " + splitName + " (" + (splitDest.length() / 1024) + " KB)");
            }

            if (cb != null) cb.onLog("   ✅ Extracted " + (app.splitSourceDirs.length + 1) + " APKs");
            return splitDir; // Return the directory containing all splits
        }
    }

    private static void copyFile(File src, File dst) throws IOException {
        try (FileInputStream fis = new FileInputStream(src);
             FileOutputStream fos = new FileOutputStream(dst)) {
            byte[] buf = new byte[65536];
            int len;
            while ((len = fis.read(buf)) > 0) {
                fos.write(buf, 0, len);
            }
        }
    }

    public interface ExtractCallback {
        void onLog(String msg);
    }
}
