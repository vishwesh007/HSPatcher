.class public Lin/startv/hotstar/FileViewerActivity$TextChangeWatcher;
.super Ljava/lang/Object;
.source "FileViewerActivity.java"

.implements Landroid/text/TextWatcher;

.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lin/startv/hotstar/FileViewerActivity;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "TextChangeWatcher"
.end annotation

.field public outer:Lin/startv/hotstar/FileViewerActivity;

.method public constructor <init>(Lin/startv/hotstar/FileViewerActivity;)V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lin/startv/hotstar/FileViewerActivity$TextChangeWatcher;->outer:Lin/startv/hotstar/FileViewerActivity;
    return-void
.end method

.method public beforeTextChanged(Ljava/lang/CharSequence;III)V
    .locals 0
    return-void
.end method

.method public onTextChanged(Ljava/lang/CharSequence;III)V
    .locals 0
    return-void
.end method

.method public afterTextChanged(Landroid/text/Editable;)V
    .locals 2
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity$TextChangeWatcher;->outer:Lin/startv/hotstar/FileViewerActivity;
    const/4 v1, 0x1
    iput-boolean v1, v0, Lin/startv/hotstar/FileViewerActivity;->isEdited:Z
    return-void
.end method
