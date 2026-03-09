.class public Lin/startv/hotstar/HostFilterActivity$NotifToggleListener;
.super Ljava/lang/Object;
.source "HostFilterActivity.java"

.implements Landroid/widget/CompoundButton$OnCheckedChangeListener;

# instance fields
.field public outer:Lin/startv/hotstar/HostFilterActivity;

.method public constructor <init>(Lin/startv/hotstar/HostFilterActivity;)V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lin/startv/hotstar/HostFilterActivity$NotifToggleListener;->outer:Lin/startv/hotstar/HostFilterActivity;
    return-void
.end method

.method public onCheckedChanged(Landroid/widget/CompoundButton;Z)V
    .locals 4

    iget-object v0, p0, Lin/startv/hotstar/HostFilterActivity$NotifToggleListener;->outer:Lin/startv/hotstar/HostFilterActivity;

    # Persist toggle (also syncs to hspatch_config for agent.js)
    invoke-static {v0, p2}, Lin/startv/hotstar/HSPatchConfig;->setBlockingNotificationEnabled(Landroid/content/Context;Z)V

    # Notify agent to refresh/cancel notification immediately
    new-instance v1, Landroid/content/Intent;
    const-string v2, "hspatch.REFRESH_BLOCK_NOTIF"
    invoke-direct {v1, v2}, Landroid/content/Intent;-><init>(Ljava/lang/String;)V
    invoke-virtual {v0, v1}, Landroid/content/Context;->sendBroadcast(Landroid/content/Intent;)V

    if-eqz p2, :notif_off
    const-string v1, "\u2705 Blocking notification: ON"
    goto :show_toast

    :notif_off
    const-string v1, "\u274c Blocking notification: OFF"

    :show_toast
    const/4 v2, 0x1
    invoke-static {v0, v1, v2}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;
    move-result-object v3
    invoke-virtual {v3}, Landroid/widget/Toast;->show()V

    return-void
.end method
