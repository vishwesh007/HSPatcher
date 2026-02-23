package in.startv.hspatcher;

import android.app.Activity;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.graphics.Color;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.GradientDrawable;
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

    private LinearLayout appListContainer;
    private EditText searchBox;
    private TextView statusText;
    private ProgressBar loadingBar;
    private CheckBox showSystem;

    private List<AppExtractor.AppInfo> allApps = new ArrayList<>();
    private List<AppExtractor.AppInfo> filteredApps = new ArrayList<>();
    private Handler handler = new Handler(Looper.getMainLooper());

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        buildUI();
        loadApps(false);
    }

    private void buildUI() {
        LinearLayout root = new LinearLayout(this);
        root.setOrientation(LinearLayout.VERTICAL);
        root.setBackgroundColor(0xFF121212);
        root.setPadding(dp(16), dp(16), dp(16), dp(16));

        // Title bar
        LinearLayout titleBar = new LinearLayout(this);
        titleBar.setOrientation(LinearLayout.HORIZONTAL);
        titleBar.setGravity(Gravity.CENTER_VERTICAL);
        titleBar.setPadding(0, dp(8), 0, dp(12));

        Button backBtn = new Button(this);
        backBtn.setText("←");
        backBtn.setTextSize(20);
        backBtn.setTextColor(0xFFFFFFFF);
        backBtn.setBackgroundColor(0x00000000);
        backBtn.setPadding(0, 0, dp(8), 0);
        backBtn.setOnClickListener(v -> finish());
        titleBar.addView(backBtn, new LinearLayout.LayoutParams(dp(48), dp(48)));

        TextView title = new TextView(this);
        title.setText("📱 Extract from Installed Apps");
        title.setTextSize(20);
        title.setTextColor(0xFF00E676);
        titleBar.addView(title, new LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1));

        root.addView(titleBar);

        // Search box
        searchBox = new EditText(this);
        searchBox.setHint("🔍 Search apps...");
        searchBox.setHintTextColor(0x66FFFFFF);
        searchBox.setTextColor(0xFFFFFFFF);
        searchBox.setTextSize(14);
        searchBox.setBackgroundColor(0xFF1E1E1E);
        searchBox.setPadding(dp(12), dp(10), dp(12), dp(10));
        searchBox.setSingleLine(true);

        GradientDrawable searchBg = new GradientDrawable();
        searchBg.setColor(0xFF1E1E1E);
        searchBg.setCornerRadius(dp(8));
        searchBg.setStroke(1, 0x33FFFFFF);
        searchBox.setBackground(searchBg);

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
        showSystem.setTextColor(0x99FFFFFF);
        showSystem.setText("Show system apps");
        showSystem.setTextSize(13);
        showSystem.setButtonTintList(android.content.res.ColorStateList.valueOf(0xFF00E676));
        showSystem.setOnCheckedChangeListener((btn, checked) -> loadApps(checked));
        toggleRow.addView(showSystem);

        statusText = new TextView(this);
        statusText.setTextColor(0x99FFFFFF);
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
            List<AppExtractor.AppInfo> apps = AppExtractor.getInstalledApps(this, includeSystem);
            handler.post(() -> {
                allApps = apps;
                loadingBar.setVisibility(View.GONE);
                statusText.setText(apps.size() + " apps");
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
        statusText.setText(filteredApps.size() + " / " + allApps.size() + " apps");
    }

    private View createAppRow(AppExtractor.AppInfo app) {
        LinearLayout row = new LinearLayout(this);
        row.setOrientation(LinearLayout.HORIZONTAL);
        row.setGravity(Gravity.CENTER_VERTICAL);
        row.setPadding(dp(12), dp(10), dp(12), dp(10));
        row.setClickable(true);

        GradientDrawable rowBg = new GradientDrawable();
        rowBg.setColor(0xFF1E1E1E);
        rowBg.setCornerRadius(dp(8));
        row.setBackground(rowBg);

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
        nameText.setTextColor(0xFFFFFFFF);
        nameText.setTextSize(15);
        nameText.setSingleLine(true);
        info.addView(nameText);

        TextView pkgText = new TextView(this);
        pkgText.setText(app.packageName);
        pkgText.setTextColor(0x88FFFFFF);
        pkgText.setTextSize(11);
        pkgText.setSingleLine(true);
        info.addView(pkgText);

        LinearLayout metaRow = new LinearLayout(this);
        metaRow.setOrientation(LinearLayout.HORIZONTAL);
        metaRow.setPadding(0, dp(2), 0, 0);

        TextView sizeText = new TextView(this);
        sizeText.setText(app.getSizeStr() + "  v" + app.version);
        sizeText.setTextColor(0x66FFFFFF);
        sizeText.setTextSize(11);
        metaRow.addView(sizeText);

        if (app.isSplit) {
            TextView splitBadge = new TextView(this);
            splitBadge.setText(" SPLIT");
            splitBadge.setTextColor(0xFF00BCD4);
            splitBadge.setTextSize(10);
            splitBadge.setPadding(dp(6), 0, dp(6), 0);
            GradientDrawable badgeBg = new GradientDrawable();
            badgeBg.setColor(0x2200BCD4);
            badgeBg.setCornerRadius(dp(4));
            splitBadge.setBackground(badgeBg);
            LinearLayout.LayoutParams badgeLp = new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
            badgeLp.leftMargin = dp(8);
            metaRow.addView(splitBadge, badgeLp);
        }

        info.addView(metaRow);
        row.addView(info, new LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1));

        // Extract button (arrow icon)
        TextView extractBtn = new TextView(this);
        extractBtn.setText("→");
        extractBtn.setTextSize(20);
        extractBtn.setTextColor(0xFF00E676);
        extractBtn.setGravity(Gravity.CENTER);
        extractBtn.setPadding(dp(8), 0, 0, 0);
        row.addView(extractBtn, new LinearLayout.LayoutParams(dp(36), dp(36)));

        // Click handler
        row.setOnClickListener(v -> onAppSelected(app));

        return row;
    }

    private void onAppSelected(AppExtractor.AppInfo app) {
        // Show extracting dialog
        appListContainer.removeAllViews();
        searchBox.setEnabled(false);

        TextView status = new TextView(this);
        status.setText("📦 Extracting " + app.label + "...\n");
        status.setTextColor(0xFFCCCCCC);
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
}
