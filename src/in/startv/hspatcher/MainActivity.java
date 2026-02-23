package in.startv.hspatcher;

import android.Manifest;
import android.app.Activity;
import android.content.Intent;
import android.util.Log;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.os.Looper;
import android.provider.Settings;
import android.view.View;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.Toast;

import java.io.*;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

public class MainActivity extends Activity {

    private static final int PICK_APK = 1001;
    private static final int STORAGE_PERM = 1002;
    private static final int MANAGE_STORAGE = 1003;
    private static final int INSTALL_REQUEST = 1004;
    private static final int EXTRACT_APP = 1005;
    private static final int INSTALL_PERM = 1006;
    private static final int UNINSTALL_REQUEST = 1007;

    private Button btnSelect, btnPatch, btnInstall, btnExtract;
    private TextView logOutput, apkName, apkSize, progressText;
    private ScrollView logScroll;
    private ProgressBar progressBar;
    private LinearLayout apkInfoPanel;

    private File selectedApk;
    private File patchedApk;
    private Handler mainHandler;
    private boolean isPatching = false;
    private boolean isSplitBundle = false;  // true if user selected .apks/.xapk/.apkm
    private String originalFileName = "";   // original filename before copy
    private boolean pendingInstallAfterUninstall = false;
    private String targetPackageName = null;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        mainHandler = new Handler(Looper.getMainLooper());

        btnSelect = findViewById(R.id.btn_select);
        btnPatch = findViewById(R.id.btn_patch);
        btnInstall = findViewById(R.id.btn_install);
        btnExtract = findViewById(R.id.btn_extract);
        logOutput = findViewById(R.id.log_output);
        apkName = findViewById(R.id.apk_name);
        apkSize = findViewById(R.id.apk_size);
        progressText = findViewById(R.id.progress_text);
        logScroll = findViewById(R.id.log_scroll);
        progressBar = findViewById(R.id.progress_bar);
        apkInfoPanel = findViewById(R.id.apk_info_panel);

        btnSelect.setOnClickListener(v -> onSelectClick());
        btnPatch.setOnClickListener(v -> onPatchClick());
        btnInstall.setOnClickListener(v -> onInstallClick());
        btnExtract.setOnClickListener(v -> onExtractClick());

        requestStoragePermission();

