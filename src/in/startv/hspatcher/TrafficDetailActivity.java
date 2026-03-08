package in.startv.hspatcher;

import android.app.Activity;
import android.content.ClipData;
import android.content.ClipboardManager;
import android.graphics.Typeface;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.Toast;
import android.widget.ViewFlipper;

import org.json.JSONArray;
import org.json.JSONObject;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Iterator;
import java.util.Locale;

/**
 * Reqable-style detail view for a single traffic entry.
 * Three tabs: OVERVIEW · REQUEST · RESPONSE
 */
public class TrafficDetailActivity extends Activity {

    private ViewFlipper flipper;
    private TextView[] tabBtns;
    private static final int TAB_OVERVIEW = 0, TAB_REQUEST = 1, TAB_RESPONSE = 2;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        String raw = getIntent().getStringExtra("entry_json");
        if (raw == null) { finish(); return; }
        JSONObject entry;
        try { entry = new JSONObject(raw); } catch (Exception e) { finish(); return; }

        String  method     = entry.optString("method", "GET").toUpperCase(Locale.US);
        String  url        = entry.optString("url", "");
        int     status     = entry.optInt("status", -1);
        long    ms         = entry.optLong("ms", 0);
        long    ts         = entry.optLong("ts", 0);
        String  blocked    = entry.optString("blocked", "");
        String  source     = entry.optString("source", "OkHttp");
        String  statusText = entry.optString("status_text", "");

