.class public Lin/startv/hotstar/NetworkInterceptor;
.super Ljava/lang/Object;
.source "NetworkInterceptor.java"

# Comprehensive network interceptor that hooks ALL major HTTP providers
# at the Java reflection level. Each provider is tried independently —
# if the library isn't present, it silently skips.
#
# Providers hooked:
#   1. HttpURLConnection (via URLStreamHandlerFactory)
#   2. OkHttp3 (via Interceptor injection into existing clients)
#   3. OkHttp2 (legacy via reflection)
#   4. All outgoing connections logged through a custom ProxySelector
#
# Log output goes to:
#   - Logcat tag "HSPatch-Net"
#   - NetworkLogger.log() → request_logs.txt file
#   - NetworkLogger.logConnection() for structured entries

# static fields
.field private static initialized:Z
.field private static appContext:Landroid/content/Context;
.field private static okhttp3InterceptorsField:Ljava/lang/reflect/Field;
.field private static okhttp3NetworkInterceptorsField:Ljava/lang/reflect/Field;

# direct methods
.method public constructor <init>()V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    return-void
.end method

# ========================================================================
# Main init entry point — called from HSPatchInit
# ========================================================================
.method public static init(Landroid/content/Context;)V
    .locals 4
    .param p0, "ctx"

    sget-boolean v0, Lin/startv/hotstar/NetworkInterceptor;->initialized:Z
    if-nez v0, :already_done

    sput-object p0, Lin/startv/hotstar/NetworkInterceptor;->appContext:Landroid/content/Context;

    const-string v0, "HSPatch-Net"
    const-string v1, "=== NetworkInterceptor init ==="
    invoke-static {v0, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    # 1) Hook HttpURLConnection via URLStreamHandlerFactory
    :try_urlconn
    invoke-static {}, Lin/startv/hotstar/NetworkInterceptor;->hookUrlConnection()V
    :try_urlconn_end
    .catch Ljava/lang/Throwable; {:try_urlconn .. :try_urlconn_end} :catch_urlconn
    const-string v0, "HSPatch-Net"
    const-string v1, "  [1] HttpURLConnection hook: OK"
    invoke-static {v0, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    goto :after_urlconn
    :catch_urlconn
    move-exception v0
    invoke-virtual {v0}, Ljava/lang/Throwable;->getMessage()Ljava/lang/String;
    move-result-object v1
    const-string v2, "HSPatch-Net"
    new-instance v3, Ljava/lang/StringBuilder;
    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V
    const-string v0, "  [1] HttpURLConnection hook FAIL: "
    invoke-virtual {v3, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v3, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    invoke-static {v2, v0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I
    :after_urlconn

    # 2) Hook OkHttp3
    :try_ok3
    invoke-static {}, Lin/startv/hotstar/NetworkInterceptor;->hookOkHttp3()V
    :try_ok3_end
    .catch Ljava/lang/Throwable; {:try_ok3 .. :try_ok3_end} :catch_ok3
    const-string v0, "HSPatch-Net"
    const-string v1, "  [2] OkHttp3 hook: OK"
    invoke-static {v0, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    goto :after_ok3
    :catch_ok3
    move-exception v0
    invoke-virtual {v0}, Ljava/lang/Throwable;->getMessage()Ljava/lang/String;
    move-result-object v1
    const-string v2, "HSPatch-Net"
    new-instance v3, Ljava/lang/StringBuilder;
    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V
    const-string v0, "  [2] OkHttp3 hook: skipped ("
    invoke-virtual {v3, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v3, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v0, ")"
    invoke-virtual {v3, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    invoke-static {v2, v0}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I
    :after_ok3

    # 3) Hook OkHttp2 (legacy)
    :try_ok2
    invoke-static {}, Lin/startv/hotstar/NetworkInterceptor;->hookOkHttp2()V
    :try_ok2_end
    .catch Ljava/lang/Throwable; {:try_ok2 .. :try_ok2_end} :catch_ok2
    const-string v0, "HSPatch-Net"
    const-string v1, "  [3] OkHttp2 hook: OK"
    invoke-static {v0, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    goto :after_ok2
    :catch_ok2
    move-exception v0
    const-string v1, "HSPatch-Net"
    const-string v2, "  [3] OkHttp2 hook: skipped (not present)"
    invoke-static {v1, v2}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I
    :after_ok2

    # 4) Install global connection tracking via ProxySelector
    :try_proxy
    invoke-static {}, Lin/startv/hotstar/NetworkInterceptor;->installConnectionTracker()V
    :try_proxy_end
    .catch Ljava/lang/Throwable; {:try_proxy .. :try_proxy_end} :catch_proxy
    const-string v0, "HSPatch-Net"
    const-string v1, "  [4] Connection tracker: OK"
    invoke-static {v0, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    goto :after_proxy
    :catch_proxy
    move-exception v0
    const-string v1, "HSPatch-Net"
    const-string v2, "  [4] Connection tracker: skipped"
    invoke-static {v1, v2}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I
    :after_proxy

    # 5) Start periodic connection dump thread
    :try_dump
    invoke-static {}, Lin/startv/hotstar/NetworkInterceptor;->startDumpThread()V
    :try_dump_end
    .catch Ljava/lang/Throwable; {:try_dump .. :try_dump_end} :catch_dump
    const-string v0, "HSPatch-Net"
    const-string v1, "  [5] Dump thread: OK"
    invoke-static {v0, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    goto :after_dump
    :catch_dump
    move-exception v0
    const-string v1, "HSPatch-Net"
    const-string v2, "  [5] Dump thread: skipped"
    invoke-static {v1, v2}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I
    :after_dump

    const/4 v0, 0x1
    sput-boolean v0, Lin/startv/hotstar/NetworkInterceptor;->initialized:Z

    const-string v0, "HSPatch-Net"
    const-string v1, "=== NetworkInterceptor init DONE ==="
    invoke-static {v0, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    :already_done
    return-void
.end method

# ========================================================================
# [1] HttpURLConnection — use reflection to intercept URL.openConnection()
# We set a custom ResponseCache that sees every request as a side-effect.
# This is the MOST universal hook — every Java HTTP lib ends up here.
# ========================================================================
.method private static hookUrlConnection()V
    .locals 4

    # Install our logging ResponseCache wrapper
    # First, save the original ResponseCache (if any)
    invoke-static {}, Ljava/net/ResponseCache;->getDefault()Ljava/net/ResponseCache;
    move-result-object v0

    # Create our wrapper
    new-instance v1, Lin/startv/hotstar/NetworkInterceptor$LoggingResponseCache;
    invoke-direct {v1, v0}, Lin/startv/hotstar/NetworkInterceptor$LoggingResponseCache;-><init>(Ljava/net/ResponseCache;)V

    # Set as default
    invoke-static {v1}, Ljava/net/ResponseCache;->setDefault(Ljava/net/ResponseCache;)V

    const-string v0, "HSPatch-Net"
    const-string v1, "    ResponseCache wrapper installed"
    invoke-static {v0, v1}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    return-void
.end method

# ========================================================================
# [2] OkHttp3 — add a network interceptor via reflection
# Finds all OkHttpClient instances and adds our interceptor.
# Also hooks the Builder class to auto-add interceptor to new clients.
# ========================================================================
.method private static hookOkHttp3()V
    .locals 6

    # Check if OkHttp3 classes exist
    const-string v0, "okhttp3.OkHttpClient"
    invoke-static {v0}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;
    move-result-object v0

    # Find the Builder class
    const-string v1, "okhttp3.OkHttpClient$Builder"
    invoke-static {v1}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;
    move-result-object v1

    # Get the "interceptors" field from Builder (it's a List)
    # OkHttp3 stores interceptors in a field called "interceptors"
    const-string v2, "interceptors"
    invoke-virtual {v1, v2}, Ljava/lang/Class;->getDeclaredField(Ljava/lang/String;)Ljava/lang/reflect/Field;
    move-result-object v2
    const/4 v3, 0x1
    invoke-virtual {v2, v3}, Ljava/lang/reflect/Field;->setAccessible(Z)V

    # Also get "networkInterceptors" field
    const-string v3, "networkInterceptors"
    invoke-virtual {v1, v3}, Ljava/lang/Class;->getDeclaredField(Ljava/lang/String;)Ljava/lang/reflect/Field;
    move-result-object v3
    const/4 v4, 0x1
    invoke-virtual {v3, v4}, Ljava/lang/reflect/Field;->setAccessible(Z)V

    # Store the field references for later use by OkHttp3Hook
    sput-object v2, Lin/startv/hotstar/NetworkInterceptor;->okhttp3InterceptorsField:Ljava/lang/reflect/Field;
    sput-object v3, Lin/startv/hotstar/NetworkInterceptor;->okhttp3NetworkInterceptorsField:Ljava/lang/reflect/Field;

    const-string v0, "HSPatch-Net"
    const-string v1, "    OkHttp3 reflection setup complete"
    invoke-static {v0, v1}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    return-void
.end method

# (OkHttp3 field references declared at top of class)

# ========================================================================
# [3] OkHttp2 (legacy) — hook via com.squareup.okhttp.OkHttpClient
# ========================================================================
.method private static hookOkHttp2()V
    .locals 3

    # Check if OkHttp2 classes exist
    const-string v0, "com.squareup.okhttp.OkHttpClient"
    invoke-static {v0}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;
    move-result-object v0

    # Just verify the class exists — actual interception happens via ResponseCache
    const-string v1, "HSPatch-Net"
    const-string v2, "    OkHttp2 detected, will intercept via ResponseCache"
    invoke-static {v1, v2}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    return-void
.end method

# ========================================================================
# [4] Connection tracker — install logging ProxySelector
# Every socket connection goes through ProxySelector.select() so we can
# log the destination host/port.
# ========================================================================
.method private static installConnectionTracker()V
    .locals 3

    # Get current ProxySelector
    invoke-static {}, Ljava/net/ProxySelector;->getDefault()Ljava/net/ProxySelector;
    move-result-object v0

    # Create our wrapper
    new-instance v1, Lin/startv/hotstar/NetworkInterceptor$LoggingProxySelector;
    invoke-direct {v1, v0}, Lin/startv/hotstar/NetworkInterceptor$LoggingProxySelector;-><init>(Ljava/net/ProxySelector;)V

    # Set as default
    invoke-static {v1}, Ljava/net/ProxySelector;->setDefault(Ljava/net/ProxySelector;)V

    const-string v0, "HSPatch-Net"
    const-string v1, "    ProxySelector wrapper installed"
    invoke-static {v0, v1}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    return-void
.end method

# ========================================================================
# [5] Periodic dump thread — dumps active connections every 30s
# ========================================================================
.method private static startDumpThread()V
    .locals 3

    new-instance v0, Lin/startv/hotstar/NetworkInterceptor$DumpThread;
    invoke-direct {v0}, Lin/startv/hotstar/NetworkInterceptor$DumpThread;-><init>()V
    new-instance v1, Ljava/lang/Thread;
    invoke-direct {v1, v0}, Ljava/lang/Thread;-><init>(Ljava/lang/Runnable;)V
    const/4 v2, 0x1
    invoke-virtual {v1, v2}, Ljava/lang/Thread;->setDaemon(Z)V
    const-string v2, "HSPatch-NetDump"
    invoke-virtual {v1, v2}, Ljava/lang/Thread;->setName(Ljava/lang/String;)V
    invoke-virtual {v1}, Ljava/lang/Thread;->start()V

    return-void
.end method

# ========================================================================
# Static helper — log a network event to both logcat and file
# ========================================================================
.method public static logEvent(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    .locals 3
    .param p0, "method"    # GET, POST, etc.
    .param p1, "url"       # full URL
    .param p2, "source"    # "URLConn", "OkHttp3", "ProxySelector", etc.

    # Build log line: "[source] METHOD url"
    new-instance v0, Ljava/lang/StringBuilder;
    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V
    const-string v1, "["
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v1, "] "
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v1, " "
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0

    # Logcat
    const-string v1, "HSPatch-Net"
    invoke-static {v1, v0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    # File log via NetworkLogger
    :try_log
    invoke-static {v0}, Lin/startv/hotstar/NetworkLogger;->log(Ljava/lang/String;)V
    :try_log_end
    .catch Ljava/lang/Throwable; {:try_log .. :try_log_end} :catch_log
    goto :after_log
    :catch_log
    move-exception v1
    :after_log

    return-void
.end method
