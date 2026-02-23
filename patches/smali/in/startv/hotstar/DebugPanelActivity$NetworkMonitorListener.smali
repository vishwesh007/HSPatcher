.class public Lin/startv/hotstar/DebugPanelActivity$NetworkMonitorListener;
.super Ljava/lang/Object;
.source "DebugPanelActivity.java"
.implements Landroid/view/View$OnClickListener;

.field public outer:Lin/startv/hotstar/DebugPanelActivity;

.method public constructor <init>(Lin/startv/hotstar/DebugPanelActivity;)V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lin/startv/hotstar/DebugPanelActivity$NetworkMonitorListener;->outer:Lin/startv/hotstar/DebugPanelActivity;
    return-void
.end method

.method public onClick(Landroid/view/View;)V
    .locals 3

    iget-object v0, p0, Lin/startv/hotstar/DebugPanelActivity$NetworkMonitorListener;->outer:Lin/startv/hotstar/DebugPanelActivity;
    const-class v1, Lin/startv/hotstar/NetworkMonitorActivity;
    new-instance v2, Landroid/content/Intent;
    invoke-direct {v2, v0, v1}, Landroid/content/Intent;-><init>(Landroid/content/Context;Ljava/lang/Class;)V
    invoke-virtual {v0, v2}, Landroid/app/Activity;->startActivity(Landroid/content/Intent;)V

    return-void
.end method
