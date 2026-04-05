package in.startv.hspatcher;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Intent;
import android.database.Cursor;
import android.graphics.PorterDuff;
import android.graphics.Typeface;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.provider.OpenableColumns;
import android.text.InputType;
import android.text.method.KeyListener;
import android.text.method.ScrollingMovementMethod;
import android.view.Gravity;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.Toast;

import java.io.*;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.util.Arrays;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.regex.PatternSyntaxException;

/**
 * Find / Replace activity that handles large text files efficiently.
 *
 * Files up to LARGE_FILE_THRESHOLD are loaded fully into an EditText for
 * interactive editing (find-next, replace-one, replace-all, save).
 *
 * Larger files switch to "stream mode": only a preview is shown, but
 * Replace All streams through the entire file line-by-line in a background
 * thread, writing replacements to a temp cache file before overwriting the
 * original. Find Next scans the file asynchronously and reports match counts.
 *
 * All I/O runs on background threads to prevent ANR. A horizontal progress bar
 * shows real-time progress and a Cancel button lets the user abort long ops.
 */
public class TextReplaceActivity extends Activity {

    private static final int PICK_FILE = 4101;
    private static final int CREATE_FILE = 4102;

    /** Files below this size are loaded fully into the EditText. */
    private static final long LARGE_FILE_THRESHOLD = 4L * 1024 * 1024; // 4 MB
    /** Max bytes loaded as a read-only preview for large files. */
    private static final long MAX_PREVIEW_BYTES = 64L * 1024; // 64 KB

    // --- Current file state ---
    private Uri currentUri;
    private File currentFile;
    private String currentDisplayName;
    private long currentFileSize = -1;
    private Charset detectedCharset = StandardCharsets.UTF_8;
    private boolean isLargeFile = false;

    // --- UI views ---
    private TextView tvFile;
    private TextView tvStatus;
    private TextView tvProgress;
    private EditText etSearch;
    private EditText etReplace;
    private CheckBox cbWholeWord;
    private CheckBox cbRegex;
    private EditText etContent;
    private ProgressBar progressBar;
    private Button btnFindNext, btnReplaceOne, btnReplaceAll, btnCancel;

    private ScrollView rootScroll;
    private KeyListener etContentKeyListener;

    // --- Threading ---
    private final Handler mainHandler = new Handler(Looper.getMainLooper());
    private volatile Thread workerThread = null;
    private volatile boolean cancelRequested = false;

    // --- Match navigation ---
    private int lastMatchStart = -1;
    private int lastMatchEnd = -1;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        applyModernSystemUi();
        buildUi();

        String filePath = getIntent() != null ? getIntent().getStringExtra("file_path") : null;
        if (filePath != null && !filePath.trim().isEmpty()) {
            File file = new File(filePath);
            if (file.isFile()) {
                openFile(file);
                return;
            }
        }

        Uri intentData = getIntent() != null ? getIntent().getData() : null;
        if (intentData != null) {
            if ("file".equalsIgnoreCase(intentData.getScheme())) {
                File file = new File(intentData.getPath());
                if (file.isFile()) {
                    openFile(file);
                    return;
                }
            }
            openUri(intentData, true);
        }
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

    @Override
    protected void onDestroy() {
        cancelWork();
        super.onDestroy();
    }

    // ======================= UI BUILD =======================

    private void buildUi() {
        rootScroll = new ScrollView(this);
        rootScroll.setFillViewport(true);
        rootScroll.setBackgroundResource(R.drawable.bg_glass_root);

        LinearLayout main = new LinearLayout(this);
        main.setOrientation(LinearLayout.VERTICAL);
        main.setPadding(dp(16), dp(16), dp(16), dp(16));

        // Header
        TextView header = new TextView(this);
        header.setText("\uD83D\uDD0E Find / Replace");
        header.setTextSize(26);
        header.setTypeface(null, Typeface.BOLD);
        header.setGravity(Gravity.CENTER);
        header.setTextColor(getColor(R.color.hsp_accent_blue));
        header.setPadding(0, dp(6), 0, dp(2));
        main.addView(header);

        TextView sub = new TextView(this);
        sub.setText("Open a text file \u2192 search \u2192 replace \u2192 save \u2022 Handles large files");
        sub.setTextSize(12);
        sub.setGravity(Gravity.CENTER);
        sub.setTextColor(getColor(R.color.hsp_text_muted));
        sub.setPadding(0, 0, 0, dp(12));
        main.addView(sub);

        // File buttons row
        LinearLayout fileRow = new LinearLayout(this);
        fileRow.setOrientation(LinearLayout.HORIZONTAL);
        fileRow.setGravity(Gravity.CENTER_VERTICAL);

        Button btnOpen = makeButton("\uD83D\uDCC2 OPEN", getColor(R.color.hsp_surface));
        btnOpen.setLayoutParams(new LinearLayout.LayoutParams(0, dp(44), 1));
        btnOpen.setOnClickListener(v -> pickFile());
        fileRow.addView(btnOpen);

        addSpacer(fileRow, 6);

        Button btnSave = makeButton("\uD83D\uDCBE SAVE", getColor(R.color.hsp_legacy_success));
        btnSave.setLayoutParams(new LinearLayout.LayoutParams(0, dp(44), 1));
        btnSave.setOnClickListener(v -> saveToCurrent());
        fileRow.addView(btnSave);

        addSpacer(fileRow, 6);

        Button btnSaveAs = makeButton("📤 SAVE AS", getColor(R.color.hsp_accent_indigo));
        btnSaveAs.setLayoutParams(new LinearLayout.LayoutParams(0, dp(44), 1));
        btnSaveAs.setOnClickListener(v -> saveAs());
        fileRow.addView(btnSaveAs);

        main.addView(fileRow);

        // File info label
        tvFile = new TextView(this);
        tvFile.setText("No file loaded");
        tvFile.setTextSize(12);
        tvFile.setTextColor(getColor(R.color.hsp_text_muted));
        tvFile.setPadding(dp(6), dp(8), dp(6), dp(8));
        tvFile.setSingleLine(true);
        main.addView(tvFile);

        // Progress bar (hidden by default)
        progressBar = new ProgressBar(this, null, android.R.attr.progressBarStyleHorizontal);
        progressBar.setMax(1000);
        progressBar.setProgress(0);
        progressBar.setVisibility(View.GONE);
        progressBar.setPadding(0, dp(4), 0, dp(4));
        progressBar.getProgressDrawable().setColorFilter(
            getColor(R.color.hsp_accent_green), PorterDuff.Mode.SRC_IN);
        main.addView(progressBar, new LinearLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT, dp(20)));

