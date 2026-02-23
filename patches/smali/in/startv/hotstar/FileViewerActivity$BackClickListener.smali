.class public Lin/startv/hotstar/FileViewerActivity$BackClickListener;
.super Ljava/lang/Object;
.source "FileViewerActivity.java"

.implements Landroid/view/View$OnClickListener;

.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lin/startv/hotstar/FileViewerActivity;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "BackClickListener"
.end annotation

.field public outer:Lin/startv/hotstar/FileViewerActivity;

.method public constructor <init>(Lin/startv/hotstar/FileViewerActivity;)V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lin/startv/hotstar/FileViewerActivity$BackClickListener;->outer:Lin/startv/hotstar/FileViewerActivity;
    return-void
.end method

.method public onClick(Landroid/view/View;)V
    .locals 1
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity$BackClickListener;->outer:Lin/startv/hotstar/FileViewerActivity;
    invoke-virtual {v0}, Lin/startv/hotstar/FileViewerActivity;->onBackPressed()V
    return-void
.end method
