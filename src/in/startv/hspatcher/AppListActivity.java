package in.startv.hspatcher;

import android.app.Activity;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Log;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.*;

import android.content.res.ColorStateList;
import java.io.*;
import java.util.*;

/**
 * Displays installed apps for extraction.
 * User selects an app -> extracts APK(s) -> returns path to caller.
 */
public class AppListActivity extends Activity {

    public static final String EXTRA_APK_PATH = "extracted_apk_path";
    public static final String EXTRA_IS_SPLIT = "is_split";
    public static final String EXTRA_APP_LABEL = "app_label";
    public static final String EXTRA_BACKUP_MODE = "backup_mode";
    public static final String EXTRA_PACKAGE_NAME = "package_name";
    public static final String EXTRA_SPLIT_DIRS = "split_dirs";
    public static final String EXTRA_PATCHED_ONLY = "patched_only";
    public static final String EXTRA_DIRECT_PLAY_UPDATE = "direct_play_update";
    public static final String EXTRA_PATCH_VERSION = "patch_version";

    private LinearLayout appListContainer;
    private EditText searchBox;
    private TextView statusText;
    private ProgressBar loadingBar;
    private CheckBox showSystem;

    private List<AppExtractor.AppInfo> allApps = new ArrayList<>();
    private List<AppExtractor.AppInfo> filteredApps = new ArrayList<>();
    private Handler handler = new Handler(Looper.getMainLooper());
    private boolean isBackupMode = false;
    private boolean patchedOnlyMode = false;
    private boolean directPlayUpdateMode = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        isBackupMode = getIntent().getBooleanExtra(EXTRA_BACKUP_MODE, false);
        patchedOnlyMode = getIntent().getBooleanExtra(EXTRA_PATCHED_ONLY, false);
        directPlayUpdateMode = getIntent().getBooleanExtra(EXTRA_DIRECT_PLAY_UPDATE, false);
        applyModernSystemUi();
        buildUI();
        loadApps(false);
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

    private void buildUI() {
        LinearLayout root = new LinearLayout(this);
        root.setOrientation(LinearLayout.VERTICAL);
        root.setBackgroundResource(R.drawable.bg_glass_root);
        root.setPadding(dp(16), dp(16), dp(16), dp(16));

        // Title bar
        LinearLayout titleBar = new LinearLayout(this);
        titleBar.setOrientation(LinearLayout.HORIZONTAL);
        titleBar.setGravity(Gravity.CENTER_VERTICAL);
        titleBar.setPadding(0, dp(8), 0, dp(12));

        Button backBtn = new Button(this);
        backBtn.setText("←");
        backBtn.setTextSize(20);
        backBtn.setTextColor(getColor(R.color.hsp_text));
        backBtn.setBackgroundResource(R.drawable.btn_surface);
        backBtn.setPadding(0, 0, dp(8), 0);
        backBtn.setOnClickListener(v -> finish());
        titleBar.addView(backBtn, new LinearLayout.LayoutParams(dp(48), dp(48)));

        TextView title = new TextView(this);
        title.setText(getScreenTitle());
        title.setTextSize(20);
        title.setTextColor(getColor(R.color.hsp_accent_green));
        title.setTypeface(null, android.graphics.Typeface.BOLD);
        LinearLayout.LayoutParams titleLp = new LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1);
        titleBar.addView(title, titleLp);

        // Backup button in title bar
        Button backupBtn = new Button(this);
        backupBtn.setText("💾");
        backupBtn.setTextSize(18);
        backupBtn.setTextColor(getColor(R.color.hsp_text));
        backupBtn.setBackgroundResource(R.drawable.btn_surface);
        backupBtn.setPadding(0, 0, 0, 0);
        backupBtn.setOnClickListener(v -> {
            isBackupMode = !isBackupMode;
            backupBtn.setTextColor(getColor(isBackupMode ? R.color.hsp_accent_amber : R.color.hsp_text));
            title.setText(isBackupMode ? "💾 Backup Installed App" : "📱 Installed Apps");
            statusText.setText(isBackupMode ? "Tap an app to return original APK paths" : "Tap an app to extract to temp workspace");
        });
        if (!patchedOnlyMode && !directPlayUpdateMode) {
            titleBar.addView(backupBtn, new LinearLayout.LayoutParams(dp(48), dp(48)));
        }

