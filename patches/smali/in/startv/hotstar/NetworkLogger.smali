.class public Lin/startv/hotstar/NetworkLogger;
.super Ljava/lang/Object;
.source "NetworkLogger.java"

# ================================================================
# NetworkLogger - Pure Java/smali network request logger
# Works independently of Frida by hooking URLStreamHandlerFactory
# and wrapping the default SSLSocketFactory
# ================================================================

# static fields
.field private static logDir:Ljava/lang/String;
.field private static initialized:Z


# direct methods
.method public constructor <init>()V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    return-void
.end method


# ================================================================
# init(Context) - Initialize the network logger
# ================================================================
.method public static init(Landroid/content/Context;)V
    .locals 4

    const-string v3, "HSPatch"

    # Check if already initialized
    sget-boolean v0, Lin/startv/hotstar/NetworkLogger;->initialized:Z
    if-nez v0, :already_init

    # Get the app's external files dir for logs
    :try_start_init
    const/4 v0, 0x0
    invoke-virtual {p0, v0}, Landroid/content/Context;->getExternalFilesDir(Ljava/lang/String;)Ljava/io/File;
    move-result-object v0

    if-eqz v0, :use_default_dir

    invoke-virtual {v0}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;
    move-result-object v0

    new-instance v1, Ljava/lang/StringBuilder;
    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v2, "/"
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0

    sput-object v0, Lin/startv/hotstar/NetworkLogger;->logDir:Ljava/lang/String;
    goto :dir_set

    :use_default_dir
    sget-object v0, Lin/startv/hotstar/HSPatchConfig;->filesDir:Ljava/lang/String;
    if-nez v0, :use_config_dir
    const-string v0, "/storage/emulated/0/Download/hspatch_logs/"
    goto :set_fallback_dir
    :use_config_dir
    new-instance v1, Ljava/lang/StringBuilder;
    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v2, "/"
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    :set_fallback_dir
    sput-object v0, Lin/startv/hotstar/NetworkLogger;->logDir:Ljava/lang/String;

    :dir_set

    # Ensure log directory exists
    sget-object v0, Lin/startv/hotstar/NetworkLogger;->logDir:Ljava/lang/String;
    new-instance v1, Ljava/io/File;
    invoke-direct {v1, v0}, Ljava/io/File;-><init>(Ljava/lang/String;)V
    invoke-virtual {v1}, Ljava/io/File;->mkdirs()Z

    # Write initial log entry
    const-string v0, "========== NETWORK LOGGER STARTED =========="
    invoke-static {v0}, Lin/startv/hotstar/NetworkLogger;->log(Ljava/lang/String;)V

    # Start the periodic log flusher thread
    invoke-static {p0}, Lin/startv/hotstar/NetworkLogger;->startMonitor(Landroid/content/Context;)V

    const/4 v0, 0x1
    sput-boolean v0, Lin/startv/hotstar/NetworkLogger;->initialized:Z

    const-string v0, "NetworkLogger initialized"
    invoke-static {v3, v0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    :try_end_init
    .catchall {:try_start_init .. :try_end_init} :catch_init
    goto :after_init

    :catch_init
    move-exception v0
    invoke-virtual {v0}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;
    move-result-object v0

    new-instance v1, Ljava/lang/StringBuilder;
    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V
    const-string v2, "NetworkLogger init error: "
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    invoke-static {v3, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    :after_init
    :already_init
    return-void
.end method


# ================================================================
# log(String) - Write to request_logs.txt
# ================================================================
.method public static log(Ljava/lang/String;)V
    .locals 5

    :try_start_log
    sget-object v0, Lin/startv/hotstar/NetworkLogger;->logDir:Ljava/lang/String;
    if-eqz v0, :skip_log

    new-instance v1, Ljava/lang/StringBuilder;
    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v2, "request_logs.txt"
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0

    new-instance v1, Ljava/io/File;
    invoke-direct {v1, v0}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    new-instance v2, Ljava/io/FileWriter;
    const/4 v3, 0x1
    invoke-direct {v2, v1, v3}, Ljava/io/FileWriter;-><init>(Ljava/io/File;Z)V

    # Timestamp
    new-instance v3, Ljava/text/SimpleDateFormat;
    const-string v4, "HH:mm:ss.SSS"
    invoke-direct {v3, v4}, Ljava/text/SimpleDateFormat;-><init>(Ljava/lang/String;)V
    new-instance v4, Ljava/util/Date;
    invoke-direct {v4}, Ljava/util/Date;-><init>()V
    invoke-virtual {v3, v4}, Ljava/text/SimpleDateFormat;->format(Ljava/util/Date;)Ljava/lang/String;
    move-result-object v3

    # Build line: [HH:mm:ss.SSS] message\n
    new-instance v4, Ljava/lang/StringBuilder;
    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V
    const-string v1, "["
    invoke-virtual {v4, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v4, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v1, "] "
    invoke-virtual {v4, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v4, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v1, "\n"
    invoke-virtual {v4, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v3

    invoke-virtual {v2, v3}, Ljava/io/Writer;->write(Ljava/lang/String;)V
    invoke-virtual {v2}, Ljava/io/Writer;->flush()V
    invoke-virtual {v2}, Ljava/io/Writer;->close()V

    :skip_log
    :try_end_log
    .catchall {:try_start_log .. :try_end_log} :catch_log
    goto :after_log
    :catch_log
    move-exception v0
    :after_log
    return-void
.end method


# ================================================================
# logConnection(String, String) - Log a URL with method prefix
# ================================================================
.method public static logConnection(Ljava/lang/String;Ljava/lang/String;)V
    .locals 2

    new-instance v0, Ljava/lang/StringBuilder;
    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V
    invoke-virtual {v0, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v1, " "
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0

    invoke-static {v0}, Lin/startv/hotstar/NetworkLogger;->log(Ljava/lang/String;)V

    # Also logcat
    const-string v1, "HSPatch-Net"
    invoke-static {v1, v0}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    return-void
.end method


# ================================================================
# startMonitor(Context) - Start a background thread that periodically
# checks active connections and logs them
# ================================================================
.method private static startMonitor(Landroid/content/Context;)V
    .locals 3

    :try_start_mon
    new-instance v0, Lin/startv/hotstar/NetworkLogger$MonitorThread;
    invoke-direct {v0, p0}, Lin/startv/hotstar/NetworkLogger$MonitorThread;-><init>(Landroid/content/Context;)V

    new-instance v1, Ljava/lang/Thread;
    invoke-direct {v1, v0}, Ljava/lang/Thread;-><init>(Ljava/lang/Runnable;)V

    const/4 v2, 0x1
    invoke-virtual {v1, v2}, Ljava/lang/Thread;->setDaemon(Z)V

    const-string v2, "HSPatch-NetMonitor"
    invoke-virtual {v1, v2}, Ljava/lang/Thread;->setName(Ljava/lang/String;)V

    invoke-virtual {v1}, Ljava/lang/Thread;->start()V

    const-string v1, "HSPatch"
    const-string v2, "Network monitor thread started"
    invoke-static {v1, v2}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    :try_end_mon
    .catchall {:try_start_mon .. :try_end_mon} :catch_mon
    goto :after_mon
    :catch_mon
    move-exception v0
    :after_mon
    return-void
.end method
