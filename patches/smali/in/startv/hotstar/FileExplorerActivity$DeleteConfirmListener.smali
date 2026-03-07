.class Lin/startv/hotstar/FileExplorerActivity$DeleteConfirmListener;
.super Ljava/lang/Object;
.source "FileExplorerActivity.java"

# interfaces
.implements Landroid/content/DialogInterface$OnClickListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lin/startv/hotstar/FileExplorerActivity;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = "DeleteConfirmListener"
.end annotation


# instance fields
.field activity:Lin/startv/hotstar/FileExplorerActivity;

.field path:Ljava/lang/String;

.field final synthetic this$0:Lin/startv/hotstar/FileExplorerActivity;


# direct methods
.method constructor <init>(Lin/startv/hotstar/FileExplorerActivity;Lin/startv/hotstar/FileExplorerActivity;Ljava/lang/String;)V
    .locals 0
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x8010,
            0x0,
            0x0
        }
        names = {
            null,
            null,
            null
        }
    .end annotation

    .line 1063
    iput-object p1, p0, Lin/startv/hotstar/FileExplorerActivity$DeleteConfirmListener;->this$0:Lin/startv/hotstar/FileExplorerActivity;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p2, p0, Lin/startv/hotstar/FileExplorerActivity$DeleteConfirmListener;->activity:Lin/startv/hotstar/FileExplorerActivity;

    iput-object p3, p0, Lin/startv/hotstar/FileExplorerActivity$DeleteConfirmListener;->path:Ljava/lang/String;

    return-void
.end method

.method private deleteRecursive(Ljava/io/File;)Z
    .locals 5

    .line 1081
    invoke-virtual {p1}, Ljava/io/File;->listFiles()[Ljava/io/File;

    move-result-object v0

    .line 1082
    if-eqz v0, :cond_1

    .line 1083
    array-length v1, v0

    const/4 v2, 0x0

    :goto_0
    if-ge v2, v1, :cond_1

    aget-object v3, v0, v2

    .line 1084
    invoke-virtual {v3}, Ljava/io/File;->isDirectory()Z

    move-result v4

    if-eqz v4, :cond_0

    invoke-direct {p0, v3}, Lin/startv/hotstar/FileExplorerActivity$DeleteConfirmListener;->deleteRecursive(Ljava/io/File;)Z

    goto :goto_1

    .line 1085
    :cond_0
    invoke-virtual {v3}, Ljava/io/File;->delete()Z

    .line 1083
    :goto_1
    add-int/lit8 v2, v2, 0x1

    goto :goto_0

    .line 1088
    :cond_1
    invoke-virtual {p1}, Ljava/io/File;->delete()Z

    move-result p1

    return p1
.end method


# virtual methods
.method public onClick(Landroid/content/DialogInterface;I)V
    .locals 1

    .line 1065
    new-instance p1, Ljava/io/File;

    iget-object p2, p0, Lin/startv/hotstar/FileExplorerActivity$DeleteConfirmListener;->path:Ljava/lang/String;

    invoke-direct {p1, p2}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    .line 1067
    invoke-virtual {p1}, Ljava/io/File;->isDirectory()Z

    move-result p2

    if-eqz p2, :cond_0

    .line 1068
    invoke-direct {p0, p1}, Lin/startv/hotstar/FileExplorerActivity$DeleteConfirmListener;->deleteRecursive(Ljava/io/File;)Z

    move-result p1

    goto :goto_0

    .line 1070
    :cond_0
    invoke-virtual {p1}, Ljava/io/File;->delete()Z

    move-result p1

    .line 1072
    :goto_0
    const/4 p2, 0x0

    if-eqz p1, :cond_1

    .line 1073
    iget-object p1, p0, Lin/startv/hotstar/FileExplorerActivity$DeleteConfirmListener;->activity:Lin/startv/hotstar/FileExplorerActivity;

    const-string v0, "Deleted"

    invoke-static {p1, v0, p2}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;

    move-result-object p1

    invoke-virtual {p1}, Landroid/widget/Toast;->show()V

    .line 1074
    iget-object p1, p0, Lin/startv/hotstar/FileExplorerActivity$DeleteConfirmListener;->activity:Lin/startv/hotstar/FileExplorerActivity;

    iget-object p2, p0, Lin/startv/hotstar/FileExplorerActivity$DeleteConfirmListener;->activity:Lin/startv/hotstar/FileExplorerActivity;

    iget-object p2, p2, Lin/startv/hotstar/FileExplorerActivity;->currentPath:Ljava/lang/String;

    invoke-virtual {p1, p2}, Lin/startv/hotstar/FileExplorerActivity;->navigateTo(Ljava/lang/String;)V

    goto :goto_1

    .line 1076
    :cond_1
    iget-object p1, p0, Lin/startv/hotstar/FileExplorerActivity$DeleteConfirmListener;->activity:Lin/startv/hotstar/FileExplorerActivity;

    const-string v0, "Delete failed"

    invoke-static {p1, v0, p2}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;

    move-result-object p1

    invoke-virtual {p1}, Landroid/widget/Toast;->show()V

    .line 1078
    :goto_1
    return-void
.end method
