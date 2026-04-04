package in.startv.hspatcher;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.text.Editable;
import android.text.InputType;
import android.text.TextWatcher;
import android.text.TextUtils;
import android.graphics.Typeface;
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
    private TextView heroEyebrow;
    private TextView heroTitle;
    private TextView heroSubtitle;
    private TextView listHeadline;
    private TextView searchHint;
    private TextView emptyState;
    private Button backupToggleBtn;

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

        LinearLayout titleBar = new LinearLayout(this);
        titleBar.setOrientation(LinearLayout.HORIZONTAL);
        titleBar.setGravity(Gravity.CENTER_VERTICAL);
        titleBar.setPadding(0, dp(4), 0, dp(12));

        Button backBtn = buildIconButton("←", 20f);
        backBtn.setOnClickListener(v -> finish());
        titleBar.addView(backBtn, new LinearLayout.LayoutParams(dp(48), dp(48)));

        TextView topLabel = new TextView(this);
        topLabel.setText("APP DECK");
        topLabel.setTextSize(11f);
        topLabel.setLetterSpacing(0.16f);
        topLabel.setTextColor(getColor(R.color.hsp_accent_teal));
        topLabel.setTypeface(null, Typeface.BOLD);
        LinearLayout.LayoutParams topLabelLp = new LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1);
        topLabelLp.leftMargin = dp(12);
        titleBar.addView(topLabel, topLabelLp);

        if (!patchedOnlyMode && !directPlayUpdateMode) {
            backupToggleBtn = buildIconButton("⟲", 16f);
            backupToggleBtn.setOnClickListener(v -> toggleBackupMode());
            titleBar.addView(backupToggleBtn, new LinearLayout.LayoutParams(dp(48), dp(48)));
        }

        root.addView(titleBar);

        LinearLayout heroCard = new LinearLayout(this);
        heroCard.setOrientation(LinearLayout.VERTICAL);
        heroCard.setBackgroundResource(R.drawable.bg_hero_panel);
        heroCard.setPadding(dp(18), dp(18), dp(18), dp(18));
        root.addView(heroCard, new LinearLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT));

        LinearLayout heroTop = new LinearLayout(this);
        heroTop.setOrientation(LinearLayout.HORIZONTAL);
        heroTop.setGravity(Gravity.CENTER_VERTICAL);

        TextView heroBadge = new TextView(this);
        heroBadge.setText(getHeroGlyph());
        heroBadge.setTextSize(20f);
        heroBadge.setGravity(Gravity.CENTER);
        heroBadge.setBackgroundResource(R.drawable.bg_signal_badge);
        heroTop.addView(heroBadge, new LinearLayout.LayoutParams(dp(54), dp(54)));

        LinearLayout heroCopy = new LinearLayout(this);
        heroCopy.setOrientation(LinearLayout.VERTICAL);
        LinearLayout.LayoutParams heroCopyLp = new LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1);
        heroCopyLp.leftMargin = dp(14);

        heroEyebrow = makeLabel("WORKFLOW", R.color.hsp_accent_teal, 10f);
        heroCopy.addView(heroEyebrow);

        heroTitle = new TextView(this);
        heroTitle.setText(getScreenTitle());
        heroTitle.setTextColor(getColor(R.color.hsp_text));
        heroTitle.setTextSize(24f);
        heroTitle.setTypeface(null, Typeface.BOLD);
        heroTitle.setPadding(0, dp(4), 0, 0);
        heroCopy.addView(heroTitle);

        heroSubtitle = new TextView(this);
        heroSubtitle.setText(getHeroSubtitle());
        heroSubtitle.setTextColor(getColor(R.color.hsp_text_muted));
        heroSubtitle.setTextSize(12.5f);
        heroSubtitle.setLineSpacing(0f, 1.08f);
        heroSubtitle.setPadding(0, dp(6), 0, 0);
        heroCopy.addView(heroSubtitle);

        heroTop.addView(heroCopy, heroCopyLp);
        heroCard.addView(heroTop);

        LinearLayout heroChips = new LinearLayout(this);
        heroChips.setOrientation(LinearLayout.HORIZONTAL);
        heroChips.setPadding(0, dp(14), 0, 0);
        heroChips.addView(makeChip(directPlayUpdateMode ? "PLAY UPDATE FLOW" : (patchedOnlyMode ? "PATCHED TARGETS" : "INSTALLED LIBRARY"), R.color.hsp_accent_green));
        heroChips.addView(makeChip(isBackupMode ? "RETURN ORIGINAL APK" : "TEMP EXTRACTION", isBackupMode ? R.color.hsp_accent_amber : R.color.hsp_accent_blue));
        heroCard.addView(heroChips);

        LinearLayout searchCard = new LinearLayout(this);
        searchCard.setOrientation(LinearLayout.VERTICAL);
        searchCard.setBackgroundResource(R.drawable.bg_section_panel);
        searchCard.setPadding(dp(14), dp(14), dp(14), dp(14));
        LinearLayout.LayoutParams searchCardLp = new LinearLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        searchCardLp.topMargin = dp(14);
        root.addView(searchCard, searchCardLp);

        LinearLayout searchHeader = new LinearLayout(this);
        searchHeader.setOrientation(LinearLayout.HORIZONTAL);
        searchHeader.setGravity(Gravity.CENTER_VERTICAL);
        searchCard.addView(searchHeader);

        listHeadline = new TextView(this);
        listHeadline.setText("Target Search");
        listHeadline.setTextColor(getColor(R.color.hsp_text));
        listHeadline.setTextSize(17f);
        listHeadline.setTypeface(null, Typeface.BOLD);
        searchHeader.addView(listHeadline, new LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1));

        statusText = makeLabel("", R.color.hsp_accent_green, 10f);
        statusText.setBackgroundResource(R.drawable.bg_chip);
        statusText.setPadding(dp(10), dp(4), dp(10), dp(4));
        searchHeader.addView(statusText);

        searchHint = new TextView(this);
        searchHint.setText("Search by app name or package, then launch the right flow from a single row.");
        searchHint.setTextColor(getColor(R.color.hsp_text_muted));
        searchHint.setTextSize(12f);
        searchHint.setPadding(0, dp(6), 0, dp(10));
        searchCard.addView(searchHint);

        searchBox = new EditText(this);
        searchBox.setHint("Search apps or package names");
        searchBox.setHintTextColor(getColor(R.color.hsp_text_faint));
        searchBox.setTextColor(getColor(R.color.hsp_text));
        searchBox.setTextSize(14);
        searchBox.setSingleLine(true);
        searchBox.setInputType(InputType.TYPE_CLASS_TEXT);
        searchBox.setBackgroundResource(R.drawable.bg_glass_input);
        searchBox.setPadding(dp(14), dp(12), dp(14), dp(12));
        searchCard.addView(searchBox, new LinearLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT));

        searchBox.addTextChangedListener(new TextWatcher() {
            @Override public void beforeTextChanged(CharSequence s, int a, int b, int c) {}
            @Override public void onTextChanged(CharSequence s, int a, int b, int c) {}
            @Override public void afterTextChanged(Editable s) { filterApps(s.toString()); }
        });

        LinearLayout toggleRow = new LinearLayout(this);
        toggleRow.setOrientation(LinearLayout.HORIZONTAL);
        toggleRow.setGravity(Gravity.CENTER_VERTICAL);
        toggleRow.setPadding(0, dp(12), 0, 0);
        searchCard.addView(toggleRow);

        showSystem = new CheckBox(this);
        showSystem.setTextColor(getColor(R.color.hsp_text_muted));
        showSystem.setText("Include system apps");
        showSystem.setTextSize(12.5f);
        showSystem.setButtonTintList(ColorStateList.valueOf(getColor(R.color.hsp_accent_teal)));
        showSystem.setOnCheckedChangeListener((btn, checked) -> loadApps(checked));
        toggleRow.addView(showSystem, new LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1));

        if (patchedOnlyMode) {
            showSystem.setChecked(false);
            showSystem.setVisibility(View.GONE);
        }

        TextView filterNote = makeLabel(directPlayUpdateMode ? "Play-linked targets only" : "Fast local package scan", R.color.hsp_text_faint, 11f);
        toggleRow.addView(filterNote);

        loadingBar = new ProgressBar(this);
        loadingBar.setIndeterminate(true);
        LinearLayout.LayoutParams loadingLp = new LinearLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT, dp(28));
        loadingLp.topMargin = dp(14);
        root.addView(loadingBar, loadingLp);

        LinearLayout listShell = new LinearLayout(this);
        listShell.setOrientation(LinearLayout.VERTICAL);
        listShell.setBackgroundResource(R.drawable.bg_console_shell);
        listShell.setPadding(dp(14), dp(14), dp(14), dp(14));
        LinearLayout.LayoutParams listShellLp = new LinearLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT, 0, 1);
        listShellLp.topMargin = dp(12);
        root.addView(listShell, listShellLp);

        LinearLayout listHeader = new LinearLayout(this);
        listHeader.setOrientation(LinearLayout.HORIZONTAL);
        listHeader.setGravity(Gravity.CENTER_VERTICAL);
        listShell.addView(listHeader);

        TextView listLabel = makeLabel("TARGETS", R.color.hsp_accent_amber, 10f);
        listHeader.addView(listLabel);

        TextView listSub = new TextView(this);
        listSub.setText(getListHeaderText());
        listSub.setTextColor(getColor(R.color.hsp_text_muted));
        listSub.setTextSize(11.5f);
        LinearLayout.LayoutParams listSubLp = new LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1);
        listSubLp.leftMargin = dp(10);
        listHeader.addView(listSub, listSubLp);

        emptyState = new TextView(this);
        emptyState.setText("");
        emptyState.setTextColor(getColor(R.color.hsp_text_muted));
        emptyState.setTextSize(12.5f);
        emptyState.setGravity(Gravity.CENTER);
        emptyState.setPadding(dp(16), dp(26), dp(16), dp(26));
        emptyState.setBackgroundResource(R.drawable.bg_tools_option);
        emptyState.setVisibility(View.GONE);
        LinearLayout.LayoutParams emptyLp = new LinearLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        emptyLp.topMargin = dp(12);
        listShell.addView(emptyState, emptyLp);

        ScrollView scroll = new ScrollView(this);
        scroll.setFillViewport(true);
        LinearLayout.LayoutParams scrollLp = new LinearLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT, 0, 1);
        scrollLp.topMargin = dp(12);
        listShell.addView(scroll, scrollLp);

        appListContainer = new LinearLayout(this);
        appListContainer.setOrientation(LinearLayout.VERTICAL);
        appListContainer.setPadding(0, 0, 0, dp(12));
        scroll.addView(appListContainer, new ScrollView.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT));

        setContentView(root);
        refreshModeUi();
    }

    private void loadApps(boolean includeSystem) {
        loadingBar.setVisibility(View.VISIBLE);
        appListContainer.removeAllViews();
        emptyState.setVisibility(View.GONE);
        statusText.setText("SCANNING");

        new Thread(() -> {
            List<AppExtractor.AppInfo> apps = AppExtractor.getInstalledApps(this, includeSystem, patchedOnlyMode);
            handler.post(() -> {
                allApps = apps;
                loadingBar.setVisibility(View.GONE);
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
        updateEmptyState(query);
    }

    private View createAppRow(AppExtractor.AppInfo app) {
        LinearLayout row = new LinearLayout(this);
        row.setOrientation(LinearLayout.HORIZONTAL);
        row.setGravity(Gravity.CENTER_VERTICAL);
        row.setPadding(dp(0), dp(0), dp(0), dp(0));
        row.setClickable(true);
        row.setFocusable(true);
        row.setBackgroundResource(R.drawable.bg_tools_option);
        row.setMinimumHeight(dp(94));

        LinearLayout.LayoutParams rowLp = new LinearLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        rowLp.bottomMargin = dp(10);
        row.setLayoutParams(rowLp);

        View accentRail = new View(this);
        accentRail.setBackgroundColor(getColor(getAccentColorForApp(app)));
        LinearLayout.LayoutParams railLp = new LinearLayout.LayoutParams(dp(5), dp(50));
        railLp.leftMargin = dp(12);
        row.addView(accentRail, railLp);

        FrameLayout iconShell = new FrameLayout(this);
        iconShell.setBackgroundResource(R.drawable.bg_chip);
        LinearLayout.LayoutParams iconShellLp = new LinearLayout.LayoutParams(dp(54), dp(54));
        iconShellLp.leftMargin = dp(12);
        iconShellLp.rightMargin = dp(12);
        row.addView(iconShell, iconShellLp);

        ImageView icon = new ImageView(this);
        if (app.icon != null) {
            icon.setImageDrawable(app.icon);
        }
        icon.setScaleType(ImageView.ScaleType.CENTER_CROP);
        FrameLayout.LayoutParams iconLp = new FrameLayout.LayoutParams(dp(40), dp(40), Gravity.CENTER);
        iconShell.addView(icon, iconLp);

        LinearLayout info = new LinearLayout(this);
        info.setOrientation(LinearLayout.VERTICAL);
        info.setPadding(0, dp(14), 0, dp(14));

        TextView nameText = new TextView(this);
        nameText.setText(app.label);
        nameText.setTextColor(getColor(R.color.hsp_text));
        nameText.setTextSize(15.5f);
        nameText.setTypeface(null, Typeface.BOLD);
        nameText.setSingleLine(true);
        nameText.setEllipsize(TextUtils.TruncateAt.END);
        info.addView(nameText);

        TextView pkgText = new TextView(this);
        pkgText.setText(app.packageName);
        pkgText.setTextColor(getColor(R.color.hsp_text_muted));
        pkgText.setTextSize(11.5f);
        pkgText.setSingleLine(true);
        pkgText.setEllipsize(TextUtils.TruncateAt.MIDDLE);
        pkgText.setPadding(0, dp(3), 0, 0);
        info.addView(pkgText);

        LinearLayout metaRow = new LinearLayout(this);
        metaRow.setOrientation(LinearLayout.HORIZONTAL);
        metaRow.setPadding(0, dp(8), 0, 0);
        metaRow.setGravity(Gravity.CENTER_VERTICAL);

        metaRow.addView(makeChip(app.getSizeStr() + " • v" + app.version, R.color.hsp_text_faint));

        if (app.isSplit) {
            metaRow.addView(makeChip("SPLIT", R.color.hsp_accent_teal));
        }

        if (app.patchVersion != null) {
            metaRow.addView(makeChip("PATCHED v" + app.patchVersion, R.color.hsp_accent_amber));
        }

        info.addView(metaRow);
        row.addView(info, new LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1));

        LinearLayout actionCol = new LinearLayout(this);
        actionCol.setOrientation(LinearLayout.VERTICAL);
        actionCol.setGravity(Gravity.END | Gravity.CENTER_VERTICAL);
        actionCol.setPadding(dp(8), dp(0), dp(14), dp(0));

        TextView extractBtn = new TextView(this);
        extractBtn.setText(getActionLabel());
        extractBtn.setTextSize(10.5f);
        extractBtn.setTextColor(getColor(getAccentColorForApp(app)));
        extractBtn.setTypeface(null, Typeface.BOLD);
        extractBtn.setBackgroundResource(R.drawable.bg_chip);
        extractBtn.setGravity(Gravity.CENTER);
        extractBtn.setPadding(dp(10), dp(5), dp(10), dp(5));
        actionCol.addView(extractBtn);

        TextView chevron = new TextView(this);
        chevron.setText("›");
        chevron.setTextColor(getColor(R.color.hsp_text_faint));
        chevron.setTextSize(22f);
        chevron.setPadding(0, dp(6), dp(2), 0);
        actionCol.addView(chevron);

        row.addView(actionCol);

        row.setOnClickListener(v -> onAppSelected(app));
        row.setAlpha(0f);
        row.setTranslationY(dp(12));
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
        emptyState.setVisibility(View.GONE);
        listHeadline.setText("Preparing target");
        searchHint.setText("Verifying source package and staging the extraction workspace.");

        TextView status = new TextView(this);
        status.setText("Extracting " + app.label + "\n");
        status.setTextColor(getColor(R.color.hsp_text_mono));
        status.setTextSize(13);
        status.setBackgroundResource(R.drawable.bg_tools_option);
        status.setPadding(dp(14), dp(16), dp(14), dp(16));
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

                    status.append("\nReady. Returning to patcher...");
                    handler.postDelayed(() -> finish(), 1200);
                });

            } catch (Exception e) {
                handler.post(() -> {
                    loadingBar.setVisibility(View.GONE);
                    status.append("\nError: " + e.getMessage());
                    searchBox.setEnabled(true);
                    listHeadline.setText("Target Search");
                    searchHint.setText("Search by app name or package, then launch the right flow from a single row.");
                });
            }
        }).start();
    }

    private void toggleBackupMode() {
        isBackupMode = !isBackupMode;
        refreshModeUi();
        filterApps(searchBox.getText().toString());
    }

    private void refreshModeUi() {
        if (heroEyebrow != null) {
            heroEyebrow.setText(directPlayUpdateMode ? "PLAY SYNC" : (patchedOnlyMode ? "PATCH INVENTORY" : (isBackupMode ? "BACKUP MODE" : "EXTRACTION MODE")));
            heroEyebrow.setTextColor(getColor(isBackupMode ? R.color.hsp_accent_amber : R.color.hsp_accent_teal));
        }
        if (heroTitle != null) {
            heroTitle.setText(getScreenTitle());
        }
        if (heroSubtitle != null) {
            heroSubtitle.setText(getHeroSubtitle());
        }
        if (listHeadline != null) {
            listHeadline.setText(isBackupMode ? "Backup Targets" : "Target Search");
        }
        if (searchHint != null) {
            searchHint.setText(isBackupMode
                ? "Choose an installed package to return its original APK paths without staging a temp extract."
                : "Search by app name or package, then launch the right flow from a single row.");
        }
        if (backupToggleBtn != null) {
            backupToggleBtn.setText(isBackupMode ? "💾" : "⟲");
            backupToggleBtn.setTextColor(getColor(isBackupMode ? R.color.hsp_accent_amber : R.color.hsp_text));
        }
    }

    private void updateEmptyState(String query) {
        if (emptyState == null) return;
        boolean hasApps = !filteredApps.isEmpty();
        emptyState.setVisibility(hasApps ? View.GONE : View.VISIBLE);
        if (hasApps) return;
        if (allApps.isEmpty()) {
            emptyState.setText(patchedOnlyMode
                ? "No Frida Packer-installed apps were detected on this device yet."
                : "No apps were returned by the package scan. Try enabling system apps or refresh the screen.");
            return;
        }
        String trimmed = query == null ? "" : query.trim();
        if (!trimmed.isEmpty()) {
            emptyState.setText("No matches for '" + trimmed + "'. Try the package name or a shorter keyword.");
        } else {
            emptyState.setText("No apps are visible with the current filters.");
        }
    }

    private int getAccentColorForApp(AppExtractor.AppInfo app) {
        if (app.patchVersion != null) return R.color.hsp_accent_amber;
        if (directPlayUpdateMode) return R.color.hsp_accent_teal;
        if (isBackupMode) return R.color.hsp_accent_blue;
        if (app.isSplit) return R.color.hsp_accent_teal;
        return R.color.hsp_accent_green;
    }

    private String getHeroGlyph() {
        if (directPlayUpdateMode) return "⬇";
        if (patchedOnlyMode) return "🩹";
        return isBackupMode ? "💾" : "📱";
    }

    private String getHeroSubtitle() {
        if (directPlayUpdateMode) {
            return "Review Frida Packer-managed installs and jump straight into the Play update handoff with clean package metadata.";
        }
        if (patchedOnlyMode) {
            return "Filter the installed library down to patched targets so updates and maintenance stay fast and deliberate.";
        }
        if (isBackupMode) {
            return "Return the original APK paths immediately for backup and archive workflows without performing a temp extraction.";
        }
        return "Scan the device, find the right installed target, and stage the package cleanly for patching with split-awareness preserved.";
    }

    private String getListHeaderText() {
        if (directPlayUpdateMode) return "Version-aware rows tuned for direct Play update selection.";
        if (patchedOnlyMode) return "Only Frida Packer-managed installs are shown in this list.";
        return "Large touch targets, metadata chips, and fast selection for extraction.";
    }

    private Button buildIconButton(String text, float textSize) {
        Button button = new Button(this);
        button.setText(text);
        button.setTextSize(textSize);
        button.setTextColor(getColor(R.color.hsp_text));
        button.setBackgroundResource(R.drawable.btn_surface);
        button.setPadding(0, 0, 0, 0);
        return button;
    }

    private TextView makeChip(String text, int colorRes) {
        TextView chip = makeLabel(text, colorRes, 10.5f);
        chip.setBackgroundResource(R.drawable.bg_chip);
        chip.setPadding(dp(10), dp(4), dp(10), dp(4));
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(
            ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        lp.rightMargin = dp(8);
        chip.setLayoutParams(lp);
        return chip;
    }

    private TextView makeLabel(String text, int colorRes, float sizeSp) {
        TextView label = new TextView(this);
        label.setText(text);
        label.setTextColor(getColor(colorRes));
        label.setTextSize(sizeSp);
        label.setTypeface(null, Typeface.BOLD);
        return label;
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
            if (totalCount == 0) return "No Frida Packer-installed apps found";
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
