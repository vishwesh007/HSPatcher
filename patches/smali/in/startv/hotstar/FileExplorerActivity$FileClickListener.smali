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

    .line 939
    iput-object p1, p0, Lin/startv/hotstar/FileExplorerActivity$FileClickListener;->this$0:Lin/startv/hotstar/FileExplorerActivity;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p2, p0, Lin/startv/hotstar/FileExplorerActivity$FileClickListener;->activity:Lin/startv/hotstar/FileExplorerActivity;

    iput-object p3, p0, Lin/startv/hotstar/FileExplorerActivity$FileClickListener;->path:Ljava/lang/String;

    return-void
.end method


# virtual methods
.method public onClick(Landroid/view/View;)V
    .locals 5

    .line 942
    const-string p1, "db_path"

    const/4 v0, 0x0

    :try_start_0
    iget-object v1, p0, Lin/startv/hotstar/FileExplorerActivity$FileClickListener;->path:Ljava/lang/String;

    invoke-virtual {v1}, Ljava/lang/String;->toLowerCase()Ljava/lang/String;

    move-result-object v1

    .line 943
    const-string v2, ".db"

    invoke-virtual {v1, v2}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result v2
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_2

    const-string v3, "filePath"

    if-nez v2, :cond_1

    :try_start_1
    const-string v2, ".sqlite"

    invoke-virtual {v1, v2}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result v2

    if-nez v2, :cond_1

    const-string v2, ".sqlite3"

    invoke-virtual {v1, v2}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result v1

    if-eqz v1, :cond_0

    goto :goto_0

    .line 966
    :cond_0
    new-instance p1, Landroid/content/Intent;

    iget-object v1, p0, Lin/startv/hotstar/FileExplorerActivity$FileClickListener;->activity:Lin/startv/hotstar/FileExplorerActivity;

    const-class v2, Lin/startv/hotstar/FileViewerActivity;

    invoke-direct {p1, v1, v2}, Landroid/content/Intent;-><init>(Landroid/content/Context;Ljava/lang/Class;)V

    .line 967
    iget-object v1, p0, Lin/startv/hotstar/FileExplorerActivity$FileClickListener;->path:Ljava/lang/String;

    invoke-virtual {p1, v3, v1}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    .line 968
    iget-object v1, p0, Lin/startv/hotstar/FileExplorerActivity$FileClickListener;->activity:Lin/startv/hotstar/FileExplorerActivity;

    invoke-virtual {v1, p1}, Lin/startv/hotstar/FileExplorerActivity;->startActivity(Landroid/content/Intent;)V
    :try_end_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_2

    goto :goto_2

    .line 946
    :cond_1
    :goto_0
    :try_start_2
    new-instance v1, Landroid/content/Intent;

    invoke-direct {v1}, Landroid/content/Intent;-><init>()V

    .line 947
    const-string v2, "in.startv.hspatcher"

    const-string v4, "in.startv.hspatcher.DbEditorActivity"

    invoke-virtual {v1, v2, v4}, Landroid/content/Intent;->setClassName(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    .line 948
    iget-object v2, p0, Lin/startv/hotstar/FileExplorerActivity$FileClickListener;->path:Ljava/lang/String;

    invoke-virtual {v1, p1, v2}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    .line 949
    iget-object v2, p0, Lin/startv/hotstar/FileExplorerActivity$FileClickListener;->activity:Lin/startv/hotstar/FileExplorerActivity;

    invoke-virtual {v2, v1}, Lin/startv/hotstar/FileExplorerActivity;->startActivity(Landroid/content/Intent;)V
    :try_end_2
    .catch Ljava/lang/Exception; {:try_start_2 .. :try_end_2} :catch_0

    .line 964
    :goto_1
    goto :goto_2

    .line 950
    :catch_0
    move-exception v1

    .line 953
    :try_start_3
    new-instance v1, Landroid/content/Intent;

    invoke-direct {v1}, Landroid/content/Intent;-><init>()V

    .line 954
    iget-object v2, p0, Lin/startv/hotstar/FileExplorerActivity$FileClickListener;->activity:Lin/startv/hotstar/FileExplorerActivity;

    invoke-virtual {v2}, Lin/startv/hotstar/FileExplorerActivity;->getPackageName()Ljava/lang/String;

    move-result-object v2

    const-string v4, "in.startv.hotstar.DbViewerActivity"

    invoke-virtual {v1, v2, v4}, Landroid/content/Intent;->setClassName(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    .line 955
    iget-object v2, p0, Lin/startv/hotstar/FileExplorerActivity$FileClickListener;->path:Ljava/lang/String;

    invoke-virtual {v1, p1, v2}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    .line 956
    iget-object p1, p0, Lin/startv/hotstar/FileExplorerActivity$FileClickListener;->activity:Lin/startv/hotstar/FileExplorerActivity;

    invoke-virtual {p1, v1}, Lin/startv/hotstar/FileExplorerActivity;->startActivity(Landroid/content/Intent;)V
    :try_end_3
    .catch Ljava/lang/Exception; {:try_start_3 .. :try_end_3} :catch_1

    .line 963
    goto :goto_1

    .line 957
    :catch_1
    move-exception p1

    .line 959
    :try_start_4
    new-instance p1, Landroid/content/Intent;

    iget-object v1, p0, Lin/startv/hotstar/FileExplorerActivity$FileClickListener;->activity:Lin/startv/hotstar/FileExplorerActivity;

    const-class v2, Lin/startv/hotstar/FileViewerActivity;

    invoke-direct {p1, v1, v2}, Landroid/content/Intent;-><init>(Landroid/content/Context;Ljava/lang/Class;)V

    .line 960
    iget-object v1, p0, Lin/startv/hotstar/FileExplorerActivity$FileClickListener;->path:Ljava/lang/String;

    invoke-virtual {p1, v3, v1}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    .line 961
    iget-object v1, p0, Lin/startv/hotstar/FileExplorerActivity$FileClickListener;->activity:Lin/startv/hotstar/FileExplorerActivity;

    invoke-virtual {v1, p1}, Lin/startv/hotstar/FileExplorerActivity;->startActivity(Landroid/content/Intent;)V

    .line 962
    iget-object p1, p0, Lin/startv/hotstar/FileExplorerActivity$FileClickListener;->activity:Lin/startv/hotstar/FileExplorerActivity;

    const-string v1, "DB Editor not available, opening as text"

    invoke-static {p1, v1, v0}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;

    move-result-object p1

    invoke-virtual {p1}, Landroid/widget/Toast;->show()V
    :try_end_4
    .catch Ljava/lang/Exception; {:try_start_4 .. :try_end_4} :catch_2

    goto :goto_1

    .line 972
    :goto_2
    goto :goto_3

    .line 970
    :catch_2
    move-exception p1

    .line 971
    iget-object v1, p0, Lin/startv/hotstar/FileExplorerActivity$FileClickListener;->activity:Lin/startv/hotstar/FileExplorerActivity;

    invoke-virtual {p1}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object p1

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "Error opening file: "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-static {v1, p1, v0}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;

    move-result-object p1

    invoke-virtual {p1}, Landroid/widget/Toast;->show()V

    .line 973
    :goto_3
    return-void
.end method
