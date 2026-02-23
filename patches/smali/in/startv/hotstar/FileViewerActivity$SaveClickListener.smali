.class public Lin/startv/hotstar/FileViewerActivity$SaveClickListener;
.super Ljava/lang/Object;
.source "FileViewerActivity.java"

.implements Landroid/view/View$OnClickListener;

.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lin/startv/hotstar/FileViewerActivity;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "SaveClickListener"
.end annotation

.field public outer:Lin/startv/hotstar/FileViewerActivity;

.method public constructor <init>(Lin/startv/hotstar/FileViewerActivity;)V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lin/startv/hotstar/FileViewerActivity$SaveClickListener;->outer:Lin/startv/hotstar/FileViewerActivity;
    return-void
.end method

.method public onClick(Landroid/view/View;)V
    .locals 2
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity$SaveClickListener;->outer:Lin/startv/hotstar/FileViewerActivity;

    # Check if binary
    iget-boolean v1, v0, Lin/startv/hotstar/FileViewerActivity;->isBinary:Z
    if-eqz v1, :can_save

    const-string v1, "Cannot save binary files"
    const/4 v2, 0x0
    invoke-static {v0, v1, v2}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;
    move-result-object v1
    invoke-virtual {v1}, Landroid/widget/Toast;->show()V
    return-void

    :can_save
    invoke-virtual {v0}, Lin/startv/hotstar/FileViewerActivity;->saveFile()V
    return-void
.end method
