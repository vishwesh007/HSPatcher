.class public Lin/startv/hotstar/DebugPanelActivity$StreamToggleListener;
.super Ljava/lang/Object;
.source "DebugPanelActivity.java"

# interfaces
.implements Landroid/view/View$OnClickListener;

# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lin/startv/hotstar/DebugPanelActivity;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "StreamToggleListener"
.end annotation


# instance fields
.field public outer:Lin/startv/hotstar/DebugPanelActivity;


# direct methods
.method public constructor <init>(Lin/startv/hotstar/DebugPanelActivity;)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lin/startv/hotstar/DebugPanelActivity$StreamToggleListener;->outer:Lin/startv/hotstar/DebugPanelActivity;
    return-void
.end method


# virtual methods
.method public onClick(Landroid/view/View;)V
    .locals 2

    iget-object v0, p0, Lin/startv/hotstar/DebugPanelActivity$StreamToggleListener;->outer:Lin/startv/hotstar/DebugPanelActivity;

    # Check if currently streaming
    iget-boolean v1, v0, Lin/startv/hotstar/DebugPanelActivity;->isStreaming:Z
    if-eqz v1, :start_stream

    # Stop streaming
    invoke-virtual {v0}, Lin/startv/hotstar/DebugPanelActivity;->stopStreaming()V
    goto :done

    :start_stream
    # Start streaming
    invoke-virtual {v0}, Lin/startv/hotstar/DebugPanelActivity;->startStreaming()V

    :done
    return-void
.end method
