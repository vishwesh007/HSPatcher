.class public Lin/startv/hotstar/FileExplorerActivity$DeleteConfirmListener;
.super Ljava/lang/Object;
.source "FileExplorerActivity.java"

.implements Landroid/content/DialogInterface$OnClickListener;

.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lin/startv/hotstar/FileExplorerActivity;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "DeleteConfirmListener"
.end annotation

.field public outer:Lin/startv/hotstar/FileExplorerActivity;
.field public filePath:Ljava/lang/String;

.method public constructor <init>(Lin/startv/hotstar/FileExplorerActivity;Ljava/lang/String;)V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lin/startv/hotstar/FileExplorerActivity$DeleteConfirmListener;->outer:Lin/startv/hotstar/FileExplorerActivity;
    iput-object p2, p0, Lin/startv/hotstar/FileExplorerActivity$DeleteConfirmListener;->filePath:Ljava/lang/String;
    return-void
.end method

.method public onClick(Landroid/content/DialogInterface;I)V
    .locals 4

    iget-object v0, p0, Lin/startv/hotstar/FileExplorerActivity$DeleteConfirmListener;->outer:Lin/startv/hotstar/FileExplorerActivity;
    iget-object v1, p0, Lin/startv/hotstar/FileExplorerActivity$DeleteConfirmListener;->filePath:Ljava/lang/String;

    # Use shell rm -rf for recursive delete
    new-instance v2, Ljava/lang/StringBuilder;
    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V
    const-string v3, "rm -rf '"
    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v2, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v3, "'"
    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v2

    invoke-static {v2}, Lin/startv/hotstar/ProfileManager;->shellExec(Ljava/lang/String;)V

    const-string v2, "\ud83d\uddd1\ufe0f Deleted"
    const/4 v3, 0x0
    invoke-static {v0, v2, v3}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;
    move-result-object v2
    invoke-virtual {v2}, Landroid/widget/Toast;->show()V

    # Refresh current directory
    iget-object v2, v0, Lin/startv/hotstar/FileExplorerActivity;->currentPath:Ljava/lang/String;
    invoke-virtual {v0, v2}, Lin/startv/hotstar/FileExplorerActivity;->navigateTo(Ljava/lang/String;)V

    return-void
.end method
