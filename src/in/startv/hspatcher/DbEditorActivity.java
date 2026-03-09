package in.startv.hspatcher;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.ContentValues;
import android.content.Intent;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.os.Looper;
import android.text.InputType;
import android.util.Log;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.*;
import android.content.res.ColorStateList;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.GradientDrawable;
import android.graphics.drawable.LayerDrawable;
import android.graphics.drawable.RippleDrawable;
import android.animation.AnimatorInflater;
import java.io.*;
import java.text.SimpleDateFormat;
import java.util.*;

/**
 * Built-in SQLite Database Editor for HSPatcher.
 *
 * Supports:
 * - Open any .db / .sqlite file from device storage
 * - Browse tables, view schema (PRAGMA table_info)
 * - View rows with horizontal scroll for wide tables
 * - Edit cell values inline (tap to edit)
 * - Delete rows, insert rows
 * - Execute raw SQL (SELECT / UPDATE / DELETE / CREATE / ALTER)
 * - Export query results or full tables
 * - Handles large databases via cursor windowing (Android manages ~2MB windows)
 *
 * Uses Android's built-in android.database.sqlite.SQLiteDatabase — zero external deps.
 * NO_LOCALIZED_COLLATORS flag prevents crashes from missing collation sequences.
 *
 * UI follows HSPatcher dark theme: #121212 background, #00E676 accent.
 * Reference: Android SQLiteDatabase docs (developer.android.com)
 */
public class DbEditorActivity extends Activity {

    private static final String TAG = "HSPatcher";
    private static final int PICK_DB = 3001;
    private static final int MAX_ROWS_PER_PAGE = 100;

    // Colors - all migrated to R.color tokens
    // (constants removed in liquid glass migration)

    private SQLiteDatabase db;
    private File currentDbFile;
    private String currentTable;
    private int currentPage = 0;
    private int totalRows = 0;

    // UI references
    private TextView tvDbPath, tvLog;
    private ScrollView logScroll;
    private Spinner spinnerTables;
    private LinearLayout tableContainer;
    private HorizontalScrollView tableHScroll;
    private EditText etSql;
    private Button btnOpenDb, btnExecSql, btnPrevPage, btnNextPage;
    private TextView tvPageInfo, tvRowCount;
    private LinearLayout toolsRow;
    private Handler mainHandler;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mainHandler = new Handler(Looper.getMainLooper());
        buildUI();

        // Accept DB path from intent
        String dbPath = getIntent().getStringExtra("db_path");
        if (dbPath != null && !dbPath.isEmpty()) {
            File f = new File(dbPath);
            if (f.exists()) {
                openDatabase(f);
            }
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        closeDb();
    }

    private void closeDb() {
        if (db != null && db.isOpen()) {
            try { db.close(); } catch (Exception ignored) {}
            db = null;
        }
    }

    // ======================== UI CONSTRUCTION ========================

