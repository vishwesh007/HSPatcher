.class public Lin/startv/hotstar/NetworkMonitorActivity$UIUpdateRunnable;
.super Ljava/lang/Object;
.source "NetworkMonitorActivity.java"
.implements Ljava/lang/Runnable;

.field public outer:Lin/startv/hotstar/NetworkMonitorActivity;

.method public constructor <init>(Lin/startv/hotstar/NetworkMonitorActivity;)V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lin/startv/hotstar/NetworkMonitorActivity$UIUpdateRunnable;->outer:Lin/startv/hotstar/NetworkMonitorActivity;
    return-void
.end method

.method public run()V
    .locals 4

    iget-object v0, p0, Lin/startv/hotstar/NetworkMonitorActivity$UIUpdateRunnable;->outer:Lin/startv/hotstar/NetworkMonitorActivity;

    # Update log text
    iget-object v1, v0, Lin/startv/hotstar/NetworkMonitorActivity;->logTextView:Landroid/widget/TextView;
    iget-object v2, v0, Lin/startv/hotstar/NetworkMonitorActivity;->logBuffer:Ljava/lang/StringBuilder;
    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v2
    invoke-virtual {v1, v2}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    # Auto-scroll to bottom
    iget-object v1, v0, Lin/startv/hotstar/NetworkMonitorActivity;->scrollView:Landroid/widget/ScrollView;
    if-eqz v1, :no_scroll
    const/16 v2, 0x82    # View.FOCUS_DOWN
    invoke-virtual {v1, v2}, Landroid/widget/ScrollView;->fullScroll(I)Z
    :no_scroll

    # Update status with count
    iget-object v1, v0, Lin/startv/hotstar/NetworkMonitorActivity;->statusText:Landroid/widget/TextView;
    new-instance v2, Ljava/lang/StringBuilder;
    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V
    const-string v3, "\ud83d\udfe2 Capturing \u2022 "
    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    iget v3, v0, Lin/startv/hotstar/NetworkMonitorActivity;->requestCount:I
    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    const-string v3, " requests"
    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v2
    invoke-virtual {v1, v2}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    return-void
.end method
