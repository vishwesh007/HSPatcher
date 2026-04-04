package in.startv.hspatcher;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.ClipData;
import android.content.ComponentName;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.graphics.Typeface;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.os.Looper;
import android.text.Editable;
import android.text.InputType;
import android.text.TextWatcher;
import android.util.Log;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AbsListView;
import android.widget.AdapterView;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.ProgressBar;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.Toast;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.lang.reflect.Field;
import java.security.MessageDigest;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Properties;
import java.util.Set;
import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;
import java.util.zip.ZipOutputStream;

import brut.androlib.ApkDecoder;
import brut.androlib.Config;
import brut.androlib.apk.ApkInfo;
import brut.androlib.src.SmaliBuilder;
import brut.directory.ExtFile;

public class ApkEditorActivity extends Activity {

    private static final String TAG = "ApkEditorActivity";

    private static final int PICK_APK = 5101;
    private static final int PICK_REPLACE_FILE = 5102;
    private static final int PICK_INSTALLED_APP = 5103;

    private static final String PREFS = "apk_editor_prefs";
    private static final String PREF_LAST_WORKSPACE = "last_workspace";
    private static final String META_FILE = ".hsp_workspace.properties";
    private static final String HASH_FILE = ".hsp_baseline.sha";
    private static final String APKEDITOR_PACKAGE = "com.apk.editor";
    private static final String APKEDITOR_ACTIVITY = "com.apk.editor.MainActivity";
    private static final String APKEDITOR_ASSET = "apkeditor/AEE_v0.32.apk";
    private static final String APKEDITOR_FILE = "AEE_v0.32.apk";
    private static final String[] XED_PACKAGES = new String[] {
        "com.rk.xededitor.debug",
        "com.rk.xededitor"
    };
    private static final String MERGED_XED_ACTIVITY = "com.rk.activities.main.MainActivity";
    private static final String XED_EXTRA_WORKSPACE_PATH = "hsp_workspace_path";
    private static final String XED_EXTRA_FOCUS_FILE = "hsp_workspace_focus_file";
    private static final String XED_EXTRA_DIRECT_JAR_WORKFLOW = "hsp_direct_jar_workflow";
    private static final String XED_EXTRA_IMPORT_APK_PATH = "hsp_import_apk_path";
    private static final String XED_EXTRA_IMPORT_APP_NAME = "hsp_import_app_name";
    private static final String XED_GITHUB_URL = "https://github.com/Xed-Editor/Xed-Editor";

    private static final short DECODE_SOURCES_NONE = 0;
    private static final short DECODE_SOURCES_FULL = 1;
    private static final short DECODE_SOURCES_ONLY_MAIN = 16;
    private static final short DECODE_ASSETS_NONE = 0;
    private static final short DECODE_RESOURCES_RAW = 256;

    private final Handler mainHandler = new Handler(Looper.getMainLooper());
    private final List<FileEntry> visibleEntries = new ArrayList<>();
    private final FileListAdapter adapter = new FileListAdapter();

    private TextView tvSelectedApk;
    private TextView tvWorkspace;
    private TextView tvCurrentDir;
    private TextView tvFolderSummary;
    private TextView tvStatus;
    private TextView tvLog;
    private ProgressBar progressBar;
    private EditText etFilter;
    private CheckBox cbAllSources;
    private CheckBox cbNoAssets;
    private CheckBox cbKeepBroken;
    private Button btnDecode;
    private Button btnRebuild;
    private Button btnInstall;
    private Button btnUp;
    private Button btnNewFile;
    private Button btnNewFolder;
    private Button btnToolbarBack;
    private Button btnResumeProject;
    private ListView listView;
    private ScrollView homeScroll;
    private LinearLayout workspacePanel;
    private LinearLayout homeCardsHost;
    private TextView tvToolbarTitle;
    private TextView tvHomeProject;

    private File workspaceBaseDir;
    private File currentWorkspaceDir;
    private File decodedDir;
    private File currentDir;
    private File selectedApkFile;
    private File builtSignedApk;
    private File pendingReplaceTarget;
    private boolean busy;
    private boolean directJarWorkflow;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        applyModernSystemUi();
        directJarWorkflow = getIntent() != null
            && getIntent().getBooleanExtra(XED_EXTRA_DIRECT_JAR_WORKFLOW, false);
        workspaceBaseDir = resolveWorkspaceBaseDir();
        buildUi();
        restoreWorkspace();

        boolean openedFromIntent = false;

        String apkPath = getIntent() != null ? getIntent().getStringExtra("apk_path") : null;
        if (apkPath != null && !apkPath.trim().isEmpty()) {
            File file = new File(apkPath);
            if (file.isFile()) {
                prepareWorkspaceForApk(file.getName());
                File copied = new File(currentWorkspaceDir, "input.apk");
                try {
                    copyFile(file, copied);
                    setSelectedApk(copied);
                    openedFromIntent = true;
                } catch (IOException e) {
                    log("❌ Could not stage APK from intent: " + safeMessage(e));
                }
            }
        }

