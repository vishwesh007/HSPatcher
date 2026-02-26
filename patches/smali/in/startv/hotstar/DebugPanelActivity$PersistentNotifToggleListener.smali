.class public Lin/startv/hotstar/DebugPanelActivity$PersistentNotifToggleListener;
.super Ljava/lang/Object;
.source "DebugPanelActivity.java"

# implements CompoundButton.OnCheckedChangeListener
.implements Landroid/widget/CompoundButton$OnCheckedChangeListener;

# instance fields
.field public outer:Lin/startv/hotstar/DebugPanelActivity;

.method public constructor <init>(Lin/startv/hotstar/DebugPanelActivity;)V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lin/startv/hotstar/DebugPanelActivity$PersistentNotifToggleListener;->outer:Lin/startv/hotstar/DebugPanelActivity;
    return-void
.end method

.method public onCheckedChanged(Landroid/widget/CompoundButton;Z)V
    .locals 3

    iget-object v0, p0, Lin/startv/hotstar/DebugPanelActivity$PersistentNotifToggleListener;->outer:Lin/startv/hotstar/DebugPanelActivity;

    # Persist toggle
    invoke-static {v0, p2}, Lin/startv/hotstar/HSPatchConfig;->setDebugNotificationPersistent(Landroid/content/Context;Z)V

    # Apply immediately
    if-eqz p2, :do_cancel

    invoke-static {v0}, Lin/startv/hotstar/DebugNotification;->show(Landroid/content/Context;)V

    const-string v1, "\u2705 Persistent debug notification: ON"
    goto :show_toast

    :do_cancel
    invoke-static {v0}, Lin/startv/hotstar/DebugNotification;->cancel(Landroid/content/Context;)V
    const-string v1, "\u274c Persistent debug notification: OFF"

    :show_toast
    const/4 v2, 0x1
    invoke-static {v0, v1, v2}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;
    move-result-object v0
    invoke-virtual {v0}, Landroid/widget/Toast;->show()V

    return-void
.end method
