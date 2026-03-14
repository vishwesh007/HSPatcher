package in.startv.hspatcher;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Intent;
import android.content.res.ColorStateList;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.GradientDrawable;
import android.graphics.drawable.LayerDrawable;
import android.graphics.drawable.RippleDrawable;
import android.net.Uri;
import android.animation.AnimatorInflater;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.view.Gravity;
import android.view.View;
import android.widget.*;
import java.io.*;
import java.math.BigInteger;
import java.security.*;
import java.security.cert.Certificate;
import java.security.cert.CertificateFactory;
import java.security.cert.X509Certificate;
import java.text.SimpleDateFormat;
import java.util.*;
import javax.security.auth.x500.X500Principal;

/**
 * Standalone APK Signer — sign any APK with a custom certificate.
 * Uses Google's apksig library (Apache 2.0) for v1+v2+v3 signing.
 * Reference: https://github.com/nicehash/ApkSigner (concept adapted)
 * Certificate generation: in-house CertBuilder (raw DER, no BouncyCastle).
 */
public class ApkSignerActivity extends Activity {

    private static final String TAG = "HSPatcher";
    private static final int PICK_APK = 2001;
    private static final int PICK_KEYSTORE = 2002;

    private EditText etCN, etOrg, etCountry, etAlias, etKeystorePass, etKeyPass, etValidity;
    private Spinner spinnerKeySize;
    private TextView tvSelectedApk, tvLog;
    private ScrollView logScroll;
    private ProgressBar progressBar;
    private Button btnSelectApk, btnSign, btnSaveKeystore, btnLoadKeystore;
    private CheckBox cbV1, cbV2, cbV3;

    private File selectedApk;
    private Handler mainHandler;
    private KeyPair savedKeyPair;
    private X509Certificate savedCert;
    private boolean isSigning = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mainHandler = new Handler(Looper.getMainLooper());
        applyModernSystemUi();
        buildUI();
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
        ScrollView root = new ScrollView(this);
        root.setBackgroundResource(R.drawable.bg_glass_root);
        root.setFillViewport(true);

        LinearLayout main = new LinearLayout(this);
        main.setOrientation(LinearLayout.VERTICAL);
        main.setPadding(dp(24), dp(24), dp(24), dp(24));

        // Header
        TextView header = new TextView(this);
        header.setText("🔐 APK Signer");
        header.setTextSize(28);
        header.setTextColor(getColor(R.color.hsp_legacy_signer));
        header.setTypeface(null, android.graphics.Typeface.BOLD);
        header.setGravity(Gravity.CENTER);
        header.setPadding(0, dp(16), 0, dp(8));
        main.addView(header);

        TextView sub = new TextView(this);
        sub.setText("Sign APKs with custom certificates (v1+v2+v3)");
        sub.setTextSize(13);
        sub.setTextColor(getColor(R.color.hsp_text_muted));
        sub.setGravity(Gravity.CENTER);
        sub.setPadding(0, 0, 0, dp(16));
        main.addView(sub);

        // Certificate Config Section
        main.addView(sectionLabel("Certificate Configuration"));

        LinearLayout row1 = hRow();
        etCN = addLabeledInput(row1, "Common Name (CN)", "HSPatch Custom");
        etOrg = addLabeledInput(row1, "Organization (O)", "HSPatch");
        main.addView(row1);

        LinearLayout row2 = hRow();
        etCountry = addLabeledInput(row2, "Country (C)", "US");
        etAlias = addLabeledInput(row2, "Key Alias", "hspatch_key");
        main.addView(row2);

        LinearLayout row3 = hRow();
        etKeystorePass = addLabeledInput(row3, "Keystore Password", "hspatch123");
        etKeyPass = addLabeledInput(row3, "Key Password", "hspatch123");
        main.addView(row3);

        LinearLayout row4 = hRow();
        etValidity = addLabeledInput(row4, "Validity (years)", "25");