        if (openedFromIntent) {
            if (directJarWorkflow) {
                decodeWorkspaceWithApkEditorJar();
                return;
            }
            showWorkspaceShell();
        } else {
            showHomeShell();
            if (directJarWorkflow) {
                mainHandler.post(this::showDirectJarWorkflowChooser);
            }
        }
        updateHomeProjectState();
    }

    private void showDirectJarWorkflowChooser() {
        boolean hasResume = false;
        if (currentWorkspaceDir != null) {
            File lastDecoded = new File(currentWorkspaceDir, "decoded");
            hasResume = lastDecoded.isDirectory();
        }

        LinearLayout root = new LinearLayout(this);
        root.setOrientation(LinearLayout.VERTICAL);
        int pad = (int) (16 * getResources().getDisplayMetrics().density);
        root.setPadding(pad, pad / 2, pad, pad / 2);

        TextView desc = new TextView(this);
        desc.setText("Decode with APKEditor.jar in Ubuntu, then edit in Xed.");
        desc.setTextColor(0xFFCCCCCC);
        desc.setTextSize(13);
        root.addView(desc);

        View spacer = new View(this);
        spacer.setMinimumHeight(pad);
        root.addView(spacer);

        addChooserButton(root, "\uD83D\uDCF1  Installed app", v -> pickInstalledApp());
        addChooserButton(root, "\uD83D\uDCC2  APK file", v -> pickApk());

        if (hasResume) {
            addChooserButton(root, "\u25B6  Resume in Xed", v -> {
                decodedDir = new File(currentWorkspaceDir, "decoded");
                currentDir = decodedDir;
                if (launchXedApp()) {
                    finish();
                } else {
                    toast("Could not open Xed workspace");
                }
            });
        }

        ScrollView scrollView = new ScrollView(this);
        scrollView.addView(root);

        jarChooserDialog = new AlertDialog.Builder(this, android.R.style.Theme_Material_Dialog)
            .setTitle("APKEditor.jar workspace")
            .setView(scrollView)
            .setOnCancelListener(dialog -> finish())
            .show();
    }

    private AlertDialog jarChooserDialog;

    private void addChooserButton(LinearLayout parent, String label, View.OnClickListener action) {
        Button btn = new Button(this);
        btn.setText(label);
        btn.setAllCaps(false);
        btn.setBackgroundColor(0x33FFFFFF);
        btn.setTextColor(0xFFFFFFFF);
        btn.setTextSize(15);
        btn.setPadding(24, 20, 24, 20);
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT);
        lp.bottomMargin = (int) (8 * getResources().getDisplayMetrics().density);
        btn.setLayoutParams(lp);
        btn.setOnClickListener(v -> {
            if (jarChooserDialog != null) jarChooserDialog.dismiss();
            action.onClick(v);
        });
        parent.addView(btn);
    }

    @Override
    protected void onResume() {
        super.onResume();
        refreshCurrentDirectory();
        updateBuildButtons();
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
        }
    }

    private void buildUi() {
        LinearLayout shell = new LinearLayout(this);
        shell.setOrientation(LinearLayout.VERTICAL);
        shell.setBackgroundResource(R.drawable.bg_glass_root);
        shell.setPadding(dp(14), dp(16), dp(14), dp(14));

        shell.addView(buildToolbar());

        homeScroll = buildHomePanel();
        shell.addView(homeScroll, new LinearLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT, 0, 1f));

        workspacePanel = buildWorkspacePanel();
        workspacePanel.setVisibility(View.GONE);
        shell.addView(workspacePanel, new LinearLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT, 0, 1f));

        setContentView(shell);
        updateBuildButtons();
    }

    private View buildToolbar() {
        LinearLayout toolbar = new LinearLayout(this);
        toolbar.setOrientation(LinearLayout.HORIZONTAL);
        toolbar.setGravity(Gravity.CENTER_VERTICAL);
        toolbar.setPadding(0, 0, 0, dp(12));

        btnToolbarBack = makeCompactAction("←");
        btnToolbarBack.setOnClickListener(v -> showHomeShell());
        toolbar.addView(btnToolbarBack);

        LinearLayout titleCol = new LinearLayout(this);
        titleCol.setOrientation(LinearLayout.VERTICAL);
        LinearLayout.LayoutParams titleLp = new LinearLayout.LayoutParams(0,
            ViewGroup.LayoutParams.WRAP_CONTENT, 1f);
        titleLp.leftMargin = dp(10);
        titleLp.rightMargin = dp(10);
        toolbar.addView(titleCol, titleLp);

        tvToolbarTitle = new TextView(this);
        tvToolbarTitle.setText("APK Editor");
        tvToolbarTitle.setTextSize(22);
        tvToolbarTitle.setTypeface(null, Typeface.BOLD);
        tvToolbarTitle.setTextColor(getColor(R.color.hsp_text));
        titleCol.addView(tvToolbarTitle);

        TextView subtitle = new TextView(this);
        subtitle.setText("Embedded APK Explorer & Editor bridge on Frida Packer's tested backend");
        subtitle.setTextSize(11);
        subtitle.setTextColor(getColor(R.color.hsp_text_muted));
        titleCol.addView(subtitle);

        Button btnSettings = makeCompactAction("⚙");
        btnSettings.setOnClickListener(v -> showEditorSettingsDialog());
        toolbar.addView(btnSettings);

        Button btnMenu = makeCompactAction("⋮");
        btnMenu.setOnClickListener(v -> showOverflowMenu());
        toolbar.addView(btnMenu);
        return toolbar;
    }

    private ScrollView buildHomePanel() {
        ScrollView scrollView = new ScrollView(this);
        scrollView.setFillViewport(true);
        scrollView.setOverScrollMode(View.OVER_SCROLL_IF_CONTENT_SCROLLS);

        LinearLayout content = new LinearLayout(this);
        content.setOrientation(LinearLayout.VERTICAL);
        scrollView.addView(content, new ViewGroup.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT));

        TextView badge = new TextView(this);
        badge.setText("APKEDITOR DIRECT");
        badge.setTextSize(10);
        badge.setTypeface(null, Typeface.BOLD);
        badge.setTextColor(getColor(R.color.hsp_accent_teal));
        badge.setBackgroundResource(R.drawable.bg_chip);
        badge.setPadding(dp(10), dp(4), dp(10), dp(4));
        content.addView(badge);

        TextView title = new TextView(this);
        title.setText("APK Explorer & Editor bundled here");
        title.setTextSize(30);
        title.setTypeface(null, Typeface.BOLD);
        title.setTextColor(getColor(R.color.hsp_text));
        title.setPadding(0, dp(10), 0, 0);
        content.addView(title);

        TextView intro = new TextView(this);
        intro.setText("This bridge installs or launches the bundled APK Explorer & Editor package directly. The native Frida Packer workspace remains available as a fallback for the Android-safe decode and rebuild flow already validated on device.");
        intro.setTextSize(12);
        intro.setTextColor(getColor(R.color.hsp_text_muted));
        intro.setPadding(0, dp(6), 0, dp(8));
        content.addView(intro);

        tvHomeProject = infoLabel("No project staged yet.");
        content.addView(tvHomeProject);

        btnResumeProject = makeButton("📂 RESUME LAST PROJECT", getColor(R.color.hsp_accent_teal));
        btnResumeProject.setOnClickListener(v -> showWorkspaceShell());
        LinearLayout.LayoutParams resumeLp = new LinearLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT, dp(48));
        resumeLp.topMargin = dp(8);
        content.addView(btnResumeProject, resumeLp);

        homeCardsHost = new LinearLayout(this);
        homeCardsHost.setOrientation(LinearLayout.VERTICAL);
        homeCardsHost.setPadding(0, dp(10), 0, 0);
        content.addView(homeCardsHost);

        addHomeCard("Launch AEE", "Open the bundled com.apk.editor app directly", "🚀",
            getColor(R.color.hsp_accent_blue), v -> launchRealApkEditorOrInstall());
        addHomeCard("Install or update AEE", "Extract the bundled AEE_v0.32.apk and open the system installer", "📦",
            getColor(R.color.hsp_accent_amber), v -> installBundledApkEditor());
        addHomeCard("Launch Xed Editor", "Open the upstream Xed code editor for richer text/code editing", "✍",
            getColor(R.color.hsp_accent_purple), v -> launchXedAppOrGitHub());
        addHomeCard("Frida Packer workspace", "Use the native on-device decode, edit, rebuild, sign, and install flow", "🧩",
            getColor(R.color.hsp_accent_teal), v -> showWorkspaceShell());
        addHomeCard("Sign APK", "Select and sign APK files with the built-in signer", "🛡",
            getColor(R.color.hsp_accent_green), v -> startActivity(new Intent(this, ApkSignerActivity.class)));
        addHomeCard("Data base", "View or edit SQLite database files", "⚙",
            getColor(R.color.hsp_accent_indigo), v -> startActivity(new Intent(this, DbEditorActivity.class)));
        addHomeCard("Settings", "Bridge, decoding, rebuild, and workspace options", "⚙",
            getColor(R.color.hsp_accent_purple), v -> showEditorSettingsDialog());
        addHomeCard("Exit", "Return to Frida Packer", "↪",
            getColor(R.color.hsp_legacy_backup), v -> finish());

        TextView footer = new TextView(this);
        footer.setText("Bundled bridge target: com.apk.editor • source: APK Explorer & Editor (AEE) v0.32 from apk-editor/APK-Explorer-Editor.");
        footer.setTextSize(11);
        footer.setTextColor(getColor(R.color.hsp_text_faint));
        footer.setPadding(dp(4), dp(12), dp(4), dp(8));
        content.addView(footer);
        return scrollView;
    }

    private LinearLayout buildWorkspacePanel() {
        LinearLayout root = new LinearLayout(this);
        root.setOrientation(LinearLayout.VERTICAL);

        ScrollView controlsScroll = new ScrollView(this);
        controlsScroll.setFillViewport(true);
        controlsScroll.setOverScrollMode(View.OVER_SCROLL_IF_CONTENT_SCROLLS);
        LinearLayout.LayoutParams controlsParams = new LinearLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            Math.max(dp(240), Math.min((int) (getResources().getDisplayMetrics().heightPixels * 0.38f), dp(520))));
        controlsScroll.setLayoutParams(controlsParams);

        LinearLayout controlsContainer = new LinearLayout(this);
        controlsContainer.setOrientation(LinearLayout.VERTICAL);
        controlsScroll.addView(controlsContainer, new ViewGroup.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT));
        root.addView(controlsScroll);

        TextView header = new TextView(this);
        header.setText("🧩 Project Workspace");
        header.setTextSize(26);
        header.setTypeface(null, Typeface.BOLD);
        header.setTextColor(getColor(R.color.hsp_accent_teal));
        controlsContainer.addView(header);

        TextView sub = new TextView(this);
        sub.setText("Decompile, browse, edit, rebuild supported changes, sign, and install inside the embedded APKEditor workspace.");
        sub.setTextSize(12);
        sub.setTextColor(getColor(R.color.hsp_text_muted));
        sub.setPadding(0, dp(4), 0, dp(12));
        controlsContainer.addView(sub);

        LinearLayout pickerRow = horizontalRow();
        Button btnSelectApk = makeButton("📦 APK FILE", getColor(R.color.hsp_accent_blue));
        btnSelectApk.setOnClickListener(v -> pickApk());
        pickerRow.addView(btnSelectApk, weightedButtonParams());
        addSpacer(pickerRow, 6);

        Button btnInstalled = makeButton("📲 INSTALLED APP", getColor(R.color.hsp_accent_amber));
        btnInstalled.setOnClickListener(v -> pickInstalledApp());
        pickerRow.addView(btnInstalled, weightedButtonParams());
        controlsContainer.addView(pickerRow);

        LinearLayout pickerRow2 = horizontalRow();
        btnDecode = makeButton("🛠 DECOMPILE", getColor(R.color.hsp_accent_green));
        btnDecode.setOnClickListener(v -> decodeWorkspace());
        pickerRow2.addView(btnDecode, weightedButtonParams());
        addSpacer(pickerRow2, 6);

        Button btnHome = makeButton("⌂ HOME", getColor(R.color.hsp_surface));
        btnHome.setOnClickListener(v -> showHomeShell());
        pickerRow2.addView(btnHome, weightedButtonParams());
        controlsContainer.addView(pickerRow2);

        tvSelectedApk = infoLabel("No APK selected");
        controlsContainer.addView(tvSelectedApk);
        tvWorkspace = infoLabel("Workspace: not created");
        controlsContainer.addView(tvWorkspace);
        tvCurrentDir = infoLabel("Current folder: -");
        controlsContainer.addView(tvCurrentDir);

        LinearLayout optionCard = sectionCard();
        optionCard.addView(sectionTitle("Decode Settings"));
        cbAllSources = makeCheckbox("Decode all DEX sources (recommended)", true);
        optionCard.addView(cbAllSources);
        cbNoAssets = makeCheckbox("Skip assets decode to keep the workspace lighter", false);
        optionCard.addView(cbNoAssets);
        cbKeepBroken = makeCheckbox("Keep broken resources when decode reports drops", true);
        optionCard.addView(cbKeepBroken);

        TextView rebuildHint = new TextView(this);
        rebuildHint.setText("On-device rebuild fully supports smali and raw file changes. XML resources and manifest text edits are detected and blocked because Apktool's bundled aapt2 is desktop-only.");
        rebuildHint.setTextSize(11);
        rebuildHint.setTextColor(getColor(R.color.hsp_text_faint));
        rebuildHint.setPadding(0, dp(8), 0, 0);
        optionCard.addView(rebuildHint);
        controlsContainer.addView(optionCard);

        etFilter = new EditText(this);
        etFilter.setHint("Filter files in current folder");
        etFilter.setHintTextColor(getColor(R.color.hsp_text_faint));
        etFilter.setTextColor(getColor(R.color.hsp_text));
        etFilter.setBackgroundResource(R.drawable.bg_glass_input);
        etFilter.setPadding(dp(12), dp(10), dp(12), dp(10));
        etFilter.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
            }

            @Override
            public void afterTextChanged(Editable s) {
                refreshCurrentDirectory();
            }
        });
        controlsContainer.addView(etFilter, new LinearLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT));

        LinearLayout actionRow = horizontalRow();
        btnUp = makeButton("⬆ UP", getColor(R.color.hsp_surface));
        btnUp.setOnClickListener(v -> navigateUp());
        actionRow.addView(btnUp, weightedButtonParams());
        addSpacer(actionRow, 4);

        Button btnRefresh = makeButton("↻ REFRESH", getColor(R.color.hsp_surface));
        btnRefresh.setOnClickListener(v -> refreshCurrentDirectory());
        actionRow.addView(btnRefresh, weightedButtonParams());
        addSpacer(actionRow, 4);

        btnNewFile = makeButton("＋ FILE", getColor(R.color.hsp_accent_indigo));
        btnNewFile.setOnClickListener(v -> promptNewFile());
        actionRow.addView(btnNewFile, weightedButtonParams());
        addSpacer(actionRow, 4);

        btnNewFolder = makeButton("📁 FOLDER", getColor(R.color.hsp_legacy_teal));
        btnNewFolder.setOnClickListener(v -> promptNewFolder());
        actionRow.addView(btnNewFolder, weightedButtonParams());
        controlsContainer.addView(actionRow);

        TextView browserTitle = sectionTitle("Extracted Contents");
        browserTitle.setPadding(0, dp(12), 0, 0);
        controlsContainer.addView(browserTitle);

        tvFolderSummary = infoLabel("Decoded folders will appear here after decompilation.");
        controlsContainer.addView(tvFolderSummary);

        listView = new ListView(this);
        listView.setAdapter(adapter);
        listView.setDividerHeight(0);
        listView.setBackgroundResource(R.drawable.bg_card);
        listView.setClipToPadding(false);
        listView.setFastScrollEnabled(true);
        listView.setPadding(dp(6), dp(6), dp(6), dp(6));
        listView.setOnItemClickListener((parent, view, position, id) -> openEntry(visibleEntries.get(position)));
        listView.setOnItemLongClickListener((parent, view, position, id) -> {
            showEntryActions(visibleEntries.get(position));
            return true;
        });
        LinearLayout.LayoutParams listParams = new LinearLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT, 0, 1f);
        listParams.topMargin = dp(10);
        root.addView(listView, listParams);

        progressBar = new ProgressBar(this, null, android.R.attr.progressBarStyleHorizontal);
        progressBar.setVisibility(View.GONE);
        progressBar.setMax(100);
        progressBar.setProgress(0);
        progressBar.setProgressTintList(android.content.res.ColorStateList.valueOf(getColor(R.color.hsp_accent_green)));
        root.addView(progressBar, new LinearLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT));

        tvStatus = infoLabel("Ready.");
        tvStatus.setTextColor(getColor(R.color.hsp_accent_green));
        root.addView(tvStatus);

        LinearLayout buildRow = horizontalRow();
        btnRebuild = makeButton("🔁 REBUILD + SIGN", getColor(R.color.hsp_accent_amber));
        btnRebuild.setOnClickListener(v -> rebuildWorkspace());
        buildRow.addView(btnRebuild, weightedButtonParams());
        addSpacer(buildRow, 6);

        btnInstall = makeButton("📲 INSTALL", getColor(R.color.hsp_accent_purple));
        btnInstall.setOnClickListener(v -> installBuiltApk());
        buildRow.addView(btnInstall, weightedButtonParams());
        root.addView(buildRow);

        ScrollView logScroll = new ScrollView(this);
        logScroll.setBackgroundResource(R.drawable.bg_log);
        LinearLayout.LayoutParams logParams = new LinearLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT, dp(110));
        logParams.topMargin = dp(10);
        logScroll.setLayoutParams(logParams);
        tvLog = new TextView(this);
        tvLog.setText("APK editor ready. Select an APK to begin.\n");
        tvLog.setTextSize(11);
        tvLog.setTypeface(Typeface.MONOSPACE);
        tvLog.setTextColor(getColor(R.color.hsp_text_mono));
        tvLog.setPadding(dp(10), dp(10), dp(10), dp(10));
        logScroll.addView(tvLog);
        root.addView(logScroll);
        return root;
    }

    private void addHomeCard(String title, String subtitle, String icon, int accent, View.OnClickListener listener) {
        homeCardsHost.addView(createHomeCard(title, subtitle, icon, accent, listener));
    }

    private View createHomeCard(String title, String subtitle, String icon, int accent, View.OnClickListener listener) {
        LinearLayout row = new LinearLayout(this);
        row.setOrientation(LinearLayout.HORIZONTAL);
        row.setGravity(Gravity.CENTER_VERTICAL);
        row.setBackgroundResource(R.drawable.bg_tools_option);
        row.setClickable(true);
        row.setFocusable(true);
        row.setMinimumHeight(dp(88));
        row.setPadding(dp(14), dp(16), dp(14), dp(16));
        LinearLayout.LayoutParams rowLp = new LinearLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        rowLp.topMargin = dp(12);
        row.setLayoutParams(rowLp);
        row.setOnClickListener(listener);

        View rail = new View(this);
        rail.setBackgroundColor(accent);
        row.addView(rail, new LinearLayout.LayoutParams(dp(6), dp(46)));

        TextView iconView = new TextView(this);
        iconView.setText(icon);
        iconView.setGravity(Gravity.CENTER);
        iconView.setTextSize(18);
        iconView.setBackgroundResource(R.drawable.bg_chip);
        LinearLayout.LayoutParams iconLp = new LinearLayout.LayoutParams(dp(44), dp(44));
        iconLp.leftMargin = dp(12);
        row.addView(iconView, iconLp);

        LinearLayout info = new LinearLayout(this);
        info.setOrientation(LinearLayout.VERTICAL);
        LinearLayout.LayoutParams infoLp = new LinearLayout.LayoutParams(0,
            ViewGroup.LayoutParams.WRAP_CONTENT, 1f);
        infoLp.leftMargin = dp(14);
        row.addView(info, infoLp);

        TextView titleView = new TextView(this);
        titleView.setText(title);
        titleView.setTextColor(getColor(R.color.hsp_text));
        titleView.setTextSize(19);
        titleView.setTypeface(null, Typeface.BOLD);
        info.addView(titleView);

        TextView subView = new TextView(this);
        subView.setText(subtitle);
        subView.setTextColor(getColor(R.color.hsp_text_muted));
        subView.setTextSize(12);
        subView.setPadding(0, dp(4), 0, 0);
        info.addView(subView);

        TextView arrow = new TextView(this);
        arrow.setText("›");
        arrow.setTextColor(getColor(R.color.hsp_text_faint));
        arrow.setTextSize(22);
        row.addView(arrow);
        return row;
    }

    private Button makeCompactAction(String label) {
        Button button = makeButton(label, getColor(R.color.hsp_surface));
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(dp(46), dp(46));
        lp.leftMargin = dp(6);
        button.setLayoutParams(lp);
        button.setTextSize(15);
        return button;
    }

    private void showHomeShell() {
        if (homeScroll != null) {
            homeScroll.setVisibility(View.VISIBLE);
        }
        if (workspacePanel != null) {
            workspacePanel.setVisibility(View.GONE);
        }
        if (btnToolbarBack != null) {
            btnToolbarBack.setVisibility(View.GONE);
        }
        if (tvToolbarTitle != null) {
            tvToolbarTitle.setText("APK Editor");
        }
        updateHomeProjectState();
    }

    private void showWorkspaceShell() {
        if (homeScroll != null) {
            homeScroll.setVisibility(View.GONE);
        }
        if (workspacePanel != null) {
            workspacePanel.setVisibility(View.VISIBLE);
        }
        if (btnToolbarBack != null) {
            btnToolbarBack.setVisibility(View.VISIBLE);
        }
        if (tvToolbarTitle != null) {
            tvToolbarTitle.setText(currentWorkspaceDir != null ? "Frida Packer Workspace" : "APK Editor");
        }
        refreshCurrentDirectory();
    }

    private void updateHomeProjectState() {
        if (tvHomeProject == null || btnResumeProject == null) {
            return;
        }
        boolean hasProject = currentWorkspaceDir != null && selectedApkFile != null && selectedApkFile.isFile();
        btnResumeProject.setVisibility(hasProject ? View.VISIBLE : View.GONE);
        if (!hasProject) {
            tvHomeProject.setText("No project staged yet.");
            return;
        }

        String status = decodedDir != null && decodedDir.isDirectory()
            ? "Decoded project ready" : "Project staged and ready to decompile";
        tvHomeProject.setText(status + " • " + selectedApkFile.getName() + " • " + formatSize(selectedApkFile.length()));
    }

    private void showOverflowMenu() {
        List<String> actions = new ArrayList<>();
        actions.add("Launch AEE");
        actions.add("Install bundled AEE");
        actions.add("Launch Xed Editor");
        if (currentWorkspaceDir != null) {
            actions.add("Projects");
        }
        actions.add("Verify signature");
        actions.add("Clean garbage");
        actions.add("Editor settings");
        actions.add("Help");
        actions.add("About");
        if (workspacePanel != null && workspacePanel.getVisibility() == View.VISIBLE) {
            actions.add("Back to launcher");
        }

        new AlertDialog.Builder(this, android.R.style.Theme_Material_Dialog)
            .setTitle("APK Editor")
            .setItems(actions.toArray(new CharSequence[0]), (dialog, which) -> {
                String action = actions.get(which);
                if ("Launch AEE".equals(action)) {
                    launchRealApkEditorOrInstall();
                } else if ("Install bundled AEE".equals(action)) {
                    installBundledApkEditor();
                } else if ("Launch Xed Editor".equals(action)) {
                    launchXedAppOrGitHub();
                } else if ("Projects".equals(action)) {
                    showWorkspaceShell();
                } else if ("Verify signature".equals(action)) {
                    showSignatureSummary();
                } else if ("Clean garbage".equals(action)) {
                    cleanWorkspaceGarbage();
                } else if ("Editor settings".equals(action)) {
                    showEditorSettingsDialog();
                } else if ("Help".equals(action)) {
                    showHelpDialog();
                } else if ("About".equals(action)) {
                    showAboutDialog();
                } else if ("Back to launcher".equals(action)) {
                    showHomeShell();
                }
            })
            .show();
    }

    private void showEditorSettingsDialog() {
        LinearLayout content = new LinearLayout(this);
        content.setOrientation(LinearLayout.VERTICAL);
        content.setPadding(dp(16), dp(12), dp(16), dp(4));

        CheckBox allSources = makeCheckbox("Decode all DEX sources", cbAllSources != null && cbAllSources.isChecked());
        CheckBox noAssets = makeCheckbox("Skip assets decode", cbNoAssets != null && cbNoAssets.isChecked());
        CheckBox keepBroken = makeCheckbox("Keep broken resources", cbKeepBroken != null && cbKeepBroken.isChecked());
        content.addView(allSources);
        content.addView(noAssets);
        content.addView(keepBroken);

        TextView note = infoLabel("Bundled AEE bridge asset: " + APKEDITOR_FILE + " • workspace directory: " + workspaceBaseDir.getAbsolutePath());
        note.setPadding(0, dp(10), 0, 0);
        content.addView(note);

        new AlertDialog.Builder(this, android.R.style.Theme_Material_Dialog)
            .setTitle("Editor settings")
            .setView(content)
            .setPositiveButton("Apply", (dialog, which) -> {
                if (cbAllSources != null) cbAllSources.setChecked(allSources.isChecked());
                if (cbNoAssets != null) cbNoAssets.setChecked(noAssets.isChecked());
                if (cbKeepBroken != null) cbKeepBroken.setChecked(keepBroken.isChecked());
            })
            .setNegativeButton("Close", null)
            .show();
    }

    private void showHelpDialog() {
        String message = "Embedded mode now targets APK Explorer & Editor (AEE) for the direct external module path, while decompilation and rebuild still use the HSPatcher backend already verified on-device.\n\n"
            + "Supported rebuilds: smali edits, raw asset changes, native libs, unknown files, and other non-resource entries.\n\n"
            + "Blocked rebuild edits: AndroidManifest.xml text changes and compiled resource XML changes, because Apktool's bundled aapt2 is desktop-only on Android.";
        new AlertDialog.Builder(this, android.R.style.Theme_Material_Dialog)
            .setTitle("Help")
            .setMessage(message)
            .setPositiveButton("OK", null)
            .show();
    }

    private void showAboutDialog() {
        String message = "APK Editor bridge\nBundled target: " + APKEDITOR_PACKAGE + "\nAPK file: " + APKEDITOR_FILE + "\n\n"
            + "Embedded external module source:\n"
            + "APK Explorer & Editor (AEE)\n"
            + "apk-editor/APK-Explorer-Editor\n\n"
            + "Text/code editing integration:\n"
            + "Xed Editor\n"
            + "Xed-Editor/Xed-Editor\n\n"
            + "Execution backend:\n"
            + "HSPatcher Android-safe decode, rebuild, sign, and install pipeline.";
        new AlertDialog.Builder(this, android.R.style.Theme_Material_Dialog)
            .setTitle("About")
            .setMessage(message)
            .setPositiveButton("Close", null)
            .show();
    }

    private void launchRealApkEditorOrInstall() {
        if (launchInstalledApkEditor()) {
            return;
        }
        installBundledApkEditor();
    }

    private boolean launchInstalledApkEditor() {
        try {
            Intent explicit = new Intent();
            explicit.setComponent(new ComponentName(APKEDITOR_PACKAGE, APKEDITOR_ACTIVITY));
            explicit.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            startActivity(explicit);
            toast("Opening APK Explorer & Editor");
            return true;
        } catch (Exception ignored) {
        }

        try {
            Intent launch = getPackageManager().getLaunchIntentForPackage(APKEDITOR_PACKAGE);
            if (launch != null) {
                launch.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                startActivity(launch);
                toast("Opening APK Explorer & Editor");
                return true;
            }
        } catch (Exception ignored) {
        }
        return false;
    }

    private void launchXedAppOrGitHub() {
        if (launchXedApp()) {
            return;
        }

        try {
            Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(XED_GITHUB_URL));
            startActivity(intent);
            toast("Xed Editor not installed. Opening GitHub.");
        } catch (Exception e) {
            toast("Xed Editor not installed");
        }
    }

    private boolean launchXedApp() {
        Intent mergedIntent = new Intent();
        mergedIntent.setClassName(getPackageName(), MERGED_XED_ACTIVITY);
        mergedIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        attachWorkspaceExtras(mergedIntent, null);
        if (mergedIntent.resolveActivity(getPackageManager()) != null) {
            try {
                startActivity(mergedIntent);
                toast("Opening Xed Editor");
                return true;
            } catch (Exception ignored) {
            }
        }

        try {
            for (String xedPackage : XED_PACKAGES) {
                Intent launch = getPackageManager().getLaunchIntentForPackage(xedPackage);
                if (launch == null) {
                    continue;
                }
                launch.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                attachWorkspaceExtras(launch, null);
                startActivity(launch);
                toast("Opening Xed Editor");
                return true;
            }
        } catch (Exception ignored) {
        }
        return false;
    }

    private boolean isXedInstalled() {
        Intent mergedIntent = new Intent();
        mergedIntent.setClassName(getPackageName(), MERGED_XED_ACTIVITY);
        if (mergedIntent.resolveActivity(getPackageManager()) != null) {
            return true;
        }

        for (String xedPackage : XED_PACKAGES) {
            try {
                getPackageManager().getPackageInfo(xedPackage, 0);
                return true;
            } catch (Exception ignored) {
            }
        }
        return false;
    }

    private void installBundledApkEditor() {
        new Thread(() -> {
            setBusy(true, "Preparing bundled AEE...");
            try {
                File bundledApk = extractBundledApkEditor();
                mainHandler.post(() -> {
                    setBusy(false, "Bundled AEE ready.");
                    Intent intent = new Intent(Intent.ACTION_VIEW);
                    Uri uri = HspFileProvider.getUriForFile(this, bundledApk);
                    intent.setDataAndType(uri, "application/vnd.android.package-archive");
                    intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
                    startActivity(intent);
                });
            } catch (Exception e) {
                log("❌ Could not prepare bundled AEE: " + safeMessage(e));
                mainHandler.post(() -> setBusy(false, "Bundled AEE failed."));
            }
        }, "BundledApkEditor").start();
    }

    private File extractBundledApkEditor() throws IOException {
        File dir = new File(getFilesDir(), "bundled_apkeditor");
        if (!dir.exists() && !dir.mkdirs() && !dir.isDirectory()) {
            throw new IOException("Could not create AEE bundle directory");
        }
        File target = new File(dir, APKEDITOR_FILE);
        long expectedSize = assetLength(APKEDITOR_ASSET);
        if (target.isFile() && target.length() == expectedSize && expectedSize > 0) {
            return target;
        }
        try (InputStream in = getAssets().open(APKEDITOR_ASSET);
             FileOutputStream out = new FileOutputStream(target, false)) {
            copyStream(in, out);
        }
        return target;
    }

    private long assetLength(String assetPath) {
        try (android.content.res.AssetFileDescriptor descriptor = getAssets().openFd(assetPath)) {
            return descriptor.getLength();
        } catch (Exception ignored) {
            return -1;
        }
    }

    private void showSignatureSummary() {
        File target = builtSignedApk != null && builtSignedApk.isFile() ? builtSignedApk : selectedApkFile;
        if (target == null || !target.isFile()) {
            toast("Select or build an APK first");
            return;
        }
        try {
            PackageManager pm = getPackageManager();
            PackageInfo info;
            if (Build.VERSION.SDK_INT >= 28) {
                info = pm.getPackageArchiveInfo(target.getAbsolutePath(), PackageManager.GET_SIGNING_CERTIFICATES);
            } else {
                info = pm.getPackageArchiveInfo(target.getAbsolutePath(), PackageManager.GET_SIGNATURES);
            }
            StringBuilder builder = new StringBuilder();
            builder.append("File: ").append(target.getName())
                .append("\nSize: ").append(formatSize(target.length()));
            if (info != null) {
                builder.append("\nPackage: ").append(info.packageName)
                    .append("\nVersion: ").append(info.versionName);
                if (Build.VERSION.SDK_INT >= 28 && info.signingInfo != null && info.signingInfo.getApkContentsSigners() != null && info.signingInfo.getApkContentsSigners().length > 0) {
                    builder.append("\nSigner SHA-256: ")
                        .append(sha256Hex(info.signingInfo.getApkContentsSigners()[0].toByteArray()));
                } else if (info.signatures != null && info.signatures.length > 0) {
                    builder.append("\nSigner SHA-256: ")
                        .append(sha256Hex(info.signatures[0].toByteArray()));
                }
            } else {
                builder.append("\nPackage metadata could not be parsed.");
            }
            new AlertDialog.Builder(this, android.R.style.Theme_Material_Dialog)
                .setTitle("Verify signature")
                .setMessage(builder.toString())
                .setPositiveButton("OK", null)
                .show();
        } catch (Exception e) {
            toast("Could not verify APK: " + safeMessage(e));
        }
    }

    private void cleanWorkspaceGarbage() {
        new Thread(() -> {
            int removed = 0;
            File[] children = workspaceBaseDir.listFiles();
            if (children != null) {
                for (File child : children) {
                    if (currentWorkspaceDir != null && currentWorkspaceDir.equals(child)) {
                        continue;
                    }
                    try {
                        deleteRecursively(child);
                        removed++;
                    } catch (Exception ignored) {
                    }
                }
            }
            final int removedFinal = removed;
            mainHandler.post(() -> toast("Removed " + removedFinal + " stale workspace(s)"));
        }, "ApkEditorCleanup").start();
    }

    private void pickInstalledApp() {
        if (busy) {
            toast("Operation in progress");
            return;
        }
        startActivityForResult(new Intent(this, AppListActivity.class), PICK_INSTALLED_APP);
    }

    private void pickApk() {
        if (busy) {
            toast("Operation in progress");
            return;
        }
        Intent intent = new Intent(Intent.ACTION_GET_CONTENT);
        intent.addCategory(Intent.CATEGORY_OPENABLE);
        intent.setType("application/vnd.android.package-archive");
        try {
            startActivityForResult(Intent.createChooser(intent, "Select APK"), PICK_APK);
        } catch (Exception e) {
            intent.setType("*/*");
            startActivityForResult(intent, PICK_APK);
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (resultCode != RESULT_OK || data == null) return;

        if (requestCode == PICK_INSTALLED_APP) {
            String path = data.getStringExtra(AppListActivity.EXTRA_APK_PATH);
            boolean isSplit = data.getBooleanExtra(AppListActivity.EXTRA_IS_SPLIT, false);
            String label = data.getStringExtra(AppListActivity.EXTRA_APP_LABEL);
            if (path != null) {
                stageInstalledApp(new File(path), isSplit, label);
            }
            return;
        }

        Uri uri = data.getData();
        if (uri == null) return;

        if (requestCode == PICK_APK) {
            stageSelectedApk(uri);
        } else if (requestCode == PICK_REPLACE_FILE && pendingReplaceTarget != null) {
            replaceFileFromUri(uri, pendingReplaceTarget);
        }
    }

    private void stageSelectedApk(Uri uri) {
        String displayName = queryDisplayName(uri);
        if (displayName == null || displayName.trim().isEmpty()) {
            displayName = "input.apk";
        }
        prepareWorkspaceForApk(displayName);
        File stagedApk = new File(currentWorkspaceDir, "input.apk");

        new Thread(() -> {
            setBusy(true, "Copying APK into workspace...");
            try (InputStream in = getContentResolver().openInputStream(uri)) {
                if (in == null) {
                    throw new IOException("Cannot open APK");
                }
                copyStream(in, new FileOutputStream(stagedApk));
                setSelectedApk(stagedApk);
                log("📦 APK staged: " + stagedApk.getAbsolutePath());
                mainHandler.post(() -> {
                    setBusy(false, "APK ready for decompilation.");
                    if (directJarWorkflow) {
                        decodeWorkspaceWithApkEditorJar();
                    } else {
                        showWorkspaceShell();
                        refreshCurrentDirectory();
                    }
                });
            } catch (Exception e) {
                log("❌ Could not stage APK: " + safeMessage(e));
                mainHandler.post(() -> setBusy(false, "Stage failed."));
            }
        }, "ApkStager").start();
    }

    private void stageInstalledApp(File extracted, boolean isSplit, String label) {
        new Thread(() -> {
            setBusy(true, "Preparing installed app...");
            try {
                File sourceForStage = extracted;
                if (isSplit || extracted.isDirectory()) {
                    File mergeRoot = new File(getCacheDir(), "apk_editor_split_merge");
                    if (mergeRoot.exists()) {
                        deleteRecursively(mergeRoot);
                    }
                    if (!mergeRoot.mkdirs() && !mergeRoot.isDirectory()) {
                        throw new IOException("Could not create merge workspace");
                    }
                    File bundleFile = new File(mergeRoot, "installed_split_bundle.apks");
                    createSplitBundleZip(extracted, bundleFile);
                    File mergedApk = new File(mergeRoot, sanitizeFileName(label == null ? "installed_app" : label) + "_merged.apk");
                    ApksMerger merger = new ApksMerger(new ApksMerger.MergeCallback() {
                        @Override
                        public void onLog(String msg) {
                            log(msg);
                        }

                        @Override
                        public void onProgress(int pct, String step) {
                            log("… " + pct + "% " + step);
                        }
                    });
                    merger.merge(bundleFile, mergedApk, new File(mergeRoot, "work"));
                    sourceForStage = mergedApk;
                    log("✅ Installed split APK merged: " + mergedApk.getName());
                }

                String projectName = label != null && !label.trim().isEmpty() ? label + ".apk" : sourceForStage.getName();
                prepareWorkspaceForApk(projectName);
                File stagedApk = new File(currentWorkspaceDir, "input.apk");
                copyFile(sourceForStage, stagedApk);
                setSelectedApk(stagedApk);
                log("📦 Installed app staged: " + stagedApk.getAbsolutePath());
                mainHandler.post(() -> {
                    setBusy(false, "Installed app ready.");
                    if (directJarWorkflow) {
                        decodeWorkspaceWithApkEditorJar();
                    } else {
                        showWorkspaceShell();
                        refreshCurrentDirectory();
                    }
                });
            } catch (Exception e) {
                log("❌ Could not prepare installed app: " + safeMessage(e));
                mainHandler.post(() -> setBusy(false, "Installed app failed."));
            }
        }, "InstalledAppStage").start();
    }

    private void decodeWorkspace() {
        if (busy) {
            toast("Operation in progress");
            return;
        }
        if (selectedApkFile == null || !selectedApkFile.isFile()) {
            toast("Select an APK first");
            return;
        }
        if (currentWorkspaceDir == null) {
            prepareWorkspaceForApk(selectedApkFile.getName());
        }
        decodedDir = new File(currentWorkspaceDir, "decoded");
        builtSignedApk = null;

        new Thread(() -> {
            setBusy(true, "Decompiling APK...");
            try {
                ensureApktoolSystemProperties();
                ensureApktoolProperties();
                if (decodedDir.exists()) {
                    deleteRecursively(decodedDir);
                }
                if (!decodedDir.mkdirs() && !decodedDir.isDirectory()) {
                    throw new IOException("Cannot create decoded workspace");
                }

                Config config = Config.getDefaultConfig();
                config.forceDelete = true;
                config.keepBrokenResources = cbKeepBroken.isChecked();
                config.baksmaliDebugMode = false;
                config.frameworkDirectory = ensureFrameworkDir().getAbsolutePath();
                config.setDecodeResources(DECODE_RESOURCES_RAW);
                config.setDecodeSources(cbAllSources.isChecked()
                    ? DECODE_SOURCES_FULL : DECODE_SOURCES_ONLY_MAIN);
                if (cbNoAssets.isChecked()) {
                    config.setDecodeAssets(DECODE_ASSETS_NONE);
                }

                ApkDecoder decoder = new ApkDecoder(config, new ExtFile(selectedApkFile));
                ApkInfo info = decoder.decode(decodedDir);
                saveWorkspaceMeta(info);
                writeBaselineHashes(decodedDir, new File(currentWorkspaceDir, HASH_FILE));

                currentDir = decodedDir;
                log("ℹ Resources were copied raw for Android compatibility; smali and non-resource files remain editable.");
                log("✅ Decompiled into workspace: " + decodedDir.getAbsolutePath());
                mainHandler.post(() -> {
                    setBusy(false, "Workspace ready.");
                    refreshCurrentDirectory();
                    updateBuildButtons();
                });
            } catch (Throwable e) {
                logThrowable("Decompile failed", e);
                log("❌ Decompile failed: " + safeMessage(e));
                mainHandler.post(() -> setBusy(false, "Decompile failed."));
            }
        }, "ApkDecode").start();
    }

    private void decodeWorkspaceWithApkEditorJar() {
        if (busy) {
            toast("Operation in progress");
            return;
        }
        if (selectedApkFile == null || !selectedApkFile.isFile()) {
            toast("Select an APK first");
            return;
        }
        if (currentWorkspaceDir == null) {
            prepareWorkspaceForApk(selectedApkFile.getName());
        }
        decodedDir = new File(currentWorkspaceDir, "decoded");
        currentDir = decodedDir;
        builtSignedApk = null;

        new Thread(() -> {
            setBusy(true, "Opening Xed import workflow...");
            mainHandler.post(() -> {
                setBusy(false, "Handing off to Xed.");
                if (launchXedImportWorkflow()) {
                    finish();
                } else {
                    showWorkspaceShell();
                    toast("Xed Editor is not available");
                }
            });
        }, "ApkEditorJarDecode").start();
    }

    private boolean launchXedImportWorkflow() {
        if (selectedApkFile == null || !selectedApkFile.isFile() || currentWorkspaceDir == null) {
            return false;
        }

        String appName = currentWorkspaceDir.getName();

        Intent mergedIntent = new Intent();
        mergedIntent.setClassName(getPackageName(), MERGED_XED_ACTIVITY);
        mergedIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        mergedIntent.putExtra(XED_EXTRA_WORKSPACE_PATH, currentWorkspaceDir.getAbsolutePath());
        mergedIntent.putExtra(XED_EXTRA_IMPORT_APK_PATH, selectedApkFile.getAbsolutePath());
        mergedIntent.putExtra(XED_EXTRA_IMPORT_APP_NAME, appName);
        if (mergedIntent.resolveActivity(getPackageManager()) != null) {
            try {
                startActivity(mergedIntent);
                toast("Opening Xed Editor workspace");
                return true;
            } catch (Exception ignored) {
            }
        }

        try {
            for (String xedPackage : XED_PACKAGES) {
                Intent launch = getPackageManager().getLaunchIntentForPackage(xedPackage);
                if (launch == null) {
                    continue;
                }
                launch.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                launch.putExtra(XED_EXTRA_WORKSPACE_PATH, currentWorkspaceDir.getAbsolutePath());
                launch.putExtra(XED_EXTRA_IMPORT_APK_PATH, selectedApkFile.getAbsolutePath());
                launch.putExtra(XED_EXTRA_IMPORT_APP_NAME, appName);
                startActivity(launch);
                toast("Opening Xed Editor workspace");
                return true;
            }
        } catch (Exception ignored) {
        }
        return false;
    }

    private void ensureApktoolSystemProperties() {
        if (isBlank(System.getProperty("os.name"))) {
            System.setProperty("os.name", "Linux");
        }
        if (isBlank(System.getProperty("sun.arch.data.model"))) {
            String osArch = System.getProperty("os.arch", "");
            System.setProperty("sun.arch.data.model", osArch.contains("64") ? "64" : "32");
        }
    }

    private void ensureApktoolProperties() {
        try {
            Class<?> propertiesClass = Class.forName("brut.androlib.ApktoolProperties");
            Field propsField = propertiesClass.getDeclaredField("sProps");
            propsField.setAccessible(true);
            Properties props = (Properties) propsField.get(null);
            if (props == null) {
                props = new Properties();
            }
            if (isBlank(props.getProperty("application.version"))) {
                props.setProperty("application.version", "2.9.3");
            }
            if (isBlank(props.getProperty("baksmaliVersion"))) {
                props.setProperty("baksmaliVersion", "2.5.2");
            }
            if (isBlank(props.getProperty("smaliVersion"))) {
                props.setProperty("smaliVersion", "2.5.2");
            }
            propsField.set(null, props);
        } catch (Exception e) {
            logThrowable("Could not seed ApktoolProperties", e);
        }
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }

    private void rebuildWorkspace() {
        if (busy) {
            toast("Operation in progress");
            return;
        }
        if (decodedDir == null || !decodedDir.isDirectory()) {
            toast("Decompile an APK first");
            return;
        }

        new Thread(() -> {
            setBusy(true, "Rebuilding supported changes...");
            try {
                Properties meta = loadWorkspaceMeta();
                String originalPath = meta.getProperty("original_apk");
                if (originalPath == null || originalPath.trim().isEmpty()) {
                    throw new IOException("Workspace metadata is missing the original APK path");
                }
                File originalApk = new File(originalPath);
                if (!originalApk.isFile()) {
                    throw new IOException("Original APK not found: " + originalApk.getAbsolutePath());
                }

                List<String> unsupportedChanges = findUnsupportedChanges();
                if (!unsupportedChanges.isEmpty()) {
                    throw new IOException(buildUnsupportedChangeMessage(unsupportedChanges));
                }

                File buildDir = new File(currentWorkspaceDir, "build");
                if (!buildDir.exists() && !buildDir.mkdirs()) {
                    throw new IOException("Cannot create build directory");
                }
                File compiledDexDir = new File(buildDir, "compiled_dex");
                if (compiledDexDir.exists()) {
                    deleteRecursively(compiledDexDir);
                }
                if (!compiledDexDir.mkdirs() && !compiledDexDir.isDirectory()) {
                    throw new IOException("Cannot create compiled dex directory");
                }

                Map<String, File> dexReplacements = buildDexOutputs(compiledDexDir, originalApk);
                Map<String, File> rawReplacements = collectRawReplacements();

                File unsignedApk = new File(buildDir, "apk_editor_unsigned.apk");
                File signedApk = new File(buildDir, buildOutputName(originalApk));
                repackageApk(originalApk, unsignedApk, dexReplacements, rawReplacements);
                log("📦 Unsigned rebuild ready: " + unsignedApk.getAbsolutePath());

                ApkSigningUtil.signApk(this, unsignedApk, signedApk, this::log);
                builtSignedApk = signedApk;
                meta.setProperty("last_built_apk", builtSignedApk.getAbsolutePath());
                saveProperties(meta, new File(currentWorkspaceDir, META_FILE));
                mainHandler.post(() -> {
                    setBusy(false, "Rebuild finished.");
                    updateBuildButtons();
                });
            } catch (Exception e) {
                log("❌ Rebuild failed: " + safeMessage(e));
                mainHandler.post(() -> setBusy(false, "Rebuild failed."));
            }
        }, "ApkRebuild").start();
    }

    private Map<String, File> buildDexOutputs(File compiledDexDir, File originalApk) throws Exception {
        Map<String, File> outputs = new LinkedHashMap<>();
        File[] children = decodedDir.listFiles();
        if (children == null) return outputs;

        int apiLevel = resolveSmaliApiLevel(originalApk);

        for (File child : children) {
            if (!child.isDirectory()) continue;
            String name = child.getName();
            if (!name.startsWith("smali")) continue;

            String dexName = "smali".equals(name)
                ? "classes.dex"
                : name.substring(name.indexOf('_') + 1) + ".dex";
            File outDex = new File(compiledDexDir, dexName);
            log("⚙️ Compiling " + name + " -> " + dexName);
            SmaliBuilder.build(new ExtFile(child), outDex, apiLevel);
            outputs.put(dexName, outDex);
        }

        if (outputs.isEmpty()) {
            log("ℹ️ No smali directories were found; original dex files will be preserved.");
        }
        return outputs;
    }

    private int resolveSmaliApiLevel(File originalApk) {
        if (originalApk == null || !originalApk.isFile()) {
            return 0;
        }
        try {
            PackageManager packageManager = getPackageManager();
            PackageInfo packageInfo = packageManager.getPackageArchiveInfo(originalApk.getAbsolutePath(), 0);
            if (packageInfo != null && packageInfo.applicationInfo != null && Build.VERSION.SDK_INT >= 24) {
                return packageInfo.applicationInfo.minSdkVersion;
            }
        } catch (Exception ignored) {
        }
        return 0;
    }

    private Map<String, File> collectRawReplacements() {
        Map<String, File> replacements = new LinkedHashMap<>();
        List<File> allFiles = new ArrayList<>();
        collectFiles(decodedDir, allFiles);
        for (File file : allFiles) {
            String relativePath = getRelativePath(decodedDir, file);
            if (isMetaPath(relativePath) || isBlockedTextResourcePath(relativePath) || isSmaliPath(relativePath)) {
                continue;
            }
            replacements.put(relativePath, file);
        }
        return replacements;
    }

    private void repackageApk(File originalApk, File unsignedApk,
                              Map<String, File> dexReplacements,
                              Map<String, File> rawReplacements) throws Exception {
        Set<String> written = new HashSet<>();
        try (ZipFile zipFile = new ZipFile(originalApk);
             ZipOutputStream zos = new ZipOutputStream(
                 new BufferedOutputStream(new FileOutputStream(unsignedApk)))) {
            Enumeration<? extends ZipEntry> entries = zipFile.entries();
            while (entries.hasMoreElements()) {
                ZipEntry entry = entries.nextElement();
                String name = entry.getName();
                if (entry.isDirectory()) {
                    continue;
                }
                if (isSignatureEntry(name)) {
                    continue;
                }

                File dexReplacement = dexReplacements.get(name);
                if (dexReplacement != null && dexReplacement.isFile()) {
                    addFileEntry(zos, name, dexReplacement);
                    written.add(name);
                    continue;
                }

                File rawReplacement = rawReplacements.get(name);
                if (rawReplacement != null && rawReplacement.isFile()) {
                    addFileEntry(zos, name, rawReplacement);
                    written.add(name);
                    continue;
                }

                if (shouldDeleteRawEntry(name)) {
                    log("🗑 Removed " + name);
                    continue;
                }

                copyZipEntry(zipFile, entry, zos);
                written.add(name);
            }

            for (Map.Entry<String, File> entry : dexReplacements.entrySet()) {
                if (!written.contains(entry.getKey()) && entry.getValue().isFile()) {
                    addFileEntry(zos, entry.getKey(), entry.getValue());
                }
            }
            for (Map.Entry<String, File> entry : rawReplacements.entrySet()) {
                if (!written.contains(entry.getKey()) && entry.getValue().isFile()) {
                    addFileEntry(zos, entry.getKey(), entry.getValue());
                }
            }
        }
    }

    private List<String> findUnsupportedChanges() throws Exception {
        Map<String, String> baseline = loadBaselineHashes();
        List<String> currentFiles = new ArrayList<>();
        collectRelativeFiles(decodedDir, decodedDir, currentFiles);
        Set<String> currentSet = new HashSet<>(currentFiles);
        List<String> unsupported = new ArrayList<>();

        for (String path : currentFiles) {
            if (!isBlockedTextResourcePath(path)) {
                continue;
            }
            String oldHash = baseline.get(path);
            String newHash = sha256(new File(decodedDir, path.replace('/', File.separatorChar)));
            if (oldHash == null || !oldHash.equals(newHash)) {
                unsupported.add(path);
            }
        }

        for (String path : baseline.keySet()) {
            if (isBlockedTextResourcePath(path) && !currentSet.contains(path)) {
                unsupported.add(path + " (deleted)");
            }
        }

        Collections.sort(unsupported);
        return unsupported;
    }

    private String buildUnsupportedChangeMessage(List<String> unsupportedChanges) {
        StringBuilder builder = new StringBuilder();
        builder.append("This workspace contains resource XML or manifest edits that cannot be compiled on-device.\n\n");
        int limit = Math.min(8, unsupportedChanges.size());
        for (int i = 0; i < limit; i++) {
            builder.append("• ").append(unsupportedChanges.get(i)).append('\n');
        }
        if (unsupportedChanges.size() > limit) {
            builder.append("• ... and ").append(unsupportedChanges.size() - limit).append(" more\n");
        }
        builder.append("\nSupported rebuilds: smali changes plus raw file changes such as assets, libs, and other non-resource entries.");
        return builder.toString();
    }

    private void installBuiltApk() {
        if (builtSignedApk == null || !builtSignedApk.isFile()) {
            toast("Build an APK first");
            return;
        }
        Intent intent = new Intent(Intent.ACTION_VIEW);
        Uri uri = HspFileProvider.getUriForFile(this, builtSignedApk);
        intent.setDataAndType(uri, "application/vnd.android.package-archive");
        intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
        try {
            startActivity(intent);
        } catch (Exception e) {
            toast("Could not open installer: " + safeMessage(e));
        }
    }

    private void openEntry(FileEntry entry) {
        if (entry.file == null) return;
        if (entry.isParent) {
            navigateUp();
            return;
        }
        if (entry.file.isDirectory()) {
            currentDir = entry.file;
            refreshCurrentDirectory();
            return;
        }
        openFileEditor(entry.file);
    }

    private void openFileEditor(File file) {
        if (isDatabaseFile(file)) {
            Intent intent = new Intent(this, DbEditorActivity.class);
            intent.putExtra("db_path", file.getAbsolutePath());
            startActivity(intent);
            return;
        }
        if (isTextEditable(file)) {
            if (!launchXedEditor(file)) {
                openBuiltInTextEditor(file);
            }
            return;
        }
        toast("Binary file detected. Long-press to replace, rename, or delete.");
    }

    private void openBuiltInTextEditor(File file) {
        Intent intent = new Intent(this, TextReplaceActivity.class);
        intent.putExtra("file_path", file.getAbsolutePath());
        startActivity(intent);
    }

    private boolean launchXedEditor(File file) {
        if (!isXedInstalled()) {
            return false;
        }

        try {
            Uri uri = HspFileProvider.getUriForFile(this, file);
            Intent intent = new Intent(Intent.ACTION_EDIT);
            String targetPackage = null;
            intent.setClassName(getPackageName(), MERGED_XED_ACTIVITY);
            if (intent.resolveActivity(getPackageManager()) != null) {
                targetPackage = getPackageName();
            } else {
                intent = new Intent(Intent.ACTION_EDIT);
                for (String xedPackage : XED_PACKAGES) {
                    intent.setPackage(xedPackage);
                    if (intent.resolveActivity(getPackageManager()) != null) {
                        targetPackage = xedPackage;
                        break;
                    }
                }
                if (targetPackage == null) {
                    return false;
                }
            }
            intent.setDataAndType(uri, HspFileProvider.getTypeForFile(file));
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION | Intent.FLAG_GRANT_WRITE_URI_PERMISSION);
            attachWorkspaceExtras(intent, file);
            intent.setClipData(ClipData.newUri(getContentResolver(), file.getName(), uri));
            grantUriPermission(targetPackage, uri,
                Intent.FLAG_GRANT_READ_URI_PERMISSION | Intent.FLAG_GRANT_WRITE_URI_PERMISSION);

            if (intent.resolveActivity(getPackageManager()) == null) {
                intent.setAction(Intent.ACTION_VIEW);
            }

            startActivity(intent);
            toast("Opening in Xed Editor");
            return true;
        } catch (Exception e) {
            log("⚠️ Xed handoff failed, falling back: " + safeMessage(e));
            return false;
        }
    }

    private void attachWorkspaceExtras(Intent intent, File focusFile) {
        File workspace = currentWorkspaceDir;
        if (workspace != null && workspace.isDirectory()) {
            intent.putExtra(XED_EXTRA_WORKSPACE_PATH, workspace.getAbsolutePath());
        }
        File focus = focusFile != null ? focusFile : getWorkspaceDefaultFocusFile();
        if (focus != null && focus.isFile()) {
            intent.putExtra(XED_EXTRA_FOCUS_FILE, focus.getAbsolutePath());
        }
    }

    private File getWorkspaceDefaultFocusFile() {
        if (decodedDir == null || !decodedDir.isDirectory()) {
            return null;
        }
        File manifest = new File(decodedDir, "AndroidManifest.xml");
        if (manifest.isFile()) {
            return manifest;
        }
        return null;
    }

    private void showEntryActions(FileEntry entry) {
        if (entry.file == null || entry.isParent) return;
        List<String> actions = new ArrayList<>();
        final boolean directory = entry.file.isDirectory();

        actions.add(directory ? "Open" : "Open / Edit");
        if (!directory) {
            if (isTextEditable(entry.file)) {
                actions.add("Open in Frida Packer editor");
                if (isXedInstalled()) {
                    actions.add("Open in Xed Editor");
                }
            }
            actions.add("Replace from file");
        }
        actions.add("Rename");
        actions.add("Delete");

        new AlertDialog.Builder(this, android.R.style.Theme_Material_Dialog)
            .setTitle(entry.file.getName())
            .setItems(actions.toArray(new CharSequence[0]), (dialog, which) -> {
                String action = actions.get(which);
                if ("Open".equals(action) || "Open / Edit".equals(action)) {
                    openEntry(entry);
                } else if ("Open in Frida Packer editor".equals(action)) {
                    openBuiltInTextEditor(entry.file);
                } else if ("Open in Xed Editor".equals(action)) {
                    if (!launchXedEditor(entry.file)) {
                        openBuiltInTextEditor(entry.file);
                    }
                } else if ("Replace from file".equals(action)) {
                    pendingReplaceTarget = entry.file;
                    pickReplacementFile();
                } else if ("Rename".equals(action)) {
                    promptRename(entry.file);
                } else if ("Delete".equals(action)) {
                    confirmDelete(entry.file);
                }
            })
            .show();
    }

    private void pickReplacementFile() {
        Intent intent = new Intent(Intent.ACTION_GET_CONTENT);
        intent.addCategory(Intent.CATEGORY_OPENABLE);
        intent.setType("*/*");
        startActivityForResult(Intent.createChooser(intent, "Select replacement file"), PICK_REPLACE_FILE);
    }

    private void replaceFileFromUri(Uri uri, File target) {
        pendingReplaceTarget = null;
        new Thread(() -> {
            setBusy(true, "Replacing file...");
            try (InputStream in = getContentResolver().openInputStream(uri)) {
                if (in == null) throw new IOException("Cannot open replacement file");
                copyStream(in, new FileOutputStream(target, false));
                log("♻️ Replaced file: " + getRelativePath(decodedDir, target));
                mainHandler.post(() -> {
                    setBusy(false, "File replaced.");
                    refreshCurrentDirectory();
                });
            } catch (Exception e) {
                log("❌ Replace failed: " + safeMessage(e));
                mainHandler.post(() -> setBusy(false, "Replace failed."));
            }
        }, "FileReplace").start();
    }

    private void promptNewFile() {
        if (currentDir == null || !currentDir.isDirectory()) {
            toast("Open a workspace folder first");
            return;
        }
        showTextInputDialog("New File", "File name", "new_file.txt", name -> {
            File target = new File(currentDir, name);
            try {
                if (!target.createNewFile()) {
                    throw new IOException("File already exists");
                }
                log("📝 Created file: " + getRelativePath(decodedDir, target));
                refreshCurrentDirectory();
            } catch (Exception e) {
                toast("Could not create file: " + safeMessage(e));
            }
        });
    }

    private void promptNewFolder() {
        if (currentDir == null || !currentDir.isDirectory()) {
            toast("Open a workspace folder first");
            return;
        }
        showTextInputDialog("New Folder", "Folder name", "new_folder", name -> {
            File target = new File(currentDir, name);
            if (target.exists() || !target.mkdirs()) {
                toast("Could not create folder");
                return;
            }
            log("📁 Created folder: " + getRelativePath(decodedDir, target));
            refreshCurrentDirectory();
        });
    }

    private void promptRename(File target) {
        showTextInputDialog("Rename", "New name", target.getName(), name -> {
            File renamed = new File(target.getParentFile(), name);
            if (renamed.exists() || !target.renameTo(renamed)) {
                toast("Rename failed");
                return;
            }
            log("✏️ Renamed: " + target.getName() + " -> " + renamed.getName());
            refreshCurrentDirectory();
        });
    }

    private void confirmDelete(File target) {
        new AlertDialog.Builder(this, android.R.style.Theme_Material_Dialog_Alert)
            .setTitle("Delete")
            .setMessage("Delete " + target.getName() + "?")
            .setPositiveButton("Delete", (dialog, which) -> {
                try {
                    deleteRecursively(target);
                    log("🗑 Deleted: " + target.getName());
                    refreshCurrentDirectory();
                } catch (Exception e) {
                    toast("Delete failed: " + safeMessage(e));
                }
            })
            .setNegativeButton("Cancel", null)
            .show();
    }

    private void navigateUp() {
        if (currentDir == null || decodedDir == null) return;
        if (currentDir.equals(decodedDir)) return;
        File parent = currentDir.getParentFile();
        if (parent != null && parent.getAbsolutePath().startsWith(decodedDir.getAbsolutePath())) {
            currentDir = parent;
            refreshCurrentDirectory();
        }
    }

    private void refreshCurrentDirectory() {
        visibleEntries.clear();
        if (currentDir == null || !currentDir.isDirectory()) {
            adapter.notifyDataSetChanged();
            tvCurrentDir.setText("Current folder: -");
            if (tvFolderSummary != null) {
                tvFolderSummary.setText("Decoded folders will appear here after decompilation.");
            }
            updateBuildButtons();
            return;
        }

        tvCurrentDir.setText("Current folder: " + getRelativeDisplayPath(currentDir));
        if (!currentDir.equals(decodedDir)) {
            visibleEntries.add(FileEntry.parent(currentDir.getParentFile()));
        }

        String filter = etFilter != null ? etFilter.getText().toString().trim().toLowerCase(Locale.US) : "";
        File[] files = currentDir.listFiles();
        List<FileEntry> directories = new ArrayList<>();
        List<FileEntry> regularFiles = new ArrayList<>();
        if (files != null) {
            for (File file : files) {
                if (isMetaFile(getRelativePath(decodedDir, file))) {
                    continue;
                }
                if (!filter.isEmpty() && !file.getName().toLowerCase(Locale.US).contains(filter)) {
                    continue;
                }
                FileEntry entry = new FileEntry(file);
                if (file.isDirectory()) {
                    directories.add(entry);
                } else {
                    regularFiles.add(entry);
                }
            }
        }
        Collections.sort(directories);
        Collections.sort(regularFiles);
        visibleEntries.addAll(directories);
        visibleEntries.addAll(regularFiles);
        updateFolderSummary(directories, regularFiles, filter);
        adapter.notifyDataSetChanged();
        if (listView != null) {
            listView.post(() -> listView.setSelection(0));
        }
        updateBuildButtons();
    }

    private void updateFolderSummary(List<FileEntry> directories, List<FileEntry> regularFiles, String filter) {
        if (tvFolderSummary == null) {
            return;
        }

        StringBuilder summary = new StringBuilder();
        if (currentDir != null && currentDir.equals(decodedDir)) {
            String preview = buildFolderPreview(directories);
            if (!preview.isEmpty()) {
                summary.append("Top folders: ").append(preview).append(" • ");
            } else {
                summary.append("Decoded root is ready • ");
            }
        } else {
            summary.append("Inside ").append(getRelativeDisplayPath(currentDir)).append(" • ");
        }

        summary.append(directories.size()).append(" folder(s) • ")
            .append(regularFiles.size()).append(" file(s)");
        if (!filter.isEmpty()) {
            summary.append(" • filtered by \"").append(filter).append("\"");
        }
        tvFolderSummary.setText(summary.toString());
    }

    private String buildFolderPreview(List<FileEntry> directories) {
        if (directories == null || directories.isEmpty()) {
            return "";
        }

        StringBuilder preview = new StringBuilder();
        int limit = Math.min(4, directories.size());
        for (int i = 0; i < limit; i++) {
            if (i > 0) {
                preview.append(", ");
            }
            preview.append(directories.get(i).file.getName());
        }
        if (directories.size() > limit) {
            preview.append(" +").append(directories.size() - limit).append(" more");
        }
        return preview.toString();
    }

    private void updateBuildButtons() {
        boolean hasWorkspace = decodedDir != null && decodedDir.isDirectory();
        btnDecode.setEnabled(!busy && selectedApkFile != null && selectedApkFile.isFile());
        btnRebuild.setEnabled(!busy && hasWorkspace);
        btnInstall.setEnabled(!busy && builtSignedApk != null && builtSignedApk.isFile());
        btnUp.setEnabled(!busy && currentDir != null && decodedDir != null && !currentDir.equals(decodedDir));
        btnNewFile.setEnabled(!busy && currentDir != null && currentDir.isDirectory());
        btnNewFolder.setEnabled(!busy && currentDir != null && currentDir.isDirectory());
    }

    private void setBusy(boolean value, String status) {
        busy = value;
        mainHandler.post(() -> {
            progressBar.setVisibility(value ? View.VISIBLE : View.GONE);
            progressBar.setIndeterminate(value);
            tvStatus.setText(status);
            updateBuildButtons();
        });
    }

    private void setSelectedApk(File file) {
        selectedApkFile = file;
        mainHandler.post(() -> tvSelectedApk.setText(
            "Selected APK: " + file.getName() + " (" + formatSize(file.length()) + ")"));
        saveLastWorkspace();
        updateHomeProjectState();
        updateBuildButtons();
    }

    private void prepareWorkspaceForApk(String apkName) {
        String safeName = apkName.replaceAll("[^A-Za-z0-9._-]", "_");
        String stamp = new SimpleDateFormat("yyyyMMdd_HHmmss", Locale.US).format(new Date());
        currentWorkspaceDir = new File(workspaceBaseDir, stamp + "_" + safeName.replaceAll("\\.apk$", ""));
        decodedDir = new File(currentWorkspaceDir, "decoded");
        currentDir = decodedDir;
        builtSignedApk = null;
        if (!currentWorkspaceDir.exists()) {
            //noinspection ResultOfMethodCallIgnored
            currentWorkspaceDir.mkdirs();
        }
        tvWorkspace.setText("Workspace: " + currentWorkspaceDir.getAbsolutePath());
        saveLastWorkspace();
        updateHomeProjectState();
    }

    private void restoreWorkspace() {
        String lastWorkspace = getSharedPreferences(PREFS, MODE_PRIVATE)
            .getString(PREF_LAST_WORKSPACE, null);
        if (lastWorkspace == null || lastWorkspace.trim().isEmpty()) {
            return;
        }
        File workspace = new File(lastWorkspace);
        if (!workspace.isDirectory()) {
            return;
        }

        currentWorkspaceDir = workspace;
        decodedDir = new File(currentWorkspaceDir, "decoded");
        currentDir = decodedDir.isDirectory() ? decodedDir : null;
        tvWorkspace.setText("Workspace: " + currentWorkspaceDir.getAbsolutePath());

        File stagedApk = new File(currentWorkspaceDir, "input.apk");
        if (stagedApk.isFile()) {
            selectedApkFile = stagedApk;
            tvSelectedApk.setText("Selected APK: " + stagedApk.getName() + " (" + formatSize(stagedApk.length()) + ")");
        }

        Properties meta = loadWorkspaceMetaQuietly();
        String lastBuilt = meta.getProperty("last_built_apk");
        if (lastBuilt != null && !lastBuilt.trim().isEmpty()) {
            File built = new File(lastBuilt);
            if (built.isFile()) {
                builtSignedApk = built;
            }
        }
        refreshCurrentDirectory();
        updateHomeProjectState();
    }

    private void saveLastWorkspace() {
        if (currentWorkspaceDir == null) return;
        getSharedPreferences(PREFS, MODE_PRIVATE)
            .edit()
            .putString(PREF_LAST_WORKSPACE, currentWorkspaceDir.getAbsolutePath())
            .apply();
    }

    private File resolveWorkspaceBaseDir() {
        File base = getExternalFilesDir("apk_editor");
        if (base == null) {
            base = new File(getFilesDir(), "apk_editor");
        }
        if (!base.exists()) {
            //noinspection ResultOfMethodCallIgnored
            base.mkdirs();
        }
        return base;
    }

    private File ensureFrameworkDir() throws IOException {
        File dir = new File(getFilesDir(), "apktool_framework");
        if (!dir.exists()) {
            //noinspection ResultOfMethodCallIgnored
            dir.mkdirs();
        }
        File frameworkApk = new File(dir, "1.apk");
        if (!isValidApktoolFrameworkFile(frameworkApk)) {
            File systemFramework = new File("/system/framework/framework-res.apk");
            if (!systemFramework.isFile()) {
                throw new IOException("System framework not found: " + systemFramework.getAbsolutePath());
            }
            if (frameworkApk.exists() && !frameworkApk.delete()) {
                throw new IOException("Cannot replace stale framework: " + frameworkApk.getAbsolutePath());
            }
            copyFile(systemFramework, frameworkApk);
            if (!isValidApktoolFrameworkFile(frameworkApk)) {
                throw new IOException("Provisioned framework is invalid: " + frameworkApk.getAbsolutePath());
            }
            log("🧱 Installed Apktool framework: " + frameworkApk.getAbsolutePath());
        }
        return dir;
    }

    private boolean isValidApktoolFrameworkFile(File file) {
        if (file == null || !file.isFile() || file.length() <= 0) {
            return false;
        }
        try (ZipFile zipFile = new ZipFile(file)) {
            return zipFile.getEntry("resources.arsc") != null;
        } catch (Exception e) {
            return false;
        }
    }

    private void saveWorkspaceMeta(ApkInfo apkInfo) throws IOException {
        Properties properties = new Properties();
        properties.setProperty("original_apk", selectedApkFile.getAbsolutePath());
        properties.setProperty("workspace_dir", currentWorkspaceDir.getAbsolutePath());
        properties.setProperty("decode_all_sources", Boolean.toString(cbAllSources.isChecked()));
        properties.setProperty("decode_no_assets", Boolean.toString(cbNoAssets.isChecked()));
        properties.setProperty("decode_keep_broken", Boolean.toString(cbKeepBroken.isChecked()));
        if (apkInfo != null && apkInfo.packageInfo != null && apkInfo.packageInfo.renameManifestPackage != null) {
            properties.setProperty("package_name", apkInfo.packageInfo.renameManifestPackage);
        }
        saveProperties(properties, new File(currentWorkspaceDir, META_FILE));
    }

    private Properties loadWorkspaceMeta() throws IOException {
        File file = new File(currentWorkspaceDir, META_FILE);
        if (!file.isFile()) {
            throw new IOException("Workspace metadata missing: " + file.getAbsolutePath());
        }
        return loadProperties(file);
    }

    private Properties loadWorkspaceMetaQuietly() {
        try {
            if (currentWorkspaceDir == null) return new Properties();
            File file = new File(currentWorkspaceDir, META_FILE);
            return file.isFile() ? loadProperties(file) : new Properties();
        } catch (Exception e) {
            return new Properties();
        }
    }

    private Map<String, String> loadBaselineHashes() throws Exception {
        Map<String, String> hashes = new HashMap<>();
        File file = new File(currentWorkspaceDir, HASH_FILE);
        if (!file.isFile()) {
            return hashes;
        }
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(new FileInputStream(file)))) {
            String line;
            while ((line = reader.readLine()) != null) {
                int idx = line.indexOf('|');
                if (idx <= 0) continue;
                hashes.put(line.substring(0, idx), line.substring(idx + 1));
            }
        }
        return hashes;
    }

    private void writeBaselineHashes(File root, File outFile) throws Exception {
        List<String> files = new ArrayList<>();
        collectRelativeFiles(root, root, files);
        Collections.sort(files);
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(outFile, false))) {
            for (String path : files) {
                if (isMetaPath(path)) continue;
                writer.write(path + "|" + sha256(new File(root, path.replace('/', File.separatorChar))));
                writer.newLine();
            }
        }
    }

    private void saveProperties(Properties properties, File file) throws IOException {
        try (FileOutputStream fos = new FileOutputStream(file)) {
            properties.store(fos, "HSPatcher APK Editor Workspace");
        }
    }

    private void createSplitBundleZip(File splitDir, File outputFile) throws IOException {
        File[] apks = splitDir.listFiles((dir, name) -> name.toLowerCase(Locale.US).endsWith(".apk"));
        if (apks == null || apks.length == 0) {
            throw new IOException("No split APK files found");
        }
        try (ZipOutputStream zos = new ZipOutputStream(new BufferedOutputStream(new FileOutputStream(outputFile)))) {
            byte[] buffer = new byte[65536];
            for (File apk : apks) {
                ZipEntry entry = new ZipEntry(apk.getName());
                entry.setTime(apk.lastModified());
                zos.putNextEntry(entry);
                try (InputStream in = new BufferedInputStream(new FileInputStream(apk), 65536)) {
                    int read;
                    while ((read = in.read(buffer)) >= 0) {
                        zos.write(buffer, 0, read);
                    }
                }
                zos.closeEntry();
            }
        }
    }

    private String sanitizeFileName(String value) {
        if (value == null || value.trim().isEmpty()) {
            return "apk_editor";
        }
        return value.replaceAll("[^A-Za-z0-9._-]", "_");
    }

    private Properties loadProperties(File file) throws IOException {
        Properties properties = new Properties();
        try (FileInputStream fis = new FileInputStream(file)) {
            properties.load(fis);
        }
        return properties;
    }

    private void showTextInputDialog(String title, String hint, String value, InputCallback callback) {
        final EditText input = new EditText(this);
        input.setHint(hint);
        input.setText(value);
        input.setInputType(InputType.TYPE_CLASS_TEXT);
        input.setTextColor(getColor(R.color.hsp_text));
        input.setHintTextColor(getColor(R.color.hsp_text_faint));
        input.setBackgroundResource(R.drawable.bg_glass_input);
        input.setPadding(dp(12), dp(10), dp(12), dp(10));

        new AlertDialog.Builder(this, android.R.style.Theme_Material_Dialog)
            .setTitle(title)
            .setView(input)
            .setPositiveButton("OK", (dialog, which) -> {
                String text = input.getText().toString().trim();
                if (!text.isEmpty()) {
                    callback.onValue(text);
                }
            })
            .setNegativeButton("Cancel", null)
            .show();
    }

    private TextView infoLabel(String text) {
        TextView label = new TextView(this);
        label.setText(text);
        label.setTextSize(11);
        label.setTextColor(getColor(R.color.hsp_text_muted));
        label.setPadding(dp(4), dp(4), dp(4), dp(4));
        return label;
    }

    private LinearLayout horizontalRow() {
        LinearLayout row = new LinearLayout(this);
        row.setOrientation(LinearLayout.HORIZONTAL);
        row.setGravity(Gravity.CENTER_VERTICAL);
        row.setPadding(0, dp(8), 0, 0);
        return row;
    }

    private LinearLayout sectionCard() {
        LinearLayout card = new LinearLayout(this);
        card.setOrientation(LinearLayout.VERTICAL);
        card.setBackgroundResource(R.drawable.bg_section_panel);
        card.setPadding(dp(12), dp(12), dp(12), dp(12));
        LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        params.topMargin = dp(10);
        card.setLayoutParams(params);
        return card;
    }

    private TextView sectionTitle(String text) {
        TextView title = new TextView(this);
        title.setText(text);
        title.setTextSize(13);
        title.setTypeface(null, Typeface.BOLD);
        title.setTextColor(getColor(R.color.hsp_text));
        return title;
    }

    private Button makeButton(String text, int tint) {
        Button button = new Button(this);
        button.setText(text);
        button.setAllCaps(false);
        button.setTextSize(11);
        button.setTextColor(getColor(R.color.hsp_text));
        button.setBackgroundResource(R.drawable.btn_surface);
        try {
            button.setBackgroundTintList(android.content.res.ColorStateList.valueOf(tint));
        } catch (Throwable ignored) {
        }
        return button;
    }

    private CheckBox makeCheckbox(String text, boolean checked) {
        CheckBox box = new CheckBox(this);
        box.setText(text);
        box.setChecked(checked);
        box.setTextColor(getColor(R.color.hsp_text_muted));
        return box;
    }

    private LinearLayout.LayoutParams weightedButtonParams() {
        return new LinearLayout.LayoutParams(0, dp(44), 1f);
    }

    private void addSpacer(LinearLayout row, int widthDp) {
        View spacer = new View(this);
        spacer.setLayoutParams(new LinearLayout.LayoutParams(dp(widthDp), 1));
        row.addView(spacer);
    }

    private void log(String message) {
        mainHandler.post(() -> {
            tvLog.append(message + "\n");
            if (tvLog.getLineCount() > 400) {
                CharSequence text = tvLog.getText();
                int cut = text.length() / 3;
                tvLog.setText(text.subSequence(cut, text.length()));
            }
        });
    }

    private void logThrowable(String prefix, Throwable throwable) {
        Log.e(TAG, prefix, throwable);
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        throwable.printStackTrace(printWriter);
        printWriter.flush();

        String[] lines = stringWriter.toString().split("\\r?\\n");
        int limit = Math.min(lines.length, 18);
        log("⚠ " + prefix + ": " + throwable.getClass().getName());
        for (int i = 0; i < limit; i++) {
            log("   " + lines[i]);
        }
        if (lines.length > limit) {
            log("   ...");
        }
    }

    private void toast(String message) {
        Toast.makeText(this, message, Toast.LENGTH_SHORT).show();
    }

    private int dp(int value) {
        return Math.round(value * getResources().getDisplayMetrics().density);
    }

    private String safeMessage(Throwable throwable) {
        String message = throwable.getMessage();
        return message == null || message.trim().isEmpty()
            ? throwable.getClass().getSimpleName() : message;
    }

    private String formatSize(long bytes) {
        if (bytes < 0) return "?";
        if (bytes < 1024) return bytes + " B";
        if (bytes < 1024 * 1024) return (bytes / 1024) + " KB";
        return String.format(Locale.US, "%.2f MB", bytes / 1024f / 1024f);
    }

    private String queryDisplayName(Uri uri) {
        android.database.Cursor cursor = null;
        try {
            cursor = getContentResolver().query(uri, null, null, null, null);
            if (cursor != null && cursor.moveToFirst()) {
                int idx = cursor.getColumnIndex(android.provider.OpenableColumns.DISPLAY_NAME);
                if (idx >= 0) {
                    return cursor.getString(idx);
                }
            }
        } catch (Throwable ignored) {
        } finally {
            if (cursor != null) {
                try { cursor.close(); } catch (Throwable ignored) {}
            }
        }
        return null;
    }

    private void copyFile(File source, File target) throws IOException {
        try (InputStream in = new FileInputStream(source);
             FileOutputStream out = new FileOutputStream(target, false)) {
            copyStream(in, out);
        }
    }

    private void copyStream(InputStream input, FileOutputStream output) throws IOException {
        try (BufferedInputStream in = new BufferedInputStream(input, 65536);
             BufferedOutputStream out = new BufferedOutputStream(output, 65536)) {
            byte[] buffer = new byte[65536];
            int read;
            while ((read = in.read(buffer)) >= 0) {
                out.write(buffer, 0, read);
            }
            out.flush();
        }
    }

    private void copyZipEntry(ZipFile zipFile, ZipEntry entry, ZipOutputStream zos) throws IOException {
        ZipEntry outEntry = new ZipEntry(entry.getName());
        outEntry.setTime(entry.getTime());
        zos.putNextEntry(outEntry);
        try (InputStream in = zipFile.getInputStream(entry)) {
            byte[] buffer = new byte[65536];
            int read;
            while ((read = in.read(buffer)) >= 0) {
                zos.write(buffer, 0, read);
            }
        }
        zos.closeEntry();
    }

    private void addFileEntry(ZipOutputStream zos, String entryName, File file) throws IOException {
        ZipEntry entry = new ZipEntry(entryName);
        entry.setTime(file.lastModified());
        zos.putNextEntry(entry);
        try (InputStream in = new BufferedInputStream(new FileInputStream(file), 65536)) {
            byte[] buffer = new byte[65536];
            int read;
            while ((read = in.read(buffer)) >= 0) {
                zos.write(buffer, 0, read);
            }
        }
        zos.closeEntry();
        log("✚ Packed " + entryName);
    }

    private void collectFiles(File root, List<File> out) {
        if (root == null || !root.exists()) return;
        if (root.isFile()) {
            out.add(root);
            return;
        }
        File[] children = root.listFiles();
        if (children == null) return;
        for (File child : children) {
            collectFiles(child, out);
        }
    }

    private void collectRelativeFiles(File root, File node, List<String> out) {
        if (node == null || !node.exists()) return;
        if (node.isFile()) {
            out.add(getRelativePath(root, node));
            return;
        }
        File[] children = node.listFiles();
        if (children == null) return;
        for (File child : children) {
            collectRelativeFiles(root, child, out);
        }
    }

    private String getRelativeDisplayPath(File file) {
        if (decodedDir == null || file == null) return "-";
        String rel = getRelativePath(decodedDir, file);
        return rel.isEmpty() ? "/" : rel;
    }

    private String getRelativePath(File root, File file) {
        String rootPath = root.getAbsolutePath();
        String filePath = file.getAbsolutePath();
        if (filePath.equals(rootPath)) {
            return "";
        }
        String rel = filePath.substring(rootPath.length() + 1);
        return rel.replace(File.separatorChar, '/');
    }

    private boolean shouldDeleteRawEntry(String entryName) {
        if (isBlockedTextResourcePath(entryName) || isSignatureEntry(entryName)) {
            return false;
        }
        if (isDexEntry(entryName)) {
            return false;
        }
        String topLevel = entryName.contains("/")
            ? entryName.substring(0, entryName.indexOf('/')) : entryName;
        File topLevelFile = new File(decodedDir, topLevel);
        if (!topLevelFile.exists()) {
            return false;
        }
        return !new File(decodedDir, entryName.replace('/', File.separatorChar)).exists();
    }

    private boolean isMetaFile(String relativePath) {
        return META_FILE.equals(relativePath) || HASH_FILE.equals(relativePath);
    }

    private boolean isMetaPath(String relativePath) {
        return isMetaFile(relativePath)
            || relativePath.startsWith("original/")
            || "apktool.yml".equals(relativePath)
            || relativePath.startsWith("build/");
    }

    private boolean isBlockedTextResourcePath(String relativePath) {
        return "AndroidManifest.xml".equals(relativePath) || relativePath.startsWith("res/");
    }

    private boolean isSmaliPath(String relativePath) {
        return relativePath.startsWith("smali/") || relativePath.startsWith("smali_");
    }

    private boolean isDexEntry(String name) {
        return name.matches("classes(\\d+)?\\.dex");
    }

    private boolean isSignatureEntry(String name) {
        return name.startsWith("META-INF/") &&
            (name.endsWith(".MF") || name.endsWith(".SF") || name.endsWith(".RSA") || name.endsWith(".DSA"));
    }

    private boolean isDatabaseFile(File file) {
        String name = file.getName().toLowerCase(Locale.US);
        return name.endsWith(".db") || name.endsWith(".sqlite") || name.endsWith(".sqlite3");
    }

    private boolean isTextEditable(File file) {
        String name = file.getName().toLowerCase(Locale.US);
        return name.endsWith(".smali")
            || name.endsWith(".xml")
            || name.endsWith(".txt")
            || name.endsWith(".json")
            || name.endsWith(".properties")
            || name.endsWith(".cfg")
            || name.endsWith(".ini")
            || name.endsWith(".gradle")
            || name.endsWith(".java")
            || name.endsWith(".kt")
            || name.endsWith(".md")
            || name.endsWith(".html")
            || name.endsWith(".js")
            || name.endsWith(".css")
            || name.endsWith(".csv")
            || name.endsWith(".yml")
            || name.endsWith(".yaml")
            || name.endsWith(".prop")
            || "apktool.yml".equals(name);
    }

    private String sha256Hex(byte[] bytes) throws Exception {
        MessageDigest digest = MessageDigest.getInstance("SHA-256");
        byte[] hash = digest.digest(bytes);
        StringBuilder builder = new StringBuilder(hash.length * 2);
        for (byte b : hash) {
            builder.append(String.format(Locale.US, "%02x", b));
        }
        return builder.toString();
    }

    private String sha256(File file) throws Exception {
        MessageDigest digest = MessageDigest.getInstance("SHA-256");
        try (InputStream in = new BufferedInputStream(new FileInputStream(file), 65536)) {
            byte[] buffer = new byte[65536];
            int read;
            while ((read = in.read(buffer)) >= 0) {
                digest.update(buffer, 0, read);
            }
        }
        byte[] bytes = digest.digest();
        StringBuilder builder = new StringBuilder(bytes.length * 2);
        for (byte b : bytes) {
            builder.append(String.format(Locale.US, "%02x", b));
        }
        return builder.toString();
    }

    private String buildOutputName(File originalApk) {
        String base = originalApk.getName().replaceAll("\\.apk$", "");
        String stamp = new SimpleDateFormat("HHmmss", Locale.US).format(new Date());
        return base + "_editor_" + stamp + ".apk";
    }

    private void deleteRecursively(File target) throws IOException {
        if (target == null || !target.exists()) return;
        if (target.isDirectory()) {
            File[] children = target.listFiles();
            if (children != null) {
                for (File child : children) {
                    deleteRecursively(child);
                }
            }
        }
        if (!target.delete()) {
            throw new IOException("Could not delete " + target.getAbsolutePath());
        }
    }

    private static final class FileEntry implements Comparable<FileEntry> {
        final File file;
        final boolean isParent;

        FileEntry(File file) {
            this.file = file;
            this.isParent = false;
        }

        private FileEntry(File file, boolean isParent) {
            this.file = file;
            this.isParent = isParent;
        }

        static FileEntry parent(File file) {
            return new FileEntry(file, true);
        }

        @Override
        public int compareTo(FileEntry other) {
            return this.file.getName().compareToIgnoreCase(other.file.getName());
        }
    }

    private static final class FileRowHolder {
        final TextView title;
        final TextView badge;
        final TextView meta;

        FileRowHolder(TextView title, TextView badge, TextView meta) {
            this.title = title;
            this.badge = badge;
            this.meta = meta;
        }
    }

    private final class FileListAdapter extends BaseAdapter {
        @Override
        public int getCount() {
            return visibleEntries.size();
        }

        @Override
        public Object getItem(int position) {
            return visibleEntries.get(position);
        }

        @Override
        public long getItemId(int position) {
            return position;
        }

        @Override
        public View getView(int position, View convertView, ViewGroup parent) {
            LinearLayout row = convertView instanceof LinearLayout
                ? (LinearLayout) convertView : buildRow();
            FileRowHolder holder = (FileRowHolder) row.getTag();

            FileEntry entry = visibleEntries.get(position);
            if (entry.isParent) {
                holder.title.setText("⬆ Parent folder");
                bindBadge(holder.badge, "UP", getColor(R.color.hsp_accent_amber));
                holder.meta.setText("Return to " + getRelativeDisplayPath(entry.file));
                return row;
            }

            File file = entry.file;
            String prefix = file.isDirectory() ? "📁 " : fileTypePrefix(file);
            holder.title.setText(prefix + file.getName());
            if (file.isDirectory()) {
                bindBadge(holder.badge, isRootChild(file) ? "ROOT" : "FOLDER",
                    isRootChild(file) ? getColor(R.color.hsp_accent_teal) : getColor(R.color.hsp_accent_blue));
            } else {
                bindBadge(holder.badge, fileKindLabel(file).toUpperCase(Locale.US), getColor(R.color.hsp_accent_indigo));
            }
            holder.meta.setText(buildEntryMeta(file));
            return row;
        }

        private LinearLayout buildRow() {
            LinearLayout row = new LinearLayout(ApkEditorActivity.this);
            row.setOrientation(LinearLayout.VERTICAL);
            row.setPadding(dp(14), dp(12), dp(14), dp(12));
            row.setBackgroundResource(R.drawable.bg_tools_option);

            LinearLayout titleRow = new LinearLayout(ApkEditorActivity.this);
            titleRow.setOrientation(LinearLayout.HORIZONTAL);
            titleRow.setGravity(Gravity.CENTER_VERTICAL);
            row.addView(titleRow);

            TextView title = new TextView(ApkEditorActivity.this);
            title.setTextColor(getColor(R.color.hsp_text));
            title.setTextSize(14);
            title.setTypeface(null, Typeface.BOLD);
            title.setLayoutParams(new LinearLayout.LayoutParams(0,
                ViewGroup.LayoutParams.WRAP_CONTENT, 1f));
            titleRow.addView(title);

            TextView badge = new TextView(ApkEditorActivity.this);
            badge.setBackgroundResource(R.drawable.bg_chip);
            badge.setPadding(dp(8), dp(3), dp(8), dp(3));
            badge.setTextSize(10);
            badge.setTypeface(null, Typeface.BOLD);
            titleRow.addView(badge);

            TextView meta = new TextView(ApkEditorActivity.this);
            meta.setTextColor(getColor(R.color.hsp_text_muted));
            meta.setTextSize(11);
            meta.setPadding(0, dp(3), 0, 0);
            row.addView(meta);

            AbsListView.LayoutParams params = new AbsListView.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
            row.setLayoutParams(params);
            row.setTag(new FileRowHolder(title, badge, meta));
            return row;
        }

        private void bindBadge(TextView badge, String label, int textColor) {
            badge.setVisibility(View.VISIBLE);
            badge.setText(label);
            badge.setTextColor(textColor);
        }
    }

    private String buildEntryMeta(File file) {
        if (file.isDirectory()) {
            int count = file.listFiles() == null ? 0 : file.listFiles().length;
            String scope = isRootChild(file) ? "decoded root folder" : "folder";
            return scope + " • " + count + " item(s)";
        }

        StringBuilder meta = new StringBuilder();
        meta.append(fileKindLabel(file)).append(" • ").append(formatSize(file.length()));
        if (decodedDir != null) {
            String relativePath = getRelativePath(decodedDir, file);
            if (!relativePath.isEmpty()) {
                meta.append(" • ").append(relativePath);
            }
        }
        return meta.toString();
    }

    private boolean isRootChild(File file) {
        return decodedDir != null && file != null && decodedDir.equals(file.getParentFile());
    }

    private String fileTypePrefix(File file) {
        if (isDatabaseFile(file)) return "🗄 ";
        if (isTextEditable(file)) return "📝 ";
        if (isDexEntry(file.getName())) return "⚙️ ";
        return "📄 ";
    }

    private String fileKindLabel(File file) {
        String rel = decodedDir != null ? getRelativePath(decodedDir, file) : file.getName();
        if (isBlockedTextResourcePath(rel)) return "resource text";
        if (isSmaliPath(rel)) return "smali";
        if (isDatabaseFile(file)) return "sqlite";
        if (isTextEditable(file)) return "text";
        return "binary";
    }

    private interface InputCallback {
        void onValue(String value);
    }
}