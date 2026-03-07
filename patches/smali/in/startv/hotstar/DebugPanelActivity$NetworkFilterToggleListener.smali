.class public Lin/startv/hotstar/DebugPanelActivity$NetworkFilterToggleListener;
.super Ljava/lang/Object;
.source "DebugPanelActivity.java"

# implements CompoundButton.OnCheckedChangeListener
.implements Landroid/widget/CompoundButton$OnCheckedChangeListener;

# instance fields
.field public outer:Lin/startv/hotstar/DebugPanelActivity;

.method public constructor <init>(Lin/startv/hotstar/DebugPanelActivity;)V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lin/startv/hotstar/DebugPanelActivity$NetworkFilterToggleListener;->outer:Lin/startv/hotstar/DebugPanelActivity;
    return-void
.end method

.method public onCheckedChanged(Landroid/widget/CompoundButton;Z)V
    .locals 3

    # Persist the toggle
    iget-object v0, p0, Lin/startv/hotstar/DebugPanelActivity$NetworkFilterToggleListener;->outer:Lin/startv/hotstar/DebugPanelActivity;
    invoke-static {v0, p2}, Lin/startv/hotstar/HSPatchConfig;->setNetworkFilterEnabled(Landroid/content/Context;Z)V

    # Show/hide filter mode container
    iget-object v0, p0, Lin/startv/hotstar/DebugPanelActivity$NetworkFilterToggleListener;->outer:Lin/startv/hotstar/DebugPanelActivity;
    iget-object v1, v0, Lin/startv/hotstar/DebugPanelActivity;->filterModeContainer:Landroid/widget/LinearLayout;
    if-eqz v1, :skip_vis
    if-eqz p2, :hide_mode
    const/4 v2, 0x0
    invoke-virtual {v1, v2}, Landroid/view/View;->setVisibility(I)V
    goto :skip_vis
    :hide_mode
    const/16 v2, 0x8
    invoke-virtual {v1, v2}, Landroid/view/View;->setVisibility(I)V
    :skip_vis

    # Send broadcast to notify agent.js
    iget-object v0, p0, Lin/startv/hotstar/DebugPanelActivity$NetworkFilterToggleListener;->outer:Lin/startv/hotstar/DebugPanelActivity;
    new-instance v1, Landroid/content/Intent;
    const-string v2, "hspatch.TOGGLE_BLOCK"
    invoke-direct {v1, v2}, Landroid/content/Intent;-><init>(Ljava/lang/String;)V
    invoke-virtual {v0, v1}, Landroid/content/Context;->sendBroadcast(Landroid/content/Intent;)V

    # Toast feedback
    iget-object v0, p0, Lin/startv/hotstar/DebugPanelActivity$NetworkFilterToggleListener;->outer:Lin/startv/hotstar/DebugPanelActivity;
    if-eqz p2, :show_off

    const-string v1, "\u2705 Network Filtering: ON"
    goto :show_toast

    :show_off
    const-string v1, "\u274c Network Filtering: OFF"

    :show_toast
    const/4 v2, 0x1
    invoke-static {v0, v1, v2}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;
    move-result-object v0
    invoke-virtual {v0}, Landroid/widget/Toast;->show()V

    return-void
.end method
