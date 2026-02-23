.class public Lin/startv/hotstar/FileExplorerActivity$BackClickListener;
.super Ljava/lang/Object;
.source "FileExplorerActivity.java"

.implements Landroid/view/View$OnClickListener;

.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lin/startv/hotstar/FileExplorerActivity;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "BackClickListener"
.end annotation

.field public outer:Lin/startv/hotstar/FileExplorerActivity;

.method public constructor <init>(Lin/startv/hotstar/FileExplorerActivity;)V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lin/startv/hotstar/FileExplorerActivity$BackClickListener;->outer:Lin/startv/hotstar/FileExplorerActivity;
    return-void
.end method

.method public onClick(Landroid/view/View;)V
    .locals 1
    iget-object v0, p0, Lin/startv/hotstar/FileExplorerActivity$BackClickListener;->outer:Lin/startv/hotstar/FileExplorerActivity;
    invoke-virtual {v0}, Landroid/app/Activity;->onBackPressed()V
    return-void
.end method
