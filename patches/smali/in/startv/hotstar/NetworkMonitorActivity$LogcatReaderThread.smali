.class public Lin/startv/hotstar/NetworkMonitorActivity$LogcatReaderThread;
.super Ljava/lang/Thread;
.source "NetworkMonitorActivity.java"

# Reads logcat HSPatch-Net tag in real-time

.field public outer:Lin/startv/hotstar/NetworkMonitorActivity;

.method public constructor <init>(Lin/startv/hotstar/NetworkMonitorActivity;)V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Thread;-><init>()V
    iput-object p1, p0, Lin/startv/hotstar/NetworkMonitorActivity$LogcatReaderThread;->outer:Lin/startv/hotstar/NetworkMonitorActivity;
    return-void
.end method

.method public run()V
    .locals 6

    :try_start_run
    # Execute logcat -s HSPatch-Net:I
    invoke-static {}, Ljava/lang/Runtime;->getRuntime()Ljava/lang/Runtime;
    move-result-object v0

    const/4 v1, 0x4
    new-array v1, v1, [Ljava/lang/String;
    const/4 v2, 0x0
    const-string v3, "logcat"
    aput-object v3, v1, v2
    const/4 v2, 0x1
    const-string v3, "-s"
    aput-object v3, v1, v2
    const/4 v2, 0x2
    const-string v3, "HSPatch-Net:I"
    aput-object v3, v1, v2
    const/4 v2, 0x3
    const-string v3, "-v"
    # Use "brief" format for compact output
    aput-object v3, v1, v2

    invoke-virtual {v0, v1}, Ljava/lang/Runtime;->exec([Ljava/lang/String;)Ljava/lang/Process;
    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/Process;->getInputStream()Ljava/io/InputStream;
    move-result-object v1
    new-instance v2, Ljava/io/BufferedReader;
    new-instance v3, Ljava/io/InputStreamReader;
    invoke-direct {v3, v1}, Ljava/io/InputStreamReader;-><init>(Ljava/io/InputStream;)V
    invoke-direct {v2, v3}, Ljava/io/BufferedReader;-><init>(Ljava/io/Reader;)V

    :loop_read
    # Check if still capturing
    iget-object v3, p0, Lin/startv/hotstar/NetworkMonitorActivity$LogcatReaderThread;->outer:Lin/startv/hotstar/NetworkMonitorActivity;
    iget-boolean v4, v3, Lin/startv/hotstar/NetworkMonitorActivity;->isCapturing:Z
    if-eqz v4, :stop_read

    invoke-virtual {v2}, Ljava/io/BufferedReader;->readLine()Ljava/lang/String;
    move-result-object v4

    if-eqz v4, :stop_read

    # Extract the message part after tag (skip logcat prefix)
    # Format: I/HSPatch-Net(  PID): message
    const-string v5, "HSPatch-Net"
    invoke-virtual {v4, v5}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v5
    if-eqz v5, :loop_read

    # Extract message after ": "
    const-string v5, ": "
    invoke-virtual {v4, v5}, Ljava/lang/String;->indexOf(Ljava/lang/String;)I
    move-result v5
    if-ltz v5, :use_full

    add-int/lit8 v5, v5, 0x2
    invoke-virtual {v4, v5}, Ljava/lang/String;->substring(I)Ljava/lang/String;
    move-result-object v4
    goto :send_to_ui

    :use_full

    :send_to_ui
    # Colorize based on type prefix
    new-instance v5, Ljava/lang/StringBuilder;
    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    # Add timestamp
    new-instance v3, Ljava/text/SimpleDateFormat;
    const-string v1, "HH:mm:ss.SSS"
    invoke-direct {v3, v1}, Ljava/text/SimpleDateFormat;-><init>(Ljava/lang/String;)V
    new-instance v1, Ljava/util/Date;
    invoke-direct {v1}, Ljava/util/Date;-><init>()V
    invoke-virtual {v3, v1}, Ljava/text/SimpleDateFormat;->format(Ljava/util/Date;)Ljava/lang/String;
    move-result-object v1
    const-string v3, "["
    invoke-virtual {v5, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v5, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v3, "] "
    invoke-virtual {v5, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v5, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v4

    # Send to activity
    iget-object v3, p0, Lin/startv/hotstar/NetworkMonitorActivity$LogcatReaderThread;->outer:Lin/startv/hotstar/NetworkMonitorActivity;
    invoke-virtual {v3, v4}, Lin/startv/hotstar/NetworkMonitorActivity;->appendLog(Ljava/lang/String;)V

    goto :loop_read

    :stop_read
    invoke-virtual {v2}, Ljava/io/BufferedReader;->close()V
    invoke-virtual {v0}, Ljava/lang/Process;->destroy()V

    :try_end_run
    .catch Ljava/lang/Exception; {:try_start_run .. :try_end_run} :catch_run
    :catch_run

    return-void
.end method