    private void buildUI() {
        ScrollView root = new ScrollView(this);
        root.setBackgroundResource(R.drawable.bg_glass_root);
        root.setFillViewport(true);

        LinearLayout main = new LinearLayout(this);
        main.setOrientation(LinearLayout.VERTICAL);
        main.setPadding(dp(16), dp(16), dp(16), dp(16));

        // Header
        TextView header = new TextView(this);
        header.setText("🗄️ DB Editor");
        header.setTextSize(28);
        header.setTextColor(getColor(R.color.hsp_accent_green));
        header.setTypeface(null, android.graphics.Typeface.BOLD);
        header.setGravity(Gravity.CENTER);
        header.setPadding(0, dp(8), 0, dp(4));
        main.addView(header);

        TextView sub = new TextView(this);
        sub.setText("SQLite Database Viewer & Editor");
        sub.setTextSize(13);
        sub.setTextColor(getColor(R.color.hsp_text_muted));
        sub.setGravity(Gravity.CENTER);
        sub.setPadding(0, 0, 0, dp(12));
        main.addView(sub);

        // DB file selector
        LinearLayout fileRow = new LinearLayout(this);
        fileRow.setOrientation(LinearLayout.HORIZONTAL);
        fileRow.setGravity(Gravity.CENTER_VERTICAL);

        btnOpenDb = makeButton("📂 OPEN DATABASE", getColor(R.color.hsp_accent_blue));
        btnOpenDb.setLayoutParams(new LinearLayout.LayoutParams(0, dp(48), 1));
        btnOpenDb.setOnClickListener(v -> pickDatabase());
        fileRow.addView(btnOpenDb);

        main.addView(fileRow);

        // DB path display
        tvDbPath = new TextView(this);
        tvDbPath.setText("No database loaded");
        tvDbPath.setTextSize(12);
        tvDbPath.setTextColor(getColor(R.color.hsp_text_muted));
        tvDbPath.setPadding(dp(4), dp(6), dp(4), dp(6));
        tvDbPath.setSingleLine(true);
        main.addView(tvDbPath);

        // Table selector
        LinearLayout tableSelRow = new LinearLayout(this);
        tableSelRow.setOrientation(LinearLayout.HORIZONTAL);
        tableSelRow.setGravity(Gravity.CENTER_VERTICAL);
        tableSelRow.setPadding(0, dp(8), 0, dp(4));

        TextView lblTable = new TextView(this);
        lblTable.setText("Table: ");
        lblTable.setTextSize(14);
        lblTable.setTextColor(getColor(R.color.hsp_text));
        tableSelRow.addView(lblTable);

        spinnerTables = new Spinner(this);
        spinnerTables.setLayoutParams(new LinearLayout.LayoutParams(0, dp(40), 1));
        spinnerTables.setBackgroundResource(R.drawable.bg_glass_input);
        spinnerTables.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int pos, long id) {
                String table = (String) parent.getItemAtPosition(pos);
                if (table != null && !table.equals(currentTable)) {
                    currentTable = table;
                    currentPage = 0;
                    loadTableData();
                }
            }
            @Override
            public void onNothingSelected(AdapterView<?> parent) {}
        });
        tableSelRow.addView(spinnerTables);

        main.addView(tableSelRow);

        // Row count + pagination
        LinearLayout pageRow = new LinearLayout(this);
        pageRow.setOrientation(LinearLayout.HORIZONTAL);
        pageRow.setGravity(Gravity.CENTER_VERTICAL);
        pageRow.setPadding(0, dp(2), 0, dp(6));

        tvRowCount = new TextView(this);
        tvRowCount.setText("");
        tvRowCount.setTextSize(12);
        tvRowCount.setTextColor(getColor(R.color.hsp_text_muted));
        tvRowCount.setLayoutParams(new LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1));
        pageRow.addView(tvRowCount);

        btnPrevPage = makeButton("◀ Prev", getColor(R.color.hsp_surface));
        btnPrevPage.setTextSize(11);
        btnPrevPage.setPadding(dp(12), dp(4), dp(12), dp(4));
        btnPrevPage.setOnClickListener(v -> { if (currentPage > 0) { currentPage--; loadTableData(); } });
        pageRow.addView(btnPrevPage);

        tvPageInfo = new TextView(this);
        tvPageInfo.setText("");
        tvPageInfo.setTextSize(11);
        tvPageInfo.setTextColor(getColor(R.color.hsp_text_muted));
        tvPageInfo.setPadding(dp(8), 0, dp(8), 0);
        tvPageInfo.setGravity(Gravity.CENTER);
        pageRow.addView(tvPageInfo);

        btnNextPage = makeButton("Next ▶", getColor(R.color.hsp_surface));
        btnNextPage.setTextSize(11);
        btnNextPage.setPadding(dp(12), dp(4), dp(12), dp(4));
        btnNextPage.setOnClickListener(v -> {
            int maxPage = Math.max(0, (totalRows - 1) / MAX_ROWS_PER_PAGE);
            if (currentPage < maxPage) { currentPage++; loadTableData(); }
        });
        pageRow.addView(btnNextPage);

        main.addView(pageRow);

        // Table tools row
        toolsRow = new LinearLayout(this);
        toolsRow.setOrientation(LinearLayout.HORIZONTAL);
        toolsRow.setPadding(0, dp(2), 0, dp(6));

        Button btnSchema = makeButton("📋 Schema", getColor(R.color.hsp_surface));
        btnSchema.setTextSize(11);
        btnSchema.setLayoutParams(new LinearLayout.LayoutParams(0, dp(36), 1));
        btnSchema.setOnClickListener(v -> showSchema());
        toolsRow.addView(btnSchema);

        addSpacer(toolsRow, 4);

        Button btnInsert = makeButton("➕ Insert", getColor(R.color.hsp_legacy_success));
        btnInsert.setTextSize(11);
        btnInsert.setLayoutParams(new LinearLayout.LayoutParams(0, dp(36), 1));
        btnInsert.setOnClickListener(v -> insertRow());
        toolsRow.addView(btnInsert);

        addSpacer(toolsRow, 4);

        Button btnExport = makeButton("💾 Export", getColor(R.color.hsp_accent_indigo));
        btnExport.setTextSize(11);
        btnExport.setLayoutParams(new LinearLayout.LayoutParams(0, dp(36), 1));
        btnExport.setOnClickListener(v -> exportTable());
        toolsRow.addView(btnExport);

        main.addView(toolsRow);

        // Table data area (horizontal scrollable)
        tableHScroll = new HorizontalScrollView(this);
        tableHScroll.setBackgroundResource(R.drawable.bg_card);
        LinearLayout.LayoutParams tableLP = new LinearLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT, dp(300));
        tableHScroll.setLayoutParams(tableLP);

        ScrollView tableVScroll = new ScrollView(this);
        tableContainer = new LinearLayout(this);
        tableContainer.setOrientation(LinearLayout.VERTICAL);
        tableContainer.setPadding(dp(2), dp(2), dp(2), dp(2));
        tableVScroll.addView(tableContainer);
        tableHScroll.addView(tableVScroll);

        main.addView(tableHScroll);

        // SQL input area
        TextView sqlLabel = new TextView(this);
        sqlLabel.setText("Raw SQL");
        sqlLabel.setTextSize(12);
        sqlLabel.setTextColor(getColor(R.color.hsp_accent_green));
        sqlLabel.setTypeface(null, android.graphics.Typeface.BOLD);
        sqlLabel.setPadding(0, dp(12), 0, dp(4));
        main.addView(sqlLabel);

        etSql = new EditText(this);
        etSql.setHint("SELECT * FROM table_name WHERE ...");
        etSql.setHintTextColor(getColor(R.color.hsp_text_faint));
        etSql.setTextColor(getColor(R.color.hsp_text));
        etSql.setTextSize(13);
        etSql.setBackgroundResource(R.drawable.bg_glass_input);
        etSql.setPadding(dp(12), dp(10), dp(12), dp(10));
        etSql.setMinLines(2);
        etSql.setMaxLines(5);
        etSql.setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_FLAG_MULTI_LINE);
        etSql.setTypeface(android.graphics.Typeface.MONOSPACE);
        main.addView(etSql);

        btnExecSql = makeButton("▶ EXECUTE SQL", getColor(R.color.hsp_accent_blue));
        LinearLayout.LayoutParams execLP = new LinearLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT, dp(44));
        execLP.topMargin = dp(6);
        btnExecSql.setLayoutParams(execLP);
        btnExecSql.setOnClickListener(v -> executeSql());
        main.addView(btnExecSql);

        // Log output
        logScroll = new ScrollView(this);
        logScroll.setBackgroundResource(R.drawable.bg_log);
        LinearLayout.LayoutParams logLP = new LinearLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT, dp(120));
        logLP.topMargin = dp(8);
        logScroll.setLayoutParams(logLP);
        logScroll.setPadding(dp(8), dp(8), dp(8), dp(8));

        tvLog = new TextView(this);
        tvLog.setText("Ready. Open a .db or .sqlite file to start.");
        tvLog.setTextSize(11);
        tvLog.setTextColor(getColor(R.color.hsp_text_mono));
        tvLog.setTypeface(android.graphics.Typeface.MONOSPACE);
        logScroll.addView(tvLog);

        main.addView(logScroll);

        root.addView(main);
        setContentView(root);
    }

    // ======================== FILE PICKER ========================

    private void pickDatabase() {
        Intent intent = new Intent(Intent.ACTION_OPEN_DOCUMENT);
        intent.addCategory(Intent.CATEGORY_OPENABLE);
        intent.setType("*/*");
        // Also accept .db and .sqlite MIME types
        String[] mimeTypes = {"application/octet-stream", "application/x-sqlite3",
                              "application/vnd.sqlite3", "*/*"};
        intent.putExtra(Intent.EXTRA_MIME_TYPES, mimeTypes);
        try {
            startActivityForResult(intent, PICK_DB);
        } catch (Exception e) {
            log("❌ No file picker available: " + e.getMessage());
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == PICK_DB && resultCode == RESULT_OK && data != null) {
            Uri uri = data.getData();
            if (uri == null) return;
            // Copy to local temp file (content URIs can't be opened directly by SQLiteDatabase)
            File tempDir = new File(getCacheDir(), "db_editor");
            if (!tempDir.exists()) tempDir.mkdirs();
            String name = getFileName(uri);
            if (name == null || name.isEmpty()) name = "database.db";
            File tempFile = new File(tempDir, name);
            try {
                InputStream is = getContentResolver().openInputStream(uri);
                if (is == null) { log("❌ Cannot read file"); return; }
                copyStream(is, new FileOutputStream(tempFile));
                is.close();
                log("📂 Copied to: " + tempFile.getAbsolutePath() + " (" + (tempFile.length() / 1024) + " KB)");
                openDatabase(tempFile);
            } catch (Exception e) {
                log("❌ Error reading file: " + e.getMessage());
            }
        }
    }

    // ======================== DATABASE OPERATIONS ========================

    private void openDatabase(File file) {
        closeDb();
        currentDbFile = file;
        currentTable = null;
        currentPage = 0;

        try {
            db = SQLiteDatabase.openDatabase(
                file.getAbsolutePath(), null,
                SQLiteDatabase.OPEN_READWRITE | SQLiteDatabase.NO_LOCALIZED_COLLATORS
            );
            tvDbPath.setText(file.getName() + " (" + (file.length() / 1024) + " KB)");
            tvDbPath.setTextColor(getColor(R.color.hsp_accent_green));
            log("✅ Opened: " + file.getName());
            log("   Path: " + file.getAbsolutePath());
            log("   Size: " + (file.length() / 1024) + " KB");

            // Check integrity
            if (db.isDatabaseIntegrityOk()) {
                log("   Integrity: OK ✅");
            } else {
                log("   ⚠️ Integrity check FAILED — database may be corrupt");
            }

            loadTables();
        } catch (Exception e) {
            log("❌ Failed to open database: " + e.getMessage());
            tvDbPath.setText("Error opening: " + file.getName());
            tvDbPath.setTextColor(getColor(R.color.hsp_accent_red));
        }
    }

    private void loadTables() {
        if (db == null || !db.isOpen()) return;

        List<String> tables = new ArrayList<>();
        Cursor c = null;
        try {
            c = db.rawQuery(
                "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' ORDER BY name",
                null
            );
            while (c.moveToNext()) {
                tables.add(c.getString(0));
            }
        } catch (Exception e) {
            log("❌ Error listing tables: " + e.getMessage());
        } finally {
            if (c != null) c.close();
        }

        log("   Tables: " + tables.size());
        for (String t : tables) {
            int count = getRowCount(t);
            log("     • " + t + " (" + count + " rows)");
        }

        ArrayAdapter<String> adapter = new ArrayAdapter<>(this,
            android.R.layout.simple_spinner_item, tables);
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        spinnerTables.setAdapter(adapter);

        if (!tables.isEmpty()) {
            currentTable = tables.get(0);
            loadTableData();
        }
    }

    private int getRowCount(String table) {
        Cursor c = null;
        try {
            c = db.rawQuery("SELECT COUNT(*) FROM \"" + escapeTable(table) + "\"", null);
            if (c.moveToFirst()) return c.getInt(0);
        } catch (Exception ignored) {
        } finally {
            if (c != null) c.close();
        }
        return 0;
    }

    private void loadTableData() {
        if (db == null || !db.isOpen() || currentTable == null) return;

        tableContainer.removeAllViews();
        totalRows = getRowCount(currentTable);
        int offset = currentPage * MAX_ROWS_PER_PAGE;
        int maxPage = Math.max(0, (totalRows - 1) / MAX_ROWS_PER_PAGE);

        tvRowCount.setText(totalRows + " rows in \"" + currentTable + "\"");
        tvPageInfo.setText("Page " + (currentPage + 1) + "/" + (maxPage + 1));
        btnPrevPage.setEnabled(currentPage > 0);
        btnNextPage.setEnabled(currentPage < maxPage);

        Cursor c = null;
        try {
            c = db.rawQuery(
                "SELECT * FROM \"" + escapeTable(currentTable) + "\" LIMIT " +
                MAX_ROWS_PER_PAGE + " OFFSET " + offset, null
            );
            renderCursor(c, true);
        } catch (Exception e) {
            log("❌ Error loading table: " + e.getMessage());
            TextView errTv = new TextView(this);
            errTv.setText("Error: " + e.getMessage());
            errTv.setTextColor(getColor(R.color.hsp_accent_red));
            errTv.setPadding(dp(8), dp(8), dp(8), dp(8));
            tableContainer.addView(errTv);
        } finally {
            if (c != null) c.close();
        }
    }

    private void renderCursor(Cursor c, boolean editable) {
        tableContainer.removeAllViews();

        if (c == null || c.getColumnCount() == 0) {
            TextView tv = new TextView(this);
            tv.setText("No data");
            tv.setTextColor(getColor(R.color.hsp_text_muted));
            tv.setPadding(dp(8), dp(8), dp(8), dp(8));
            tableContainer.addView(tv);
            return;
        }

        String[] cols = c.getColumnNames();
        int colCount = cols.length;

        // Calculate column widths (min 80dp, max 200dp)
        int[] colWidths = new int[colCount];
        for (int i = 0; i < colCount; i++) {
            colWidths[i] = Math.max(dp(80), Math.min(dp(200), dp(12) * cols[i].length() + dp(24)));
        }

        // Header row
        LinearLayout headerRow = new LinearLayout(this);
        headerRow.setOrientation(LinearLayout.HORIZONTAL);
        headerRow.setBackgroundColor(getColor(R.color.hsp_glass_fill_strong));
        headerRow.setPadding(0, dp(2), 0, dp(2));

        // Row number column
        TextView rnHeader = makeCell("#", dp(40));
        rnHeader.setTextColor(getColor(R.color.hsp_accent_green));
        rnHeader.setTypeface(null, android.graphics.Typeface.BOLD);
        headerRow.addView(rnHeader);

        for (int i = 0; i < colCount; i++) {
            TextView cell = makeCell(cols[i], colWidths[i]);
            cell.setTextColor(getColor(R.color.hsp_accent_green));
            cell.setTypeface(null, android.graphics.Typeface.BOLD);
            headerRow.addView(cell);
        }

        // Delete header
        if (editable) {
            TextView delHeader = makeCell("DEL", dp(50));
            delHeader.setTextColor(getColor(R.color.hsp_accent_red));
            delHeader.setTypeface(null, android.graphics.Typeface.BOLD);
            headerRow.addView(delHeader);
        }

        tableContainer.addView(headerRow);

        // Data rows
        int rowIdx = currentPage * MAX_ROWS_PER_PAGE;
        while (c.moveToNext()) {
            rowIdx++;
            final int displayRowNum = rowIdx;
            LinearLayout dataRow = new LinearLayout(this);
            dataRow.setOrientation(LinearLayout.HORIZONTAL);
            dataRow.setBackgroundColor(rowIdx % 2 == 0 ? getColor(R.color.hsp_glass_fill) : 0x00000000);
            dataRow.setPadding(0, dp(1), 0, dp(1));

            // Row number
            TextView rnCell = makeCell(String.valueOf(displayRowNum), dp(40));
            rnCell.setTextColor(getColor(R.color.hsp_text_muted));
            dataRow.addView(rnCell);

            // Collect row values for editing
            final String[] rowValues = new String[colCount];
            for (int i = 0; i < colCount; i++) {
                String val;
                try {
                    if (c.isNull(i)) {
                        val = "(NULL)";
                    } else {
                        int type = c.getType(i);
                        if (type == Cursor.FIELD_TYPE_BLOB) {
                            val = "(BLOB " + c.getBlob(i).length + " bytes)";
                        } else {
                            val = c.getString(i);
                        }
                    }
                } catch (Exception e) {
                    val = "(error)";
                }
                rowValues[i] = val;

                TextView cell = makeCell(val != null ? val : "(NULL)", colWidths[i]);
                if (val != null && val.startsWith("(")) {
                    cell.setTextColor(getColor(R.color.hsp_text_muted));
                }

                // Tap to edit
                if (editable) {
                    final int colIdx = i;
                    final String colName = cols[i];
                    cell.setOnClickListener(v -> editCell(colName, rowValues, cols));
                }

                dataRow.addView(cell);
            }

            // Delete button
            if (editable) {
                Button delBtn = new Button(this);
                delBtn.setText("🗑");
                delBtn.setTextSize(14);
                delBtn.setTextColor(getColor(R.color.hsp_accent_red));
                GradientDrawable delFill = new GradientDrawable();
                delFill.setShape(GradientDrawable.RECTANGLE);
                delFill.setCornerRadius(dp(12));
                delFill.setColor(0x33FF5252);

                GradientDrawable delStroke = new GradientDrawable();
                delStroke.setShape(GradientDrawable.RECTANGLE);
                delStroke.setCornerRadius(dp(12));
                delStroke.setColor(0x00000000);
                delStroke.setStroke(dp(1), getColor(R.color.hsp_glass_stroke));

                LayerDrawable delBase = new LayerDrawable(new Drawable[] { delFill, delStroke });
                RippleDrawable delRipple = new RippleDrawable(
                        ColorStateList.valueOf(getColor(R.color.hsp_ripple)),
                        delBase,
                        null
                );
                delBtn.setBackground(delRipple);
                delBtn.setPadding(dp(4), 0, dp(4), 0);
                LinearLayout.LayoutParams delLP = new LinearLayout.LayoutParams(dp(50), dp(32));
                delLP.gravity = Gravity.CENTER_VERTICAL;
                delBtn.setLayoutParams(delLP);
                try {
                    delBtn.setStateListAnimator(AnimatorInflater.loadStateListAnimator(this, R.xml.press_scale));
                } catch (Exception ignored) {
                }
                delBtn.setOnClickListener(v -> deleteRow(cols, rowValues));
                dataRow.addView(delBtn);
            }

            tableContainer.addView(dataRow);
        }

        if (rowIdx == currentPage * MAX_ROWS_PER_PAGE) {
            TextView empty = new TextView(this);
            empty.setText("(empty table)");
            empty.setTextColor(getColor(R.color.hsp_text_muted));
            empty.setPadding(dp(8), dp(16), dp(8), dp(16));
            empty.setGravity(Gravity.CENTER);
            tableContainer.addView(empty);
        }
    }

    // ======================== EDIT OPERATIONS ========================

    private void editCell(String colName, String[] rowValues, String[] allCols) {
        if (db == null || !db.isOpen() || currentTable == null) return;

        AlertDialog.Builder b = new AlertDialog.Builder(this, android.R.style.Theme_Material_Dialog);
        b.setTitle("Edit: " + colName);

        LinearLayout layout = new LinearLayout(this);
        layout.setOrientation(LinearLayout.VERTICAL);
        layout.setPadding(dp(24), dp(16), dp(24), dp(8));

        // Find current value
        int colIdx = -1;
        for (int i = 0; i < allCols.length; i++) {
            if (allCols[i].equals(colName)) { colIdx = i; break; }
        }
        String currentVal = (colIdx >= 0) ? rowValues[colIdx] : "";
        if ("(NULL)".equals(currentVal)) currentVal = "";

        TextView lbl = new TextView(this);
        lbl.setText("Column: " + colName);
        lbl.setTextColor(getColor(R.color.hsp_text_muted));
        lbl.setTextSize(12);
        layout.addView(lbl);

        EditText input = new EditText(this);
        input.setText(currentVal);
        input.setTextColor(getColor(R.color.hsp_text));
        input.setTextSize(14);
        input.setBackgroundResource(R.drawable.bg_glass_input);
        input.setPadding(dp(12), dp(10), dp(12), dp(10));
        input.setMinLines(1);
        input.setMaxLines(8);
        layout.addView(input);

        // Set NULL button
        CheckBox cbNull = new CheckBox(this);
        cbNull.setText("Set to NULL");
        cbNull.setTextColor(getColor(R.color.hsp_text_muted));
        cbNull.setOnCheckedChangeListener((btn, checked) -> input.setEnabled(!checked));
        layout.addView(cbNull);

        b.setView(layout);

        // Build WHERE clause using all columns (since we may not know PK)
        final String[] fRowValues = rowValues.clone();
        final int fColIdx = colIdx;

        b.setPositiveButton("Save", (dialog, which) -> {
            try {
                String whereClause = buildWhereClause(allCols, fRowValues);
                ContentValues cv = new ContentValues();
                if (cbNull.isChecked()) {
                    cv.putNull(colName);
                } else {
                    cv.put(colName, input.getText().toString());
                }
                int affected = db.update("\"" + escapeTable(currentTable) + "\"", cv, whereClause, null);
                log("✅ Updated " + affected + " row(s): " + colName + " = " +
                    (cbNull.isChecked() ? "NULL" : "'" + input.getText().toString() + "'"));
                loadTableData();
            } catch (Exception e) {
                log("❌ Update error: " + e.getMessage());
            }
        });
        b.setNegativeButton("Cancel", null);
        b.show();
    }

    private void deleteRow(String[] cols, String[] values) {
        if (db == null || !db.isOpen() || currentTable == null) return;

        new AlertDialog.Builder(this, android.R.style.Theme_Material_Dialog)
            .setTitle("Delete Row?")
            .setMessage("Are you sure you want to delete this row? This cannot be undone.")
            .setPositiveButton("Delete", (dialog, which) -> {
                try {
                    String whereClause = buildWhereClause(cols, values);
                    int affected = db.delete("\"" + escapeTable(currentTable) + "\"", whereClause, null);
                    log("🗑 Deleted " + affected + " row(s)");
                    loadTableData();
                } catch (Exception e) {
                    log("❌ Delete error: " + e.getMessage());
                }
            })
            .setNegativeButton("Cancel", null)
            .show();
    }

    private void insertRow() {
        if (db == null || !db.isOpen() || currentTable == null) return;

        // Get column info
        List<String[]> colInfo = getColumnInfo(currentTable);
        if (colInfo.isEmpty()) { log("❌ No columns found"); return; }

        AlertDialog.Builder b = new AlertDialog.Builder(this, android.R.style.Theme_Material_Dialog);
        b.setTitle("Insert Row into " + currentTable);

        ScrollView sv = new ScrollView(this);
        LinearLayout layout = new LinearLayout(this);
        layout.setOrientation(LinearLayout.VERTICAL);
        layout.setPadding(dp(24), dp(16), dp(24), dp(8));

        List<EditText> inputs = new ArrayList<>();
        for (String[] info : colInfo) {
            String name = info[0];
            String type = info[1];
            boolean isPk = "1".equals(info[2]);

            TextView lbl = new TextView(this);
            lbl.setText(name + " (" + type + ")" + (isPk ? " PK" : ""));
            lbl.setTextColor(isPk ? getColor(R.color.hsp_accent_green) : getColor(R.color.hsp_text_muted));
            lbl.setTextSize(12);
            lbl.setPadding(0, dp(6), 0, dp(2));
            layout.addView(lbl);

            EditText et = new EditText(this);
            et.setHint(isPk ? "(auto)" : "value");
            et.setHintTextColor(getColor(R.color.hsp_text_faint));
            et.setTextColor(getColor(R.color.hsp_text));
            et.setTextSize(13);
            et.setBackgroundResource(R.drawable.bg_glass_input);
            et.setPadding(dp(8), dp(6), dp(8), dp(6));
            et.setSingleLine(true);
            layout.addView(et);
            inputs.add(et);
        }

        sv.addView(layout);
        b.setView(sv);

        b.setPositiveButton("Insert", (dialog, which) -> {
            try {
                ContentValues cv = new ContentValues();
                for (int i = 0; i < colInfo.size(); i++) {
                    String val = inputs.get(i).getText().toString();
                    if (!val.isEmpty()) {
                        cv.put(colInfo.get(i)[0], val);
                    }
                }
                if (cv.size() == 0) { log("❌ No values to insert"); return; }
                long rowId = db.insert("\"" + escapeTable(currentTable) + "\"", null, cv);
                if (rowId == -1) {
                    log("❌ Insert failed");
                } else {
                    log("✅ Inserted row (id=" + rowId + ")");
                    loadTableData();
                }
            } catch (Exception e) {
                log("❌ Insert error: " + e.getMessage());
            }
        });
        b.setNegativeButton("Cancel", null);
        b.show();
    }

    // ======================== SCHEMA VIEW ========================

    private void showSchema() {
        if (db == null || !db.isOpen() || currentTable == null) return;

        List<String[]> colInfo = getColumnInfo(currentTable);
        StringBuilder sb = new StringBuilder();
        sb.append("Table: ").append(currentTable).append("\n\n");
        sb.append(String.format("%-4s %-24s %-12s %-4s %-16s%n", "#", "Name", "Type", "PK", "Default"));
        sb.append("─".repeat(60)).append("\n");
        for (String[] info : colInfo) {
            sb.append(String.format("%-4s %-24s %-12s %-4s %-16s%n",
                info[3], info[0], info[1], "1".equals(info[2]) ? "✓" : "", info[4]));
        }

        // Also get indexes
        Cursor idxC = null;
        try {
            idxC = db.rawQuery("SELECT name, sql FROM sqlite_master WHERE type='index' AND tbl_name=?",
                new String[]{currentTable});
            if (idxC.getCount() > 0) {
                sb.append("\nIndexes:\n");
                while (idxC.moveToNext()) {
                    sb.append("  • ").append(idxC.getString(0));
                    String sql = idxC.getString(1);
                    if (sql != null) sb.append(": ").append(sql);
                    sb.append("\n");
                }
            }
        } catch (Exception ignored) {
        } finally {
            if (idxC != null) idxC.close();
        }

        // Show CREATE TABLE statement
        Cursor createC = null;
        try {
            createC = db.rawQuery("SELECT sql FROM sqlite_master WHERE type='table' AND name=?",
                new String[]{currentTable});
            if (createC.moveToFirst()) {
                String createSql = createC.getString(0);
                if (createSql != null) {
                    sb.append("\nCREATE statement:\n").append(createSql).append("\n");
                }
            }
        } catch (Exception ignored) {
        } finally {
            if (createC != null) createC.close();
        }

        new AlertDialog.Builder(this, android.R.style.Theme_Material_Dialog)
            .setTitle("Schema: " + currentTable)
            .setMessage(sb.toString())
            .setPositiveButton("OK", null)
            .show();

        log("📋 Schema for '" + currentTable + "': " + colInfo.size() + " columns");
    }

    // ======================== RAW SQL EXECUTION ========================

    private void executeSql() {
        if (db == null || !db.isOpen()) {
            log("❌ No database open");
            return;
        }
        String sql = etSql.getText().toString().trim();
        if (sql.isEmpty()) {
            log("❌ Enter a SQL statement");
            return;
        }

        log("▶ SQL: " + sql);
        String upper = sql.toUpperCase(Locale.ROOT).trim();

        if (upper.startsWith("SELECT") || upper.startsWith("PRAGMA") || upper.startsWith("EXPLAIN")) {
            // Query — show results
            Cursor c = null;
            try {
                c = db.rawQuery(sql, null);
                int count = c.getCount();
                log("  → " + count + " row(s) returned");
                renderCursor(c, false); // Not editable for raw SQL results
            } catch (Exception e) {
                log("❌ Query error: " + e.getMessage());
            } finally {
                if (c != null) c.close();
            }
        } else {
            // DDL/DML — execute
            try {
                db.execSQL(sql);
                log("✅ Executed successfully");
                // Refresh table list if DDL
                if (upper.startsWith("CREATE") || upper.startsWith("DROP") || upper.startsWith("ALTER")) {
                    loadTables();
                } else {
                    loadTableData();
                }
            } catch (Exception e) {
                log("❌ Execution error: " + e.getMessage());
            }
        }
    }

    // ======================== EXPORT ========================

    private void exportTable() {
        if (db == null || !db.isOpen() || currentTable == null) return;

        new Thread(() -> {
            Cursor c = null;
            try {
                c = db.rawQuery("SELECT * FROM \"" + escapeTable(currentTable) + "\"", null);
                String[] cols = c.getColumnNames();

                File downloads = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS);
                String ts = new SimpleDateFormat("HHmmss", Locale.US).format(new Date());
                File out = new File(downloads, currentTable + "_" + ts + ".csv");

                BufferedWriter bw = new BufferedWriter(new FileWriter(out));

                // Header
                StringBuilder header = new StringBuilder();
                for (int i = 0; i < cols.length; i++) {
                    if (i > 0) header.append(",");
                    header.append(csvEscape(cols[i]));
                }
                bw.write(header.toString());
                bw.newLine();

                // Data
                int rowCount = 0;
                while (c.moveToNext()) {
                    StringBuilder row = new StringBuilder();
                    for (int i = 0; i < cols.length; i++) {
                        if (i > 0) row.append(",");
                        if (c.isNull(i)) {
                            row.append("");
                        } else if (c.getType(i) == Cursor.FIELD_TYPE_BLOB) {
                            row.append("[BLOB]");
                        } else {
                            row.append(csvEscape(c.getString(i)));
                        }
                    }
                    bw.write(row.toString());
                    bw.newLine();
                    rowCount++;
                }
                bw.flush();
                bw.close();

                final int fc = rowCount;
                final String path = out.getAbsolutePath();
                mainHandler.post(() -> {
                    log("💾 Exported " + fc + " rows to: " + path);
                    Toast.makeText(this, "Exported to Downloads", Toast.LENGTH_SHORT).show();
                });
            } catch (Exception e) {
                final String err = e.getMessage();
                mainHandler.post(() -> log("❌ Export error: " + err));
            } finally {
                if (c != null) c.close();
            }
        }).start();
    }

    // ======================== HELPERS ========================

    private List<String[]> getColumnInfo(String table) {
        List<String[]> cols = new ArrayList<>();
        Cursor c = null;
        try {
            c = db.rawQuery("PRAGMA table_info(\"" + escapeTable(table) + "\")", null);
            while (c.moveToNext()) {
                // cid, name, type, notnull, dflt_value, pk
                String cid = c.getString(0);
                String name = c.getString(1);
                String type = c.getString(2);
                String pk = c.getString(5);
                String dflt = c.isNull(4) ? "" : c.getString(4);
                cols.add(new String[]{name, type, pk, cid, dflt});
            }
        } catch (Exception e) {
            log("❌ PRAGMA error: " + e.getMessage());
        } finally {
            if (c != null) c.close();
        }
        return cols;
    }

    private String buildWhereClause(String[] cols, String[] values) {
        StringBuilder where = new StringBuilder();
        for (int i = 0; i < cols.length; i++) {
            if (i > 0) where.append(" AND ");
            if (values[i] == null || "(NULL)".equals(values[i])) {
                where.append("\"").append(escapeCol(cols[i])).append("\" IS NULL");
            } else if (values[i].startsWith("(BLOB") || values[i].equals("(error)")) {
                // Skip blobs and errors in WHERE — they can't be compared easily
                where.append("1=1");
            } else {
                where.append("\"").append(escapeCol(cols[i])).append("\" = '")
                     .append(values[i].replace("'", "''")).append("'");
            }
        }
        return where.toString();
    }

    private String escapeTable(String name) {
        return name.replace("\"", "\"\"");
    }

    private String escapeCol(String name) {
        return name.replace("\"", "\"\"");
    }

    private String csvEscape(String val) {
        if (val == null) return "";
        if (val.contains(",") || val.contains("\"") || val.contains("\n")) {
            return "\"" + val.replace("\"", "\"\"") + "\"";
        }
        return val;
    }

    private String getFileName(Uri uri) {
        Cursor c = null;
        try {
            c = getContentResolver().query(uri, null, null, null, null);
            if (c != null && c.moveToFirst()) {
                int idx = c.getColumnIndex("_display_name");
                if (idx >= 0) return c.getString(idx);
            }
        } catch (Exception ignored) {
        } finally {
            if (c != null) c.close();
        }
        String path = uri.getLastPathSegment();
        return path != null ? path : "database.db";
    }

    private void copyStream(InputStream in, OutputStream out) throws IOException {
        byte[] buf = new byte[8192];
        int len;
        while ((len = in.read(buf)) > 0) {
            out.write(buf, 0, len);
        }
        out.flush();
        out.close();
    }

    private void log(String msg) {
        Log.d(TAG, "[DbEditor] " + msg);
        mainHandler.post(() -> {
            String cur = tvLog.getText().toString();
            tvLog.setText(cur + "\n" + msg);
            logScroll.post(() -> logScroll.fullScroll(View.FOCUS_DOWN));
        });
    }

    private TextView makeCell(String text, int width) {
        TextView tv = new TextView(this);
        tv.setText(text != null ? text : "");
        tv.setTextSize(11);
        tv.setTextColor(getColor(R.color.hsp_text));
        tv.setPadding(dp(6), dp(4), dp(6), dp(4));
        tv.setMaxLines(2);
        tv.setSingleLine(false);
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(width, ViewGroup.LayoutParams.WRAP_CONTENT);
        tv.setLayoutParams(lp);
        return tv;
    }

    private Button makeButton(String text, int bgColor) {
        Button btn = new Button(this);
        btn.setText(text);
        btn.setTextSize(13);
        btn.setTextColor(getColor(R.color.hsp_text));
        btn.setAllCaps(false);
        btn.setPadding(dp(12), dp(8), dp(12), dp(8));

        GradientDrawable fill = new GradientDrawable();
        fill.setShape(GradientDrawable.RECTANGLE);
        fill.setCornerRadius(dp(14));
        fill.setColor(bgColor);

        GradientDrawable stroke = new GradientDrawable();
        stroke.setShape(GradientDrawable.RECTANGLE);
        stroke.setCornerRadius(dp(14));
        stroke.setColor(0x00000000);
        stroke.setStroke(dp(1), getColor(R.color.hsp_glass_stroke));

        LayerDrawable base = new LayerDrawable(new Drawable[] { fill, stroke });
        RippleDrawable ripple = new RippleDrawable(
                ColorStateList.valueOf(getColor(R.color.hsp_ripple)),
                base,
                null
        );
        btn.setBackground(ripple);

        try {
            btn.setStateListAnimator(AnimatorInflater.loadStateListAnimator(this, R.xml.press_scale));
        } catch (Exception ignored) {
        }

        return btn;
    }

    private void addSpacer(LinearLayout parent, int widthDp) {
        View spacer = new View(this);
        spacer.setLayoutParams(new LinearLayout.LayoutParams(dp(widthDp), dp(1)));
        parent.addView(spacer);
    }

    private int dp(int dp) {
        return (int) (dp * getResources().getDisplayMetrics().density);
    }
}
