.class public Lin/startv/hotstar/DebugPanelActivity$StreamRunnable;
.super Ljava/lang/Object;
.source "DebugPanelActivity.java"

# interfaces
.implements Ljava/lang/Runnable;

# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lin/startv/hotstar/DebugPanelActivity;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "StreamRunnable"
.end annotation


# instance fields
.field public outer:Lin/startv/hotstar/DebugPanelActivity;


# direct methods
.method public constructor <init>(Lin/startv/hotstar/DebugPanelActivity;)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lin/startv/hotstar/DebugPanelActivity$StreamRunnable;->outer:Lin/startv/hotstar/DebugPanelActivity;
    return-void
.end method


# virtual methods
.method public run()V
    .locals 4

    iget-object v0, p0, Lin/startv/hotstar/DebugPanelActivity$StreamRunnable;->outer:Lin/startv/hotstar/DebugPanelActivity;

    # Refresh the log view
    invoke-virtual {v0}, Lin/startv/hotstar/DebugPanelActivity;->refreshLog()V

    # If still streaming, schedule next refresh
    iget-boolean v1, v0, Lin/startv/hotstar/DebugPanelActivity;->isStreaming:Z
    if-eqz v1, :stop

    iget-object v1, v0, Lin/startv/hotstar/DebugPanelActivity;->handler:Landroid/os/Handler;
    const-wide/16 v2, 0x5dc    # 1500ms
    invoke-virtual {v1, p0, v2, v3}, Landroid/os/Handler;->postDelayed(Ljava/lang/Runnable;J)Z

    :stop
    return-void
.end method