        setContentView(buildRoot(entry, method, url, status, statusText, ms, ts, blocked, source));
        switchTab(TAB_OVERVIEW);
    }

    // ============================================================
    //  Root Layout
    // ============================================================

    private View buildRoot(JSONObject entry, String method, String url, int status,
                           String statusText, long ms, long ts,
                           String blocked, String source) {
        LinearLayout root = new LinearLayout(this);
        root.setOrientation(LinearLayout.VERTICAL);
        root.setBackgroundColor(0xFF0A0A0A);

        // ── Toolbar ──
        root.addView(buildToolbar(method, url, status, blocked));

        // ── URL strip ──
        TextView urlBar = new TextView(this);
        urlBar.setText(url);
        urlBar.setTextColor(0x88FFFFFF);
        urlBar.setTextSize(11);
        urlBar.setTypeface(Typeface.MONOSPACE);
        urlBar.setPadding(dp(14), dp(8), dp(14), dp(8));
        urlBar.setBackgroundColor(0xFF111111);
        urlBar.setMaxLines(3);
        urlBar.setEllipsize(TextUtils.TruncateAt.END);
        final String finalUrl = url;
        urlBar.setOnLongClickListener(v -> { copyToClipboard("URL", finalUrl); return true; });
        root.addView(urlBar, matchH());

        // ── Tab bar ──
        root.addView(buildTabBar());

        // ── Content flipper ──
        flipper = new ViewFlipper(this);
        flipper.addView(buildOverviewPage(entry, method, url, status, statusText, ms, ts, blocked, source));
        flipper.addView(buildRequestPage(entry));
        flipper.addView(buildResponsePage(entry, status, blocked));

        LinearLayout.LayoutParams fp = new LinearLayout.LayoutParams(-1, 0, 1f);
        root.addView(flipper, fp);

        return root;
    }

    // ── Toolbar: back · method · status · spacer · copy ──
    private View buildToolbar(String method, String url, int status, String blocked) {
        LinearLayout tb = new LinearLayout(this);
        tb.setOrientation(LinearLayout.HORIZONTAL);
        tb.setBackgroundColor(0xFF161616);
        tb.setPadding(dp(12), dp(12), dp(12), dp(12));
        tb.setGravity(Gravity.CENTER_VERTICAL);

        // Back
        TextView back = tv("←  ", 22, 0xFF448AFF, false);
        back.setOnClickListener(v -> finish());
        tb.addView(back, wrap());

        // Method badge
        TextView mBadge = tv(method, 11, 0xFFFFFFFF, true);
        mBadge.setPadding(dp(8), dp(3), dp(8), dp(3));
        mBadge.setBackgroundColor(methodColor(method));
        tb.addView(mBadge, wrap());

        // Status
        if (!blocked.isEmpty() || status == 0) {
            TextView bv = tv("  ⛔ BLOCKED", 12, 0xFFFF5252, true);
            tb.addView(bv, wrap());
        } else if (status > 0) {
            int col = statusColor(status);
            TextView sv = tv("  " + status + " " + ("".equals(statusText(status))
                    ? "" : statusText(status)), 13, col, true);
            tb.addView(sv, wrap());
        }

        // Spacer
        tb.addView(new View(this), new LinearLayout.LayoutParams(0, -2, 1f));

        // Copy URL
        TextView copyBtn = tv("📋", 18, 0x99FFFFFF, false);
        final String finalUrl = url != null ? url : "";
        copyBtn.setOnClickListener(v -> copyToClipboard("URL", finalUrl));
        tb.addView(copyBtn, wrap());

        return tb;
    }

    // ── Tab bar ──
    private View buildTabBar() {
        LinearLayout bar = new LinearLayout(this);
        bar.setOrientation(LinearLayout.HORIZONTAL);
        bar.setBackgroundColor(0xFF141414);

        String[] labels = {"OVERVIEW", "REQUEST", "RESPONSE"};
        tabBtns = new TextView[3];
        for (int i = 0; i < 3; i++) {
            final int idx = i;
            tabBtns[i] = new TextView(this);
            tabBtns[i].setText(labels[i]);
            tabBtns[i].setTextSize(11);
            tabBtns[i].setTypeface(null, Typeface.BOLD);
            tabBtns[i].setGravity(Gravity.CENTER);
            tabBtns[i].setPadding(dp(4), dp(13), dp(4), dp(13));
            tabBtns[i].setLetterSpacing(0.08f);
            tabBtns[i].setOnClickListener(v -> switchTab(idx));
            bar.addView(tabBtns[i], new LinearLayout.LayoutParams(0, -2, 1f));
        }
        return bar;
    }

    private void switchTab(int idx) {
        flipper.setDisplayedChild(idx);
        for (int i = 0; i < tabBtns.length; i++) {
            boolean active = (i == idx);
            tabBtns[i].setTextColor(active ? 0xFF448AFF : 0x55FFFFFF);
            tabBtns[i].setBackgroundColor(active ? 0xFF1A2530 : 0xFF141414);
        }
    }

    // ============================================================
    //  OVERVIEW page
    // ============================================================

    private View buildOverviewPage(JSONObject entry, String method, String url, int status,
                                    String statusText, long ms, long ts,
                                    String blocked, String source) {
        ScrollView sv = scrollPage();
        LinearLayout page = pagePad();

        sectionHeader(page, "GENERAL");
        kv(page, "Method",   method);
        kv(page, "URL",      url);
        kv(page, "Source",   source);
        if (ts > 0) kv(page, "Time",
                new SimpleDateFormat("yyyy-MM-dd  HH:mm:ss.SSS", Locale.US).format(new Date(ts)));
        if (ms > 0) kv(page, "Duration", ms + " ms  (" + speedHint(ms) + ")");

        sectionHeader(page, "RESPONSE");
        if (!blocked.isEmpty() || status == 0) {
            kv(page, "Status",  "⛔  BLOCKED");
            kv(page, "Rule",    blocked);
        } else {
            kv(page, "Status",  status + (statusText.isEmpty() ? "" : "  " + statusText));
            if (ms > 0) {
                String resBody = entry.optString("res_body", "");
                if (!resBody.isEmpty()) kv(page, "Body size", formatBytes(resBody.length()));
            }
        }

        sv.addView(page, pageLP());
        return sv;
    }

    // ============================================================
    //  REQUEST page
    // ============================================================

    private View buildRequestPage(JSONObject entry) {
        ScrollView sv = scrollPage();
        LinearLayout page = pagePad();

        // -- Headers --
        sectionHeader(page, "HEADERS");
        JSONObject rh = entry.optJSONObject("req_headers");
        if (rh == null || rh.length() == 0) {
            emptyNote(page, "(no headers)");
        } else {
            renderHeaders(page, rh);
        }

        // -- Body --
        sectionHeader(page, "BODY");
        String body = entry.optString("req_body", "");
        if (body.isEmpty()) {
            emptyNote(page, "(empty body)");
        } else {
            String ct = rh != null ? headerCI(rh, "content-type") : "";
            bodyBlock(page, prettyBody(body, ct));
        }

        sv.addView(page, pageLP());
        return sv;
    }

    // ============================================================
    //  RESPONSE page
    // ============================================================

    private View buildResponsePage(JSONObject entry, int status, String blocked) {
        ScrollView sv = scrollPage();
        LinearLayout page = pagePad();

        if (!blocked.isEmpty() || status == 0) {
            page.addView(centeredNote("⛔  This request was blocked by HSPatch.\n\nRule: " + blocked));
        } else {
            // -- Headers --
            sectionHeader(page, "HEADERS");
            JSONObject rh = entry.optJSONObject("res_headers");
            if (rh == null || rh.length() == 0) {
                emptyNote(page, "(no headers)");
            } else {
                renderHeaders(page, rh);
            }

            // -- Body --
            sectionHeader(page, "BODY");
            String body = entry.optString("res_body", "");
            if (body.isEmpty()) {
                emptyNote(page, "(empty body)");
            } else {
                String ct = rh != null ? headerCI(rh, "content-type") : "";
                bodyBlock(page, prettyBody(body, ct));
            }
        }

        sv.addView(page, pageLP());
        return sv;
    }

    // ============================================================
    //  UI building helpers
    // ============================================================

    private void sectionHeader(LinearLayout parent, String title) {
        // Leading spacer
        parent.addView(spacer(dp(18)));

        LinearLayout row = new LinearLayout(this);
        row.setOrientation(LinearLayout.HORIZONTAL);
        row.setGravity(Gravity.CENTER_VERTICAL);

        TextView lbl = tv(title, 10, 0xFF448AFF, true);
        lbl.setLetterSpacing(0.15f);
        row.addView(lbl, wrap());

        View line = new View(this);
        line.setBackgroundColor(0xFF252525);
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(0, dp(1), 1f);
        lp.setMarginStart(dp(8));
        row.addView(line, lp);
        parent.addView(row, matchH());

        parent.addView(spacer(dp(10)));
    }

    private void kv(LinearLayout parent, String key, String value) {
        LinearLayout row = new LinearLayout(this);
        row.setOrientation(LinearLayout.HORIZONTAL);
        row.setPadding(0, dp(3), 0, dp(3));

        TextView kv = tv(key, 12, 0x66FFFFFF, false);
        kv.setMinWidth(dp(82));
        row.addView(kv, wrap());

        TextView vv = tv(value, 12, 0xDDFFFFFF, false);
        vv.setLineSpacing(dp(2), 1f);
        row.addView(vv, new LinearLayout.LayoutParams(0, -2, 1f));

        parent.addView(row, matchH());
    }

    private void renderHeaders(LinearLayout parent, JSONObject headers) {
        Iterator<String> keys = headers.keys();
        boolean odd = false;
        while (keys.hasNext()) {
            String k = keys.next();
            String v = headers.optString(k, "");
            odd = !odd;

            LinearLayout row = new LinearLayout(this);
            row.setOrientation(LinearLayout.HORIZONTAL);
            row.setBackgroundColor(odd ? 0xFF111111 : 0xFF141414);
            row.setPadding(dp(10), dp(6), dp(10), dp(6));

            LinearLayout.LayoutParams rp = new LinearLayout.LayoutParams(-1, -2);
            rp.topMargin = dp(1);

            // Key
            TextView kt = tv(k + ": ", 11, 0xFF9E9E9E, false);
            kt.setSingleLine(true);
            kt.setMinWidth(dp(0));
            row.addView(kt, wrap());

            // Value
            TextView vt = tv(v, 11, 0xEEFFFFFF, false);
            vt.setSingleLine(true);
            vt.setEllipsize(TextUtils.TruncateAt.END);
            row.addView(vt, new LinearLayout.LayoutParams(0, -2, 1f));

            parent.addView(row, rp);
        }
    }

    private void bodyBlock(LinearLayout parent, String text) {
        // Copy button
        TextView copyBtn = tv("📋  Copy body", 11, 0xFF448AFF, false);
        copyBtn.setPadding(dp(10), dp(4), dp(10), dp(8));
        final String finalText = text;
        copyBtn.setOnClickListener(v -> copyToClipboard("body", finalText));
        parent.addView(copyBtn, wrap());

        // Body text
        TextView body = new TextView(this);
        body.setText(text);
        body.setTextColor(0xCCFFFFFF);
        body.setTextSize(11);
        body.setTypeface(Typeface.MONOSPACE);
        body.setBackgroundColor(0xFF111111);
        body.setPadding(dp(12), dp(12), dp(12), dp(12));
        body.setTextIsSelectable(true);
        parent.addView(body, matchH());
    }

    private void emptyNote(LinearLayout parent, String msg) {
        parent.addView(tv(msg, 12, 0x33FFFFFF, false));
    }

    private TextView centeredNote(String msg) {
        TextView t = tv(msg, 14, 0x88FFFFFF, false);
        t.setGravity(Gravity.CENTER);
        t.setPadding(dp(32), dp(64), dp(32), dp(32));
        return t;
    }

    // ============================================================
    //  Body formatting
    // ============================================================

    private String prettyBody(String raw, String contentType) {
        if (raw == null || raw.isEmpty()) return "";
        String ct = contentType != null ? contentType.toLowerCase(Locale.US) : "";
        // JSON?
        if (ct.contains("json") || raw.trim().startsWith("{") || raw.trim().startsWith("[")) {
            try {
                if (raw.trim().startsWith("[")) return new JSONArray(raw).toString(2);
                return new JSONObject(raw).toString(2);
            } catch (Exception ignored) {}
        }
        // XML / HTML? Return as-is for now (could add basic indent later)
        return raw;
    }

    // ============================================================
    //  Utility
    // ============================================================

    private String headerCI(JSONObject headers, String name) {
        Iterator<String> keys = headers.keys();
        while (keys.hasNext()) {
            String k = keys.next();
            if (k.equalsIgnoreCase(name)) return headers.optString(k, "");
        }
        return "";
    }

    private void copyToClipboard(String label, String text) {
        ClipboardManager cm = (ClipboardManager) getSystemService(CLIPBOARD_SERVICE);
        if (cm != null) cm.setPrimaryClip(ClipData.newPlainText(label, text));
        Toast.makeText(this, "Copied to clipboard", Toast.LENGTH_SHORT).show();
    }

    private String speedHint(long ms) {
        if (ms < 100)  return "🚀 fast";
        if (ms < 500)  return "✅ ok";
        if (ms < 2000) return "🐢 slow";
        return "🔴 very slow";
    }

    private String formatBytes(int n) {
        if (n < 1024) return n + " B";
        if (n < 1024 * 1024) return String.format(Locale.US, "%.1f KB", n / 1024f);
        return String.format(Locale.US, "%.2f MB", n / (1024f * 1024f));
    }

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

    private static int statusColor(int s) {
        if (s >= 500) return 0xFFFF5252;
        if (s >= 400) return 0xFFFF9800;
        if (s >= 300) return 0xFFFFD740;
        return 0xFF69F0AE;
    }

    private static String statusText(int s) {
        switch (s) {
            case 200: return "OK";
            case 201: return "Created";
            case 204: return "No Content";
            case 301: return "Moved";
            case 302: return "Found";
            case 304: return "Not Modified";
            case 400: return "Bad Request";
            case 401: return "Unauthorized";
            case 403: return "Forbidden";
            case 404: return "Not Found";
            case 429: return "Too Many Requests";
            case 500: return "Server Error";
            case 502: return "Bad Gateway";
            case 503: return "Unavailable";
            default:  return "";
        }
    }

    // ── Layout helpers ──
    private ScrollView scrollPage() {
        ScrollView sv = new ScrollView(this);
        sv.setBackgroundColor(0xFF0A0A0A);
        return sv;
    }

    private LinearLayout pagePad() {
        LinearLayout l = new LinearLayout(this);
        l.setOrientation(LinearLayout.VERTICAL);
        l.setPadding(dp(16), dp(12), dp(16), dp(32));
        return l;
    }

    private ViewGroup.LayoutParams pageLP() {
        return new ViewGroup.LayoutParams(-1, -2);
    }

    private TextView tv(String s, float sp, int color, boolean bold) {
        TextView t = new TextView(this);
        t.setText(s);
        t.setTextSize(sp);
        t.setTextColor(color);
        if (bold) t.setTypeface(null, Typeface.BOLD);
        return t;
    }

    private View spacer(int h) {
        View v = new View(this);
        v.setLayoutParams(new LinearLayout.LayoutParams(-1, h));
        return v;
    }

    private LinearLayout.LayoutParams wrap() {
        return new LinearLayout.LayoutParams(-2, -2);
    }

    private LinearLayout.LayoutParams matchH() {
        return new LinearLayout.LayoutParams(-1, -2);
    }

    private int dp(int v) {
        return Math.round(v * getResources().getDisplayMetrics().density);
    }
}