        root.addView(titleBar);

        // Search box
        searchBox = new EditText(this);
        searchBox.setHint("🔍 Search apps...");
        searchBox.setHintTextColor(getColor(R.color.hsp_text_faint));
        searchBox.setTextColor(getColor(R.color.hsp_text));
        searchBox.setTextSize(14);
        searchBox.setPadding(dp(12), dp(10), dp(12), dp(10));
        searchBox.setSingleLine(true);

        searchBox.setBackgroundResource(R.drawable.bg_glass_input);

        root.addView(searchBox, new LinearLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT));

        searchBox.addTextChangedListener(new TextWatcher() {
            @Override public void beforeTextChanged(CharSequence s, int a, int b, int c) {}
            @Override public void onTextChanged(CharSequence s, int a, int b, int c) {}
            @Override public void afterTextChanged(Editable s) { filterApps(s.toString()); }
        });

        // Show system apps toggle
        LinearLayout toggleRow = new LinearLayout(this);
        toggleRow.setOrientation(LinearLayout.HORIZONTAL);
        toggleRow.setGravity(Gravity.CENTER_VERTICAL);
        toggleRow.setPadding(0, dp(8), 0, dp(4));

        showSystem = new CheckBox(this);
        showSystem.setTextColor(getColor(R.color.hsp_text_muted));
        showSystem.setText("Show system apps");
        showSystem.setTextSize(13);
        showSystem.setButtonTintList(ColorStateList.valueOf(getColor(R.color.hsp_accent_green)));
        showSystem.setOnCheckedChangeListener((btn, checked) -> loadApps(checked));
        toggleRow.addView(showSystem);

        if (patchedOnlyMode) {
            showSystem.setChecked(false);
            showSystem.setVisibility(View.GONE);
        }

        statusText = new TextView(this);
        statusText.setTextColor(getColor(R.color.hsp_text_muted));
        statusText.setTextSize(12);
        statusText.setGravity(Gravity.END);
        LinearLayout.LayoutParams stlp = new LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1);
        toggleRow.addView(statusText, stlp);

        root.addView(toggleRow);

        // Loading bar
        loadingBar = new ProgressBar(this);
        loadingBar.setIndeterminate(true);
        root.addView(loadingBar, new LinearLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT, dp(32)));

        // Scrollable app list
        ScrollView scroll = new ScrollView(this);
        scroll.setFillViewport(true);

        appListContainer = new LinearLayout(this);
        appListContainer.setOrientation(LinearLayout.VERTICAL);
        appListContainer.setPadding(0, dp(4), 0, dp(16));
        scroll.addView(appListContainer);

        LinearLayout.LayoutParams scrollLp = new LinearLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT, 0, 1);
        scrollLp.topMargin = dp(8);
        root.addView(scroll, scrollLp);

        setContentView(root);
    }

    private void loadApps(boolean includeSystem) {
        loadingBar.setVisibility(View.VISIBLE);
        appListContainer.removeAllViews();
        statusText.setText("Loading...");

        new Thread(() -> {
            List<AppExtractor.AppInfo> apps = AppExtractor.getInstalledApps(this, includeSystem, patchedOnlyMode);
            handler.post(() -> {
                allApps = apps;
                loadingBar.setVisibility(View.GONE);
                statusText.setText(getStatusText(apps.size(), apps.size()));
                filterApps(searchBox.getText().toString());
            });
        }).start();
    }

    private void filterApps(String query) {
        filteredApps.clear();
        String q = query.toLowerCase().trim();
        for (AppExtractor.AppInfo app : allApps) {
            if (q.isEmpty() || app.label.toLowerCase().contains(q) || app.packageName.toLowerCase().contains(q)) {
                filteredApps.add(app);
            }
        }

        appListContainer.removeAllViews();
        for (AppExtractor.AppInfo app : filteredApps) {
            appListContainer.addView(createAppRow(app));
        }
        statusText.setText(getStatusText(filteredApps.size(), allApps.size()));
    }

    private View createAppRow(AppExtractor.AppInfo app) {
        LinearLayout row = new LinearLayout(this);
        row.setOrientation(LinearLayout.HORIZONTAL);
        row.setGravity(Gravity.CENTER_VERTICAL);
        row.setPadding(dp(12), dp(10), dp(12), dp(10));
        row.setClickable(true);
        row.setFocusable(true);

        row.setBackgroundResource(R.drawable.bg_tools_option);

        LinearLayout.LayoutParams rowLp = new LinearLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        rowLp.bottomMargin = dp(6);
        row.setLayoutParams(rowLp);

        // App icon
        ImageView icon = new ImageView(this);
        if (app.icon != null) {
            icon.setImageDrawable(app.icon);
        }
        LinearLayout.LayoutParams iconLp = new LinearLayout.LayoutParams(dp(44), dp(44));
        iconLp.rightMargin = dp(12);
        row.addView(icon, iconLp);

        // App info (name, package, size)
        LinearLayout info = new LinearLayout(this);
        info.setOrientation(LinearLayout.VERTICAL);

        TextView nameText = new TextView(this);
        nameText.setText(app.label);
        nameText.setTextColor(getColor(R.color.hsp_text));
        nameText.setTextSize(15);
        nameText.setSingleLine(true);
        info.addView(nameText);

        TextView pkgText = new TextView(this);
        pkgText.setText(app.packageName);
        pkgText.setTextColor(getColor(R.color.hsp_text_muted));
        pkgText.setTextSize(11);
        pkgText.setSingleLine(true);
        info.addView(pkgText);

        LinearLayout metaRow = new LinearLayout(this);
        metaRow.setOrientation(LinearLayout.HORIZONTAL);
        metaRow.setPadding(0, dp(2), 0, 0);

        TextView sizeText = new TextView(this);
        sizeText.setText(app.getSizeStr() + "  v" + app.version);
        sizeText.setTextColor(getColor(R.color.hsp_text_faint));
        sizeText.setTextSize(11);
        metaRow.addView(sizeText);

        if (app.isSplit) {
            TextView splitBadge = new TextView(this);
            splitBadge.setText(" SPLIT");
            splitBadge.setTextColor(getColor(R.color.hsp_accent_teal));
            splitBadge.setTextSize(10);
            splitBadge.setPadding(dp(6), 0, dp(6), 0);
            splitBadge.setBackgroundResource(R.drawable.bg_chip);
            LinearLayout.LayoutParams badgeLp = new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
            badgeLp.leftMargin = dp(8);
            metaRow.addView(splitBadge, badgeLp);
        }

        if (app.patchVersion != null) {
            TextView patchedBadge = new TextView(this);
            patchedBadge.setText(" PATCHED v" + app.patchVersion);
            patchedBadge.setTextColor(getColor(R.color.hsp_accent_amber));
            patchedBadge.setTextSize(10);
            patchedBadge.setPadding(dp(6), 0, dp(6), 0);
            patchedBadge.setBackgroundResource(R.drawable.bg_chip);
            LinearLayout.LayoutParams badgeLp = new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
            badgeLp.leftMargin = dp(8);
            metaRow.addView(patchedBadge, badgeLp);
        }

        info.addView(metaRow);
        row.addView(info, new LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1));

        // Extract button (arrow icon)
        TextView extractBtn = new TextView(this);
        extractBtn.setText(getActionLabel());
        extractBtn.setTextSize(10);
        extractBtn.setTextColor(getColor(R.color.hsp_accent_green));
        extractBtn.setTypeface(null, android.graphics.Typeface.BOLD);
        extractBtn.setBackgroundResource(R.drawable.bg_chip);
        extractBtn.setGravity(Gravity.CENTER);
        extractBtn.setPadding(dp(8), dp(4), dp(8), dp(4));
        row.addView(extractBtn, new LinearLayout.LayoutParams(
            ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT));

        // Click handler
        row.setOnClickListener(v -> onAppSelected(app));
        row.setAlpha(0f);
        row.setTranslationY(dp(8));
        row.animate().alpha(1f).translationY(0f).setDuration(180).start();

        return row;
    }

    private void onAppSelected(AppExtractor.AppInfo app) {
        if (directPlayUpdateMode) {
            Intent resultIntent = new Intent();
            resultIntent.putExtra(EXTRA_PACKAGE_NAME, app.packageName);
            resultIntent.putExtra(EXTRA_APP_LABEL, app.label);
            resultIntent.putExtra(EXTRA_PATCH_VERSION, app.patchVersion);
            setResult(RESULT_OK, resultIntent);
            finish();
            return;
        }

        // Backup mode: skip temp extraction, return original APK paths directly
        if (isBackupMode || getIntent().getBooleanExtra(EXTRA_BACKUP_MODE, false)) {
            Intent resultIntent = new Intent();
            resultIntent.putExtra(EXTRA_APK_PATH, app.sourceDir);
            resultIntent.putExtra(EXTRA_IS_SPLIT, app.isSplit);
            resultIntent.putExtra(EXTRA_APP_LABEL, app.label);
            resultIntent.putExtra(EXTRA_PACKAGE_NAME, app.packageName);
            resultIntent.putExtra(EXTRA_BACKUP_MODE, true);
            if (app.splitSourceDirs != null) {
                resultIntent.putExtra(EXTRA_SPLIT_DIRS, app.splitSourceDirs);
            }
            setResult(RESULT_OK, resultIntent);
            finish();
            return;
        }
        // Show extracting dialog
        appListContainer.removeAllViews();
        searchBox.setEnabled(false);

        TextView status = new TextView(this);
        status.setText("📦 Extracting " + app.label + "...\n");
        status.setTextColor(getColor(R.color.hsp_text_mono));
        status.setTextSize(13);
        status.setPadding(dp(8), dp(16), dp(8), 0);
        appListContainer.addView(status);

        loadingBar.setVisibility(View.VISIBLE);

        new Thread(() -> {
            try {
                File extractDir = new File(getFilesDir(), "extracted_apks");
                if (extractDir.exists()) deleteDir(extractDir);

                File result = AppExtractor.extractApp(app, extractDir, msg -> {
                    handler.post(() -> status.append(msg + "\n"));
                });

                handler.post(() -> {
                    loadingBar.setVisibility(View.GONE);

                    Intent resultIntent = new Intent();
                    resultIntent.putExtra(EXTRA_APK_PATH, result.getAbsolutePath());
                    resultIntent.putExtra(EXTRA_IS_SPLIT, app.isSplit);
                    resultIntent.putExtra(EXTRA_APP_LABEL, app.label);
                    setResult(RESULT_OK, resultIntent);

                    status.append("\n✅ Extraction complete!\nReturning to patcher...");
                    handler.postDelayed(() -> finish(), 1200);
                });

            } catch (Exception e) {
                handler.post(() -> {
                    loadingBar.setVisibility(View.GONE);
                    status.append("\n❌ Error: " + e.getMessage());
                    searchBox.setEnabled(true);
                });
            }
        }).start();
    }

    private void deleteDir(File dir) {
        if (dir.isDirectory()) {
            File[] children = dir.listFiles();
            if (children != null) for (File c : children) deleteDir(c);
        }
        dir.delete();
    }

    private int dp(int val) {
        return (int) TypedValue.applyDimension(
            TypedValue.COMPLEX_UNIT_DIP, val, getResources().getDisplayMetrics());
    }

    private String getScreenTitle() {
        if (directPlayUpdateMode) return "⬇️ Patched App Updates";
        if (patchedOnlyMode) return "🩹 Patched Apps";
        return "📱 Installed Apps";
    }

    private String getActionLabel() {
        if (directPlayUpdateMode) return "UPDATE";
        return isBackupMode ? "BACKUP" : "OPEN";
    }

    private String getStatusText(int visibleCount, int totalCount) {
        if (patchedOnlyMode) {
            if (totalCount == 0) return "No HSPatcher-installed apps found";
            if (visibleCount == totalCount) {
                return totalCount + " patched app" + (totalCount == 1 ? "" : "s")
                    + (directPlayUpdateMode ? " ready for Play update" : " found");
            }
            return visibleCount + " / " + totalCount + " patched apps";
        }
        return visibleCount == totalCount
            ? totalCount + " apps"
            : visibleCount + " / " + totalCount + " apps";
    }
}
