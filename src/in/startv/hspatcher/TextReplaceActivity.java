package in.startv.hspatcher;

import android.app.Activity;
import android.content.Intent;
import android.database.Cursor;
import android.graphics.Typeface;
import android.net.Uri;
import android.os.Bundle;
import android.provider.OpenableColumns;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.Toast;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.regex.PatternSyntaxException;

public class TextReplaceActivity extends Activity {

    private static final int PICK_FILE = 4101;
    private static final int CREATE_FILE = 4102;

    private Uri currentUri;
    private String currentDisplayName;

    private TextView tvFile;
    private TextView tvStatus;
    private EditText etSearch;
    private EditText etReplace;
    private CheckBox cbWholeWord;
    private CheckBox cbRegex;
    private EditText etContent;

    private int lastMatchStart = -1;
    private int lastMatchEnd = -1;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        buildUi();

        Uri intentData = getIntent() != null ? getIntent().getData() : null;
        if (intentData != null) {
            openUri(intentData, true);
        }
    }

    private void buildUi() {
        ScrollView root = new ScrollView(this);
        root.setFillViewport(true);
        root.setBackgroundResource(R.drawable.bg_glass_root);

        LinearLayout main = new LinearLayout(this);
        main.setOrientation(LinearLayout.VERTICAL);
        main.setPadding(dp(16), dp(16), dp(16), dp(16));

        TextView header = new TextView(this);
        header.setText("🔎 Find / Replace");
        header.setTextSize(26);
        header.setTypeface(null, Typeface.BOLD);
        header.setGravity(Gravity.CENTER);
        header.setTextColor(getColor(R.color.hsp_accent_blue));
        header.setPadding(0, dp(6), 0, dp(2));
        main.addView(header);

        TextView sub = new TextView(this);
        sub.setText("Open a text file → search (whole word / regex) → replace → save");
        sub.setTextSize(12);
        sub.setGravity(Gravity.CENTER);
        sub.setTextColor(getColor(R.color.hsp_text_muted));
        sub.setPadding(0, 0, 0, dp(12));
        main.addView(sub);

        LinearLayout fileRow = new LinearLayout(this);
        fileRow.setOrientation(LinearLayout.HORIZONTAL);
        fileRow.setGravity(Gravity.CENTER_VERTICAL);

        Button btnOpen = makeButton("📂 OPEN", getColor(R.color.hsp_surface));
        btnOpen.setLayoutParams(new LinearLayout.LayoutParams(0, dp(44), 1));
        btnOpen.setOnClickListener(v -> pickFile());
        fileRow.addView(btnOpen);

        addSpacer(fileRow, 6);

        Button btnSave = makeButton("💾 SAVE", getColor(R.color.hsp_legacy_success));
        btnSave.setLayoutParams(new LinearLayout.LayoutParams(0, dp(44), 1));
        btnSave.setOnClickListener(v -> saveToCurrent());
        fileRow.addView(btnSave);

        addSpacer(fileRow, 6);

        Button btnSaveAs = makeButton("SAVE AS", getColor(R.color.hsp_accent_indigo));
        btnSaveAs.setLayoutParams(new LinearLayout.LayoutParams(0, dp(44), 1));
        btnSaveAs.setOnClickListener(v -> saveAs());
        fileRow.addView(btnSaveAs);

        main.addView(fileRow);

        tvFile = new TextView(this);
        tvFile.setText("No file loaded");
        tvFile.setTextSize(12);
        tvFile.setTextColor(getColor(R.color.hsp_text_muted));
        tvFile.setPadding(dp(6), dp(8), dp(6), dp(8));
        tvFile.setSingleLine(true);
        main.addView(tvFile);

        // Search input row
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
        main.addView(etSearch, new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT));

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

        // Replace input row
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
        main.addView(etReplace, new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT));

        LinearLayout actionRow = new LinearLayout(this);
        actionRow.setOrientation(LinearLayout.HORIZONTAL);
        actionRow.setPadding(0, dp(10), 0, dp(6));

        Button btnFindNext = makeButton("FIND NEXT", getColor(R.color.hsp_accent_blue));
        btnFindNext.setLayoutParams(new LinearLayout.LayoutParams(0, dp(42), 1));
        btnFindNext.setOnClickListener(v -> findNext(true));
        actionRow.addView(btnFindNext);

        addSpacer(actionRow, 6);

        Button btnReplaceOne = makeButton("REPLACE", getColor(R.color.hsp_accent_amber));
        btnReplaceOne.setLayoutParams(new LinearLayout.LayoutParams(0, dp(42), 1));
        btnReplaceOne.setOnClickListener(v -> replaceCurrent());
        actionRow.addView(btnReplaceOne);

        addSpacer(actionRow, 6);

        Button btnReplaceAll = makeButton("REPLACE ALL", getColor(R.color.hsp_legacy_danger));
        btnReplaceAll.setLayoutParams(new LinearLayout.LayoutParams(0, dp(42), 1));
        btnReplaceAll.setOnClickListener(v -> replaceAll());
        actionRow.addView(btnReplaceAll);

        main.addView(actionRow);

        tvStatus = new TextView(this);
        tvStatus.setText("Status: idle");
        tvStatus.setTextSize(12);
        tvStatus.setTextColor(getColor(R.color.hsp_text_muted));
        tvStatus.setPadding(dp(6), dp(4), dp(6), dp(10));
        main.addView(tvStatus);

        TextView lblContent = new TextView(this);
        lblContent.setText("File content");
        lblContent.setTextSize(13);
        lblContent.setTextColor(getColor(R.color.hsp_text));
        lblContent.setPadding(0, dp(6), 0, dp(4));
        main.addView(lblContent);

        etContent = new EditText(this);
        etContent.setTypeface(Typeface.MONOSPACE);
        etContent.setTextColor(getColor(R.color.hsp_text));
        etContent.setHintTextColor(getColor(R.color.hsp_text_muted));
        etContent.setBackgroundResource(R.drawable.bg_log);
        etContent.setPadding(dp(12), dp(12), dp(12), dp(12));
        etContent.setMinLines(12);
        etContent.setGravity(Gravity.TOP | Gravity.START);
        etContent.setHorizontallyScrolling(true);
        etContent.setScrollBarStyle(View.SCROLLBARS_INSIDE_OVERLAY);
        main.addView(etContent, new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, dp(420)));

        root.addView(main);
        setContentView(root);
    }

    // ======================= FILE OPEN / SAVE =======================

    private void pickFile() {
        Intent intent = new Intent(Intent.ACTION_OPEN_DOCUMENT);
        intent.addCategory(Intent.CATEGORY_OPENABLE);
        intent.setType("*/*");
        intent.putExtra(Intent.EXTRA_MIME_TYPES, new String[]{"text/*", "application/json", "application/xml"});
        startActivityForResult(intent, PICK_FILE);
    }

    private void openUri(Uri uri, boolean tryPersist) {
        if (uri == null) return;
        try {
            if (tryPersist) {
                int takeFlags = (getIntent() != null ? getIntent().getFlags() : 0)
                    & (Intent.FLAG_GRANT_READ_URI_PERMISSION | Intent.FLAG_GRANT_WRITE_URI_PERMISSION);
                if (takeFlags != 0) {
                    try {
                        getContentResolver().takePersistableUriPermission(uri, takeFlags);
                    } catch (Throwable ignored) {
                        // Some providers don't offer persistable permission.
                    }
                }
            }

            currentUri = uri;
            currentDisplayName = queryDisplayName(uri);
            tvFile.setText(currentDisplayName != null ? ("Loaded: " + currentDisplayName) : ("Loaded: " + uri));

            byte[] data = readAllBytes(uri);
            DecodedText decoded = decodeText(data);
            etContent.setText(decoded.text);
            lastMatchStart = -1;
            lastMatchEnd = -1;

            setStatus("Loaded " + (decoded.charset != null ? decoded.charset.displayName() : "text") + " (" + data.length + " bytes)");
        } catch (Exception e) {
            toast("Open failed: " + safeMsg(e));
            setStatus("Open failed");
        }
    }

    private void saveToCurrent() {
        if (currentUri == null) {
            toast("No file loaded. Use SAVE AS.");
            return;
        }
        try {
            writeTextToUri(currentUri, etContent.getText().toString());
            toast("Saved");
            setStatus("Saved to current file");
        } catch (Exception e) {
            toast("Save failed: " + safeMsg(e));
            setStatus("Save failed");
        }
    }

    private void saveAs() {
        String defaultName = (currentDisplayName != null && !currentDisplayName.trim().isEmpty())
            ? currentDisplayName
            : "text.txt";

        Intent intent = new Intent(Intent.ACTION_CREATE_DOCUMENT);
        intent.addCategory(Intent.CATEGORY_OPENABLE);
        intent.setType("text/plain");
        intent.putExtra(Intent.EXTRA_TITLE, defaultName);
        startActivityForResult(intent, CREATE_FILE);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (resultCode != RESULT_OK || data == null) return;

        if (requestCode == PICK_FILE) {
            Uri uri = data.getData();
            if (uri != null) {
                // Persist permission offered by SAF.
                int flags = data.getFlags() & (Intent.FLAG_GRANT_READ_URI_PERMISSION | Intent.FLAG_GRANT_WRITE_URI_PERMISSION);
                try {
                    getContentResolver().takePersistableUriPermission(uri, flags);
                } catch (Throwable ignored) {}
                openUri(uri, false);
            }
        } else if (requestCode == CREATE_FILE) {
            Uri uri = data.getData();
            if (uri != null) {
                try {
                    writeTextToUri(uri, etContent.getText().toString());
                    toast("Saved");
                    setStatus("Saved (new file)");
                } catch (Exception e) {
                    toast("Save As failed: " + safeMsg(e));
                    setStatus("Save As failed");
                }
            }
        }
    }

    // ======================= SEARCH / REPLACE =======================

    private void findNext(boolean wrapAround) {
        String content = etContent.getText().toString();
        Pattern pattern = compilePattern();
        if (pattern == null) return;

        int startFrom = 0;
        if (lastMatchEnd >= 0 && lastMatchEnd <= content.length()) {
            startFrom = lastMatchEnd;
        }

        Matcher matcher = pattern.matcher(content);
        boolean found = matcher.find(startFrom);
        if (!found && wrapAround && startFrom > 0) {
            matcher = pattern.matcher(content);
            found = matcher.find(0);
            if (found) {
                toast("Wrapped to start");
            }
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

    private void replaceCurrent() {
        String content = etContent.getText().toString();
        Pattern pattern = compilePattern();
        if (pattern == null) return;

        if (lastMatchStart < 0 || lastMatchEnd < 0 || lastMatchEnd > content.length()) {
            toast("Use FIND NEXT first");
            return;
        }

        // Verify the current selection still matches.
        Matcher verifyMatcher = pattern.matcher(content);
        boolean ok = false;
        while (verifyMatcher.find()) {
            if (verifyMatcher.start() == lastMatchStart && verifyMatcher.end() == lastMatchEnd) {
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
                if (replaceMatcher.start() == lastMatchStart && replaceMatcher.end() == lastMatchEnd) {
                    replaceMatcher.appendReplacement(sb, replacement);
                    newCursor = sb.length();
                } else {
                    replaceMatcher.appendReplacement(sb, Matcher.quoteReplacement(replaceMatcher.group(0)));
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
        try { etContent.setSelection(Math.min(newCursor, replaced.length())); } catch (Throwable ignored) {}

        // Reset match pointer and find next after the replacement.
        lastMatchStart = -1;
        lastMatchEnd = newCursor;
        findNext(true);
    }

    private void replaceAll() {
        String content = etContent.getText().toString();
        Pattern pattern = compilePattern();
        if (pattern == null) return;

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

    private Pattern compilePattern() {
        String raw = etSearch.getText().toString();
        if (raw == null || raw.isEmpty()) {
            toast("Search is empty");
            return null;
        }

        boolean isRegex = cbRegex.isChecked();
        boolean wholeWord = cbWholeWord.isChecked();

        String pattern = isRegex ? raw : Pattern.quote(raw);
        if (wholeWord) {
            pattern = "(?<!\\w)(?:" + pattern + ")(?!\\w)";
        }

        try {
            return Pattern.compile(pattern, Pattern.MULTILINE);
        } catch (PatternSyntaxException e) {
            toast("Bad regex: " + safeMsg(e));
            return null;
        }
    }

    private String matchCountText(Pattern pattern, String content, int currentStart) {
        int count = 0;
        int currentIndex = -1;
        Matcher matcher = pattern.matcher(content);
        while (matcher.find()) {
            if (currentStart >= 0 && matcher.start() == currentStart) {
                currentIndex = count + 1;
            }
            count++;
            // Safety guard for extremely pathological patterns.
            if (count > 200000) break;
        }

        if (count == 0) return "0 matches";
        if (currentIndex > 0) return "match " + currentIndex + " / " + count;
        return count + " matches";
    }

    // ======================= IO HELPERS =======================

    private static class DecodedText {
        final String text;
        final Charset charset;

        DecodedText(String text, Charset charset) {
            this.text = text;
            this.charset = charset;
        }
    }

    private byte[] readAllBytes(Uri uri) throws IOException {
        try (InputStream in = getContentResolver().openInputStream(uri)) {
            if (in == null) throw new IOException("openInputStream returned null");
            BufferedInputStream bin = new BufferedInputStream(in);
            ByteArrayOutputStream out = new ByteArrayOutputStream();
            byte[] buf = new byte[8192];
            int n;
            while ((n = bin.read(buf)) >= 0) {
                out.write(buf, 0, n);
                if (out.size() > 16 * 1024 * 1024) {
                    // Avoid trying to load extremely large files into an EditText.
                    throw new IOException("File too large (>16MB) for in-app editing");
                }
            }
            return out.toByteArray();
        }
    }

    private DecodedText decodeText(byte[] data) {
        if (data == null) return new DecodedText("", StandardCharsets.UTF_8);

        // BOM detection: UTF-8 / UTF-16 LE/BE
        if (data.length >= 3
            && (data[0] & 0xFF) == 0xEF
            && (data[1] & 0xFF) == 0xBB
            && (data[2] & 0xFF) == 0xBF) {
            return new DecodedText(new String(data, 3, data.length - 3, StandardCharsets.UTF_8), StandardCharsets.UTF_8);
        }
        if (data.length >= 2 && (data[0] & 0xFF) == 0xFF && (data[1] & 0xFF) == 0xFE) {
            Charset cs = Charset.forName("UTF-16LE");
            return new DecodedText(new String(data, 2, data.length - 2, cs), cs);
        }
        if (data.length >= 2 && (data[0] & 0xFF) == 0xFE && (data[1] & 0xFF) == 0xFF) {
            Charset cs = Charset.forName("UTF-16BE");
            return new DecodedText(new String(data, 2, data.length - 2, cs), cs);
        }

        // Default to UTF-8.
        return new DecodedText(new String(data, StandardCharsets.UTF_8), StandardCharsets.UTF_8);
    }

    private void writeTextToUri(Uri uri, String text) throws IOException {
        try (OutputStream out = getContentResolver().openOutputStream(uri, "wt")) {
            if (out == null) throw new IOException("openOutputStream returned null");
            BufferedOutputStream bout = new BufferedOutputStream(out);
            byte[] bytes = (text != null ? text : "").getBytes(StandardCharsets.UTF_8);
            bout.write(bytes);
            bout.flush();
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
            btn.setBackgroundTintList(android.content.res.ColorStateList.valueOf(bgColor));
        } catch (Throwable ignored) {}
        return btn;
    }

    private void addSpacer(LinearLayout row, int dp) {
        View spacer = new View(this);
        spacer.setLayoutParams(new LinearLayout.LayoutParams(dp(dp), 1));
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

    private static String safeMsg(Throwable t) {
        if (t == null) return "";
        String m = t.getMessage();
        if (m == null || m.trim().isEmpty()) return t.getClass().getSimpleName();
        return m;
    }

}
