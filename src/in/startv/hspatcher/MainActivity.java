package in.startv.hspatcher;

import android.Manifest;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.Intent;
import android.util.Log;
import android.content.pm.PackageManager;
import android.graphics.Color;
import android.net.Uri;
import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.animation.AnimatorSet;
import android.animation.ObjectAnimator;
import android.animation.PropertyValuesHolder;
import android.animation.ValueAnimator;
import android.view.ViewAnimationUtils;
import android.view.ViewGroup;
import android.view.animation.AccelerateDecelerateInterpolator;
import android.view.animation.AccelerateInterpolator;
import android.view.animation.DecelerateInterpolator;
import android.view.animation.LinearInterpolator;
import android.view.animation.OvershootInterpolator;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.os.Looper;
import android.provider.Settings;
import android.view.View;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.Toast;
import android.content.SharedPreferences;

import java.io.*;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.Locale;
import java.util.Random;

public class MainActivity extends Activity {

    private static final int PICK_APK = 1001;
    private static final int STORAGE_PERM = 1002;
    private static final int MANAGE_STORAGE = 1003;
    private static final int INSTALL_REQUEST = 1004;
    private static final int EXTRACT_APP = 1005;
    private static final int INSTALL_PERM = 1006;
    private static final int UNINSTALL_REQUEST = 1007;
    private static final int BACKUP_APP = 1008;
    private static final int PICK_CERT = 1009;

    private Button btnSelect, btnPatch, btnInstall, btnExtract, btnUninstall;
    private Button btnCancel, btnMod, btnTools, btnCert;
    private TextView logOutput, apkName, apkSize, progressText, versionText;
    private ScrollView logScroll;
    private ProgressBar progressBar;
    private LinearLayout apkInfoPanel;
    private View headerContainer;
    private TextView titleText;
    private TextView subtitleText;
    private LinearLayout phase1Buttons, phase2Buttons, phase4Buttons;
    private View colorOverlay;
    private FrameLayout particleContainer;

    private static final int PHASE_INITIAL = 0;
    private static final int PHASE_SELECTED = 1;
    private static final int PHASE_PATCHING = 2;
    private static final int PHASE_COMPLETE = 3;
    private int currentPhase = PHASE_INITIAL;

    private File selectedApk;
    private File patchedApk;
    private Handler mainHandler;
    private boolean isPatching = false;
    private boolean isSplitBundle = false;  // true if user selected .apks/.xapk/.apkm
    private String originalFileName = "";   // original filename before copy
    private boolean pendingInstallAfterUninstall = false;
    private String targetPackageName = null;
    private boolean autoPatchAfterLoad = false;
    private String selectedApkPatchedVersion = null; // non-null if APK is already patched

    private boolean pendingLogAutoScroll = false;
    private final Runnable logAutoScrollRunnable = new Runnable() {
        @Override
        public void run() {
            pendingLogAutoScroll = false;
            if (logScroll == null || logOutput == null) return;

            int contentHeight = logOutput.getHeight();
            int containerHeight = logScroll.getHeight();
            int targetY = Math.max(0, contentHeight - containerHeight);
            logScroll.smoothScrollTo(0, targetY);
        }
    };

    private final Handler entertainmentHandler = new Handler(Looper.getMainLooper());
    private boolean patchEntertainmentRunning = false;
    private int entertainmentTick = 0;
    private int lastProgressPct = 0;
    private String lastProgressStep = "";
    private AnimatorSet patchAnimatorSet;

    private final Runnable patchEntertainmentRunnable = new Runnable() {
        @Override
        public void run() {
            if (!patchEntertainmentRunning) return;
            entertainmentTick++;
            renderProgressText();
            entertainmentHandler.postDelayed(this, 420);
        }
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        mainHandler = new Handler(Looper.getMainLooper());

        applyModernSystemUi();

        btnSelect = findViewById(R.id.btn_select);
        btnPatch = findViewById(R.id.btn_patch);
        btnInstall = findViewById(R.id.btn_install);
        btnExtract = findViewById(R.id.btn_extract);
        btnUninstall = findViewById(R.id.btn_uninstall);
        btnCancel = findViewById(R.id.btn_cancel);
        btnMod = findViewById(R.id.btn_mod);
        btnTools = findViewById(R.id.btn_tools);
        logOutput = findViewById(R.id.log_output);
        apkName = findViewById(R.id.apk_name);
        apkSize = findViewById(R.id.apk_size);
        progressText = findViewById(R.id.progress_text);
        logScroll = findViewById(R.id.log_scroll);
        progressBar = findViewById(R.id.progress_bar);
        apkInfoPanel = findViewById(R.id.apk_info_panel);
        versionText = findViewById(R.id.version_text);
        headerContainer = findViewById(R.id.header_container);
        titleText = findViewById(R.id.title_text);
        subtitleText = findViewById(R.id.subtitle_text);
        phase1Buttons = findViewById(R.id.phase1_buttons);
        phase2Buttons = findViewById(R.id.phase2_buttons);
        phase4Buttons = findViewById(R.id.phase4_buttons);
        colorOverlay = findViewById(R.id.color_overlay);
        particleContainer = findViewById(R.id.particle_container);

        // Display app version
        try {
            String vName = getPackageManager().getPackageInfo(getPackageName(), 0).versionName;
            if (vName == null || vName.isEmpty()) vName = "dev";
            versionText.setText("v" + vName);
        } catch (Exception e) {
            versionText.setText("v3.10");
        }

        btnSelect.setOnClickListener(v -> { animateButtonPress(v, 0xFF00E676); onSelectClick(); });
        btnPatch.setOnClickListener(v -> onPatchClick());
        btnInstall.setOnClickListener(v -> onInstallClick());
        btnExtract.setOnClickListener(v -> { animateButtonPress(v, 0xFF00BCD4); onExtractClick(); });
        btnUninstall.setOnClickListener(v -> onUninstallClick());
        btnCancel.setOnClickListener(v -> onCancelClick());
        btnMod.setOnClickListener(v -> onModClick());
        btnTools.setOnClickListener(v -> showToolsMenu());

        // FAB for CA cert
        btnCert = findViewById(R.id.fab_cert);
        btnCert.setOnClickListener(v -> onCertClick());
        updateCertButton();

        // Entrance animations
        animateEntrance();

        requestStoragePermission();

        // Auto-load APK if passed via intent
        String intentPath = getIntent().getStringExtra("apk_path");
        if (intentPath != null && !intentPath.isEmpty()) {
            autoPatchAfterLoad = getIntent().getBooleanExtra("auto_patch", false);
            File f = new File(intentPath);
            if (f.exists()) {
                log("📂 Auto-loading APK from intent: " + intentPath);
                autoLoadApk(f);
            }
        }
    }