        // Key size spinner
        LinearLayout keySizeCol = new LinearLayout(this);
        keySizeCol.setOrientation(LinearLayout.VERTICAL);
        keySizeCol.setLayoutParams(new LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1));
        keySizeCol.setPadding(dp(4), 0, dp(4), 0);

        TextView lblKeySize = new TextView(this);
        lblKeySize.setText("Key Size");
        lblKeySize.setTextSize(12);
        lblKeySize.setTextColor(0x99FFFFFF);
        keySizeCol.addView(lblKeySize);

        spinnerKeySize = new Spinner(this);
        ArrayAdapter<String> adapter = new ArrayAdapter<>(this,
            android.R.layout.simple_spinner_item,
            new String[]{"2048", "4096"});
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        spinnerKeySize.setAdapter(adapter);
        spinnerKeySize.setBackgroundResource(R.drawable.bg_glass_input);
        keySizeCol.addView(spinnerKeySize);
        row4.addView(keySizeCol);
        main.addView(row4);

        // Signing scheme checkboxes
        main.addView(sectionLabel("Signing Schemes"));
        LinearLayout cbRow = hRow();
        cbV1 = makeCheckbox("v1 (JAR)", true);
        cbV2 = makeCheckbox("v2 (APK Sig v2)", true);
        cbV3 = makeCheckbox("v3 (APK Sig v3)", true);
        cbRow.addView(cbV1);
        cbRow.addView(cbV2);
        cbRow.addView(cbV3);
        main.addView(cbRow);

        // Keystore management buttons
        main.addView(sectionLabel("Keystore Management"));
        LinearLayout ksRow = hRow();

        btnSaveKeystore = makeButton("💾 SAVE KEY", getColor(R.color.hsp_legacy_teal));
        btnSaveKeystore.setOnClickListener(v -> onSaveKeystore());
        ksRow.addView(btnSaveKeystore, new LinearLayout.LayoutParams(0, dp(44), 1));

        btnLoadKeystore = makeButton("📂 LOAD KEY", getColor(R.color.hsp_legacy_backup));
        btnLoadKeystore.setOnClickListener(v -> onLoadKeystore());
        ksRow.addView(btnLoadKeystore, new LinearLayout.LayoutParams(0, dp(44), 1));
        main.addView(ksRow);

        // APK selection
        main.addView(sectionLabel("APK to Sign"));

        tvSelectedApk = new TextView(this);
        tvSelectedApk.setText("No APK selected");
        tvSelectedApk.setTextSize(14);
        tvSelectedApk.setTextColor(getColor(R.color.hsp_text_mono));
        tvSelectedApk.setPadding(dp(12), dp(8), dp(12), dp(8));
        tvSelectedApk.setBackgroundResource(R.drawable.bg_card);
        main.addView(tvSelectedApk);

        btnSelectApk = makeButton("📱 SELECT APK", getColor(R.color.hsp_accent_green));
        btnSelectApk.setTextColor(0xFF000000);
        btnSelectApk.setOnClickListener(v -> onSelectApk());
        main.addView(btnSelectApk, new LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT, dp(52)));

        btnSign = makeButton("✅ SIGN APK", getColor(R.color.hsp_legacy_purple));
        btnSign.setEnabled(false);
        btnSign.setOnClickListener(v -> onSignClick());
        main.addView(btnSign, new LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT, dp(52)));

        // Progress
        progressBar = new ProgressBar(this, null, android.R.attr.progressBarStyleHorizontal);
        progressBar.setMax(100);
        progressBar.setVisibility(View.GONE);
        main.addView(progressBar);

        // Log output
        logScroll = new ScrollView(this);
        logScroll.setBackgroundResource(R.drawable.bg_log);
        logScroll.setPadding(dp(12), dp(8), dp(12), dp(8));
        logScroll.setLayoutParams(new LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT, dp(200)));

        tvLog = new TextView(this);
        tvLog.setText("Ready. Configure certificate and select an APK.");
        tvLog.setTextSize(12);
        tvLog.setTextColor(getColor(R.color.hsp_text_mono));
        tvLog.setTypeface(android.graphics.Typeface.MONOSPACE);
        logScroll.addView(tvLog);
        main.addView(logScroll);

        // Back button
        Button btnBack = makeButton("← BACK TO PATCHER", getColor(R.color.hsp_surface));
        btnBack.setOnClickListener(v -> finish());
        main.addView(btnBack, new LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT, dp(44)));

        root.addView(main);
        setContentView(root);
    }

    private void onSelectApk() {
        Intent intent = new Intent(Intent.ACTION_GET_CONTENT);
        intent.setType("application/vnd.android.package-archive");
        intent.addCategory(Intent.CATEGORY_OPENABLE);
        try {
            startActivityForResult(Intent.createChooser(intent, "Select APK to sign"), PICK_APK);
        } catch (Exception e) {
            intent.setType("*/*");
            startActivityForResult(intent, PICK_APK);
        }
    }

    private void onLoadKeystore() {
        Intent intent = new Intent(Intent.ACTION_GET_CONTENT);
        intent.setType("*/*");
        intent.addCategory(Intent.CATEGORY_OPENABLE);
        startActivityForResult(Intent.createChooser(intent, "Select keystore (.bks/.jks)"), PICK_KEYSTORE);
    }

    @Override
    protected void onActivityResult(int req, int res, Intent data) {
        super.onActivityResult(req, res, data);
        if (res != RESULT_OK || data == null) return;

        Uri uri = data.getData();
        if (uri == null) return;

        if (req == PICK_APK) {
            copyFileFromUri(uri, "sign_input.apk", f -> {
                selectedApk = f;
                mainHandler.post(() -> {
                    tvSelectedApk.setText(f.getName() + " (" + (f.length() / 1024) + " KB)");
                    tvSelectedApk.setTextColor(0xFF00E676);
                    btnSign.setEnabled(true);
                });
                log("✅ APK loaded: " + f.getName());
            });
        } else if (req == PICK_KEYSTORE) {
            loadKeystoreFromUri(uri);
        }
    }

    private void loadKeystoreFromUri(Uri uri) {
        new Thread(() -> {
            try {
                File ksFile = new File(getFilesDir(), "imported_keystore");
                InputStream is = getContentResolver().openInputStream(uri);
                FileOutputStream fos = new FileOutputStream(ksFile);
                byte[] buf = new byte[8192];
                int len;
                while ((len = is.read(buf)) > 0) fos.write(buf, 0, len);
                fos.close();
                is.close();

                String pass = etKeystorePass.getText().toString().trim();
                String alias = etAlias.getText().toString().trim();
                String keyPass = etKeyPass.getText().toString().trim();
                if (pass.isEmpty()) pass = "hspatch123";
                if (alias.isEmpty()) alias = "hspatch_key";
                if (keyPass.isEmpty()) keyPass = pass;

                // Try BKS first, then JKS
                KeyStore ks = null;
                for (String type : new String[]{"BKS", "JKS", "PKCS12"}) {
                    try {
                        ks = KeyStore.getInstance(type);
                        ks.load(new FileInputStream(ksFile), pass.toCharArray());
                        break;
                    } catch (Exception e) {
                        ks = null;
                    }
                }
                if (ks == null) {
                    log("❌ Could not load keystore (tried BKS/JKS/PKCS12)");
                    return;
                }

                PrivateKey pk = (PrivateKey) ks.getKey(alias, keyPass.toCharArray());
                Certificate cert = ks.getCertificate(alias);
                if (pk == null || cert == null) {
                    log("❌ Key/cert not found for alias: " + alias);
                    // List available aliases
                    Enumeration<String> aliases = ks.aliases();
                    StringBuilder sb = new StringBuilder("Available aliases: ");
                    while (aliases.hasMoreElements()) sb.append(aliases.nextElement()).append(", ");
                    log(sb.toString());
                    return;
                }

                savedKeyPair = new KeyPair(cert.getPublicKey(), pk);
                savedCert = (X509Certificate) cert;
                log("✅ Keystore loaded: alias=" + alias +
                    ", CN=" + savedCert.getSubjectDN().getName());
            } catch (Exception e) {
                log("❌ Keystore load error: " + e.getMessage());
            }
        }).start();
    }

    private void onSaveKeystore() {
        new Thread(() -> {
            try {
                log("💾 Generating keystore...");
                int keySize = Integer.parseInt(spinnerKeySize.getSelectedItem().toString());
                String cn = etCN.getText().toString().trim();
                String org = etOrg.getText().toString().trim();
                String country = etCountry.getText().toString().trim();
                String alias = etAlias.getText().toString().trim();
                String ksPass = etKeystorePass.getText().toString().trim();
                String keyPass = etKeyPass.getText().toString().trim();
                int validityYears = 25;
                try { validityYears = Integer.parseInt(etValidity.getText().toString().trim()); }
                catch (Exception e) { /* default */ }

                if (cn.isEmpty()) cn = "HSPatch Custom";
                if (org.isEmpty()) org = "HSPatch";
                if (country.isEmpty()) country = "US";
                if (alias.isEmpty()) alias = "hspatch_key";
                if (ksPass.isEmpty()) ksPass = "hspatch123";
                if (keyPass.isEmpty()) keyPass = ksPass;

                // Generate key pair
                KeyPairGenerator kpg = KeyPairGenerator.getInstance("RSA");
                kpg.initialize(keySize);
                KeyPair kp = kpg.generateKeyPair();

                X500Principal subject = new X500Principal(
                    "CN=" + cn + ", O=" + org + ", C=" + country);
                long now = System.currentTimeMillis();
                byte[] certDer = CertBuilder.buildSelfSigned(
                    kp.getPublic(), kp.getPrivate(), subject,
                    new Date(now),
                    new Date(now + (long) validityYears * 365 * 24 * 60 * 60 * 1000));

                CertificateFactory cf = CertificateFactory.getInstance("X.509");
                X509Certificate cert = (X509Certificate) cf.generateCertificate(
                    new ByteArrayInputStream(certDer));

                // Save as BKS keystore
                KeyStore ks = KeyStore.getInstance("BKS", "BC");
                ks.load(null, ksPass.toCharArray());
                ks.setKeyEntry(alias, kp.getPrivate(), keyPass.toCharArray(),
                    new Certificate[]{cert});

                File downloads = Environment.getExternalStoragePublicDirectory(
                    Environment.DIRECTORY_DOWNLOADS);
                String timestamp = new SimpleDateFormat("yyyyMMdd_HHmmss", Locale.US).format(new Date());
                File ksFile = new File(downloads, "hspatch_keystore_" + timestamp + ".bks");
                ks.store(new FileOutputStream(ksFile), ksPass.toCharArray());

                savedKeyPair = kp;
                savedCert = cert;

                log("✅ Keystore saved: " + ksFile.getAbsolutePath());
                log("   CN=" + cn + ", O=" + org + ", Key=" + keySize + "-bit RSA");
                log("   Validity: " + validityYears + " years");
            } catch (Exception e) {
                log("❌ Keystore save error: " + e.getMessage());
                // BKS provider might not be available, try raw cert save instead
                saveRawKeystore(e);
            }
        }).start();
    }

    private void saveRawKeystore(Exception originalError) {
        try {
            log("↪ Fallback: saving as PKCS12 keystore...");
            int keySize = Integer.parseInt(spinnerKeySize.getSelectedItem().toString());
            String cn = etCN.getText().toString().trim();
            String org = etOrg.getText().toString().trim();
            String country = etCountry.getText().toString().trim();
            String alias = etAlias.getText().toString().trim();
            String ksPass = etKeystorePass.getText().toString().trim();
            String keyPass = etKeyPass.getText().toString().trim();
            int validityYears = 25;
            try { validityYears = Integer.parseInt(etValidity.getText().toString().trim()); }
            catch (Exception e) { /* default */ }

            if (cn.isEmpty()) cn = "HSPatch Custom";
            if (org.isEmpty()) org = "HSPatch";
            if (country.isEmpty()) country = "US";
            if (alias.isEmpty()) alias = "hspatch_key";
            if (ksPass.isEmpty()) ksPass = "hspatch123";
            if (keyPass.isEmpty()) keyPass = ksPass;

            KeyPairGenerator kpg = KeyPairGenerator.getInstance("RSA");
            kpg.initialize(keySize);
            KeyPair kp = kpg.generateKeyPair();

            X500Principal subject = new X500Principal(
                "CN=" + cn + ", O=" + org + ", C=" + country);
            long now = System.currentTimeMillis();
            byte[] certDer = CertBuilder.buildSelfSigned(
                kp.getPublic(), kp.getPrivate(), subject,
                new Date(now),
                new Date(now + (long) validityYears * 365 * 24 * 60 * 60 * 1000));

            CertificateFactory cf = CertificateFactory.getInstance("X.509");
            X509Certificate cert = (X509Certificate) cf.generateCertificate(
                new ByteArrayInputStream(certDer));

            // Use PKCS12 which is available on all Android versions
            KeyStore ks = KeyStore.getInstance("PKCS12");
            ks.load(null, ksPass.toCharArray());
            ks.setKeyEntry(alias, kp.getPrivate(), keyPass.toCharArray(),
                new Certificate[]{cert});

            File downloads = Environment.getExternalStoragePublicDirectory(
                Environment.DIRECTORY_DOWNLOADS);
            String timestamp = new SimpleDateFormat("yyyyMMdd_HHmmss", Locale.US).format(new Date());
            File ksFile = new File(downloads, "hspatch_keystore_" + timestamp + ".p12");
            ks.store(new FileOutputStream(ksFile), ksPass.toCharArray());

            savedKeyPair = kp;
            savedCert = cert;

            log("✅ PKCS12 Keystore saved: " + ksFile.getAbsolutePath());
            log("   CN=" + cn + ", O=" + org + ", Key=" + keySize + "-bit RSA");
        } catch (Exception e2) {
            log("❌ Fallback save also failed: " + e2.getMessage());
        }
    }

    private void onSignClick() {
        if (isSigning || selectedApk == null) return;
        isSigning = true;
        btnSign.setEnabled(false);
        btnSelectApk.setEnabled(false);
        progressBar.setVisibility(View.VISIBLE);
        progressBar.setProgress(0);

        new Thread(() -> {
            try {
                log("\n🔐 Starting APK signing...");
                log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

                KeyPair kp;
                X509Certificate cert;

                if (savedKeyPair != null && savedCert != null) {
                    log("🔑 Using saved/imported keystore");
                    kp = savedKeyPair;
                    cert = savedCert;
                } else {
                    log("🔑 Generating new signing certificate...");
                    String cn = etCN.getText().toString().trim();
                    String org = etOrg.getText().toString().trim();
                    String country = etCountry.getText().toString().trim();
                    int keySize = Integer.parseInt(spinnerKeySize.getSelectedItem().toString());
                    int validityYears = 25;
                    try { validityYears = Integer.parseInt(etValidity.getText().toString().trim()); }
                    catch (Exception e) { /* default */ }

                    if (cn.isEmpty()) cn = "HSPatch Custom";
                    if (org.isEmpty()) org = "HSPatch";
                    if (country.isEmpty()) country = "US";

                    updateProgress(10);
                    KeyPairGenerator kpg = KeyPairGenerator.getInstance("RSA");
                    kpg.initialize(keySize);
                    kp = kpg.generateKeyPair();
                    log("   Generated " + keySize + "-bit RSA key pair");

                    updateProgress(20);
                    X500Principal subject = new X500Principal(
                        "CN=" + cn + ", O=" + org + ", C=" + country);
                    long now = System.currentTimeMillis();
                    byte[] certDer = CertBuilder.buildSelfSigned(
                        kp.getPublic(), kp.getPrivate(), subject,
                        new Date(now),
                        new Date(now + (long) validityYears * 365 * 24 * 60 * 60 * 1000));

                    CertificateFactory cf = CertificateFactory.getInstance("X.509");
                    cert = (X509Certificate) cf.generateCertificate(
                        new ByteArrayInputStream(certDer));
                    log("   Certificate: CN=" + cn + ", O=" + org + ", C=" + country);
                    log("   Validity: " + validityYears + " years");
                }

                updateProgress(30);
                log("📦 Configuring signer...");
                boolean v1 = cbV1.isChecked();
                boolean v2 = cbV2.isChecked();
                boolean v3 = cbV3.isChecked();
                log("   Schemes: " + (v1 ? "v1 " : "") + (v2 ? "v2 " : "") + (v3 ? "v3" : ""));

                com.android.apksig.ApkSigner.SignerConfig signerConfig =
                    new com.android.apksig.ApkSigner.SignerConfig.Builder(
                        "CERT", kp.getPrivate(), Collections.singletonList(cert)
                    ).build();

                File downloads = Environment.getExternalStoragePublicDirectory(
                    Environment.DIRECTORY_DOWNLOADS);
                String timestamp = new SimpleDateFormat("HHmmss", Locale.US).format(new Date());
                String baseName = selectedApk.getName().replaceAll("\\.[^.]+$", "");
                File signedApk = new File(downloads, baseName + "_signed_" + timestamp + ".apk");

                updateProgress(50);
                log("🔑 Signing APK...");

                com.android.apksig.ApkSigner signer = new com.android.apksig.ApkSigner.Builder(
                        Collections.singletonList(signerConfig))
                    .setInputApk(selectedApk)
                    .setOutputApk(signedApk)
                    .setV1SigningEnabled(v1)
                    .setV2SigningEnabled(v2)
                    .setV3SigningEnabled(v3)
                    .setV4SigningEnabled(false)
                    .setCreatedBy("HSPatcher APK Signer")
                    .build();

                signer.sign();

                updateProgress(100);
                log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
                log("✅ APK signed successfully!");
                log("📁 Output: " + signedApk.getAbsolutePath());
                log("📏 Size: " + (signedApk.length() / 1024) + " KB");

                mainHandler.post(() -> {
                    Toast.makeText(this, "Signed APK saved to Downloads",
                        Toast.LENGTH_LONG).show();
                });
            } catch (Exception e) {
                log("❌ Signing failed: " + e.getMessage());
                for (StackTraceElement st : e.getStackTrace()) {
                    log("   " + st.toString());
                }
            } finally {
                mainHandler.post(() -> {
                    isSigning = false;
                    btnSign.setEnabled(selectedApk != null);
                    btnSelectApk.setEnabled(true);
                    progressBar.setVisibility(View.GONE);
                });
            }
        }).start();
    }

    private void copyFileFromUri(Uri uri, String destName, FileCallback cb) {
        new Thread(() -> {
            try {
                File dest = new File(getFilesDir(), destName);
                InputStream is = getContentResolver().openInputStream(uri);
                FileOutputStream fos = new FileOutputStream(dest);
                byte[] buf = new byte[65536];
                int len;
                while ((len = is.read(buf)) > 0) fos.write(buf, 0, len);
                fos.close();
                is.close();
                cb.onFile(dest);
            } catch (Exception e) {
                log("❌ Error: " + e.getMessage());
            }
        }).start();
    }

    private void log(String msg) {
        Log.d(TAG, msg);
        mainHandler.post(() -> {
            tvLog.append(msg + "\n");
            logScroll.post(() -> logScroll.fullScroll(View.FOCUS_DOWN));
        });
    }

    private void updateProgress(int pct) {
        mainHandler.post(() -> progressBar.setProgress(pct));
    }

    // --- UI helpers ---
    private int dp(int dp) {
        return (int) (dp * getResources().getDisplayMetrics().density);
    }

    private TextView sectionLabel(String text) {
        TextView tv = new TextView(this);
        tv.setText(text);
        tv.setTextSize(14);
        tv.setTextColor(0xFF448AFF);
        tv.setTypeface(null, android.graphics.Typeface.BOLD);
        tv.setPadding(0, dp(16), 0, dp(6));
        return tv;
    }

    private LinearLayout hRow() {
        LinearLayout row = new LinearLayout(this);
        row.setOrientation(LinearLayout.HORIZONTAL);
        row.setPadding(0, dp(4), 0, dp(4));
        return row;
    }

    private EditText addLabeledInput(LinearLayout row, String label, String hint) {
        LinearLayout col = new LinearLayout(this);
        col.setOrientation(LinearLayout.VERTICAL);
        col.setLayoutParams(new LinearLayout.LayoutParams(0,
            LinearLayout.LayoutParams.WRAP_CONTENT, 1));
        col.setPadding(dp(4), 0, dp(4), 0);

        TextView lbl = new TextView(this);
        lbl.setText(label);
        lbl.setTextSize(12);
        lbl.setTextColor(getColor(R.color.hsp_text_muted));
        col.addView(lbl);

        EditText et = new EditText(this);
        et.setHint(hint);
        et.setText(hint);
        et.setTextSize(14);
        et.setTextColor(getColor(R.color.hsp_text));
        et.setHintTextColor(getColor(R.color.hsp_text_faint));
        et.setBackgroundResource(R.drawable.bg_glass_input);
        et.setPadding(dp(8), dp(6), dp(8), dp(6));
        et.setSingleLine(true);
        col.addView(et);

        row.addView(col);
        return et;
    }

    private Button makeButton(String text, int bgColor) {
        Button btn = new Button(this);
        btn.setText(text);
        btn.setTextColor(getColor(R.color.hsp_text));
        btn.setTextSize(13);
        btn.setTypeface(null, android.graphics.Typeface.BOLD);
        btn.setBackground(makeGlassButtonBackground(bgColor));
        try {
            btn.setStateListAnimator(AnimatorInflater.loadStateListAnimator(this, R.xml.press_scale));
        } catch (Throwable ignored) {}
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT, dp(44));
        lp.topMargin = dp(6);
        btn.setLayoutParams(lp);
        return btn;
    }

    private Drawable makeGlassButtonBackground(int solidColor) {
        float r = dp(14);

        GradientDrawable base = new GradientDrawable();
        base.setColor(solidColor);
        base.setCornerRadius(r);
        base.setStroke(dp(1), getColor(R.color.hsp_glass_stroke));

        GradientDrawable gloss = new GradientDrawable(
            GradientDrawable.Orientation.TOP_BOTTOM,
            new int[]{getColor(R.color.hsp_glass_highlight), 0x00FFFFFF});
        gloss.setCornerRadius(r);

        LayerDrawable layers = new LayerDrawable(new Drawable[]{base, gloss});

        return new RippleDrawable(
            ColorStateList.valueOf(getColor(R.color.hsp_ripple)),
            layers,
            null
        );
    }

    private CheckBox makeCheckbox(String text, boolean checked) {
        CheckBox cb = new CheckBox(this);
        cb.setText(text);
        cb.setChecked(checked);
        cb.setTextSize(13);
        cb.setTextColor(getColor(R.color.hsp_text));
        try {
            cb.setButtonTintList(ColorStateList.valueOf(getColor(R.color.hsp_accent_green)));
        } catch (Throwable ignored) {}
        cb.setLayoutParams(new LinearLayout.LayoutParams(0,
            LinearLayout.LayoutParams.WRAP_CONTENT, 1));
        return cb;
    }

    interface FileCallback {
        void onFile(File f);
    }
}
