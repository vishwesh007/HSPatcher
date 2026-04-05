package in.startv.hspatcher;

import android.content.Context;

import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.security.KeyPair;
import java.security.KeyPairGenerator;
import java.security.KeyStore;
import java.security.PrivateKey;
import java.security.cert.Certificate;
import java.security.cert.CertificateFactory;
import java.security.cert.X509Certificate;
import java.util.Collections;
import java.util.Date;

import javax.security.auth.x500.X500Principal;

final class ApkSigningUtil {

    interface Logger {
        void log(String msg);
    }

    private static final String KS_TYPE = "PKCS12";
    private static final String KS_FILE = "hspatcher_sign.p12";
    private static final String LEGACY_KS_FILE = "hspatcher_sign.jks";
    private static final String KS_PASS = "hspatcher123";
    private static final String KS_ALIAS = "hspatcher";

    private ApkSigningUtil() {
    }

    static void signApk(Context context, File unsignedApk, File signedApk, Logger logger) throws Exception {
        KeyStore keyStore = getOrCreateKeyStore(context, logger);
        PrivateKey privateKey = (PrivateKey) keyStore.getKey(KS_ALIAS, KS_PASS.toCharArray());
        Certificate[] chain = keyStore.getCertificateChain(KS_ALIAS);
        if (privateKey == null || chain == null || chain.length == 0) {
            throw new IllegalStateException("Persistent signing key is unavailable");
        }

        X509Certificate certificate = (X509Certificate) chain[0];
        com.android.apksig.ApkSigner.SignerConfig signerConfig =
            new com.android.apksig.ApkSigner.SignerConfig.Builder(
                "HSPatcher", privateKey, Collections.singletonList(certificate)
            ).build();

        com.android.apksig.ApkSigner signer = new com.android.apksig.ApkSigner.Builder(
                Collections.singletonList(signerConfig))
            .setInputApk(unsignedApk)
            .setOutputApk(signedApk)
            .setV1SigningEnabled(true)
            .setV2SigningEnabled(true)
            .setV3SigningEnabled(true)
            .setV4SigningEnabled(false)
            .setCreatedBy("HSPatcher APK Editor")
            .build();

        signer.sign();
        if (logger != null) {
            logger.log("🔐 Signed APK: " + signedApk.getAbsolutePath());
        }
    }

    private static KeyStore getOrCreateKeyStore(Context context, Logger logger) throws Exception {
        File filesDir = context.getFilesDir();
        File keyStoreFile = new File(filesDir, KS_FILE);
        if (keyStoreFile.exists()) {
            KeyStore keyStore = KeyStore.getInstance(KS_TYPE);
            try (FileInputStream fis = new FileInputStream(keyStoreFile)) {
                keyStore.load(fis, KS_PASS.toCharArray());
            }
            if (logger != null) {
                logger.log("🔑 Using persistent signing key: " + keyStoreFile.getName());
            }
            return keyStore;
        }

        File legacyKeyStoreFile = new File(filesDir, LEGACY_KS_FILE);
        if (legacyKeyStoreFile.exists()) {
            try {
                KeyStore legacy = KeyStore.getInstance("JKS");
                try (FileInputStream fis = new FileInputStream(legacyKeyStoreFile)) {
                    legacy.load(fis, KS_PASS.toCharArray());
                }

                PrivateKey privateKey = (PrivateKey) legacy.getKey(KS_ALIAS, KS_PASS.toCharArray());
                Certificate[] chain = legacy.getCertificateChain(KS_ALIAS);
                if (privateKey == null || chain == null || chain.length == 0) {
                    throw new IllegalStateException("Legacy signing key is missing alias " + KS_ALIAS);
                }

                KeyStore migrated = KeyStore.getInstance(KS_TYPE);
                migrated.load(null, KS_PASS.toCharArray());
                migrated.setKeyEntry(KS_ALIAS, privateKey, KS_PASS.toCharArray(), chain);
                try (FileOutputStream fos = new FileOutputStream(keyStoreFile)) {
                    migrated.store(fos, KS_PASS.toCharArray());
                }
                if (logger != null) {
                    logger.log("🔁 Migrated persistent signing key: " + keyStoreFile.getName());
                }
                return migrated;
            } catch (Exception e) {
                throw new IllegalStateException(
                    "Legacy signing keystore exists but could not be migrated.", e);
            }
        }

        KeyStore created = KeyStore.getInstance(KS_TYPE);
        created.load(null, KS_PASS.toCharArray());

        KeyPairGenerator keyPairGenerator = KeyPairGenerator.getInstance("RSA");
        keyPairGenerator.initialize(2048);
        KeyPair keyPair = keyPairGenerator.generateKeyPair();

        X500Principal subject = new X500Principal("CN=HSPatcher, OU=APK Editor, O=HSPatcher, C=IN");
        long now = System.currentTimeMillis();
        byte[] certDer = CertBuilder.buildSelfSigned(
            keyPair.getPublic(),
            keyPair.getPrivate(),
            subject,
            new Date(now),
            new Date(now + 365L * 24L * 60L * 60L * 1000L * 100L)
        );

        CertificateFactory factory = CertificateFactory.getInstance("X.509");
        X509Certificate certificate = (X509Certificate) factory.generateCertificate(
            new ByteArrayInputStream(certDer));
        created.setKeyEntry(KS_ALIAS, keyPair.getPrivate(), KS_PASS.toCharArray(),
            new Certificate[]{certificate});

        try (FileOutputStream fos = new FileOutputStream(keyStoreFile)) {
            created.store(fos, KS_PASS.toCharArray());
        }
        if (logger != null) {
            logger.log("🔑 Created persistent signing key: " + keyStoreFile.getName());
        }
        return created;
    }
}