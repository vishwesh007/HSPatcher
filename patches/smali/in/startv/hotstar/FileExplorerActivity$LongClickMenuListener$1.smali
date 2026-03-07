.class Lin/startv/hotstar/FileExplorerActivity$LongClickMenuListener$1;
.super Ljava/lang/Object;
.source "FileExplorerActivity.java"

# interfaces
.implements Landroid/content/DialogInterface$OnClickListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lin/startv/hotstar/FileExplorerActivity$LongClickMenuListener;->showRenameDialog()V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$1:Lin/startv/hotstar/FileExplorerActivity$LongClickMenuListener;

.field final synthetic val$input:Landroid/widget/EditText;


# direct methods
.method constructor <init>(Lin/startv/hotstar/FileExplorerActivity$LongClickMenuListener;Landroid/widget/EditText;)V
    .locals 0
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x8010,
            0x1010
        }
        names = {
            null,
            null
        }
    .end annotation

    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()V"
        }
    .end annotation

    .line 1039
    iput-object p1, p0, Lin/startv/hotstar/FileExplorerActivity$LongClickMenuListener$1;->this$1:Lin/startv/hotstar/FileExplorerActivity$LongClickMenuListener;

    iput-object p2, p0, Lin/startv/hotstar/FileExplorerActivity$LongClickMenuListener$1;->val$input:Landroid/widget/EditText;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onClick(Landroid/content/DialogInterface;I)V
    .locals 3

    .line 1042
    iget-object p1, p0, Lin/startv/hotstar/FileExplorerActivity$LongClickMenuListener$1;->val$input:Landroid/widget/EditText;

    invoke-virtual {p1}, Landroid/widget/EditText;->getText()Landroid/text/Editable;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object p1

    .line 1043
    invoke-virtual {p1}, Ljava/lang/String;->isEmpty()Z

    move-result p2

    if-eqz p2, :cond_0

    return-void

    .line 1044
    :cond_0
    new-instance p2, Ljava/io/File;

    iget-object v0, p0, Lin/startv/hotstar/FileExplorerActivity$LongClickMenuListener$1;->this$1:Lin/startv/hotstar/FileExplorerActivity$LongClickMenuListener;

    iget-object v0, v0, Lin/startv/hotstar/FileExplorerActivity$LongClickMenuListener;->path:Ljava/lang/String;

    invoke-direct {p2, v0}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    .line 1045
    new-instance v0, Ljava/io/File;

    invoke-virtual {p2}, Ljava/io/File;->getParent()Ljava/lang/String;

    move-result-object v1

    invoke-direct {v0, v1, p1}, Ljava/io/File;-><init>(Ljava/lang/String;Ljava/lang/String;)V

    .line 1046
    invoke-virtual {p2, v0}, Ljava/io/File;->renameTo(Ljava/io/File;)Z

    move-result p2

    const/4 v0, 0x0

    if-eqz p2, :cond_1

    .line 1047
    iget-object p2, p0, Lin/startv/hotstar/FileExplorerActivity$LongClickMenuListener$1;->this$1:Lin/startv/hotstar/FileExplorerActivity$LongClickMenuListener;

    iget-object p2, p2, Lin/startv/hotstar/FileExplorerActivity$LongClickMenuListener;->activity:Lin/startv/hotstar/FileExplorerActivity;

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "Renamed to: "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-static {p2, p1, v0}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;

    move-result-object p1

    invoke-virtual {p1}, Landroid/widget/Toast;->show()V

    .line 1048
    iget-object p1, p0, Lin/startv/hotstar/FileExplorerActivity$LongClickMenuListener$1;->this$1:Lin/startv/hotstar/FileExplorerActivity$LongClickMenuListener;

    iget-object p1, p1, Lin/startv/hotstar/FileExplorerActivity$LongClickMenuListener;->activity:Lin/startv/hotstar/FileExplorerActivity;

    iget-object p2, p0, Lin/startv/hotstar/FileExplorerActivity$LongClickMenuListener$1;->this$1:Lin/startv/hotstar/FileExplorerActivity$LongClickMenuListener;

    iget-object p2, p2, Lin/startv/hotstar/FileExplorerActivity$LongClickMenuListener;->activity:Lin/startv/hotstar/FileExplorerActivity;

    iget-object p2, p2, Lin/startv/hotstar/FileExplorerActivity;->currentPath:Ljava/lang/String;

    invoke-virtual {p1, p2}, Lin/startv/hotstar/FileExplorerActivity;->navigateTo(Ljava/lang/String;)V

    goto :goto_0

    .line 1050
    :cond_1
    iget-object p1, p0, Lin/startv/hotstar/FileExplorerActivity$LongClickMenuListener$1;->this$1:Lin/startv/hotstar/FileExplorerActivity$LongClickMenuListener;

    iget-object p1, p1, Lin/startv/hotstar/FileExplorerActivity$LongClickMenuListener;->activity:Lin/startv/hotstar/FileExplorerActivity;

    const-string p2, "Rename failed"

    invoke-static {p1, p2, v0}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;

    move-result-object p1

    invoke-virtual {p1}, Landroid/widget/Toast;->show()V

    .line 1052
    :goto_0
    return-void
.end method
