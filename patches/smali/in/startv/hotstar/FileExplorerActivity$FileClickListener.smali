.class public Lin/startv/hotstar/FileExplorerActivity$FileClickListener;
.super Ljava/lang/Object;
.source "FileExplorerActivity.java"

.implements Landroid/view/View$OnClickListener;

.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lin/startv/hotstar/FileExplorerActivity;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "FileClickListener"
.end annotation

.field public outer:Lin/startv/hotstar/FileExplorerActivity;
.field public filePath:Ljava/lang/String;

.method public constructor <init>(Lin/startv/hotstar/FileExplorerActivity;Ljava/lang/String;)V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lin/startv/hotstar/FileExplorerActivity$FileClickListener;->outer:Lin/startv/hotstar/FileExplorerActivity;
    iput-object p2, p0, Lin/startv/hotstar/FileExplorerActivity$FileClickListener;->filePath:Ljava/lang/String;
    return-void
.end method

.method public onClick(Landroid/view/View;)V
    .locals 3

    iget-object v0, p0, Lin/startv/hotstar/FileExplorerActivity$FileClickListener;->outer:Lin/startv/hotstar/FileExplorerActivity;
    iget-object v1, p0, Lin/startv/hotstar/FileExplorerActivity$FileClickListener;->filePath:Ljava/lang/String;

    # Launch FileViewerActivity with the path
    new-instance v2, Landroid/content/Intent;
    const-class v3, Lin/startv/hotstar/FileViewerActivity;
    invoke-direct {v2, v0, v3}, Landroid/content/Intent;-><init>(Landroid/content/Context;Ljava/lang/Class;)V
    const-string v3, "path"
    invoke-virtual {v2, v3, v1}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;
    invoke-virtual {v0, v2}, Landroid/app/Activity;->startActivity(Landroid/content/Intent;)V

    return-void
.end method
