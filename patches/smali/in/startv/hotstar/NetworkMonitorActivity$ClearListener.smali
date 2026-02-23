.class public Lin/startv/hotstar/NetworkMonitorActivity$ClearListener;
.super Ljava/lang/Object;
.source "NetworkMonitorActivity.java"
.implements Landroid/view/View$OnClickListener;

.field public outer:Lin/startv/hotstar/NetworkMonitorActivity;

.method public constructor <init>(Lin/startv/hotstar/NetworkMonitorActivity;)V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lin/startv/hotstar/NetworkMonitorActivity$ClearListener;->outer:Lin/startv/hotstar/NetworkMonitorActivity;
    return-void
.end method

.method public onClick(Landroid/view/View;)V
    .locals 3
    iget-object v0, p0, Lin/startv/hotstar/NetworkMonitorActivity$ClearListener;->outer:Lin/startv/hotstar/NetworkMonitorActivity;

    # Replace buffer with new empty one
    new-instance v1, Ljava/lang/StringBuilder;
    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V
    iput-object v1, v0, Lin/startv/hotstar/NetworkMonitorActivity;->logBuffer:Ljava/lang/StringBuilder;

    # Clear display
    iget-object v1, v0, Lin/startv/hotstar/NetworkMonitorActivity;->logTextView:Landroid/widget/TextView;
    const-string v2, "\u2502 Log cleared"
    invoke-virtual {v1, v2}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    # Reset counter
    const/4 v1, 0x0
    iput v1, v0, Lin/startv/hotstar/NetworkMonitorActivity;->requestCount:I

    # Toast
    const-string v1, "\ud83d\uddd1 Network log cleared"
    const/4 v2, 0x0
    invoke-static {v0, v1, v2}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;
    move-result-object v0
    invoke-virtual {v0}, Landroid/widget/Toast;->show()V

    return-void
.end method
