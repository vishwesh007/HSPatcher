.class public Lin/startv/hotstar/DebugPanelActivity$AppBarHideToggleListener;
.super Ljava/lang/Object;
.source "DebugPanelActivity.java"

# implements CompoundButton.OnCheckedChangeListener
.implements Landroid/widget/CompoundButton$OnCheckedChangeListener;

.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lin/startv/hotstar/DebugPanelActivity;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x1
    name = "AppBarHideToggleListener"
.end annotation

# instance fields
.field public outer:Lin/startv/hotstar/DebugPanelActivity;

.method public constructor <init>(Lin/startv/hotstar/DebugPanelActivity;)V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lin/startv/hotstar/DebugPanelActivity$AppBarHideToggleListener;->outer:Lin/startv/hotstar/DebugPanelActivity;
    return-void
.end method

.method public onCheckedChanged(Landroid/widget/CompoundButton;Z)V
    .locals 3

    # Persist the toggle
    iget-object v0, p0, Lin/startv/hotstar/DebugPanelActivity$AppBarHideToggleListener;->outer:Lin/startv/hotstar/DebugPanelActivity;
    invoke-static {v0, p2}, Lin/startv/hotstar/HSPatchConfig;->setAppBarHideEnabled(Landroid/content/Context;Z)V

    # Send broadcast to notify agent.js
    iget-object v0, p0, Lin/startv/hotstar/DebugPanelActivity$AppBarHideToggleListener;->outer:Lin/startv/hotstar/DebugPanelActivity;
    new-instance v1, Landroid/content/Intent;
    const-string v2, "hspatch.TOGGLE_APPBAR_HIDE"
    invoke-direct {v1, v2}, Landroid/content/Intent;-><init>(Ljava/lang/String;)V
    invoke-virtual {v0, v1}, Landroid/content/Context;->sendBroadcast(Landroid/content/Intent;)V

    # Toast feedback
    iget-object v0, p0, Lin/startv/hotstar/DebugPanelActivity$AppBarHideToggleListener;->outer:Lin/startv/hotstar/DebugPanelActivity;
    if-eqz p2, :show_off

    const-string v1, "\ud83d\udeab App Bar Hidden"
    goto :show_toast

    :show_off
    const-string v1, "\u2705 App Bar Visible"

    :show_toast
    const/4 v2, 0x1
    invoke-static {v0, v1, v2}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;
    move-result-object v0
    invoke-virtual {v0}, Landroid/widget/Toast;->show()V

    return-void
.end method
