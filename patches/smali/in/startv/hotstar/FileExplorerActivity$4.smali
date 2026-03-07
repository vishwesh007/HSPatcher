.class Lin/startv/hotstar/FileExplorerActivity$4;
.super Ljava/lang/Object;
.source "FileExplorerActivity.java"

# interfaces
.implements Landroid/content/DialogInterface$OnClickListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lin/startv/hotstar/FileExplorerActivity;->showNameInputDialog(Z)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lin/startv/hotstar/FileExplorerActivity;

.field final synthetic val$input:Landroid/widget/EditText;

.field final synthetic val$isFolder:Z


# direct methods
.method constructor <init>(Lin/startv/hotstar/FileExplorerActivity;Landroid/widget/EditText;Z)V
    .locals 0
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x8010,
            0x1010,
            0x1010
        }
        names = {
            null,
            null,
            null
        }
    .end annotation

    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()V"
        }
    .end annotation

    .line 710
    iput-object p1, p0, Lin/startv/hotstar/FileExplorerActivity$4;->this$0:Lin/startv/hotstar/FileExplorerActivity;

    iput-object p2, p0, Lin/startv/hotstar/FileExplorerActivity$4;->val$input:Landroid/widget/EditText;

    iput-boolean p3, p0, Lin/startv/hotstar/FileExplorerActivity$4;->val$isFolder:Z

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onClick(Landroid/content/DialogInterface;I)V
    .locals 3

    .line 713
    iget-object p1, p0, Lin/startv/hotstar/FileExplorerActivity$4;->val$input:Landroid/widget/EditText;

    invoke-virtual {p1}, Landroid/widget/EditText;->getText()Landroid/text/Editable;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object p1

    .line 714
    invoke-virtual {p1}, Ljava/lang/String;->isEmpty()Z

    move-result p2

    if-eqz p2, :cond_0

    return-void

    .line 716
    :cond_0
    new-instance p2, Ljava/io/File;

    iget-object v0, p0, Lin/startv/hotstar/FileExplorerActivity$4;->this$0:Lin/startv/hotstar/FileExplorerActivity;

    iget-object v0, v0, Lin/startv/hotstar/FileExplorerActivity;->currentPath:Ljava/lang/String;

    invoke-direct {p2, v0, p1}, Ljava/io/File;-><init>(Ljava/lang/String;Ljava/lang/String;)V

    .line 719
    const/4 v0, 0x0

    :try_start_0
    iget-boolean v1, p0, Lin/startv/hotstar/FileExplorerActivity$4;->val$isFolder:Z

    if-eqz v1, :cond_1

    .line 720
    invoke-virtual {p2}, Ljava/io/File;->mkdirs()Z

    move-result p2

    goto :goto_0

    .line 722
    :cond_1
    invoke-virtual {p2}, Ljava/io/File;->createNewFile()Z

    move-result p2

    .line 724
    :goto_0
    if-eqz p2, :cond_2

    .line 725
    iget-object p2, p0, Lin/startv/hotstar/FileExplorerActivity$4;->this$0:Lin/startv/hotstar/FileExplorerActivity;

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "Created: "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-static {p2, p1, v0}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;

    move-result-object p1

    invoke-virtual {p1}, Landroid/widget/Toast;->show()V

    .line 726
    iget-object p1, p0, Lin/startv/hotstar/FileExplorerActivity$4;->this$0:Lin/startv/hotstar/FileExplorerActivity;

    iget-object p2, p0, Lin/startv/hotstar/FileExplorerActivity$4;->this$0:Lin/startv/hotstar/FileExplorerActivity;

    iget-object p2, p2, Lin/startv/hotstar/FileExplorerActivity;->currentPath:Ljava/lang/String;

    invoke-virtual {p1, p2}, Lin/startv/hotstar/FileExplorerActivity;->navigateTo(Ljava/lang/String;)V

    goto :goto_1

    .line 728
    :cond_2
    iget-object p1, p0, Lin/startv/hotstar/FileExplorerActivity$4;->this$0:Lin/startv/hotstar/FileExplorerActivity;

    const-string p2, "Already exists or failed"

    invoke-static {p1, p2, v0}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;

    move-result-object p1

    invoke-virtual {p1}, Landroid/widget/Toast;->show()V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 732
    :goto_1
    goto :goto_2

    .line 730
    :catch_0
    move-exception p1

    .line 731
    iget-object p2, p0, Lin/startv/hotstar/FileExplorerActivity$4;->this$0:Lin/startv/hotstar/FileExplorerActivity;

    invoke-virtual {p1}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object p1

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "Error: "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-static {p2, p1, v0}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;

    move-result-object p1

    invoke-virtual {p1}, Landroid/widget/Toast;->show()V

    .line 733
    :goto_2
    return-void
.end method
