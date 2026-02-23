.class public Lin/startv/hotstar/SSLBypass;
.super Ljava/lang/Object;
.source "SSLBypass.java"


# direct methods
.method public constructor <init>()V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    return-void
.end method


# ================================================================
# init() - Call from Application.onCreate to disable SSL pinning
# Installs a TrustAll TrustManager + permissive HostnameVerifier
# ================================================================
.method public static init(Landroid/content/Context;)V
    .locals 6

    const-string v5, "HSPatch"

    # ===== Step 1: Create TrustAll TrustManager array =====
    :try_start_ssl
    const/4 v0, 0x1
    new-array v0, v0, [Ljavax/net/ssl/TrustManager;

    new-instance v1, Lin/startv/hotstar/SSLBypass$TrustAll;
    invoke-direct {v1}, Lin/startv/hotstar/SSLBypass$TrustAll;-><init>()V

    const/4 v2, 0x0
    aput-object v1, v0, v2

    # ===== Step 2: Init SSLContext with TrustAll =====
    const-string v1, "TLS"
    invoke-static {v1}, Ljavax/net/ssl/SSLContext;->getInstance(Ljava/lang/String;)Ljavax/net/ssl/SSLContext;
    move-result-object v1

    new-instance v2, Ljava/security/SecureRandom;
    invoke-direct {v2}, Ljava/security/SecureRandom;-><init>()V

    const/4 v3, 0x0
    invoke-virtual {v1, v3, v0, v2}, Ljavax/net/ssl/SSLContext;->init([Ljavax/net/ssl/KeyManager;[Ljavax/net/ssl/TrustManager;Ljava/security/SecureRandom;)V

    # ===== Step 3: Set as default SSLContext =====
    invoke-static {v1}, Ljavax/net/ssl/SSLContext;->setDefault(Ljavax/net/ssl/SSLContext;)V

    # ===== Step 4: Set default SSLSocketFactory for HttpsURLConnection =====
    invoke-virtual {v1}, Ljavax/net/ssl/SSLContext;->getSocketFactory()Ljavax/net/ssl/SSLSocketFactory;
    move-result-object v2
    invoke-static {v2}, Ljavax/net/ssl/HttpsURLConnection;->setDefaultSSLSocketFactory(Ljavax/net/ssl/SSLSocketFactory;)V

    # ===== Step 5: Set permissive HostnameVerifier =====
    new-instance v3, Lin/startv/hotstar/SSLBypass$AllHostnames;
    invoke-direct {v3}, Lin/startv/hotstar/SSLBypass$AllHostnames;-><init>()V

    invoke-static {v3}, Ljavax/net/ssl/HttpsURLConnection;->setDefaultHostnameVerifier(Ljavax/net/ssl/HostnameVerifier;)V

    const-string v4, "SSL pinning bypass installed (TrustAll + AllHostnames)"
    invoke-static {v5, v4}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    :try_end_ssl
    .catchall {:try_start_ssl .. :try_end_ssl} :catch_ssl
    goto :after_ssl

    :catch_ssl
    move-exception v0
    invoke-virtual {v0}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;
    move-result-object v0

    new-instance v1, Ljava/lang/StringBuilder;
    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V
    const-string v2, "SSL bypass error: "
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    invoke-static {v5, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    :after_ssl
    return-void
.end method