        // Auto-load APK if passed via intent (for testing: adb shell am start -n ... --es apk_path /sdcard/...)
        String intentPath = getIntent().getStringExtra("apk_path");
        if (intentPath != null && !intentPath.isEmpty()) {
            File f = new File(intentPath);
            if (f.exists()) {
                log("📂 Auto-loading APK from intent: " + intentPath);
                autoLoadApk(f);
                // Auto-patch if requested
                if (getIntent().getBooleanExtra("auto_patch", false)) {
                    mainHandler.postDelayed(() -> onPatchClick(), 2000);
                }
            }
        }
    }

    private int findId(String name) {
        return getResources().getIdentifier(name, "id", getPackageName());
    }

    // ======================== PERMISSIONS ========================

    private void requestStoragePermission() {
        if (Build.VERSION.SDK_INT >= 30) {
            if (!Environment.isExternalStorageManager()) {
                try {
                    Intent intent = new Intent(Settings.ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION);
                    intent.setData(Uri.parse("package:" + getPackageName()));
                    startActivityForResult(intent, MANAGE_STORAGE);
                } catch (Exception e) {
                    Intent intent = new Intent(Settings.ACTION_MANAGE_ALL_FILES_ACCESS_PERMISSION);
                    startActivityForResult(intent, MANAGE_STORAGE);
                }
            }
        } else {
            if (checkSelfPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE)
                    != PackageManager.PERMISSION_GRANTED) {
                requestPermissions(new String[]{
                    Manifest.permission.READ_EXTERNAL_STORAGE,
                    Manifest.permission.WRITE_EXTERNAL_STORAGE
                }, STORAGE_PERM);
            }
        }
    }

    // ======================== FILE PICKER ========================

    private void onExtractClick() {
        if (isPatching) return;
        Intent intent = new Intent(this, AppListActivity.class);
        startActivityForResult(intent, EXTRACT_APP);
    }

    private void autoLoadApk(File f) {
        logClear();
        log("📂 Loading file from path...");
        new Thread(() -> {
            try {
                File workDir = new File(getFilesDir(), "hspatch_work");
                if (workDir.exists()) deleteDir(workDir);
                workDir.mkdirs();

                originalFileName = f.getName();
                isSplitBundle = ApksMerger.isSplitApkByName(f.getName())
                    || ApksMerger.isSplitApkBundle(f);
                String destName = isSplitBundle ? "input_bundle.zip" : "input.apk";

                File dest = new File(workDir, destName);
                copyFile(f, dest);
                selectedApk = dest;
                long total = f.length();
                long sizeMB = total / (1024 * 1024);
                String fName = f.getName();
                String fSize = sizeMB + " MB (" + total + " bytes)";
                final boolean isBundle = isSplitBundle;
                mainHandler.post(() -> {
                    apkInfoPanel.setVisibility(View.VISIBLE);
                    apkName.setText(fName + (isBundle ? " [SPLIT BUNDLE]" : ""));
                    apkSize.setText(fSize);
                    btnPatch.setEnabled(true);
                    btnInstall.setVisibility(View.GONE);
                });
                if (isBundle) {
                    log("✅ Split APK bundle loaded: " + fName + " (" + fSize + ")");
                    log("📦 Will merge splits → single APK → then patch.");
                } else {
                    log("✅ APK loaded: " + fName + " (" + fSize + ")");
                }
                log("Ready to patch. Press ⚡ PATCH to begin.");
            } catch (Exception e) {
                log("❌ Error loading file: " + e.getMessage());
            }
        }).start();
    }

    private void onSelectClick() {
        if (isPatching) return;
        Intent intent = new Intent(Intent.ACTION_GET_CONTENT);
        // Accept APK and split APK bundles (APKS/XAPK/APKM/ZIP)
        intent.setType("*/*");
        String[] mimeTypes = {
            "application/vnd.android.package-archive",   // .apk
            "application/zip",                           // .apks/.xapk/.apkm (ZIP-based)
            "application/x-zip-compressed",              // alternate ZIP mime
            "application/octet-stream"                   // fallback for unknown extensions
        };
        intent.putExtra(Intent.EXTRA_MIME_TYPES, mimeTypes);
        intent.addCategory(Intent.CATEGORY_OPENABLE);
        try {
            startActivityForResult(Intent.createChooser(intent,
                "Select APK or Split Bundle (.apk/.apks/.xapk/.apkm)"), PICK_APK);
        } catch (Exception e) {
            // Fallback: any file
            intent.setType("*/*");
            startActivityForResult(intent, PICK_APK);
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        // Fallback: detect uninstall completion when onActivityResult doesn't fire
        if (pendingInstallAfterUninstall && targetPackageName != null) {
            mainHandler.postDelayed(() -> {
                if (!pendingInstallAfterUninstall) return; // already handled by onActivityResult
                try {
                    getPackageManager().getPackageInfo(targetPackageName, 0);
                    // Still installed — do nothing, wait for user action
                } catch (PackageManager.NameNotFoundException e) {
                    pendingInstallAfterUninstall = false;
                    log("✅ Previous version uninstalled (detected via onResume)");
                    doInstall();
                }
            }, 500);
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == PICK_APK && resultCode == RESULT_OK && data != null) {
            Uri uri = data.getData();
            if (uri != null) {
                copyApkFromUri(uri);
            }
        } else if (requestCode == EXTRACT_APP && resultCode == RESULT_OK && data != null) {
            String path = data.getStringExtra(AppListActivity.EXTRA_APK_PATH);
            boolean isSplit = data.getBooleanExtra(AppListActivity.EXTRA_IS_SPLIT, false);
            String label = data.getStringExtra(AppListActivity.EXTRA_APP_LABEL);
            if (path != null) {
                loadExtractedApp(new File(path), isSplit, label);
            }
        } else if (requestCode == INSTALL_PERM) {
            if (Build.VERSION.SDK_INT >= 26 && getPackageManager().canRequestPackageInstalls()) {
                log("✅ Install from unknown sources enabled");
                checkSignatureAndInstall();
            } else {
                log("❌ Install permission was not granted");
                Toast.makeText(this, "Install permission is required to install APKs",
                    Toast.LENGTH_LONG).show();
            }
        } else if (requestCode == UNINSTALL_REQUEST) {
            if (pendingInstallAfterUninstall) {
                pendingInstallAfterUninstall = false;
                boolean stillInstalled = false;
                if (targetPackageName != null) {
                    try {
                        getPackageManager().getPackageInfo(targetPackageName, 0);
                        stillInstalled = true;
                    } catch (PackageManager.NameNotFoundException e) {
                        stillInstalled = false;
                    }
                }
                if (!stillInstalled) {
                    log("✅ Previous version uninstalled — installing patched APK...");
                    doInstall();
                } else {
                    log("⚠️ App is still installed — uninstall was cancelled or failed");
                    log("💡 Tip: Uninstall the existing app manually, then tap Install");
                }
            }
        } else if (requestCode == INSTALL_REQUEST) {
            if (resultCode == RESULT_OK) {
                log("✅ APK installation completed successfully!");
            } else if (resultCode == RESULT_CANCELED) {
                log("⚠️ Installation was cancelled or failed");
                log("📁 APK is available at: " + (patchedApk != null ? patchedApk.getAbsolutePath() : "unknown"));
            } else {
                log("⚠️ Install result code: " + resultCode);
            }
        }
    }

    private void loadExtractedApp(File extracted, boolean isSplit, String label) {
        logClear();
        log("📱 Loading extracted app: " + label);

        new Thread(() -> {
            try {
                File workDir = new File(getFilesDir(), "hspatch_work");
                if (workDir.exists()) deleteDir(workDir);
                workDir.mkdirs();

                if (isSplit) {
                    // extracted is a directory containing base.apk + splits
                    // Copy the whole splits dir
                    File splitDir = new File(workDir, "splits");
                    splitDir.mkdirs();
                    File[] apks = extracted.listFiles();
                    if (apks == null) throw new IOException("No APK files found in extracted splits");
                    long total = 0;
                    for (File apk : apks) {
                        copyFile(apk, new File(splitDir, apk.getName()));
                        total += apk.length();
                    }

                    // Create a zip bundle from the splits so ApksMerger can handle it
                    File bundleZip = new File(workDir, "input_bundle.zip");
                    java.util.zip.ZipOutputStream zos = new java.util.zip.ZipOutputStream(new FileOutputStream(bundleZip));
                    for (File apk : apks) {
                        zos.putNextEntry(new java.util.zip.ZipEntry(apk.getName()));
                        InputStream in = new FileInputStream(apk);
                        byte[] buf = new byte[65536];
                        int len;
                        while ((len = in.read(buf)) > 0) zos.write(buf, 0, len);
                        in.close();
                        zos.closeEntry();
                    }
                    zos.close();

                    selectedApk = bundleZip;
                    isSplitBundle = true;
                    originalFileName = label + "_splits.apks";
                    long sizeMB = total / (1024 * 1024);
                    String fSize = sizeMB + " MB (" + total + " bytes)";
                    int apkCount = apks.length;
                    mainHandler.post(() -> {
                        apkInfoPanel.setVisibility(View.VISIBLE);
                        apkName.setText(label + " [SPLIT, " + apkCount + " APKs]");
                        apkSize.setText(fSize);
                        btnPatch.setEnabled(true);
                        btnInstall.setVisibility(View.GONE);
                    });
                    log("✅ Split APK bundle loaded: " + label + " (" + apkCount + " splits, " + fSize + ")");
                    log("📦 Will merge splits → single APK → then patch.");
                } else {
                    // Single APK — just copy it
                    File dest = new File(workDir, "input.apk");
                    copyFile(extracted, dest);
                    selectedApk = dest;
                    isSplitBundle = false;
                    originalFileName = label + ".apk";
                    long total = dest.length();
                    long sizeMB = total / (1024 * 1024);
                    String fSize = sizeMB + " MB (" + total + " bytes)";
                    mainHandler.post(() -> {
                        apkInfoPanel.setVisibility(View.VISIBLE);
                        apkName.setText(label);
                        apkSize.setText(fSize);
                        btnPatch.setEnabled(true);
                        btnInstall.setVisibility(View.GONE);
                    });
                    log("✅ APK loaded: " + label + " (" + fSize + ")");
                }
                log("Ready to patch. Press ⚡ PATCH to begin.");
            } catch (Exception e) {
                log("❌ Error loading extracted app: " + e.getMessage());
            }
        }).start();
    }

    private void copyApkFromUri(Uri uri) {
        logClear();
        log("📂 Copying selected file...");

        new Thread(() -> {
            try {
                File workDir = new File(getFilesDir(), "hspatch_work");
                if (workDir.exists()) deleteDir(workDir);
                workDir.mkdirs();

                // Determine original filename
                String name = uri.getLastPathSegment();
                if (name == null) name = "unknown.apk";
                if (name.contains("/")) name = name.substring(name.lastIndexOf('/') + 1);
                if (name.contains(":")) name = name.substring(name.lastIndexOf(':') + 1);
                originalFileName = name;

                // Determine if this is a split APK bundle by filename
                isSplitBundle = ApksMerger.isSplitApkByName(name);
                String destName = isSplitBundle ? "input_bundle.zip" : "input.apk";
                File dest = new File(workDir, destName);

                InputStream is = getContentResolver().openInputStream(uri);
                FileOutputStream fos = new FileOutputStream(dest);
                byte[] buf = new byte[65536];
                int len;
                long total = 0;
                while ((len = is.read(buf)) > 0) {
                    fos.write(buf, 0, len);
                    total += len;
                }
                fos.close();
                is.close();

                // If not detected by name, check file contents (ZIP with APKs inside)
                if (!isSplitBundle && !name.toLowerCase().endsWith(".apk")) {
                    isSplitBundle = ApksMerger.isSplitApkBundle(dest);
                }

                selectedApk = dest;
                long sizeMB = total / (1024 * 1024);
                final String fName = name;
                final String fSize = sizeMB + " MB (" + total + " bytes)";
                final boolean isBundle = isSplitBundle;
                mainHandler.post(() -> {
                    apkInfoPanel.setVisibility(View.VISIBLE);
                    apkName.setText(fName + (isBundle ? " [SPLIT BUNDLE]" : ""));
                    apkSize.setText(fSize);
                    btnPatch.setEnabled(true);
                    btnInstall.setVisibility(View.GONE);
                });
                if (isBundle) {
                    log("✅ Split APK bundle loaded: " + fName + " (" + fSize + ")");
                    log("📦 Will merge splits → single APK → then patch.");
                } else {
                    log("✅ APK loaded: " + fName + " (" + fSize + ")");
                }
                log("Ready to patch. Press ⚡ PATCH to begin.");

            } catch (Exception e) {
                log("❌ Error loading file: " + e.getMessage());
            }
        }).start();
    }

    // ======================== PATCH ========================

    private void onPatchClick() {
        if (isPatching || selectedApk == null) return;
        isPatching = true;
        btnPatch.setEnabled(false);
        btnSelect.setEnabled(false);
        btnInstall.setVisibility(View.GONE);
        progressBar.setVisibility(View.VISIBLE);
        progressBar.setProgress(0);
        progressText.setVisibility(View.VISIBLE);
        logClear();

        log("⚡ HSPatcher v3.1 — Starting one-click patch");
        log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

        new Thread(() -> {
            try {
                File workDir = new File(getFilesDir(), "hspatch_work");

                // ========= APKS MERGE STEP (if split bundle) =========
                File apkToProcess = selectedApk;
                if (isSplitBundle) {
                    log("\n🔀 SPLIT BUNDLE DETECTED — Merging first...");
                    log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
                    File mergedApk = new File(workDir, "merged.apk");
                    File mergeWork = new File(workDir, "merge_tmp");
                    mergeWork.mkdirs();

                    ApksMerger merger = new ApksMerger(new ApksMerger.MergeCallback() {
                        @Override
                        public void onLog(String msg) { log(msg); }
                        @Override
                        public void onProgress(int pct, String step) {
                            // Map merge progress 0-100 to overall 2-15
                            updateProgress(2 + (pct * 13 / 100), "Merge: " + step);
                        }
                    });
                    merger.merge(selectedApk, mergedApk, mergeWork);
                    apkToProcess = mergedApk;

                    // Update selectedApk reference so downstream uses merged APK
                    selectedApk = mergedApk;
                    log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
                    log("✅ Merge complete — proceeding to patch\n");
                }

                // Extract bundled extra.zip from assets
                updateProgress(16, "Extracting HSPatch modules...");
                File extraZip = new File(workDir, "extra.zip");
                extractAsset("extra.zip", extraZip);
                log("📦 Extracted HSPatch module pack");

                // Extract Frida gadgets zip (optional — may not be bundled)
                File fridaZip = null;
                try {
                    fridaZip = new File(workDir, "frida_gadgets.zip");
                    extractAsset("frida_gadgets.zip", fridaZip);
                    log("🔧 Extracted Frida gadget pack (" +
                        (fridaZip.length() / 1024 / 1024) + " MB)");
                } catch (Exception ex) {
                    fridaZip = null;
                    log("ℹ️ No Frida gadgets bundled (optional)");
                }

                // Extract SignatureKiller native libs (optional)
                File sigkillDir = null;
                try {
                    sigkillDir = new File(workDir, "sigkill");
                    sigkillDir.mkdirs();
                    String[] sigkillFiles = {"arm64-v8a_libSignatureKiller.so",
                                             "armeabi-v7a_libSignatureKiller.so"};
                    int extracted = 0;
                    for (String name : sigkillFiles) {
                        try {
                            File dest = new File(sigkillDir, name);
                            extractAsset("sigkill/" + name, dest);
                            extracted++;
                        } catch (Exception ignored) {}
                    }
                    if (extracted > 0) {
                        log("🔒 Extracted SignatureKiller libs (" + extracted + " ABIs)");
                    } else {
                        sigkillDir = null;
                        log("ℹ️ No SignatureKiller libs bundled (optional)");
                    }
                } catch (Exception ex) {
                    sigkillDir = null;
                }

                // Create the patch engine and run
                PatchEngine engine = new PatchEngine(
                    apkToProcess,
                    extraZip,
                    fridaZip,
                    sigkillDir,
                    workDir,
                    new PatchEngine.Callback() {
                        @Override
                        public void onLog(String msg) { log(msg); }
                        @Override
                        public void onProgress(int pct, String step) { updateProgress(pct, step); }
                    }
                );

                File result = engine.patch();

                // Keep patchedApk pointing to the internal file (app's private storage)
                // The FileProvider can serve this to the package installer.
                // Also copy to a stable internal location for install.
                File installApk = new File(getFilesDir(), "patched_output.apk");
                copyFile(result, installApk);
                patchedApk = installApk;

                // Also copy to Downloads for manual access / sharing
                File downloads = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS);
                String timestamp = new SimpleDateFormat("HHmmss", Locale.US).format(new Date());
                File outputFile = new File(downloads, "HSPatched_" + timestamp + ".apk");
                try {
                    copyFile(result, outputFile);
                    log("📁 Also saved to: " + outputFile.getAbsolutePath());
                } catch (Exception ex) {
                    log("⚠️ Could not copy to Downloads: " + ex.getMessage());
                }

                updateProgress(100, "Done!");
                log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
                log("✅ PATCHED APK: " + outputFile.getName());
                log("📁 Location: " + outputFile.getAbsolutePath());
                log("📏 Size: " + (outputFile.length() / 1024 / 1024) + " MB");

                mainHandler.post(() -> {
                    btnInstall.setVisibility(View.VISIBLE);
                    isPatching = false;
                    btnSelect.setEnabled(true);
                    btnPatch.setEnabled(true);
                });

            } catch (Throwable e) {
                log("❌ FATAL: " + e.getClass().getName() + ": " + e.getMessage());
                for (StackTraceElement st : e.getStackTrace()) {
                    log("   " + st.toString());
                }
                mainHandler.post(() -> {
                    isPatching = false;
                    btnSelect.setEnabled(true);
                    btnPatch.setEnabled(true);
                });
            }
        }).start();
    }

    // ======================== INSTALL ========================

    private void onInstallClick() {
        if (patchedApk == null || !patchedApk.exists()) {
            Toast.makeText(this, "No patched APK found", Toast.LENGTH_SHORT).show();
            return;
        }

        // Check install from unknown sources permission (Android 8+)
        if (Build.VERSION.SDK_INT >= 26) {
            if (!getPackageManager().canRequestPackageInstalls()) {
                log("⚠️ Install from unknown sources not enabled for HSPatcher");
                log("↪ Opening settings to grant permission...");
                try {
                    Intent intent = new Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES);
                    intent.setData(Uri.parse("package:" + getPackageName()));
                    startActivityForResult(intent, INSTALL_PERM);
                } catch (Exception e) {
                    log("❌ Could not open install settings: " + e.getMessage());
                }
                return;
            }
        }

        checkSignatureAndInstall();
    }

    private void checkSignatureAndInstall() {
        log("🔍 Checking APK signatures...");
        new Thread(() -> {
            try {
                android.content.pm.PackageManager pm = getPackageManager();

                // Read package info from patched APK
                android.content.pm.PackageInfo patchedInfo = pm.getPackageArchiveInfo(
                    patchedApk.getAbsolutePath(),
                    PackageManager.GET_SIGNATURES);

                if (patchedInfo == null || patchedInfo.packageName == null) {
                    log("⚠️ Could not read package info from APK");
                    mainHandler.post(this::doInstall);
                    return;
                }

                targetPackageName = patchedInfo.packageName;
                log("📦 Package: " + targetPackageName);
                log("📦 Version: " + patchedInfo.versionName
                    + " (" + patchedInfo.versionCode + ")");

                // Check if app is already installed
                android.content.pm.PackageInfo installedInfo;
                try {
                    installedInfo = pm.getPackageInfo(targetPackageName,
                        PackageManager.GET_SIGNATURES);
                } catch (PackageManager.NameNotFoundException e) {
                    log("ℹ️ App not currently installed — fresh install");
                    mainHandler.post(this::doInstall);
                    return;
                }

                // Compare signatures
                android.content.pm.Signature[] instSigs = installedInfo.signatures;
                android.content.pm.Signature[] patchSigs = patchedInfo.signatures;

                boolean sigMatch = false;
                if (instSigs != null && patchSigs != null
                        && instSigs.length > 0 && patchSigs.length > 0) {
                    sigMatch = instSigs[0].toCharsString().equals(
                        patchSigs[0].toCharsString());
                }

                if (sigMatch) {
                    log("✅ Signature matches installed version — update install");
                    mainHandler.post(this::doInstall);
                } else {
                    // Signature mismatch
                    String instHash = (instSigs != null && instSigs.length > 0)
                        ? sigHash(instSigs[0].toByteArray()) : "none";
                    String patchHash = (patchSigs != null && patchSigs.length > 0)
                        ? sigHash(patchSigs[0].toByteArray()) : "none";

                    log("⚠️ SIGNATURE MISMATCH DETECTED");
                    log("   Installed sig: " + instHash);
                    log("   Patched sig:   " + patchHash);

                    final String instVer = installedInfo.versionName != null
                        ? installedInfo.versionName : "?";
                    final String patchVer = patchedInfo.versionName != null
                        ? patchedInfo.versionName : "?";

                    mainHandler.post(() -> showSignatureMismatchDialog(instVer, patchVer));
                }
            } catch (Exception e) {
                log("⚠️ Signature check error: " + e.getMessage());
                mainHandler.post(this::doInstall);
            }
        }).start();
    }

    private void showSignatureMismatchDialog(String installedVer, String patchedVer) {
        new android.app.AlertDialog.Builder(this)
            .setTitle("⚠️ Signature Mismatch")
            .setMessage(
                "The installed \"" + targetPackageName + "\" has a different signing key " +
                "than the patched APK.\n\n" +
                "Installed version: " + installedVer + "\n" +
                "Patched version: " + patchedVer + "\n\n" +
                "You must uninstall the existing app before installing the patched version. " +
                "This will remove all app data.\n\n" +
                "What would you like to do?")
            .setPositiveButton("Uninstall & Install", (d, w) -> {
                pendingInstallAfterUninstall = true;
                // Try ADB shell uninstall first (works without user interaction if we have shell)
                log("🗑️ Attempting adb shell uninstall of " + targetPackageName + "...");
                if (tryAdbUninstall(targetPackageName)) {
                    return; // adb uninstall succeeded, will auto-install
                }
                // Fallback: standard UI uninstall
                log("↪ Falling back to standard uninstall UI...");
                try {
                    // Preferred: ACTION_UNINSTALL_PACKAGE with result callback
                    Intent uninstall = new Intent(Intent.ACTION_UNINSTALL_PACKAGE);
                    uninstall.setData(Uri.parse("package:" + targetPackageName));
                    uninstall.putExtra(Intent.EXTRA_RETURN_RESULT, true);
                    startActivityForResult(uninstall, UNINSTALL_REQUEST);
                } catch (Exception e) {
                    // Fallback: ACTION_DELETE (older devices)
                    log("↪ Fallback to ACTION_DELETE...");
                    Intent uninstall2 = new Intent(Intent.ACTION_DELETE);
                    uninstall2.setData(Uri.parse("package:" + targetPackageName));
                    startActivityForResult(uninstall2, UNINSTALL_REQUEST);
                }
            })
            .setNeutralButton("Try Anyway", (d, w) -> {
                log("↪ Attempting install despite signature mismatch...");
                doInstall();
            })
            .setNegativeButton("Cancel", (d, w) -> log("❌ Install cancelled by user"))
            .setCancelable(false)
            .show();
    }

    private void doInstall() {
        log("📲 Installing patched APK...");
        log("   File: " + patchedApk.getAbsolutePath());
        log("   Size: " + patchedApk.length() + " bytes");
        log("   Exists: " + patchedApk.exists());
        log("   Readable: " + patchedApk.canRead());

        // Build content URI for Android 7+
        Uri apkUri;
        if (Build.VERSION.SDK_INT >= 24) {
            apkUri = HspFileProvider.getUriForFile(this, patchedApk);
        } else {
            apkUri = Uri.fromFile(patchedApk);
        }
        log("   URI: " + apkUri);

        // Try Method 1: ACTION_INSTALL_PACKAGE (most explicit for APK installation)
        try {
            log("↪ Method 1: ACTION_INSTALL_PACKAGE...");
            Intent intent = new Intent(Intent.ACTION_INSTALL_PACKAGE);
            intent.setData(apkUri);
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
            intent.putExtra(Intent.EXTRA_NOT_UNKNOWN_SOURCE, false);
            intent.putExtra(Intent.EXTRA_RETURN_RESULT, true);
            startActivityForResult(intent, INSTALL_REQUEST);
            log("✅ Install dialog launched — please confirm installation");
            return;
        } catch (Exception e) {
            log("⚠️ Method 1 failed: " + e.getMessage());
        }

        // Try Method 2: ACTION_VIEW with MIME type
        try {
            log("↪ Method 2: ACTION_VIEW...");
            Intent intent = new Intent(Intent.ACTION_VIEW);
            intent.setDataAndType(apkUri, "application/vnd.android.package-archive");
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            startActivity(intent);
            log("✅ Install dialog launched — please confirm installation");
            return;
        } catch (Exception e) {
            log("⚠️ Method 2 failed: " + e.getMessage());
        }

        // Try Method 3: PackageInstaller Session API
        log("↪ Method 3: PackageInstaller Session...");
        doInstallViaSession();
    }

    private void doInstallViaSession() {
        try {
            android.content.pm.PackageInstaller installer = getPackageManager().getPackageInstaller();
            android.content.pm.PackageInstaller.SessionParams params =
                new android.content.pm.PackageInstaller.SessionParams(
                    android.content.pm.PackageInstaller.SessionParams.MODE_FULL_INSTALL);
            params.setSize(patchedApk.length());

            int sessionId = installer.createSession(params);
            android.content.pm.PackageInstaller.Session session = installer.openSession(sessionId);

            log("   Writing APK to session " + sessionId + "...");
            InputStream apkIn = new java.io.FileInputStream(patchedApk);
            java.io.OutputStream sessionOut = session.openWrite("patched.apk", 0, patchedApk.length());
            byte[] buf = new byte[65536];
            int len;
            while ((len = apkIn.read(buf)) > 0) sessionOut.write(buf, 0, len);
            session.fsync(sessionOut);
            sessionOut.close();
            apkIn.close();

            // Use BroadcastReceiver for session callback (required on Android 14+)
            Intent callbackIntent = new Intent("in.startv.hspatcher.INSTALL_STATUS");
            callbackIntent.setPackage(getPackageName());
            android.app.PendingIntent pi = android.app.PendingIntent.getBroadcast(
                this, sessionId, callbackIntent,
                android.app.PendingIntent.FLAG_UPDATE_CURRENT
                    | android.app.PendingIntent.FLAG_MUTABLE);
            session.commit(pi.getIntentSender());
            log("📲 Session install triggered — please confirm installation");
        } catch (Exception e) {
            log("❌ All install methods failed: " + e.getMessage());
            for (StackTraceElement st : e.getStackTrace()) {
                log("   " + st.toString());
            }
            log("📁 Install manually from: " + patchedApk.getAbsolutePath());
            Toast.makeText(this,
                "Install manually: " + patchedApk.getAbsolutePath(),
                Toast.LENGTH_LONG).show();
        }
    }

    /**
     * Try to uninstall via 'pm uninstall' shell command.
     * Works when running via adb or with shell permissions.
     * Returns true if uninstall succeeded.
     */
    private boolean tryAdbUninstall(String packageName) {
        try {
            Process p = Runtime.getRuntime().exec(new String[]{
                "pm", "uninstall", packageName
            });
            int exitCode = p.waitFor();
            InputStream is = p.getInputStream();
            byte[] buf = new byte[1024];
            int len = is.read(buf);
            String output = len > 0 ? new String(buf, 0, len).trim() : "";
            is.close();

            if (exitCode == 0 && output.contains("Success")) {
                log("✅ Uninstalled via pm command: " + packageName);
                pendingInstallAfterUninstall = false;
                mainHandler.postDelayed(this::doInstall, 500);
                return true;
            } else {
                log("   pm uninstall returned: " + output + " (exit=" + exitCode + ")");
                return false;
            }
        } catch (Exception e) {
            log("   pm uninstall not available: " + e.getMessage());
            return false;
        }
    }

    private String sigHash(byte[] data) {
        try {
            java.security.MessageDigest md = java.security.MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(data);
            StringBuilder sb = new StringBuilder("SHA256:");
            for (int i = 0; i < Math.min(8, hash.length); i++) {
                sb.append(String.format("%02X", hash[i]));
            }
            return sb.append("...").toString();
        } catch (Exception e) {
            return "unknown";
        }
    }

    // ======================== UTILITIES ========================

    private void extractAsset(String assetName, File dest) throws Exception {
        InputStream is = getAssets().open(assetName);
        FileOutputStream fos = new FileOutputStream(dest);
        byte[] buf = new byte[65536];
        int len;
        while ((len = is.read(buf)) > 0) fos.write(buf, 0, len);
        fos.close();
        is.close();
    }

    private void copyFile(File src, File dst) throws Exception {
        java.io.FileInputStream fis = new java.io.FileInputStream(src);
        FileOutputStream fos = new FileOutputStream(dst);
        byte[] buf = new byte[65536];
        int len;
        while ((len = fis.read(buf)) > 0) fos.write(buf, 0, len);
        fos.close();
        fis.close();
    }

    private void deleteDir(File dir) {
        if (dir.isDirectory()) {
            File[] children = dir.listFiles();
            if (children != null) for (File c : children) deleteDir(c);
        }
        dir.delete();
    }

    private void log(String msg) {
        Log.d("HSPatcher", msg);
        mainHandler.post(() -> {
            logOutput.append(msg + "\n");
            logScroll.post(() -> logScroll.fullScroll(View.FOCUS_DOWN));
        });
    }

    private void logClear() {
        mainHandler.post(() -> logOutput.setText(""));
    }

    private void updateProgress(int pct, String step) {
        mainHandler.post(() -> {
            progressBar.setProgress(pct);
            progressText.setText(step);
        });
    }
}
