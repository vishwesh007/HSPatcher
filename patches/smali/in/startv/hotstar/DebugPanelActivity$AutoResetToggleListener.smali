.class public Lin/startv/hotstar/DebugPanelActivity$AutoResetToggleListener;
.super Ljava/lang/Object;
.source "DebugPanelActivity.java"

# implements CompoundButton.OnCheckedChangeListener
.implements Landroid/widget/CompoundButton$OnCheckedChangeListener;

# instance fields
.field public outer:Lin/startv/hotstar/DebugPanelActivity;

.method public constructor <init>(Lin/startv/hotstar/DebugPanelActivity;)V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lin/startv/hotstar/DebugPanelActivity$AutoResetToggleListener;->outer:Lin/startv/hotstar/DebugPanelActivity;
    return-void
.end method

.method public onCheckedChanged(Landroid/widget/CompoundButton;Z)V
    .locals 3

    # Persist the toggle
    iget-object v0, p0, Lin/startv/hotstar/DebugPanelActivity$AutoResetToggleListener;->outer:Lin/startv/hotstar/DebugPanelActivity;
    invoke-static {v0, p2}, Lin/startv/hotstar/HSPatchConfig;->setAutoResetFingerprint(Landroid/content/Context;Z)V

    # Toast feedback
    iget-object v0, p0, Lin/startv/hotstar/DebugPanelActivity$AutoResetToggleListener;->outer:Lin/startv/hotstar/DebugPanelActivity;
    if-eqz p2, :show_off

    const-string v1, "\u2705 Auto-reset fingerprint: ON (new profiles will get fresh identity)"
    goto :show_toast

    :show_off
    const-string v1, "\u274c Auto-reset fingerprint: OFF (new profiles keep real device identity)"

    :show_toast
    const/4 v2, 0x1
    invoke-static {v0, v1, v2}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;
    move-result-object v0
    invoke-virtual {v0}, Landroid/widget/Toast;->show()V

    return-void
.end method
