.class public Lin/startv/hotstar/DebugPanelActivity$DeviceSpoofResetListener;
.super Ljava/lang/Object;
.source "DebugPanelActivity.java"
.implements Landroid/view/View$OnClickListener;

.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lin/startv/hotstar/DebugPanelActivity;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x1
    name = "DeviceSpoofResetListener"
.end annotation

.field public this$0:Lin/startv/hotstar/DebugPanelActivity;

.method public constructor <init>(Lin/startv/hotstar/DebugPanelActivity;)V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lin/startv/hotstar/DebugPanelActivity$DeviceSpoofResetListener;->this$0:Lin/startv/hotstar/DebugPanelActivity;
    return-void
.end method

.method public onClick(Landroid/view/View;)V
    .locals 3
    iget-object v0, p0, Lin/startv/hotstar/DebugPanelActivity$DeviceSpoofResetListener;->this$0:Lin/startv/hotstar/DebugPanelActivity;
    # Reset spoofed values - generates fresh random fingerprint
    invoke-static {v0}, Lin/startv/hotstar/DeviceSpoofer;->resetFingerprint(Landroid/content/Context;)V
    const-string v1, "\ud83d\udd12 Device fingerprint regenerated! Restart app to apply."
    const/4 v2, 0x1
    invoke-static {v0, v1, v2}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;
    move-result-object v1
    invoke-virtual {v1}, Landroid/widget/Toast;->show()V
    return-void
.end method