    private void showToolsMenu() {
        String[] items = {"🔐 APK Signer", "🗄️ DB Editor"};
        new AlertDialog.Builder(this)
            .setTitle("⚙ Tools")
            .setItems(items, (dialog, which) -> {
                if (which == 0) {
                    startActivity(new Intent(this, ApkSignerActivity.class));
                } else if (which == 1) {
                    startActivity(new Intent(this, DbEditorActivity.class));
                }
            })
            .show();
    }

    private void onCancelClick() {
        if (isPatching) return;
        selectedApk = null;
        patchedApk = null;
        isSplitBundle = false;
        originalFileName = "";
        selectedApkPatchedVersion = null;
        switchToPhase(PHASE_INITIAL);
        apkInfoPanel.setVisibility(View.GONE);
        logClear();
        log("Ready. Select an APK to patch.");
    }

    private void onModClick() {
        patchedApk = null;
        selectedApk = null;
        isSplitBundle = false;
        originalFileName = "";
        selectedApkPatchedVersion = null;
        switchToPhase(PHASE_INITIAL);
        apkInfoPanel.setVisibility(View.GONE);
        logClear();
        log("Ready. Select an APK to patch.");
    }

    private void applyModernSystemUi() {
        try {
            getWindow().setStatusBarColor(getColor(R.color.hsp_bg));
            getWindow().setNavigationBarColor(getColor(R.color.hsp_bg));

            View decorView = getWindow().getDecorView();
            int flags = decorView.getSystemUiVisibility();
            flags &= ~View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR;
            flags &= ~View.SYSTEM_UI_FLAG_LIGHT_NAVIGATION_BAR;
            decorView.setSystemUiVisibility(flags);
        } catch (Throwable ignored) {
            // Best-effort only.
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

                // Pre-check: is this APK already patched?
                selectedApkPatchedVersion = isBundle ? null : PatchEngine.isAlreadyPatched(dest);

                mainHandler.post(() -> {
                    apkInfoPanel.setVisibility(View.VISIBLE);
                    apkName.setText(fName + (isBundle ? " [SPLIT BUNDLE]" : "")
                        + (selectedApkPatchedVersion != null ? " \u26a0\ufe0f ALREADY PATCHED" : ""));
                    apkSize.setText(fSize);
                    switchToPhase(PHASE_SELECTED);

                    // If launched with --ez auto_patch true, patch only after load completes
                    if (autoPatchAfterLoad) {
                        autoPatchAfterLoad = false;
                        mainHandler.postDelayed(this::onPatchClick, 250);
                    }
                });
                if (isBundle) {
                    log("✅ Split APK bundle loaded: " + fName + " (" + fSize + ")");
                    log("📦 Will merge splits → single APK → then patch.");
                } else {
                    log("✅ APK loaded: " + fName + " (" + fSize + ")");
                }
                if (selectedApkPatchedVersion != null) {
                    log("");
                    log("⚠️  WARNING: This APK appears to be ALREADY PATCHED (v" + selectedApkPatchedVersion + ")");
                    log("   Re-patching can cause crashes, duplicate hooks, or bloated size.");
                    log("   Use the ORIGINAL (unmodified) APK for best results.");
                    log("");
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
        if (isPatching) {
            startPatchEntertainment();
        } else {
            stopPatchEntertainment();
        }
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
    protected void onPause() {
        super.onPause();
        // Avoid animating in background; patch thread continues regardless.
        stopPatchEntertainment();
    }

    @Override
    protected void onDestroy() {
        stopPatchEntertainment();
        super.onDestroy();
    }

    // ======================== UI PHASE MANAGEMENT ========================

    private void switchToPhase(int phase) {
        currentPhase = phase;
        try {
            switch (phase) {
                case PHASE_INITIAL:
                    animatePhaseTransition(phase1Buttons, phase2Buttons, phase4Buttons);
                    progressBar.setVisibility(View.GONE);
                    progressText.setVisibility(View.GONE);
                    btnCert.setVisibility(View.VISIBLE);
                    break;
                case PHASE_SELECTED:
                    animatePhaseTransition(phase2Buttons, phase1Buttons, phase4Buttons);
                    progressBar.setVisibility(View.GONE);
                    progressText.setVisibility(View.GONE);
                    btnCert.setVisibility(View.VISIBLE);
                    break;
                case PHASE_PATCHING:
                    // Phase 2 buttons hidden by explosion; show progress
                    phase1Buttons.setVisibility(View.GONE);
                    phase4Buttons.setVisibility(View.GONE);
                    btnCert.setVisibility(View.GONE);
                    progressBar.setVisibility(View.VISIBLE);
                    progressText.setVisibility(View.VISIBLE);
                    break;
                case PHASE_COMPLETE:
                    animatePhaseTransition(phase4Buttons, phase1Buttons, phase2Buttons);
                    btnCert.setVisibility(View.VISIBLE);
                    break;
            }
        } catch (Throwable t) {
            // Fallback: just set visibility directly
            phase1Buttons.setVisibility(phase == PHASE_INITIAL ? View.VISIBLE : View.GONE);
            phase2Buttons.setVisibility(phase == PHASE_SELECTED ? View.VISIBLE : View.GONE);
            phase4Buttons.setVisibility(phase == PHASE_COMPLETE ? View.VISIBLE : View.GONE);
        }
    }

    private void animatePhaseTransition(View showGroup, View hideGroup1, View hideGroup2) {
        try {
            // Slide out old groups
            if (hideGroup1.getVisibility() == View.VISIBLE) {
                hideGroup1.animate()
                    .translationY(60f).alpha(0f).setDuration(250)
                    .setInterpolator(new AccelerateInterpolator())
                    .withEndAction(() -> {
                        hideGroup1.setVisibility(View.GONE);
                        hideGroup1.setTranslationY(0f);
                        hideGroup1.setAlpha(1f);
                    }).start();
            } else {
                hideGroup1.setVisibility(View.GONE);
            }
            if (hideGroup2.getVisibility() == View.VISIBLE) {
                hideGroup2.animate()
                    .translationY(60f).alpha(0f).setDuration(250)
                    .setInterpolator(new AccelerateInterpolator())
                    .withEndAction(() -> {
                        hideGroup2.setVisibility(View.GONE);
                        hideGroup2.setTranslationY(0f);
                        hideGroup2.setAlpha(1f);
                    }).start();
            } else {
                hideGroup2.setVisibility(View.GONE);
            }

            // Slide in new group after a short delay
            showGroup.setTranslationY(-40f);
            showGroup.setAlpha(0f);
            showGroup.setVisibility(View.VISIBLE);
            showGroup.animate()
                .translationY(0f).alpha(1f).setDuration(350)
                .setStartDelay(200)
                .setInterpolator(new OvershootInterpolator(1.2f))
                .start();
        } catch (Throwable t) {
            hideGroup1.setVisibility(View.GONE);
            hideGroup2.setVisibility(View.GONE);
            showGroup.setVisibility(View.VISIBLE);
            showGroup.setAlpha(1f);
            showGroup.setTranslationY(0f);
        }
    }

    // ======================== ENTRANCE ANIMATIONS ========================

    private void animateEntrance() {
        try {
            // Title slides in from left
            if (titleText != null) {
                titleText.setTranslationX(-300f);
                titleText.setAlpha(0f);
                titleText.animate().translationX(0f).alpha(1f)
                    .setDuration(600).setInterpolator(new DecelerateInterpolator(2f)).start();
            }
            // Subtitle fades in
            if (subtitleText != null) {
                subtitleText.setAlpha(0f);
                subtitleText.animate().alpha(1f).setDuration(500).setStartDelay(300).start();
            }
            // Version chip pops in
            if (versionText != null) {
                versionText.setScaleX(0f);
                versionText.setScaleY(0f);
                versionText.animate().scaleX(1f).scaleY(1f)
                    .setDuration(400).setStartDelay(400)
                    .setInterpolator(new OvershootInterpolator(2f)).start();
            }
            // Buttons slide up with stagger
            if (phase1Buttons != null) {
                for (int i = 0; i < phase1Buttons.getChildCount(); i++) {
                    View child = phase1Buttons.getChildAt(i);
                    child.setTranslationY(120f);
                    child.setAlpha(0f);
                    child.animate().translationY(0f).alpha(1f)
                        .setDuration(500).setStartDelay(500 + i * 150L)
                        .setInterpolator(new DecelerateInterpolator(2f)).start();
                }
            }
            // FAB scales in
            if (btnCert != null) {
                btnCert.setScaleX(0f);
                btnCert.setScaleY(0f);
                btnCert.animate().scaleX(1f).scaleY(1f)
                    .setDuration(400).setStartDelay(900)
                    .setInterpolator(new OvershootInterpolator(3f)).start();
            }
            // Log area fades in
            if (logScroll != null) {
                logScroll.setAlpha(0f);
                logScroll.animate().alpha(1f).setDuration(600).setStartDelay(200).start();
            }
        } catch (Throwable ignored) {}
    }

    // ======================== BUTTON PRESS COLOR FILL ========================

    private void animateButtonPress(View button, int color) {
        try {
            if (colorOverlay == null) return;
            int[] loc = new int[2];
            button.getLocationInWindow(loc);
            int cx = loc[0] + button.getWidth() / 2;
            int cy = loc[1] + button.getHeight() / 2;

            colorOverlay.setBackgroundColor(color);
            colorOverlay.setVisibility(View.VISIBLE);
            colorOverlay.setAlpha(0.3f);

            int finalRadius = (int) Math.hypot(
                colorOverlay.getWidth() > 0 ? colorOverlay.getWidth() : 1080,
                colorOverlay.getHeight() > 0 ? colorOverlay.getHeight() : 2200);

            Animator reveal = ViewAnimationUtils.createCircularReveal(
                colorOverlay, cx, cy, 0, finalRadius);
            reveal.setDuration(500);
            reveal.setInterpolator(new DecelerateInterpolator());
            reveal.start();

            // Fade out after reveal
            colorOverlay.animate().alpha(0f).setDuration(400).setStartDelay(350)
                .withEndAction(() -> colorOverlay.setVisibility(View.GONE))
                .start();
        } catch (Throwable ignored) {
            if (colorOverlay != null) colorOverlay.setVisibility(View.GONE);
        }
    }

    // ======================== PATCH BUTTON EXPLOSION ========================

    private void explodePatchButton(Runnable afterExplosion) {
        try {
            if (particleContainer == null || btnPatch == null) {
                afterExplosion.run();
                return;
            }

            // Get patch button center position
            int[] loc = new int[2];
            btnPatch.getLocationInWindow(loc);
            int cx = loc[0] + btnPatch.getWidth() / 2;
            int cy = loc[1] + btnPatch.getHeight() / 2;

            // Button pulse + scale up before exploding
            AnimatorSet preExplosion = new AnimatorSet();
            ObjectAnimator scaleUpX = ObjectAnimator.ofFloat(btnPatch, "scaleX", 1f, 1.3f);
            ObjectAnimator scaleUpY = ObjectAnimator.ofFloat(btnPatch, "scaleY", 1f, 1.3f);
            scaleUpX.setDuration(250);
            scaleUpY.setDuration(250);
            scaleUpX.setInterpolator(new AccelerateInterpolator());
            scaleUpY.setInterpolator(new AccelerateInterpolator());
            preExplosion.playTogether(scaleUpX, scaleUpY);

            preExplosion.addListener(new AnimatorListenerAdapter() {
                @Override
                public void onAnimationEnd(Animator animation) {
                    // Hide the patch button
                    btnPatch.setScaleX(1f);
                    btnPatch.setScaleY(1f);

                    // Create explosion particles
                    spawnExplosionParticles(cx, cy);

                    // Hide phase2 buttons immediately
                    phase2Buttons.setVisibility(View.GONE);

                    // Flash the screen
                    flashScreen(0xFF7C4DFF);

                    // After particle animation, run the callback
                    mainHandler.postDelayed(() -> {
                        particleContainer.removeAllViews();
                        afterExplosion.run();
                    }, 800);
                }
            });

            preExplosion.start();
        } catch (Throwable t) {
            // Fallback: skip animation
            try { phase2Buttons.setVisibility(View.GONE); } catch (Throwable ignored) {}
            afterExplosion.run();
        }
    }

    private void spawnExplosionParticles(int cx, int cy) {
        try {
            Random rand = new Random();
            int[] colors = {0xFF7C4DFF, 0xFF00E676, 0xFFFF5252, 0xFFFFC107, 0xFF00BCD4, 0xFFFFFFFF};
            int particleCount = 24;

            for (int i = 0; i < particleCount; i++) {
                View particle = new View(this);
                int size = 8 + rand.nextInt(16); // 8-24dp
                int sizePx = (int) (size * getResources().getDisplayMetrics().density);
                FrameLayout.LayoutParams lp = new FrameLayout.LayoutParams(sizePx, sizePx);
                lp.leftMargin = cx - sizePx / 2;
                lp.topMargin = cy - sizePx / 2;
                particle.setLayoutParams(lp);
                particle.setBackgroundColor(colors[rand.nextInt(colors.length)]);
                particle.setAlpha(1f);

                // Make some particles round
                if (rand.nextBoolean()) {
                    android.graphics.drawable.GradientDrawable circle =
                        new android.graphics.drawable.GradientDrawable();
                    circle.setShape(android.graphics.drawable.GradientDrawable.OVAL);
                    circle.setColor(colors[rand.nextInt(colors.length)]);
                    particle.setBackground(circle);
                }

                particleContainer.addView(particle);

                // Random direction
                double angle = rand.nextDouble() * 2 * Math.PI;
                float distance = 300 + rand.nextInt(500); // px
                float dx = (float) (Math.cos(angle) * distance);
                float dy = (float) (Math.sin(angle) * distance);
                float rotation = rand.nextFloat() * 720 - 360;

                particle.animate()
                    .translationXBy(dx)
                    .translationYBy(dy)
                    .rotation(rotation)
                    .scaleX(0f)
                    .scaleY(0f)
                    .alpha(0f)
                    .setDuration(600 + rand.nextInt(400))
                    .setInterpolator(new DecelerateInterpolator(1.5f))
                    .start();
            }
        } catch (Throwable ignored) {}
    }

    private void flashScreen(int color) {
        try {
            if (colorOverlay == null) return;
            colorOverlay.setBackgroundColor(color);
            colorOverlay.setAlpha(0.5f);
            colorOverlay.setVisibility(View.VISIBLE);
            colorOverlay.animate().alpha(0f).setDuration(500)
                .withEndAction(() -> colorOverlay.setVisibility(View.GONE))
                .start();
        } catch (Throwable ignored) {
            if (colorOverlay != null) colorOverlay.setVisibility(View.GONE);
        }
    }

    private void startPatchEntertainment() {
        if (patchEntertainmentRunning) return;
        patchEntertainmentRunning = true;
        entertainmentTick = 0;

        // Ensure some sane defaults
        if (headerContainer != null) {
            headerContainer.setPivotX(headerContainer.getWidth() * 0.5f);
            headerContainer.setPivotY(headerContainer.getHeight() * 0.5f);
        }
        if (titleText != null) {
            titleText.setPivotX(titleText.getWidth() * 0.5f);
            titleText.setPivotY(titleText.getHeight() * 0.5f);
        }
        if (versionText != null) {
            versionText.setPivotX(versionText.getWidth() * 0.5f);
            versionText.setPivotY(versionText.getHeight() * 0.5f);
        }
        if (progressBar != null) {
            progressBar.setPivotY(progressBar.getHeight() * 0.5f);
        }

        // Build a small "show" using lightweight property animations.
        // Keep it subtle to avoid jank on low-end devices.
        try {
            ArrayList<Animator> anims = new ArrayList<>();

            ObjectAnimator headerFloat = null;
            if (headerContainer != null) {
                headerFloat = ObjectAnimator.ofFloat(headerContainer, "translationY", 0f, -6f, 0f);
                headerFloat.setDuration(1800);
                headerFloat.setRepeatCount(ObjectAnimator.INFINITE);
                headerFloat.setInterpolator(new AccelerateDecelerateInterpolator());
                anims.add(headerFloat);
            }

            ObjectAnimator titleWiggle = null;
            if (titleText != null) {
                PropertyValuesHolder rot = PropertyValuesHolder.ofFloat("rotation", -1.2f, 1.2f, -1.2f);
                PropertyValuesHolder sx = PropertyValuesHolder.ofFloat("scaleX", 1.0f, 1.03f, 1.0f);
                PropertyValuesHolder sy = PropertyValuesHolder.ofFloat("scaleY", 1.0f, 1.03f, 1.0f);
                titleWiggle = ObjectAnimator.ofPropertyValuesHolder(titleText, rot, sx, sy);
                titleWiggle.setDuration(1400);
                titleWiggle.setRepeatCount(ObjectAnimator.INFINITE);
                titleWiggle.setInterpolator(new AccelerateDecelerateInterpolator());
                anims.add(titleWiggle);
            }

            ObjectAnimator subtitlePulse = null;
            if (subtitleText != null) {
                subtitlePulse = ObjectAnimator.ofFloat(subtitleText, "alpha", 0.75f, 1.0f, 0.75f);
                subtitlePulse.setDuration(1600);
                subtitlePulse.setRepeatCount(ObjectAnimator.INFINITE);
                subtitlePulse.setInterpolator(new LinearInterpolator());
                anims.add(subtitlePulse);
            }

            ObjectAnimator chipBreath = null;
            if (versionText != null) {
                PropertyValuesHolder csx = PropertyValuesHolder.ofFloat("scaleX", 1.0f, 1.05f, 1.0f);
                PropertyValuesHolder csy = PropertyValuesHolder.ofFloat("scaleY", 1.0f, 1.05f, 1.0f);
                chipBreath = ObjectAnimator.ofPropertyValuesHolder(versionText, csx, csy);
                chipBreath.setDuration(1100);
                chipBreath.setRepeatCount(ObjectAnimator.INFINITE);
                chipBreath.setInterpolator(new AccelerateDecelerateInterpolator());
                anims.add(chipBreath);
            }

            ObjectAnimator progressPulse = null;
            if (progressBar != null) {
                progressPulse = ObjectAnimator.ofFloat(progressBar, "scaleY", 1.0f, 1.12f, 1.0f);
                progressPulse.setDuration(900);
                progressPulse.setRepeatCount(ObjectAnimator.INFINITE);
                progressPulse.setInterpolator(new AccelerateDecelerateInterpolator());
                anims.add(progressPulse);
            }

            ObjectAnimator progressTextPulse = null;
            if (progressText != null) {
                progressTextPulse = ObjectAnimator.ofFloat(progressText, "alpha", 0.80f, 1.0f, 0.80f);
                progressTextPulse.setDuration(700);
                progressTextPulse.setRepeatCount(ObjectAnimator.INFINITE);
                progressTextPulse.setInterpolator(new LinearInterpolator());
                anims.add(progressTextPulse);
            }

            patchAnimatorSet = new AnimatorSet();
            if (!anims.isEmpty()) {
                patchAnimatorSet.playTogether(anims);
                patchAnimatorSet.start();
            }
        } catch (Throwable ignored) {
            // If any vendor ROM breaks animations, keep patching functional.
        }

        entertainmentHandler.removeCallbacks(patchEntertainmentRunnable);
        entertainmentHandler.post(patchEntertainmentRunnable);
    }

    private void stopPatchEntertainment() {
        patchEntertainmentRunning = false;
        entertainmentHandler.removeCallbacks(patchEntertainmentRunnable);

        if (patchAnimatorSet != null) {
            try {
                patchAnimatorSet.cancel();
            } catch (Throwable ignored) {}
            patchAnimatorSet = null;
        }

        // Reset transforms (avoid leaving the UI skewed)
        if (headerContainer != null) {
            headerContainer.setTranslationY(0f);
        }
        if (titleText != null) {
            titleText.setRotation(0f);
            titleText.setScaleX(1f);
            titleText.setScaleY(1f);
        }
        if (subtitleText != null) {
            subtitleText.setAlpha(1f);
        }
        if (versionText != null) {
            versionText.setScaleX(1f);
            versionText.setScaleY(1f);
        }
        if (progressBar != null) {
            progressBar.setScaleY(1f);
        }
        if (progressText != null) {
            progressText.setAlpha(1f);
            renderProgressText();
        }
    }

    private void renderProgressText() {
        if (progressText == null) return;
        if (progressText.getVisibility() != View.VISIBLE) return;

        if (!patchEntertainmentRunning) {
            String step = (lastProgressStep == null || lastProgressStep.isEmpty()) ? "Working" : lastProgressStep;
            progressText.setText(step + " (" + lastProgressPct + "%)");
            return;
        }

        String[] spinner = {"◐", "◓", "◑", "◒"};
        String spin = spinner[Math.abs(entertainmentTick) % spinner.length];
        int dotCount = Math.abs(entertainmentTick) % 4;
        String dots = dotCount == 0 ? "" : (dotCount == 1 ? "." : (dotCount == 2 ? ".." : "..."));

        String flair;
        int pct = lastProgressPct;
        if (pct < 15) flair = "Booting tools";
        else if (pct < 35) flair = "Merging / unpacking";
        else if (pct < 55) flair = "Rewriting internals";
        else if (pct < 75) flair = "Injecting patches";
        else if (pct < 92) flair = "Optimizing output";
        else if (pct < 100) flair = "Zipalign + signing";
        else flair = "Complete";

        String step = (lastProgressStep == null || lastProgressStep.isEmpty()) ? "Working" : lastProgressStep;
        progressText.setText(step + " (" + pct + "%)  " + spin + dots + "  " + flair);
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
                if (data.getBooleanExtra(AppListActivity.EXTRA_BACKUP_MODE, false)) {
                    handleBackupResult(path, isSplit, label);
                } else {
                    loadExtractedApp(new File(path), isSplit, label);
                }
            }
        } else if (requestCode == BACKUP_APP && resultCode == RESULT_OK && data != null) {
            String path = data.getStringExtra(AppListActivity.EXTRA_APK_PATH);
            boolean isSplit = data.getBooleanExtra(AppListActivity.EXTRA_IS_SPLIT, false);
            String label = data.getStringExtra(AppListActivity.EXTRA_APP_LABEL);
            if (path != null) {
                handleBackupResult(path, isSplit, label);
            }
        } else if (requestCode == PICK_CERT && resultCode == RESULT_OK && data != null) {
            Uri uri = data.getData();
            if (uri != null) importCaCert(uri);
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
            boolean stillInstalled = true;
            if (targetPackageName != null) {
                try {
                    getPackageManager().getPackageInfo(targetPackageName, 0);
                    stillInstalled = true;
                } catch (PackageManager.NameNotFoundException e) {
                    stillInstalled = false;
                }
            }

            if (!stillInstalled) {
                log("✅ Uninstalled: " + targetPackageName);
                if (pendingInstallAfterUninstall) {
                    pendingInstallAfterUninstall = false;
                    log("↪ Installing patched APK...");
                    doInstall();
                }
            } else {
                if (pendingInstallAfterUninstall) {
                    pendingInstallAfterUninstall = false;
                    log("⚠️ App is still installed — uninstall was cancelled or failed");
                    log("💡 Tip: Uninstall the existing app manually, then tap Install");
                } else {
                    log("⚠️ Uninstall cancelled or failed");
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
                        switchToPhase(PHASE_SELECTED);
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

                    // Pre-check: is this APK already patched?
                    selectedApkPatchedVersion = PatchEngine.isAlreadyPatched(dest);

                    long total = dest.length();
                    long sizeMB = total / (1024 * 1024);
                    String fSize = sizeMB + " MB (" + total + " bytes)";
                    mainHandler.post(() -> {
                        apkInfoPanel.setVisibility(View.VISIBLE);
                        apkName.setText(label
                            + (selectedApkPatchedVersion != null ? " ⚠️ ALREADY PATCHED" : ""));
                        apkSize.setText(fSize);
                        switchToPhase(PHASE_SELECTED);
                    });
                    log("✅ APK loaded: " + label + " (" + fSize + ")");
                }
                if (selectedApkPatchedVersion != null) {
                    log("");
                    log("⚠️  WARNING: This APK appears to be ALREADY PATCHED (v" + selectedApkPatchedVersion + ")");
                    log("   Re-patching can cause crashes, duplicate hooks, or bloated size.");
                    log("   Use the ORIGINAL (unmodified) APK for best results.");
                    log("");
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

                // Pre-check: is this APK already patched?
                selectedApkPatchedVersion = isBundle ? null : PatchEngine.isAlreadyPatched(dest);

                mainHandler.post(() -> {
                    apkInfoPanel.setVisibility(View.VISIBLE);
                    apkName.setText(fName + (isBundle ? " [SPLIT BUNDLE]" : "")
                        + (selectedApkPatchedVersion != null ? " ⚠️ ALREADY PATCHED" : ""));
                    apkSize.setText(fSize);
                    switchToPhase(PHASE_SELECTED);
                });
                if (isBundle) {
                    log("✅ Split APK bundle loaded: " + fName + " (" + fSize + ")");
                    log("📦 Will merge splits → single APK → then patch.");
                } else {
                    log("✅ APK loaded: " + fName + " (" + fSize + ")");
                }
                if (selectedApkPatchedVersion != null) {
                    log("");
                    log("⚠️  WARNING: This APK appears to be ALREADY PATCHED (v" + selectedApkPatchedVersion + ")");
                    log("   Re-patching can cause crashes, duplicate hooks, or bloated size.");
                    log("   Use the ORIGINAL (unmodified) APK for best results.");
                    log("");
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

        // If already patched, show confirmation dialog first
        if (selectedApkPatchedVersion != null) {
            new AlertDialog.Builder(this)
                .setTitle("\u26a0\ufe0f Already Patched")
                .setMessage("This APK was previously patched by HSPatcher (v"
                    + selectedApkPatchedVersion + ").\n\n"
                    + "Re-patching may cause:\n"
                    + "\u2022 App crashes from duplicate hooks\n"
                    + "\u2022 Bloated APK size\n"
                    + "\u2022 Broken functionality\n\n"
                    + "Use the ORIGINAL unmodified APK for best results.\n\n"
                    + "Proceed anyway?")
                .setPositiveButton("Patch Anyway", (d, w) -> doPatch())
                .setNegativeButton("Cancel", null)
                .show();
            return;
        }
        doPatch();
    }

    private void doPatch() {
        if (isPatching) return;
        isPatching = true;

        logClear();
        lastProgressPct = 0;
        lastProgressStep = "Starting";

        // Explosion animation, then start patching
        explodePatchButton(() -> {
            switchToPhase(PHASE_PATCHING);
            progressBar.setProgress(0);
            renderProgressText();
            if (progressText != null) {
                progressText.post(this::startPatchEntertainment);
            } else {
                startPatchEntertainment();
            }

            // Animate progress bar entrance
            try {
                progressBar.setScaleX(0f);
                progressBar.animate().scaleX(1f).setDuration(400)
                    .setInterpolator(new OvershootInterpolator(1.5f)).start();
            } catch (Throwable ignored) {}

            log("⚡ HSPatcher v3.55 — Starting one-click patch");
            log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

            new Thread(() -> {
            try {
                File workDir = new File(getFilesDir(), "hspatch_work");

                // ========= APKS MERGE STEP (if split bundle) =========
                File apkToProcess = selectedApk;
                File bundleBaseApk = null;
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

                    // Extract base.apk from bundle for signature extraction
                    // (merged APK is unsigned; we need the original signature)
                    bundleBaseApk = ApksMerger.extractBaseApk(selectedApk, mergeWork);
                    if (bundleBaseApk != null) {
                        log("🔑 Extracted base.apk from bundle for signature");
                    }

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

                // Inject stored CA certificate if available
                File certFile = getCaCertFile();
                if (certFile.exists()) {
                    byte[] certData = readFileBytes(certFile);
                    engine.setCaCert(certData);
                    log("📜 CA certificate will be embedded (" + certData.length + " bytes)");
                }

                // For split bundles, tell engine to extract signature from original base.apk
                if (isSplitBundle && bundleBaseApk != null && bundleBaseApk.exists()) {
                    engine.setOriginalApkForSignature(bundleBaseApk);
                }

                // Allow re-patching if user confirmed via dialog
                if (selectedApkPatchedVersion != null) {
                    engine.setForceRepatch(true);
                }

                File result = engine.patch();

                // Keep patchedApk pointing to the internal file (app's private storage)
                // The FileProvider can serve this to the package installer.
                // Also copy to a stable internal location for install.
                File installApk = new File(getFilesDir(), "patched_output.apk");
                copyFile(result, installApk);
                patchedApk = installApk;

                // Capture target app metadata (package + label) from the patched APK
                String appLabelForName = null;
                try {
                    android.content.pm.PackageManager pm = getPackageManager();
                    android.content.pm.PackageInfo info = pm.getPackageArchiveInfo(
                        patchedApk.getAbsolutePath(), 0);
                    if (info != null) {
                        targetPackageName = info.packageName;
                        if (info.applicationInfo != null) {
                            info.applicationInfo.sourceDir = patchedApk.getAbsolutePath();
                            info.applicationInfo.publicSourceDir = patchedApk.getAbsolutePath();
                            CharSequence labelCs = pm.getApplicationLabel(info.applicationInfo);
                            if (labelCs != null) appLabelForName = labelCs.toString();
                        }
                    }
                } catch (Throwable t) {
                    // ignore — filename will fall back
                }

                // Also copy to Downloads for manual access / sharing
                File downloads = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS);
                String timestamp = new SimpleDateFormat("HHmmss", Locale.US).format(new Date());
                String appPart = appLabelForName;
                if (appPart == null || appPart.trim().isEmpty()) {
                    appPart = (targetPackageName != null && !targetPackageName.isEmpty())
                        ? targetPackageName
                        : (originalFileName != null && !originalFileName.isEmpty()
                            ? originalFileName.replaceAll("\\.[a-zA-Z0-9]+$", "")
                            : "UnknownApp");
                }
                appPart = sanitizeFileName(appPart);
                File outputFile = new File(downloads, "HSPatched_" + appPart + "_" + timestamp + ".apk");
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
                    isPatching = false;
                    stopPatchEntertainment();
                    switchToPhase(PHASE_COMPLETE);
                });

            } catch (Throwable e) {
                String msg = e.getMessage();
                if (msg != null && msg.startsWith("APK_ALREADY_PATCHED")) {
                    log("");
                    log("\u26d4 ABORTED: This APK is already patched by HSPatcher.");
                    log("   Please use the ORIGINAL (unmodified) APK file.");
                    log("   If you extracted this from an installed app, it was already patched.");
                                } else if (e instanceof OutOfMemoryError) {
                    log("\u274c OUT OF MEMORY: APK too large to patch on this device.");
                    log("   The APK requires more RAM than available.");
                    log("   Try closing other apps and retrying, or use a device with more RAM.");
                    log("   Error: " + msg);
                } else {
                    log("\u274c FATAL: " + e.getClass().getName() + ": " + msg);
                    for (StackTraceElement st : e.getStackTrace()) {
                        log("   " + st.toString());
                    }
                }
                mainHandler.post(() -> {
                    isPatching = false;
                    stopPatchEntertainment();
                    switchToPhase(PHASE_SELECTED);
                    progressBar.setVisibility(View.GONE);
                    progressText.setVisibility(View.GONE);
                });
            }
            }).start();
        }); // end explodePatchButton callback
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
                startUninstallFlow(targetPackageName, true);
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
    private boolean tryPmUninstall(String packageName) {
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

    private void onUninstallClick() {
        if (targetPackageName == null || targetPackageName.trim().isEmpty()) {
            Toast.makeText(this, "No target package detected yet", Toast.LENGTH_SHORT).show();
            log("⚠️ No target package detected yet — patch an APK first.");
            return;
        }

        new android.app.AlertDialog.Builder(this)
            .setTitle("Uninstall")
            .setMessage("Uninstall \"" + targetPackageName + "\"?\n\nThis will remove all app data.")
            .setPositiveButton("Uninstall", (d, w) -> startUninstallFlow(targetPackageName, false))
            .setNegativeButton("Cancel", null)
            .show();
    }

    private void startUninstallFlow(String packageName, boolean installAfter) {
        if (packageName == null || packageName.trim().isEmpty()) {
            log("⚠️ No package name to uninstall");
            return;
        }

        pendingInstallAfterUninstall = installAfter;
        log("🗑️ Attempting pm uninstall of " + packageName + "...");
        if (tryPmUninstall(packageName)) {
            if (installAfter) {
                mainHandler.postDelayed(this::doInstall, 500);
            }
            return;
        }

        log("↪ Falling back to standard uninstall UI...");
        try {
            Intent uninstall = new Intent(Intent.ACTION_UNINSTALL_PACKAGE);
            uninstall.setData(Uri.parse("package:" + packageName));
            uninstall.putExtra(Intent.EXTRA_RETURN_RESULT, true);
            startActivityForResult(uninstall, UNINSTALL_REQUEST);
        } catch (Exception e) {
            log("↪ Fallback to ACTION_DELETE...");
            Intent uninstall2 = new Intent(Intent.ACTION_DELETE);
            uninstall2.setData(Uri.parse("package:" + packageName));
            startActivityForResult(uninstall2, UNINSTALL_REQUEST);
        }
    }

    // ======================== APP BACKUP (moved to AppListActivity) ========================

    private void handleBackupResult(String path, boolean isSplit, String label) {
        logClear();
        log("💾 Starting app backup: " + label);

        new Thread(() -> {
            try {
                File downloads = Environment.getExternalStoragePublicDirectory(
                    Environment.DIRECTORY_DOWNLOADS);
                File backupDir = new File(downloads, "HSPatcher_Backups");
                if (!backupDir.exists()) backupDir.mkdirs();

                String timestamp = new java.text.SimpleDateFormat("yyyyMMdd_HHmmss", Locale.US)
                    .format(new Date());
                String safeName = sanitizeFileName(label);

                if (isSplit) {
                    // Split APK — copy all files into a zip
                    File splitDir = new File(path);
                    File[] apks = splitDir.listFiles();
                    if (apks == null || apks.length == 0) {
                        log("❌ No APK files found for backup");
                        return;
                    }

                    File backupZip = new File(backupDir,
                        "Backup_" + safeName + "_" + timestamp + ".apks");

                    log("📦 Creating split APK backup (" + apks.length + " files)...");
                    java.util.zip.ZipOutputStream zos = new java.util.zip.ZipOutputStream(
                        new FileOutputStream(backupZip));
                    long totalBytes = 0;
                    for (File apk : apks) {
                        zos.putNextEntry(new java.util.zip.ZipEntry(apk.getName()));
                        InputStream in = new java.io.FileInputStream(apk);
                        byte[] buf = new byte[65536];
                        int len;
                        while ((len = in.read(buf)) > 0) {
                            zos.write(buf, 0, len);
                            totalBytes += len;
                        }
                        in.close();
                        zos.closeEntry();
                        log("   📄 " + apk.getName() + " (" + (apk.length() / 1024) + " KB)");
                    }
                    zos.close();

                    log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
                    log("✅ Backup complete!");
                    log("📁 " + backupZip.getAbsolutePath());
                    log("📏 " + (backupZip.length() / (1024 * 1024)) + " MB");

                    mainHandler.post(() -> Toast.makeText(this,
                        "Backup saved to Downloads/HSPatcher_Backups/",
                        Toast.LENGTH_LONG).show());
                } else {
                    // Single APK — simple copy
                    File src = new File(path);
                    File backupFile = new File(backupDir,
                        "Backup_" + safeName + "_" + timestamp + ".apk");

                    log("📦 Backing up single APK...");
                    copyFile(src, backupFile);

                    log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
                    log("✅ Backup complete!");
                    log("📁 " + backupFile.getAbsolutePath());
                    log("📏 " + (backupFile.length() / (1024 * 1024)) + " MB");

                    mainHandler.post(() -> Toast.makeText(this,
                        "Backup saved to Downloads/HSPatcher_Backups/",
                        Toast.LENGTH_LONG).show());
                }
            } catch (Exception e) {
                log("❌ Backup failed: " + e.getMessage());
            }
        }).start();
    }

    // ======================== APK SIGNER (accessed via Tools menu) ========================

    private String sanitizeFileName(String input) {
        if (input == null) return "UnknownApp";
        String s = input.trim();
        if (s.isEmpty()) return "UnknownApp";
        // Replace characters that break common filesystems
        s = s.replaceAll("[\\\\/:*?\"<>|]+", "_");
        s = s.replaceAll("\\s+", "_");
        // Keep it reasonably short
        if (s.length() > 40) s = s.substring(0, 40);
        return s;
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
            if (!pendingLogAutoScroll) {
                pendingLogAutoScroll = true;
                logScroll.removeCallbacks(logAutoScrollRunnable);
                logScroll.post(logAutoScrollRunnable);
            }
        });
    }

    private void logClear() {
        mainHandler.post(() -> logOutput.setText(""));
    }

    private void updateProgress(int pct, String step) {
        mainHandler.post(() -> {
            lastProgressPct = pct;
            lastProgressStep = step;
            if (Build.VERSION.SDK_INT >= 24) {
                progressBar.setProgress(pct, true);
            } else {
                progressBar.setProgress(pct);
            }
            renderProgressText();
        });
    }

    // ======================== CA CERTIFICATE MANAGEMENT ========================

    private static final String PREFS_NAME = "hspatcher_prefs";
    private static final String PREF_CERT_NAME = "ca_cert_name";

    private File getCaCertFile() {
        return new File(getFilesDir(), "user_ca.crt");
    }

    private boolean hasCaCert() {
        return getCaCertFile().exists() && getCaCertFile().length() > 0;
    }

    private void updateCertButton() {
        if (hasCaCert()) {
            btnCert.setText("✅");
        } else {
            btnCert.setText("📜");
        }
    }

    private void onCertClick() {
        if (hasCaCert()) {
            SharedPreferences prefs = getSharedPreferences(PREFS_NAME, MODE_PRIVATE);
            String certName = prefs.getString(PREF_CERT_NAME, "unknown");
            long certSize = getCaCertFile().length();

            new AlertDialog.Builder(this)
                .setTitle("📜 CA Certificate")
                .setMessage("Stored certificate:\n\n"
                    + "\u2022 " + certName + "\n"
                    + "\u2022 " + certSize + " bytes\n\n"
                    + "This certificate will be embedded into\n"
                    + "every patched APK for MITM proxy support.\n\n"
                    + "What would you like to do?")
                .setPositiveButton("Replace", (d, w) -> pickCertFile())
                .setNegativeButton("Delete", (d, w) -> {
                    deleteCaCert();
                    Toast.makeText(this, "CA certificate deleted", Toast.LENGTH_SHORT).show();
                })
                .setNeutralButton("Close", null)
                .show();
        } else {
            new AlertDialog.Builder(this)
                .setTitle("📜 Import CA Certificate")
                .setMessage("Import a proxy CA certificate (.crt / .pem / .cer / .der)\n\n"
                    + "The certificate will be:\n"
                    + "\u2022 Stored once in HSPatcher\n"
                    + "\u2022 Embedded in every patched APK\n"
                    + "\u2022 Dumped to /data/local/tmp/ at runtime\n"
                    + "\u2022 Trusted by the Frida SSL bypass\n\n"
                    + "Supports: Reqable, Charles, mitmproxy, Burp Suite")
                .setPositiveButton("Import", (d, w) -> pickCertFile())
                .setNegativeButton("Cancel", null)
                .show();
        }
    }

    private void pickCertFile() {
        Intent intent = new Intent(Intent.ACTION_GET_CONTENT);
        intent.setType("*/*");
        intent.addCategory(Intent.CATEGORY_OPENABLE);
        try {
            startActivityForResult(
                Intent.createChooser(intent, "Select CA Certificate"),
                PICK_CERT);
        } catch (Exception e) {
            log("\u274c Could not open file picker: " + e.getMessage());
        }
    }

    private void importCaCert(Uri uri) {
        new Thread(() -> {
            try {
                // Read cert data
                InputStream is = getContentResolver().openInputStream(uri);
                ByteArrayOutputStream bos = new ByteArrayOutputStream();
                byte[] buf = new byte[8192];
                int len;
                while ((len = is.read(buf)) > 0) bos.write(buf, 0, len);
                is.close();
                byte[] certData = bos.toByteArray();

                if (certData.length < 10 || certData.length > 1048576) {
                    log("\u274c Invalid certificate file (size: " + certData.length + ")");
                    return;
                }

                // Save to internal storage
                FileOutputStream fos = new FileOutputStream(getCaCertFile());
                fos.write(certData);
                fos.close();

                // Extract filename
                String name = uri.getLastPathSegment();
                if (name == null) name = "user_ca.crt";
                if (name.contains("/")) name = name.substring(name.lastIndexOf('/') + 1);
                if (name.contains(":")) name = name.substring(name.lastIndexOf(':') + 1);

                // Store cert name in prefs
                SharedPreferences prefs = getSharedPreferences(PREFS_NAME, MODE_PRIVATE);
                prefs.edit().putString(PREF_CERT_NAME, name).apply();

                final String fName = name;
                final int fSize = certData.length;
                mainHandler.post(() -> {
                    updateCertButton();
                    log("\u2705 CA certificate imported: " + fName + " (" + fSize + " bytes)");
                    log("   Will be embedded in all patched APKs.");
                    Toast.makeText(this, "CA cert imported: " + fName, Toast.LENGTH_SHORT).show();
                });
            } catch (Exception e) {
                mainHandler.post(() -> {
                    log("\u274c Failed to import certificate: " + e.getMessage());
                    Toast.makeText(this, "Import failed: " + e.getMessage(), Toast.LENGTH_LONG).show();
                });
            }
        }).start();
    }

    private void deleteCaCert() {
        File certFile = getCaCertFile();
        if (certFile.exists()) certFile.delete();
        SharedPreferences prefs = getSharedPreferences(PREFS_NAME, MODE_PRIVATE);
        prefs.edit().remove(PREF_CERT_NAME).apply();
        updateCertButton();
        log("🗑 CA certificate deleted");
    }

    private byte[] readFileBytes(File f) throws Exception {
        FileInputStream fis = new FileInputStream(f);
        ByteArrayOutputStream bos = new ByteArrayOutputStream();
        byte[] buf = new byte[8192];
        int len;
        while ((len = fis.read(buf)) > 0) bos.write(buf, 0, len);
        fis.close();
        return bos.toByteArray();
    }

}
