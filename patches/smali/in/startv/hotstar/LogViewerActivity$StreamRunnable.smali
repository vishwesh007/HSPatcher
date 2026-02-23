.class public Lin/startv/hotstar/LogViewerActivity$StreamRunnable;
.super Ljava/lang/Object;
.source "LogViewerActivity.java"
.implements Ljava/lang/Runnable;

.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lin/startv/hotstar/LogViewerActivity;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x1
    name = "StreamRunnable"
.end annotation

.field public outer:Lin/startv/hotstar/LogViewerActivity;

.method public constructor <init>(Lin/startv/hotstar/LogViewerActivity;)V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lin/startv/hotstar/LogViewerActivity$StreamRunnable;->outer:Lin/startv/hotstar/LogViewerActivity;
    return-void
.end method

.method public run()V
    .locals 3
    iget-object v0, p0, Lin/startv/hotstar/LogViewerActivity$StreamRunnable;->outer:Lin/startv/hotstar/LogViewerActivity;
    iget-boolean v1, v0, Lin/startv/hotstar/LogViewerActivity;->isStreaming:Z
    if-eqz v1, :done_sr
    invoke-virtual {v0}, Lin/startv/hotstar/LogViewerActivity;->refreshLog()V
    # Repost
    iget-object v1, v0, Lin/startv/hotstar/LogViewerActivity;->handler:Landroid/os/Handler;
    const-wide/16 v2, 0x5dc
    invoke-virtual {v1, p0, v2, v3}, Landroid/os/Handler;->postDelayed(Ljava/lang/Runnable;J)Z
    :done_sr
    return-void
.end method
