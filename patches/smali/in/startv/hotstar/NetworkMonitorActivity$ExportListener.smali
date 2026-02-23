.class public Lin/startv/hotstar/NetworkMonitorActivity$ExportListener;
.super Ljava/lang/Object;
.source "NetworkMonitorActivity.java"
.implements Landroid/view/View$OnClickListener;

.field public outer:Lin/startv/hotstar/NetworkMonitorActivity;

.method public constructor <init>(Lin/startv/hotstar/NetworkMonitorActivity;)V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lin/startv/hotstar/NetworkMonitorActivity$ExportListener;->outer:Lin/startv/hotstar/NetworkMonitorActivity;
    return-void
.end method

.method public onClick(Landroid/view/View;)V
    .locals 1
    iget-object v0, p0, Lin/startv/hotstar/NetworkMonitorActivity$ExportListener;->outer:Lin/startv/hotstar/NetworkMonitorActivity;
    invoke-virtual {v0}, Lin/startv/hotstar/NetworkMonitorActivity;->exportLog()V
    return-void
.end method