        tvProgress = new TextView(this);
        tvProgress.setText("");
        tvProgress.setTextSize(11);
        tvProgress.setTextColor(getColor(R.color.hsp_accent_green));
        tvProgress.setGravity(Gravity.CENTER);
        tvProgress.setVisibility(View.GONE);
        tvProgress.setPadding(0, 0, 0, dp(4));
        main.addView(tvProgress);

        // Search input
        TextView lblSearch = new TextView(this);
        lblSearch.setText("Search");
        lblSearch.setTextSize(13);
        lblSearch.setTextColor(getColor(R.color.hsp_text));
        lblSearch.setPadding(0, dp(6), 0, dp(4));
        main.addView(lblSearch);

        etSearch = new EditText(this);
        etSearch.setHint("text or regex pattern");
        etSearch.setTextColor(getColor(R.color.hsp_text));
        etSearch.setHintTextColor(getColor(R.color.hsp_text_muted));
        etSearch.setBackgroundResource(R.drawable.bg_glass_input);
        etSearch.setPadding(dp(12), dp(10), dp(12), dp(10));
        main.addView(etSearch, new LinearLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT));

        // Options row
        LinearLayout optionsRow = new LinearLayout(this);
        optionsRow.setOrientation(LinearLayout.HORIZONTAL);
        optionsRow.setPadding(0, dp(6), 0, dp(4));

        cbWholeWord = new CheckBox(this);
        cbWholeWord.setText("Whole word");
        cbWholeWord.setTextColor(getColor(R.color.hsp_text));
        optionsRow.addView(cbWholeWord);

        addSpacer(optionsRow, 12);

        cbRegex = new CheckBox(this);
        cbRegex.setText("Regex");
        cbRegex.setTextColor(getColor(R.color.hsp_text));
        optionsRow.addView(cbRegex);

        main.addView(optionsRow);

        // Replace input
        TextView lblReplace = new TextView(this);
        lblReplace.setText("Replace");
        lblReplace.setTextSize(13);
        lblReplace.setTextColor(getColor(R.color.hsp_text));
        lblReplace.setPadding(0, dp(6), 0, dp(4));
        main.addView(lblReplace);

        etReplace = new EditText(this);
        etReplace.setHint("replacement text");
        etReplace.setTextColor(getColor(R.color.hsp_text));
        etReplace.setHintTextColor(getColor(R.color.hsp_text_muted));
        etReplace.setBackgroundResource(R.drawable.bg_glass_input);
        etReplace.setPadding(dp(12), dp(10), dp(12), dp(10));
        main.addView(etReplace, new LinearLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT));

        // Action buttons row
        LinearLayout actionRow = new LinearLayout(this);
        actionRow.setOrientation(LinearLayout.HORIZONTAL);
        actionRow.setPadding(0, dp(10), 0, dp(6));

        btnFindNext = makeButton("🔎 FIND NEXT", getColor(R.color.hsp_accent_blue));
        btnFindNext.setLayoutParams(new LinearLayout.LayoutParams(0, dp(42), 1));
        btnFindNext.setOnClickListener(v -> findNext(true));
        actionRow.addView(btnFindNext);

        addSpacer(actionRow, 6);

        btnReplaceOne = makeButton("✏ REPLACE", getColor(R.color.hsp_accent_amber));
        btnReplaceOne.setLayoutParams(new LinearLayout.LayoutParams(0, dp(42), 1));
        btnReplaceOne.setOnClickListener(v -> replaceCurrent());
        actionRow.addView(btnReplaceOne);

        addSpacer(actionRow, 6);

        btnReplaceAll = makeButton("REPLACE ALL", getColor(R.color.hsp_legacy_danger));
        btnReplaceAll.setLayoutParams(new LinearLayout.LayoutParams(0, dp(42), 1));
        btnReplaceAll.setOnClickListener(v -> replaceAll());
        actionRow.addView(btnReplaceAll);

        main.addView(actionRow);

        // Cancel button (hidden by default, shown during async ops)
        btnCancel = makeButton("\u26D4 CANCEL", getColor(R.color.hsp_accent_red));
        btnCancel.setVisibility(View.GONE);
        btnCancel.setOnClickListener(v -> cancelWork());
        main.addView(btnCancel, new LinearLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT, dp(42)));

        // Status
        tvStatus = new TextView(this);
        tvStatus.setText("Status: idle");
        tvStatus.setTextSize(12);
        tvStatus.setTextColor(getColor(R.color.hsp_text_muted));
        tvStatus.setPadding(dp(6), dp(4), dp(6), dp(10));
        main.addView(tvStatus);

        // Content label
        TextView lblContent = new TextView(this);
        lblContent.setText("File content");
        lblContent.setTextSize(13);
        lblContent.setTextColor(getColor(R.color.hsp_text));
        lblContent.setPadding(0, dp(6), 0, dp(4));
        main.addView(lblContent);

        // Content EditText
        etContent = new EditText(this);
        etContent.setTypeface(Typeface.MONOSPACE);
        etContent.setTextColor(getColor(R.color.hsp_text));
        etContent.setHintTextColor(getColor(R.color.hsp_text_muted));
        etContent.setBackgroundResource(R.drawable.bg_log);
        etContent.setPadding(dp(12), dp(12), dp(12), dp(12));
        etContent.setMinLines(12);
        etContent.setGravity(Gravity.TOP | Gravity.START);
        etContent.setSingleLine(false);
        etContent.setInputType(InputType.TYPE_CLASS_TEXT
            | InputType.TYPE_TEXT_FLAG_MULTI_LINE
            | InputType.TYPE_TEXT_FLAG_NO_SUGGESTIONS);
        etContent.setHorizontallyScrolling(true);
        etContent.setVerticalScrollBarEnabled(true);
        etContent.setHorizontalScrollBarEnabled(true);
        etContent.setScrollBarStyle(View.SCROLLBARS_INSIDE_OVERLAY);
        etContent.setOverScrollMode(View.OVER_SCROLL_ALWAYS);
        etContent.setMovementMethod(ScrollingMovementMethod.getInstance());
        etContent.setOnTouchListener((v, event) -> {
            // Allow scrolling inside etContent even though the whole screen is a ScrollView.
            // Otherwise the parent ScrollView intercepts touch events and it feels like
            // the content area is "not scrollable".
            if (rootScroll != null) {
                int action = event.getActionMasked();
                if (action == MotionEvent.ACTION_DOWN || action == MotionEvent.ACTION_MOVE) {
                    rootScroll.requestDisallowInterceptTouchEvent(true);
                } else if (action == MotionEvent.ACTION_UP || action == MotionEvent.ACTION_CANCEL) {
                    rootScroll.requestDisallowInterceptTouchEvent(false);
                }
            }
            return false;
        });
        etContentKeyListener = etContent.getKeyListener();
        main.addView(etContent, new LinearLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT, dp(420)));

        rootScroll.addView(main);
        setContentView(rootScroll);
    }

    private void setContentReadOnly(boolean readOnly) {
        // Keep the view enabled so it can scroll/select text.
        etContent.setEnabled(true);
        if (readOnly) {
            etContent.setKeyListener(null);
            etContent.setCursorVisible(false);
            etContent.setTextIsSelectable(true);
        } else {
            etContent.setKeyListener(etContentKeyListener);
            etContent.setCursorVisible(true);
            etContent.setTextIsSelectable(false);
        }
    }

    // ======================= PROGRESS UI =======================

    private void showProgress(boolean show) {
        progressBar.setVisibility(show ? View.VISIBLE : View.GONE);
        tvProgress.setVisibility(show ? View.VISIBLE : View.GONE);
        btnCancel.setVisibility(show ? View.VISIBLE : View.GONE);
        if (!show) {
            progressBar.setProgress(0);
            tvProgress.setText("");
        }
    }

    /** Post-safe progress update from any thread. permille = 0..1000. */
    private void updateProgress(int permille, String message) {
        mainHandler.post(() -> {
            progressBar.setProgress(Math.max(0, Math.min(1000, permille)));
            if (message != null) tvProgress.setText(message);
        });
    }

    /** Lock/unlock UI controls during async work. */
    private void setWorkingState(boolean working) {
        mainHandler.post(() -> {
            showProgress(working);
            etSearch.setEnabled(!working);
            etReplace.setEnabled(!working);
            btnFindNext.setEnabled(!working);
            btnReplaceOne.setEnabled(!working);
            btnReplaceAll.setEnabled(!working);
        });
    }

    // ======================= FILE OPEN / SAVE =======================

    private void pickFile() {
        if (isWorking()) {
            toast("Operation in progress \u2014 please wait or cancel");
            return;
        }
        Intent intent = new Intent(Intent.ACTION_OPEN_DOCUMENT);
        intent.addCategory(Intent.CATEGORY_OPENABLE);
        intent.setType("*/*");
        intent.putExtra(Intent.EXTRA_MIME_TYPES,
            new String[]{"text/*", "application/json", "application/xml"});
        startActivityForResult(intent, PICK_FILE);
    }

    private void openUri(Uri uri, boolean tryPersist) {
        if (uri == null) return;
        if (isWorking()) { toast("Operation in progress"); return; }

        if (tryPersist) {
            int takeFlags = (getIntent() != null ? getIntent().getFlags() : 0)
                & (Intent.FLAG_GRANT_READ_URI_PERMISSION
                    | Intent.FLAG_GRANT_WRITE_URI_PERMISSION);
            if (takeFlags != 0) {
                try { getContentResolver().takePersistableUriPermission(uri, takeFlags); }
                catch (Throwable ignored) {}
            }
        }

        currentUri = uri;
        currentFile = null;
        currentDisplayName = queryDisplayName(uri);
        currentFileSize = queryFileSize(uri);
        isLargeFile = currentFileSize > LARGE_FILE_THRESHOLD;

        String sizeLabel = formatSize(currentFileSize);
        String nameLabel = currentDisplayName != null
            ? currentDisplayName : String.valueOf(uri.getLastPathSegment());
        tvFile.setText("Loading: " + nameLabel + " (" + sizeLabel + ")");

        loadFileAsync(uri);
    }

    private void openFile(File file) {
        if (file == null || !file.isFile()) return;
        if (isWorking()) { toast("Operation in progress"); return; }

        currentFile = file;
        currentUri = null;
        currentDisplayName = file.getName();
        currentFileSize = file.length();
        isLargeFile = currentFileSize > LARGE_FILE_THRESHOLD;
        tvFile.setText("Loading: " + currentDisplayName + " (" + formatSize(currentFileSize) + ")");
        loadFileAsync(null);
    }

    /** Loads the file on a background thread with progress reporting. */
    private void loadFileAsync(Uri uri) {
        cancelRequested = false;
        setWorkingState(true);
        setStatus("Loading file...");

        workerThread = new Thread(() -> {
            try {
                if (isLargeFile) {
                    loadLargeFilePreview(uri);
                } else {
                    loadSmallFile(uri);
                }
            } catch (Exception e) {
                final String msg = safeMsg(e);
                mainHandler.post(() -> {
                    setWorkingState(false);
                    if (!"Cancelled".equals(msg)) toast("Load failed: " + msg);
                    setStatus(cancelRequested ? "Load cancelled" : "Load failed");
                });
            }
        }, "FileLoader");
        workerThread.start();
    }

    /** Reads the entire file into memory and populates the EditText (edit mode). */
    private void loadSmallFile(Uri uri) throws IOException {
        long total = currentFileSize > 0 ? currentFileSize : 1;
        ByteArrayOutputStream bos = new ByteArrayOutputStream();
        try (InputStream in = openInputStream(uri)) {
            if (in == null) throw new IOException("Cannot open file");
            BufferedInputStream bin = new BufferedInputStream(in, 32768);
            byte[] buf = new byte[32768];
            long read = 0;
            int n;
            while ((n = bin.read(buf)) >= 0) {
                if (cancelRequested) throw new IOException("Cancelled");
                bos.write(buf, 0, n);
                read += n;
                // If size was unknown (-1) and actual bytes exceed threshold,
                // switch to large-file stream mode to avoid EditText OOM/ANR.
                if (currentFileSize < 0 && read > LARGE_FILE_THRESHOLD) {
                    bos.close();
                    currentFileSize = read; // estimate (may grow)
                    isLargeFile = true;
                    loadLargeFilePreview(uri);
                    return;
                }
                int pct = total > 1 ? (int) (read * 1000 / total) : -1;
                if (pct >= 0) updateProgress(pct,
                    "Loading... " + formatSize(read) + " / " + formatSize(total));
                else updateProgress(500, "Loading... " + formatSize(read));
            }
        }
        byte[] data = bos.toByteArray();

        // Double-check: actual bytes may exceed threshold even if queryFileSize
        // returned a small/stale value.
        if (data.length > LARGE_FILE_THRESHOLD) {
            currentFileSize = data.length;
            isLargeFile = true;
            loadLargeFilePreview(uri);
            return;
        }

        DecodedText decoded = decodeText(data);
        detectedCharset = decoded.charset;

        mainHandler.post(() -> {
            setWorkingState(false);
            isLargeFile = false;
            setContentReadOnly(false);
            etContent.setText(decoded.text);
            etContent.setHint("");
            lastMatchStart = -1;
            lastMatchEnd = -1;
            String name = currentDisplayName != null ? currentDisplayName : "file";
            tvFile.setText("Loaded: " + name + " (" + formatSize(data.length) + ")");
            setStatus("Loaded " + decoded.charset.displayName() + " \u2022 Edit mode");
        });
    }

    /** Reads only a preview of the large file and shows it read-only. */
    private void loadLargeFilePreview(Uri uri) throws IOException {
        long total = currentFileSize > 0 ? currentFileSize : 1;
        int previewSize = (int) Math.min(MAX_PREVIEW_BYTES, total);
        byte[] preview = new byte[previewSize];
        int read = 0;
        try (InputStream in = openInputStream(uri)) {
            if (in == null) throw new IOException("Cannot open file");
            BufferedInputStream bin = new BufferedInputStream(in, 32768);
            int n;
            while (read < previewSize
                    && (n = bin.read(preview, read, previewSize - read)) >= 0) {
                if (cancelRequested) throw new IOException("Cancelled");
                read += n;
            }
        }

        byte[] actualPreview = read < previewSize
            ? Arrays.copyOf(preview, read) : preview;
        DecodedText decoded = decodeText(actualPreview);
        detectedCharset = decoded.charset;

        // Truncate at last complete line for a clean preview
        String previewText = decoded.text;
        int lastNewline = previewText.lastIndexOf('\n');
        if (lastNewline > 0 && lastNewline < previewText.length() - 1) {
            previewText = previewText.substring(0, lastNewline + 1);
        }

        final String displayText = previewText
            + "\n\n\u2501\u2501\u2501 PREVIEW END \u2501\u2501\u2501\n"
            + "File too large for inline editing (" + formatSize(total) + ")\n"
            + "Use REPLACE ALL to process the entire file via streaming.\n"
            + "Use FIND NEXT to scan for matches.\n";

        mainHandler.post(() -> {
            setWorkingState(false);
            isLargeFile = true;
            setContentReadOnly(true);
            etContent.setText(displayText);
            etContent.setHint("");
            lastMatchStart = -1;
            lastMatchEnd = -1;
            String name = currentDisplayName != null ? currentDisplayName : "file";
            tvFile.setText("Loaded (stream mode): " + name
                + " (" + formatSize(total) + ")");
            setStatus("Stream mode \u2014 Replace All processes entire file");
        });
    }

    private void saveToCurrent() {
        if (isWorking()) { toast("Operation in progress"); return; }
        if (isLargeFile) {
            toast("Large file \u2014 content was not fully loaded. Use Replace All.");
            return;
        }

        if (currentFile != null) {
            saveToFileAsync(currentFile, etContent.getText().toString(), "Saved");
            return;
        }

        if (currentUri == null) { toast("No file loaded. Use SAVE AS."); return; }
        saveAsync(currentUri, etContent.getText().toString(), "Saved");
    }

    private void saveAs() {
        if (isWorking()) { toast("Operation in progress"); return; }
        if (isLargeFile) {
            toast("Large file \u2014 content was not fully loaded. Use Replace All.");
            return;
        }
        String defaultName = (currentDisplayName != null
            && !currentDisplayName.trim().isEmpty())
            ? currentDisplayName : "text.txt";

        Intent intent = new Intent(Intent.ACTION_CREATE_DOCUMENT);
        intent.addCategory(Intent.CATEGORY_OPENABLE);
        intent.setType("text/plain");
        intent.putExtra(Intent.EXTRA_TITLE, defaultName);
        startActivityForResult(intent, CREATE_FILE);
    }

    /** Writes text to the given URI on a background thread with progress. */
    private void saveAsync(Uri uri, String text, String successMsg) {
        cancelRequested = false;
        setWorkingState(true);
        setStatus("Saving...");

        workerThread = new Thread(() -> {
            try {
                Charset cs = detectedCharset != null
                    ? detectedCharset : StandardCharsets.UTF_8;
                byte[] bytes = (text != null ? text : "").getBytes(cs);
                long total = bytes.length;
                 try (OutputStream out = openOutputStream(uri)) {
                    if (out == null) throw new IOException("Cannot open output");
                    BufferedOutputStream bos = new BufferedOutputStream(out, 32768);
                    int offset = 0;
                    while (offset < bytes.length) {
                        if (cancelRequested) throw new IOException("Cancelled");
                        int len = Math.min(32768, bytes.length - offset);
                        bos.write(bytes, offset, len);
                        offset += len;
                        updateProgress((int) (offset * 1000 / total),
                            "Saving... " + formatSize(offset)
                                + " / " + formatSize(total));
                    }
                    bos.flush();
                }
                mainHandler.post(() -> {
                    setWorkingState(false);
                    toast(successMsg);
                    setStatus(successMsg);
                });
            } catch (Exception e) {
                final String msg = safeMsg(e);
                mainHandler.post(() -> {
                    setWorkingState(false);
                    if (!"Cancelled".equals(msg)) toast("Save failed: " + msg);
                    setStatus(cancelRequested ? "Save cancelled" : "Save failed");
                });
            }
        }, "FileSaver");
        workerThread.start();
    }

    private void saveToFileAsync(File file, String text, String successMsg) {
        cancelRequested = false;
        setWorkingState(true);
        setStatus("Saving...");

        workerThread = new Thread(() -> {
            try {
                Charset cs = detectedCharset != null
                    ? detectedCharset : StandardCharsets.UTF_8;
                byte[] bytes = (text != null ? text : "").getBytes(cs);
                long total = Math.max(1, bytes.length);
                try (BufferedOutputStream bos = new BufferedOutputStream(
                        new FileOutputStream(file, false), 32768)) {
                    int offset = 0;
                    while (offset < bytes.length) {
                        if (cancelRequested) throw new IOException("Cancelled");
                        int len = Math.min(32768, bytes.length - offset);
                        bos.write(bytes, offset, len);
                        offset += len;
                        updateProgress((int) (offset * 1000L / total),
                            "Saving... " + formatSize(offset)
                                + " / " + formatSize(bytes.length));
                    }
                    bos.flush();
                }
                currentFileSize = file.length();
                mainHandler.post(() -> {
                    setWorkingState(false);
                    toast(successMsg);
                    setStatus(successMsg);
                    tvFile.setText("Loaded: " + file.getName() + " (" + formatSize(file.length()) + ")");
                });
            } catch (Exception e) {
                final String msg = safeMsg(e);
                mainHandler.post(() -> {
                    setWorkingState(false);
                    if (!"Cancelled".equals(msg)) toast("Save failed: " + msg);
                    setStatus(cancelRequested ? "Save cancelled" : "Save failed");
                });
            }
        }, "FileSaver");
        workerThread.start();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (resultCode != RESULT_OK || data == null) return;

        if (requestCode == PICK_FILE) {
            Uri uri = data.getData();
            if (uri != null) {
                int flags = data.getFlags()
                    & (Intent.FLAG_GRANT_READ_URI_PERMISSION
                        | Intent.FLAG_GRANT_WRITE_URI_PERMISSION);
                try { getContentResolver().takePersistableUriPermission(uri, flags); }
                catch (Throwable ignored) {}
                openUri(uri, false);
            }
        } else if (requestCode == CREATE_FILE) {
            Uri uri = data.getData();
            if (uri != null) {
                saveAsync(uri, etContent.getText().toString(), "Saved (new file)");
            }
        }
    }

    // ======================= SEARCH / REPLACE =======================

    private void findNext(boolean wrapAround) {
        if (isWorking()) { toast("Operation in progress"); return; }

        Pattern pattern = compilePattern();
        if (pattern == null) return;

        if (isLargeFile) {
            // Large file: scan asynchronously without loading all content
            findInStreamAsync(pattern);
            return;
        }

        // Small file: search in-memory
        String content = etContent.getText().toString();
        int startFrom = (lastMatchEnd >= 0 && lastMatchEnd <= content.length())
            ? lastMatchEnd : 0;

        Matcher matcher = pattern.matcher(content);
        boolean found = matcher.find(startFrom);
        if (!found && wrapAround && startFrom > 0) {
            matcher = pattern.matcher(content);
            found = matcher.find(0);
            if (found) toast("Wrapped to start");
        }

        if (!found) {
            lastMatchStart = -1;
            lastMatchEnd = -1;
            toast("No match");
            setStatus(matchCountText(pattern, content, -1));
            return;
        }

        lastMatchStart = matcher.start();
        lastMatchEnd = matcher.end();
        try {
            etContent.requestFocus();
            etContent.setSelection(lastMatchStart, lastMatchEnd);
        } catch (Throwable ignored) {}

        setStatus(matchCountText(pattern, content, lastMatchStart));
    }

    /**
     * Scans the large file line-by-line on a background thread to count matches.
     */
    private void findInStreamAsync(Pattern pattern) {
        cancelRequested = false;
        setWorkingState(true);
        setStatus("Scanning file for matches...");

        workerThread = new Thread(() -> {
            long totalBytes = currentFileSize > 0 ? currentFileSize : 1;
            long bytesRead = 0;
            int matchCount = 0;
            int lineNum = 0;
            int firstMatchLine = -1;
            String firstMatchSnippet = null;

            try (InputStream in = openCurrentInputStream()) {
                if (in == null) throw new IOException("Cannot open file");
                BufferedReader reader = new BufferedReader(
                    new InputStreamReader(
                        new BufferedInputStream(in, 65536), detectedCharset));

                String line;
                while ((line = reader.readLine()) != null) {
                    if (cancelRequested) throw new IOException("Cancelled");
                    lineNum++;
                    bytesRead += line.length() + 1;

                    Matcher m = pattern.matcher(line);
                    while (m.find()) {
                        matchCount++;
                        if (firstMatchLine < 0) {
                            firstMatchLine = lineNum;
                            int start = Math.max(0, m.start() - 20);
                            int end = Math.min(line.length(), m.end() + 20);
                            firstMatchSnippet = "..."
                                + line.substring(start, end) + "...";
                        }
                    }

                    if (lineNum % 2000 == 0) {
                        int pct = (int) (bytesRead * 1000 / totalBytes);
                        int mc = matchCount;
                        updateProgress(Math.min(pct, 999),
                            "Scanning... " + mc + " matches, line " + lineNum);
                    }
                }
            } catch (IOException e) {
                final String msg = safeMsg(e);
                mainHandler.post(() -> {
                    setWorkingState(false);
                    if (!"Cancelled".equals(msg)) toast("Scan failed: " + msg);
                    setStatus(cancelRequested ? "Scan cancelled" : "Scan failed");
                });
                return;
            }

            final int totalMatches = matchCount;
            final int fmLine = firstMatchLine;
            final String fmSnippet = firstMatchSnippet;
            final int totalLines = lineNum;

            mainHandler.post(() -> {
                setWorkingState(false);
                if (totalMatches == 0) {
                    toast("No matches found");
                    setStatus("0 matches in " + totalLines + " lines");
                } else {
                    String statusMsg = totalMatches + " match"
                        + (totalMatches > 1 ? "es" : "") + " found";
                    if (fmLine > 0) statusMsg += " \u2022 first at line " + fmLine;
                    setStatus(statusMsg);
                    if (fmSnippet != null) toast("First match line " + fmLine);
                }
            });
        }, "StreamFinder");
        workerThread.start();
    }

    private void replaceCurrent() {
        if (isWorking()) { toast("Operation in progress"); return; }
        if (isLargeFile) {
            toast("Single replace not available in stream mode. Use REPLACE ALL.");
            return;
        }

        String content = etContent.getText().toString();
        Pattern pattern = compilePattern();
        if (pattern == null) return;

        if (lastMatchStart < 0 || lastMatchEnd < 0
                || lastMatchEnd > content.length()) {
            toast("Use FIND NEXT first");
            return;
        }

        // Verify the current selection still matches.
        Matcher verifyMatcher = pattern.matcher(content);
        boolean ok = false;
        while (verifyMatcher.find()) {
            if (verifyMatcher.start() == lastMatchStart
                    && verifyMatcher.end() == lastMatchEnd) {
                ok = true;
                break;
            }
            if (verifyMatcher.start() > lastMatchStart) break;
        }

        if (!ok) {
            toast("Current match moved. Use FIND NEXT again.");
            return;
        }

        String replacement = etReplace.getText().toString();
        if (!cbRegex.isChecked()) {
            replacement = Matcher.quoteReplacement(replacement);
        }

        String replaced;
        int newCursor;
        try {
            Matcher replaceMatcher = pattern.matcher(content);
            StringBuffer sb = new StringBuffer();
            newCursor = -1;
            while (replaceMatcher.find()) {
                if (replaceMatcher.start() == lastMatchStart
                        && replaceMatcher.end() == lastMatchEnd) {
                    replaceMatcher.appendReplacement(sb, replacement);
                    newCursor = sb.length();
                } else {
                    replaceMatcher.appendReplacement(sb,
                        Matcher.quoteReplacement(replaceMatcher.group(0)));
                }
            }
            replaceMatcher.appendTail(sb);
            replaced = sb.toString();
            if (newCursor < 0) {
                toast("Replace failed: current match not found");
                return;
            }
        } catch (Exception e) {
            toast("Replace failed: " + safeMsg(e));
            return;
        }

        etContent.setText(replaced);
        try {
            etContent.setSelection(Math.min(newCursor, replaced.length()));
        } catch (Throwable ignored) {}

        lastMatchStart = -1;
        lastMatchEnd = newCursor;
        findNext(true);
    }

    private void replaceAll() {
        if (isWorking()) { toast("Operation in progress"); return; }

        Pattern pattern = compilePattern();
        if (pattern == null) return;

        if (isLargeFile) {
            // Confirm before streaming through a large file
            String searchText = etSearch.getText().toString();
            String replaceText = etReplace.getText().toString();
            new AlertDialog.Builder(this,
                    android.R.style.Theme_Material_Dialog_Alert)
                .setTitle("Replace All (large file)")
                .setMessage("Stream-process entire file ("
                    + formatSize(currentFileSize) + ")?\n\n"
                    + "Search: " + searchText + "\n"
                    + "Replace: " + replaceText + "\n\n"
                    + "The file will be modified in place.")
                .setPositiveButton("Replace",
                    (d, w) -> streamReplaceAllAsync(pattern))
                .setNegativeButton("Cancel", null)
                .show();
            return;
        }

        // Small file: in-memory replace
        replaceAllInMemory(pattern);
    }

    /** Fast in-memory replace for small files already loaded in EditText. */
    private void replaceAllInMemory(Pattern pattern) {
        String content = etContent.getText().toString();
        String replacement = etReplace.getText().toString();
        if (!cbRegex.isChecked()) {
            replacement = Matcher.quoteReplacement(replacement);
        }

        try {
            Matcher matcher = pattern.matcher(content);
            String replaced = matcher.replaceAll(replacement);
            etContent.setText(replaced);
            lastMatchStart = -1;
            lastMatchEnd = 0;
            setStatus(matchCountText(pattern, replaced, -1));
            toast("Replace all done");
        } catch (Exception e) {
            toast("Replace all failed: " + safeMsg(e));
        }
    }

    /**
    * Core large-file handler. Reads from the current source line-by-line, applies
     * find/replace, writes to a temp cache file, then streams the temp file
     * back to the original URI. Runs entirely on a background thread with
     * two-phase progress (processing + write-back).
     */
    private void streamReplaceAllAsync(Pattern pattern) {
        cancelRequested = false;
        setWorkingState(true);

        String replacement = etReplace.getText().toString();
        final String safeReplacement = cbRegex.isChecked()
            ? replacement : Matcher.quoteReplacement(replacement);

        workerThread = new Thread(() -> {
            File tempFile = new File(getCacheDir(),
                "text_replace_temp_" + System.currentTimeMillis() + ".tmp");
            long totalBytes = currentFileSize > 0 ? currentFileSize : 1;
            long bytesRead = 0;
            int totalReplacements = 0;
            int linesProcessed = 0;

            try {
                // Phase 1: Read source -> apply replacements -> write to temp
                updateProgress(0, "Phase 1/2: Processing...");

                try (InputStream in = openCurrentInputStream();
                     BufferedWriter writer = new BufferedWriter(
                         new OutputStreamWriter(
                             new FileOutputStream(tempFile), detectedCharset),
                         65536)) {

                    if (in == null) throw new IOException("Cannot open source");
                    BufferedReader reader = new BufferedReader(
                        new InputStreamReader(
                            new BufferedInputStream(in, 65536),
                            detectedCharset));

                    String line;
                    boolean firstLine = true;
                    while ((line = reader.readLine()) != null) {
                        if (cancelRequested) throw new IOException("Cancelled");
                        linesProcessed++;
                        bytesRead += line.length() + 1;

                        // Count matches in this line
                        Matcher counter = pattern.matcher(line);
                        while (counter.find()) totalReplacements++;

                        // Apply replacement
                        String replaced =
                            pattern.matcher(line).replaceAll(safeReplacement);

                        if (!firstLine) writer.newLine();
                        writer.write(replaced);
                        firstLine = false;

                        if (linesProcessed % 500 == 0) {
                            int pct = (int) (bytesRead * 500 / totalBytes);
                            int tr = totalReplacements;
                            int lp = linesProcessed;
                            updateProgress(Math.min(pct, 499),
                                "Processing... " + tr + " replacements, line "
                                    + lp + " (" + formatSize(bytesRead)
                                    + "/" + formatSize(totalBytes) + ")");
                        }
                    }
                }

                if (cancelRequested) throw new IOException("Cancelled");

                // Phase 2: Write temp file back to the original URI
                updateProgress(500, "Phase 2/2: Writing back...");
                long tempSize = tempFile.length();
                long written = 0;

                try (InputStream tempIn = new BufferedInputStream(
                         new FileInputStream(tempFile), 65536);
                     OutputStream out = openCurrentOutputStream()) {

                    if (out == null) throw new IOException("Cannot write output");
                    BufferedOutputStream bos =
                        new BufferedOutputStream(out, 65536);

                    byte[] buf = new byte[65536];
                    int n;
                    while ((n = tempIn.read(buf)) >= 0) {
                        if (cancelRequested) throw new IOException("Cancelled");
                        bos.write(buf, 0, n);
                        written += n;
                        if (written % (256 * 1024) < 65536) {
                            int pct = 500 + (int) (written * 500
                                / (tempSize > 0 ? tempSize : 1));
                            updateProgress(Math.min(pct, 999),
                                "Writing... " + formatSize(written)
                                    + " / " + formatSize(tempSize));
                        }
                    }
                    bos.flush();
                }

                final int tr = totalReplacements;
                final int lp = linesProcessed;
                mainHandler.post(() -> {
                    setWorkingState(false);
                    toast("Replace All done: " + tr + " replacements");
                    setStatus(tr + " replacements in " + lp + " lines");
                    // Reload to show updated preview
                    reloadCurrentSource();
                });

            } catch (IOException e) {
                final String msg = safeMsg(e);
                mainHandler.post(() -> {
                    setWorkingState(false);
                    if (!"Cancelled".equals(msg)) {
                        toast("Replace failed: " + msg);
                        setStatus("Replace failed: " + msg);
                    } else {
                        setStatus("Replace cancelled");
                    }
                });
            } finally {
                if (tempFile.exists()) {
                    //noinspection ResultOfMethodCallIgnored
                    tempFile.delete();
                }
            }
        }, "StreamReplacer");
        workerThread.start();
    }

    // ======================= PATTERN / MATCH HELPERS =======================

    private Pattern compilePattern() {
        String raw = etSearch.getText().toString();
        if (raw == null || raw.isEmpty()) {
            toast("Search is empty");
            return null;
        }

        boolean isRegex = cbRegex.isChecked();
        boolean wholeWord = cbWholeWord.isChecked();

        String patternStr = isRegex ? raw : Pattern.quote(raw);
        if (wholeWord) {
            patternStr = "(?<!\\w)(?:" + patternStr + ")(?!\\w)";
        }

        try {
            return Pattern.compile(patternStr, Pattern.MULTILINE);
        } catch (PatternSyntaxException e) {
            toast("Bad regex: " + safeMsg(e));
            return null;
        }
    }

    private String matchCountText(Pattern pattern, String content,
                                  int currentStart) {
        int count = 0;
        int currentIndex = -1;
        Matcher matcher = pattern.matcher(content);
        while (matcher.find()) {
            if (currentStart >= 0 && matcher.start() == currentStart) {
                currentIndex = count + 1;
            }
            count++;
            if (count > 200000) break;
        }

        if (count == 0) return "0 matches";
        if (currentIndex > 0) return "match " + currentIndex + " / " + count;
        return count + " matches";
    }

    // ======================= ASYNC / CANCEL =======================

    private boolean isWorking() {
        return workerThread != null && workerThread.isAlive();
    }

    private void cancelWork() {
        cancelRequested = true;
        setStatus("Cancelling...");
    }

    // ======================= IO / DECODE HELPERS =======================

    private static class DecodedText {
        final String text;
        final Charset charset;
        DecodedText(String text, Charset charset) {
            this.text = text;
            this.charset = charset;
        }
    }

    private DecodedText decodeText(byte[] data) {
        if (data == null) return new DecodedText("", StandardCharsets.UTF_8);

        // BOM detection: UTF-8 / UTF-16 LE/BE
        if (data.length >= 3
                && (data[0] & 0xFF) == 0xEF
                && (data[1] & 0xFF) == 0xBB
                && (data[2] & 0xFF) == 0xBF) {
            return new DecodedText(
                new String(data, 3, data.length - 3, StandardCharsets.UTF_8),
                StandardCharsets.UTF_8);
        }
        if (data.length >= 2
                && (data[0] & 0xFF) == 0xFF && (data[1] & 0xFF) == 0xFE) {
            Charset cs = Charset.forName("UTF-16LE");
            return new DecodedText(
                new String(data, 2, data.length - 2, cs), cs);
        }
        if (data.length >= 2
                && (data[0] & 0xFF) == 0xFE && (data[1] & 0xFF) == 0xFF) {
            Charset cs = Charset.forName("UTF-16BE");
            return new DecodedText(
                new String(data, 2, data.length - 2, cs), cs);
        }

        return new DecodedText(
            new String(data, StandardCharsets.UTF_8), StandardCharsets.UTF_8);
    }

    private long queryFileSize(Uri uri) {
        if (uri == null) return -1;
        Cursor cursor = null;
        try {
            cursor = getContentResolver().query(uri, null, null, null, null);
            if (cursor != null && cursor.moveToFirst()) {
                int idx = cursor.getColumnIndex(OpenableColumns.SIZE);
                if (idx >= 0 && !cursor.isNull(idx)) return cursor.getLong(idx);
            }
        } catch (Throwable ignored) {
        } finally {
            if (cursor != null) {
                try { cursor.close(); } catch (Throwable ignored) {}
            }
        }
        return -1;
    }

    private InputStream openCurrentInputStream() throws IOException {
        return openInputStream(currentUri);
    }

    private InputStream openInputStream(Uri uri) throws IOException {
        if (currentFile != null) {
            return new FileInputStream(currentFile);
        }
        if (uri == null) {
            throw new IOException("No file selected");
        }
        return getContentResolver().openInputStream(uri);
    }

    private OutputStream openCurrentOutputStream() throws IOException {
        if (currentFile != null) {
            return new FileOutputStream(currentFile, false);
        }
        if (currentUri == null) {
            throw new IOException("No file selected");
        }
        return openOutputStream(currentUri);
    }

    private OutputStream openOutputStream(Uri uri) throws IOException {
        if (uri == null) {
            throw new IOException("No output target selected");
        }
        return getContentResolver().openOutputStream(uri, "wt");
    }

    private void reloadCurrentSource() {
        if (currentFile != null) {
            openFile(currentFile);
        } else if (currentUri != null) {
            openUri(currentUri, false);
        }
    }

    private String queryDisplayName(Uri uri) {
        if (uri == null) return null;
        Cursor cursor = null;
        try {
            cursor = getContentResolver().query(uri, null, null, null, null);
            if (cursor != null && cursor.moveToFirst()) {
                int idx = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME);
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

    // ======================= UI HELPERS =======================

    private Button makeButton(String text, int bgColor) {
        Button btn = new Button(this);
        btn.setText(text);
        btn.setAllCaps(false);
        btn.setTextSize(12);
        btn.setTextColor(getColor(R.color.hsp_text));
        btn.setPadding(dp(10), dp(8), dp(10), dp(8));
        btn.setBackgroundResource(R.drawable.btn_surface);
        try {
            btn.setBackgroundTintList(
                android.content.res.ColorStateList.valueOf(bgColor));
        } catch (Throwable ignored) {}
        return btn;
    }

    private void addSpacer(LinearLayout row, int dpVal) {
        View spacer = new View(this);
        spacer.setLayoutParams(new LinearLayout.LayoutParams(dp(dpVal), 1));
        row.addView(spacer);
    }

    private int dp(int v) {
        return Math.round(v * getResources().getDisplayMetrics().density);
    }

    private void toast(String msg) {
        Toast.makeText(this, msg, Toast.LENGTH_SHORT).show();
    }

    private void setStatus(String msg) {
        if (msg == null) msg = "";
        tvStatus.setText("Status: " + msg);
    }

    private static String formatSize(long bytes) {
        if (bytes < 0) return "unknown";
        if (bytes < 1024) return bytes + " B";
        if (bytes < 1024 * 1024)
            return String.format("%.1f KB", bytes / 1024.0);
        if (bytes < 1024L * 1024 * 1024)
            return String.format("%.1f MB", bytes / (1024.0 * 1024));
        return String.format("%.2f GB", bytes / (1024.0 * 1024 * 1024));
    }

    private static String safeMsg(Throwable t) {
        if (t == null) return "";
        String m = t.getMessage();
        if (m == null || m.trim().isEmpty()) return t.getClass().getSimpleName();
        return m;
    }
}
