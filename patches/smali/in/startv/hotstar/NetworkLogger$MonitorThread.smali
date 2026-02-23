.class public Lin/startv/hotstar/NetworkLogger$MonitorThread;
.super Ljava/lang/Object;
.source "NetworkLogger.java"

# interfaces
.implements Ljava/lang/Runnable;

# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lin/startv/hotstar/NetworkLogger;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "MonitorThread"
.end annotation


# instance fields
.field public context:Landroid/content/Context;


# direct methods
.method public constructor <init>(Landroid/content/Context;)V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lin/startv/hotstar/NetworkLogger$MonitorThread;->context:Landroid/content/Context;
    return-void
.end method


# virtual methods
.method public run()V
    .locals 6

    const-string v5, "HSPatch"

    # Wait 5 seconds for app to initialize
    :try_start_sleep
    const-wide/16 v0, 0x1388
    invoke-static {v0, v1}, Ljava/lang/Thread;->sleep(J)V
    :try_end_sleep
    .catchall {:try_start_sleep .. :try_end_sleep} :catch_sleep
    goto :after_sleep
    :catch_sleep
    move-exception v0
    :after_sleep

    # Log initial connectivity info
    :try_start_info
    iget-object v0, p0, Lin/startv/hotstar/NetworkLogger$MonitorThread;->context:Landroid/content/Context;

    const-string v1, "connectivity"
    invoke-virtual {v0, v1}, Landroid/content/Context;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;
    move-result-object v0
    check-cast v0, Landroid/net/ConnectivityManager;

    invoke-virtual {v0}, Landroid/net/ConnectivityManager;->getActiveNetworkInfo()Landroid/net/NetworkInfo;
    move-result-object v1

    if-eqz v1, :no_net

    invoke-virtual {v1}, Landroid/net/NetworkInfo;->getTypeName()Ljava/lang/String;
    move-result-object v2

    invoke-virtual {v1}, Landroid/net/NetworkInfo;->isConnected()Z
    move-result v3

    new-instance v4, Ljava/lang/StringBuilder;
    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V
    const-string v1, "NET-INFO Type="
    invoke-virtual {v4, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v4, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v1, " Connected="
    invoke-virtual {v4, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v4, v3}, Ljava/lang/StringBuilder;->append(Z)Ljava/lang/StringBuilder;
    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v1

    invoke-static {v1}, Lin/startv/hotstar/NetworkLogger;->log(Ljava/lang/String;)V

    :no_net

    # Log DNS info
    const-string v1, "NET-DNS Checking default resolver..."
    invoke-static {v1}, Lin/startv/hotstar/NetworkLogger;->log(Ljava/lang/String;)V

    :try_end_info
    .catchall {:try_start_info .. :try_end_info} :catch_info
    goto :after_info
    :catch_info
    move-exception v0
    :after_info

    # Log that monitoring is ready
    const-string v0, "NET-MONITOR ready - Frida hooks handle URL logging"
    invoke-static {v0}, Lin/startv/hotstar/NetworkLogger;->log(Ljava/lang/String;)V

    const-string v0, "Network monitor: initial check complete"
    invoke-static {v5, v0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    return-void
.end method
