.class public Lin/startv/hotstar/HostFilterActivity$BackListener;
.super Ljava/lang/Object;
.source "HostFilterActivity.java"

.implements Landroid/view/View$OnClickListener;

.field public outer:Lin/startv/hotstar/HostFilterActivity;

.method public constructor <init>(Lin/startv/hotstar/HostFilterActivity;)V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lin/startv/hotstar/HostFilterActivity$BackListener;->outer:Lin/startv/hotstar/HostFilterActivity;
    return-void
.end method

.method public onClick(Landroid/view/View;)V
    .locals 1
    iget-object v0, p0, Lin/startv/hotstar/HostFilterActivity$BackListener;->outer:Lin/startv/hotstar/HostFilterActivity;
    invoke-virtual {v0}, Landroid/app/Activity;->finish()V
    return-void
.end method
