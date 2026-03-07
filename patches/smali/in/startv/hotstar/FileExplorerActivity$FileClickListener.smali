.class Lin/startv/hotstar/FileExplorerActivity$FileClickListener;
.super Ljava/lang/Object;
.source "FileExplorerActivity.java"

# interfaces
.implements Landroid/view/View$OnClickListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lin/startv/hotstar/FileExplorerActivity;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = "FileClickListener"
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

    .line 781
    iput-object p1, p0, Lin/startv/hotstar/FileExplorerActivity$FileClickListener;->this$0:Lin/startv/hotstar/FileExplorerActivity;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p2, p0, Lin/startv/hotstar/FileExplorerActivity$FileClickListener;->activity:Lin/startv/hotstar/FileExplorerActivity;

    iput-object p3, p0, Lin/startv/hotstar/FileExplorerActivity$FileClickListener;->path:Ljava/lang/String;

    return-void
.end method


# virtual methods
.method public onClick(Landroid/view/View;)V
    .locals 3

    .line 784
    :try_start_0
    new-instance p1, Landroid/content/Intent;

    iget-object v0, p0, Lin/startv/hotstar/FileExplorerActivity$FileClickListener;->activity:Lin/startv/hotstar/FileExplorerActivity;

    const-class v1, Lin/startv/hotstar/FileViewerActivity;

    invoke-direct {p1, v0, v1}, Landroid/content/Intent;-><init>(Landroid/content/Context;Ljava/lang/Class;)V

    .line 785
    const-string v0, "filePath"

    iget-object v1, p0, Lin/startv/hotstar/FileExplorerActivity$FileClickListener;->path:Ljava/lang/String;

    invoke-virtual {p1, v0, v1}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    .line 786
    iget-object v0, p0, Lin/startv/hotstar/FileExplorerActivity$FileClickListener;->activity:Lin/startv/hotstar/FileExplorerActivity;

    invoke-virtual {v0, p1}, Lin/startv/hotstar/FileExplorerActivity;->startActivity(Landroid/content/Intent;)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 789
    goto :goto_0

    .line 787
    :catch_0
    move-exception p1

    .line 788
    iget-object v0, p0, Lin/startv/hotstar/FileExplorerActivity$FileClickListener;->activity:Lin/startv/hotstar/FileExplorerActivity;

    invoke-virtual {p1}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object p1

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "Error opening file: "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    const/4 v1, 0x0

    invoke-static {v0, p1, v1}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;

    move-result-object p1

    invoke-virtual {p1}, Landroid/widget/Toast;->show()V

    .line 790
    :goto_0
    return-void
.end method
