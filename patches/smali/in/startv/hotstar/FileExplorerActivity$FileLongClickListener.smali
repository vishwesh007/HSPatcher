.class public Lin/startv/hotstar/FileExplorerActivity$FileLongClickListener;
.super Ljava/lang/Object;
.source "FileExplorerActivity.java"

.implements Landroid/view/View$OnLongClickListener;

.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lin/startv/hotstar/FileExplorerActivity;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "FileLongClickListener"
.end annotation

.field public outer:Lin/startv/hotstar/FileExplorerActivity;
.field public filePath:Ljava/lang/String;
.field public fileName:Ljava/lang/String;

.method public constructor <init>(Lin/startv/hotstar/FileExplorerActivity;Ljava/lang/String;Ljava/lang/String;)V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lin/startv/hotstar/FileExplorerActivity$FileLongClickListener;->outer:Lin/startv/hotstar/FileExplorerActivity;
    iput-object p2, p0, Lin/startv/hotstar/FileExplorerActivity$FileLongClickListener;->filePath:Ljava/lang/String;
    iput-object p3, p0, Lin/startv/hotstar/FileExplorerActivity$FileLongClickListener;->fileName:Ljava/lang/String;
    return-void
.end method

.method public onLongClick(Landroid/view/View;)Z
    .locals 8

    iget-object v0, p0, Lin/startv/hotstar/FileExplorerActivity$FileLongClickListener;->outer:Lin/startv/hotstar/FileExplorerActivity;
    iget-object v1, p0, Lin/startv/hotstar/FileExplorerActivity$FileLongClickListener;->filePath:Ljava/lang/String;
    iget-object v2, p0, Lin/startv/hotstar/FileExplorerActivity$FileLongClickListener;->fileName:Ljava/lang/String;

    # Show AlertDialog with options
    new-instance v3, Landroid/app/AlertDialog$Builder;
    invoke-direct {v3, v0}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    invoke-virtual {v3, v2}, Landroid/app/AlertDialog$Builder;->setTitle(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    # Options: Copy Path, Delete, Properties
    const/4 v4, 0x3
    new-array v5, v4, [Ljava/lang/CharSequence;
    const/4 v4, 0x0
    const-string v6, "\ud83d\udccb Copy Path"
    aput-object v6, v5, v4
    const/4 v4, 0x1
    const-string v6, "\ud83d\uddd1\ufe0f Delete"
    aput-object v6, v5, v4
    const/4 v4, 0x2
    const-string v6, "\u2139\ufe0f Properties"
    aput-object v6, v5, v4

    new-instance v6, Lin/startv/hotstar/FileExplorerActivity$LongClickMenuListener;
    invoke-direct {v6, v0, v1, v2}, Lin/startv/hotstar/FileExplorerActivity$LongClickMenuListener;-><init>(Lin/startv/hotstar/FileExplorerActivity;Ljava/lang/String;Ljava/lang/String;)V
    invoke-virtual {v3, v5, v6}, Landroid/app/AlertDialog$Builder;->setItems([Ljava/lang/CharSequence;Landroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    invoke-virtual {v3}, Landroid/app/AlertDialog$Builder;->show()Landroid/app/AlertDialog;

    const/4 v0, 0x1
    return v0
.end method
