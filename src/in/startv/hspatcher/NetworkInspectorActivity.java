package in.startv.hspatcher;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.Typeface;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.BaseAdapter;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;

import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.List;
import java.util.Locale;

/**
 * Reqable-style Network Inspector.
 * Reads traffic_log.jsonl from the patched app's external files dir
 * and shows requests in real-time, newest first.
 */
public class NetworkInspectorActivity extends Activity {

    public static final String EXTRA_PACKAGE_NAME = "pkg_name";

    private ListView listView;
    private TextView statusBar;
    private TextView emptyView;
    private TrafficAdapter adapter;
    private final List<TrafficEntry> entries = new ArrayList<>();
    private final Handler handler = new Handler(Looper.getMainLooper());
    private String targetPkg;
    private long lastFileSize = -1;
    private long lastModified = 0;

    // ========== Lifecycle ==========

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        targetPkg = getIntent().getStringExtra(EXTRA_PACKAGE_NAME);
        setContentView(buildRootLayout());
        adapter = new TrafficAdapter();
        listView.setAdapter(adapter);
        listView.setOnItemClickListener((parent, view, pos, id) -> {
            if (pos < entries.size()) openDetail(entries.get(pos));
        });
        // Start polling immediately
        handler.post(pollRunnable);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        handler.removeCallbacksAndMessages(null);
    }

    // ========== Polling ==========

    private final Runnable pollRunnable = new Runnable() {
        @Override public void run() {
            refreshEntries();
            handler.postDelayed(this, 800);
        }
    };

    private void refreshEntries() {
        new Thread(() -> {
            File logFile = findLogFile();
            if (logFile == null) {
                handler.post(() -> {
                    statusBar.setText("Waiting for patched app… (" + resolvedPkg() + ")");
                    if (entries.isEmpty()) emptyView.setVisibility(View.VISIBLE);
                });
                return;
            }
            long curSize = logFile.length();
            long curMod  = logFile.lastModified();
            if (curSize == lastFileSize && curMod == lastModified && !entries.isEmpty()) return;

            try {
                List<TrafficEntry> loaded = new ArrayList<>();
                BufferedReader reader = new BufferedReader(new FileReader(logFile));
                String line;
                while ((line = reader.readLine()) != null) {
                    line = line.trim();
                    if (line.isEmpty()) continue;
                    try {
                        JSONObject o = new JSONObject(line);
                        loaded.add(new TrafficEntry(o, line));
                    } catch (Exception ignored) {}
                }
                reader.close();
                // Newest first
                Collections.reverse(loaded);
                lastFileSize = curSize;
                lastModified = curMod;

                handler.post(() -> {
                    entries.clear();
                    entries.addAll(loaded);
                    adapter.notifyDataSetChanged();
                    emptyView.setVisibility(entries.isEmpty() ? View.VISIBLE : View.GONE);
                    String ts = new SimpleDateFormat("HH:mm:ss", Locale.US).format(new Date());
                    statusBar.setText(entries.size() + " requests  •  " + ts +
                            "  •  " + resolvedPkg());
                });
            } catch (Exception e) {
                handler.post(() -> statusBar.setText("Read error: " + e.getMessage()));
            }
        }).start();
    }

    private String resolvedPkg() {
        if (targetPkg != null && !targetPkg.isEmpty()) return targetPkg;
        return "in.startv.hotstar";
    }

    private File findLogFile() {
        String[] pkgs = targetPkg != null && !targetPkg.isEmpty()
                ? new String[]{targetPkg, "in.startv.hotstar"}
                : new String[]{"in.startv.hotstar"};
        for (String pkg : pkgs) {
            File f = new File(Environment.getExternalStorageDirectory(),
                    "Android/data/" + pkg + "/files/traffic_log.jsonl");
            if (f.exists() && f.length() > 0) return f;
        }
        // Downloads fallback
        File dl = new File(Environment.getExternalStoragePublicDirectory(
                Environment.DIRECTORY_DOWNLOADS), "hspatch_traffic.jsonl");
        if (dl.exists() && dl.length() > 0) return dl;
        return null;
    }

    // ========== Actions ==========

    private void openDetail(TrafficEntry e) {
        Intent i = new Intent(this, TrafficDetailActivity.class);
        i.putExtra("entry_json", e.raw);
        startActivity(i);
    }

    private void clearLog() {
        new Thread(() -> {
            File f = findLogFile();
            if (f != null) f.delete();
            lastFileSize = -1;
            lastModified = 0;
            handler.post(() -> {
                entries.clear();
                adapter.notifyDataSetChanged();
                emptyView.setVisibility(View.VISIBLE);
                statusBar.setText("Log cleared");
            });
        }).start();
    }

    // ========== Layout ==========

    private LinearLayout rootLayout;
    private ListView listView() { return listView; }

    private View buildRootLayout() {
        LinearLayout root = new LinearLayout(this);
        root.setOrientation(LinearLayout.VERTICAL);
        root.setBackgroundColor(0xFF0A0A0A);

        // ── Toolbar ──
        LinearLayout toolbar = new LinearLayout(this);
        toolbar.setOrientation(LinearLayout.HORIZONTAL);
        toolbar.setBackgroundColor(0xFF161616);
        toolbar.setPadding(dp(14), dp(12), dp(14), dp(12));
        toolbar.setGravity(Gravity.CENTER_VERTICAL);

        TextView btnBack = makeText("←", 22, 0xFF448AFF, false);
        btnBack.setPadding(0, 0, dp(14), 0);
        btnBack.setOnClickListener(v -> finish());
        toolbar.addView(btnBack, wrap());

        TextView title = makeText("Network Inspector", 17, 0xFFFFFFFF, true);
        toolbar.addView(title, new LinearLayout.LayoutParams(0, -2, 1f));

        // Filter chips (ALL / OK / BLOCK / ERR)
        // Keep it simple for now — clear only
        TextView btnClear = makeText("🗑", 18, 0xFFFF5252, false);
        btnClear.setOnClickListener(v -> {
            new android.app.AlertDialog.Builder(this)
                    .setTitle("Clear log?")
                    .setMessage("All recorded traffic will be deleted.")
                    .setPositiveButton("Clear", (d, w) -> clearLog())
                    .setNegativeButton("Cancel", null)
                    .show();
        });
        toolbar.addView(btnClear, wrap());

        root.addView(toolbar, matchH());

        // ── Status bar ──
        statusBar = makeText("Loading…", 11, 0x66FFFFFF, false);
        statusBar.setPadding(dp(14), dp(6), dp(14), dp(6));
        statusBar.setBackgroundColor(0xFF111111);
        root.addView(statusBar, matchH());

        // ── Legend row ──
        root.addView(buildLegend(), matchH());

        // ── Divider ──
        root.addView(dividerH(), matchH());

        // ── Frame for list + empty state ──
        android.widget.FrameLayout frame = new android.widget.FrameLayout(this);

        listView = new ListView(this);
        listView.setBackgroundColor(0xFF0A0A0A);
        listView.setDivider(new ColorDrawable(0xFF1C1C1C));
        listView.setDividerHeight(1);
        listView.setScrollbarFadingEnabled(false);
        frame.addView(listView, matchFill());

        emptyView = makeText("No traffic recorded yet.\n\nOpen the patched app and\nperform some actions.", 14, 0x44FFFFFF, false);
        emptyView.setGravity(Gravity.CENTER);
        emptyView.setVisibility(View.GONE);
        frame.addView(emptyView, matchFill());

        root.addView(frame, new LinearLayout.LayoutParams(-1, 0, 1f));

        return root;
    }

    private View buildLegend() {
        LinearLayout row = new LinearLayout(this);
        row.setOrientation(LinearLayout.HORIZONTAL);
        row.setBackgroundColor(0xFF111111);
        row.setPadding(dp(14), dp(5), dp(14), dp(5));
        row.setGravity(Gravity.CENTER_VERTICAL);

        addLegendDot(row, 0xFF43A047, "GET");
        addLegendDot(row, 0xFF1976D2, "POST");
        addLegendDot(row, 0xFFEF6C00, "PUT");
        addLegendDot(row, 0xFFC62828, "DEL");
        addLegendDot(row, 0xFF69F0AE, "2xx");
        addLegendDot(row, 0xFFFFD740, "3xx");
        addLegendDot(row, 0xFFFF9800, "4xx");
        addLegendDot(row, 0xFFFF5252, "5xx / BLOCK");
        return row;
    }

    private void addLegendDot(LinearLayout parent, int color, String label) {
        TextView dot = new TextView(this);
        dot.setText("● ");
        dot.setTextColor(color);
        dot.setTextSize(10);
        parent.addView(dot, wrap());

        TextView lbl = new TextView(this);
        lbl.setText(label + "  ");
        lbl.setTextColor(0x66FFFFFF);
        lbl.setTextSize(10);
        parent.addView(lbl, wrap());
    }

    // ========== Adapter ==========

    class TrafficAdapter extends BaseAdapter {
        @Override public int getCount() { return entries.size(); }
        @Override public TrafficEntry getItem(int i) { return entries.get(i); }
        @Override public long getItemId(int i) { return i; }

        @Override
        public View getView(int position, View convertView, ViewGroup parent) {
            TrafficEntry e = entries.get(position);
            LinearLayout card = new LinearLayout(NetworkInspectorActivity.this);
            card.setOrientation(LinearLayout.VERTICAL);
            card.setPadding(dp(14), dp(10), dp(14), dp(10));

            // Subtle left-border accent based on status
            int accentColor = statusAccent(e);

            // Row 1: method badge ── host ─────────────── status badge
            LinearLayout r1 = new LinearLayout(NetworkInspectorActivity.this);
            r1.setOrientation(LinearLayout.HORIZONTAL);
            r1.setGravity(Gravity.CENTER_VERTICAL);

            // Method pill
            TextView methodBadge = new TextView(NetworkInspectorActivity.this);
            methodBadge.setText(e.method);
            methodBadge.setTextSize(9);
            methodBadge.setTextColor(0xFFFFFFFF);
            methodBadge.setTypeface(null, Typeface.BOLD);
            methodBadge.setPadding(dp(6), dp(2), dp(6), dp(2));
            methodBadge.setBackgroundColor(methodColor(e.method));
            r1.addView(methodBadge, wrap());

            TextView spacer = new TextView(NetworkInspectorActivity.this);
            spacer.setText("  ");
            r1.addView(spacer, wrap());

            // Host
            TextView hostView = new TextView(NetworkInspectorActivity.this);
            hostView.setText(e.host);
            hostView.setTextColor(0xDDFFFFFF);
            hostView.setTextSize(13);
            hostView.setTypeface(null, Typeface.BOLD);
            hostView.setSingleLine(true);
            hostView.setEllipsize(TextUtils.TruncateAt.END);
            r1.addView(hostView, new LinearLayout.LayoutParams(0, -2, 1f));

            // Status
            TextView statusBadge = new TextView(NetworkInspectorActivity.this);
            statusBadge.setText(e.statusLabel);
            statusBadge.setTextSize(11);
            statusBadge.setTextColor(accentColor);
            statusBadge.setTypeface(null, Typeface.BOLD);
            statusBadge.setPadding(dp(4), 0, 0, 0);
            r1.addView(statusBadge, wrap());

            card.addView(r1, matchH());

            // Row 2: path (dimmed)
            if (!e.path.isEmpty() && !e.path.equals("/")) {
                TextView pathView = new TextView(NetworkInspectorActivity.this);
                pathView.setText(e.path);
                pathView.setTextColor(0x66FFFFFF);
                pathView.setTextSize(11);
                pathView.setSingleLine(true);
                pathView.setEllipsize(TextUtils.TruncateAt.END);
                pathView.setPadding(0, dp(2), 0, 0);
                card.addView(pathView, matchH());
            }

            // Row 3: time ── ──────────────────────── duration
            LinearLayout r3 = new LinearLayout(NetworkInspectorActivity.this);
            r3.setOrientation(LinearLayout.HORIZONTAL);
            r3.setPadding(0, dp(5), 0, 0);

            TextView timeView = new TextView(NetworkInspectorActivity.this);
            timeView.setText(e.timeFormatted);
            timeView.setTextColor(0x33FFFFFF);
            timeView.setTextSize(10);
            r3.addView(timeView, new LinearLayout.LayoutParams(0, -2, 1f));

            if (e.ms > 0) {
                TextView durView = new TextView(NetworkInspectorActivity.this);
                durView.setText(e.ms + " ms");
                durView.setTextColor(durationColor(e.ms));
                durView.setTextSize(10);
                r3.addView(durView, wrap());
            }
            card.addView(r3, matchH());

            // Card background / accent — lighter row for selected ripple
            card.setBackgroundColor(position % 2 == 0 ? 0xFF111111 : 0xFF0E0E0E);

            // Left-border accent (simulate via padding + background on wrapper)
            // Wrap in a horizontal layout to add the accent border
            LinearLayout wrapper = new LinearLayout(NetworkInspectorActivity.this);
            wrapper.setOrientation(LinearLayout.HORIZONTAL);
            wrapper.setBackgroundColor(position % 2 == 0 ? 0xFF111111 : 0xFF0E0E0E);

            View accent = new View(NetworkInspectorActivity.this);
            accent.setBackgroundColor(accentColor);
            wrapper.addView(accent, new LinearLayout.LayoutParams(dp(3), -1));
            wrapper.addView(card, new LinearLayout.LayoutParams(0, -2, 1f));

            return wrapper;
        }
    }

    // ========== Data model ==========

    public static class TrafficEntry {
        public final String raw;
        public final String method;
        public final String url;
        public final String host;
        public final String path;
        public final int status;
        public final String statusLabel;
        public final long ts;
        public final long ms;
        public final String timeFormatted;
        public final String blocked;

        public TrafficEntry(JSONObject o, String raw) {
            this.raw = raw;
            this.method  = o.optString("method", "GET").toUpperCase(Locale.US);
            this.url     = o.optString("url", "");
            this.status  = o.optInt("status", -1);
            this.ts      = o.optLong("ts", 0);
            this.ms      = o.optLong("ms", 0);
            this.blocked = o.optString("blocked", "");
            this.timeFormatted = ts > 0
                    ? new SimpleDateFormat("HH:mm:ss.SSS", Locale.US).format(new Date(ts))
                    : "";
            this.statusLabel = status == 0 ? "BLOCK" : (status > 0 ? String.valueOf(status) : "—");

            // Parse host/path
            String h = "", p = "";
            try {
                int pp = url.indexOf("://");
                if (pp >= 0) {
                    int hs = pp + 3;
                    int pe = url.indexOf("/", hs);
                    if (pe < 0) { h = url.substring(hs); p = "/"; }
                    else { h = url.substring(hs, pe); p = url.substring(pe); }
                    int col = h.indexOf(":");
                    if (col > 0) h = h.substring(0, col);
                    // Strip query from path for display (keep it short)
                    int qi = p.indexOf("?");
                    if (qi > 0) p = p.substring(0, qi) + "?…";
                } else { h = url; }
            } catch (Exception ignored) {}
            this.host = h;
            this.path = p;
        }
    }

    // ========== Colour helpers ==========

    private static int methodColor(String m) {
        if (m == null) return 0xFF546E7A;
        switch (m) {
            case "GET":    return 0xFF2E7D32;
            case "POST":   return 0xFF1565C0;
            case "PUT":    return 0xFFE65100;
            case "DELETE": return 0xFFC62828;
            case "PATCH":  return 0xFF4A148C;
            case "HEAD":   return 0xFF00838F;
            default:       return 0xFF546E7A;
        }
    }

    private static int statusAccent(TrafficEntry e) {
        if (e.status == 0 || !e.blocked.isEmpty()) return 0xFFFF5252;
        if (e.status >= 500) return 0xFFFF5252;
        if (e.status >= 400) return 0xFFFF9800;
        if (e.status >= 300) return 0xFFFFD740;
        if (e.status >= 200) return 0xFF69F0AE;
        return 0xFF546E7A;
    }

    private static int durationColor(long ms) {
        if (ms < 300)  return 0xFF69F0AE;
        if (ms < 1000) return 0xFFFFD740;
        return 0xFFFF5252;
    }

    // ========== View helpers ==========

    private TextView makeText(String s, float sp, int color, boolean bold) {
        TextView tv = new TextView(this);
        tv.setText(s);
        tv.setTextSize(sp);
        tv.setTextColor(color);
        if (bold) tv.setTypeface(null, Typeface.BOLD);
        return tv;
    }

    private int dp(int v) {
        return Math.round(v * getResources().getDisplayMetrics().density);
    }

    private LinearLayout.LayoutParams wrap() {
        return new LinearLayout.LayoutParams(-2, -2);
    }

    private LinearLayout.LayoutParams matchH() {
        return new LinearLayout.LayoutParams(-1, -2);
    }

    private android.widget.FrameLayout.LayoutParams matchFill() {
        return new android.widget.FrameLayout.LayoutParams(-1, -1);
    }

    private View dividerH() {
        View v = new View(this);
        v.setBackgroundColor(0xFF252525);
        v.setLayoutParams(new LinearLayout.LayoutParams(-1, 1));
        return v;
    }
}
