.class Lin/startv/hotstar/FileExplorerActivity$7;
.super Ljava/lang/Object;
.source "FileExplorerActivity.java"

# interfaces
.implements Ljava/lang/Runnable;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lin/startv/hotstar/FileExplorerActivity;->performRecursiveSearch(Ljava/lang/String;Z)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lin/startv/hotstar/FileExplorerActivity;

.field final synthetic val$lowerQuery:Ljava/lang/String;

.field final synthetic val$query:Ljava/lang/String;

.field final synthetic val$results:Ljava/util/ArrayList;

.field final synthetic val$searchContent:Z


# direct methods
.method constructor <init>(Lin/startv/hotstar/FileExplorerActivity;Ljava/lang/String;ZLjava/util/ArrayList;Ljava/lang/String;)V
    .locals 0
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x8010,
            0x1010,
            0x1010,
            0x1010,
            0x1010
        }
        names = {
            null,
            null,
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

    .line 784
    iput-object p1, p0, Lin/startv/hotstar/FileExplorerActivity$7;->this$0:Lin/startv/hotstar/FileExplorerActivity;

    iput-object p2, p0, Lin/startv/hotstar/FileExplorerActivity$7;->val$lowerQuery:Ljava/lang/String;

    iput-boolean p3, p0, Lin/startv/hotstar/FileExplorerActivity$7;->val$searchContent:Z

    iput-object p4, p0, Lin/startv/hotstar/FileExplorerActivity$7;->val$results:Ljava/util/ArrayList;

    iput-object p5, p0, Lin/startv/hotstar/FileExplorerActivity$7;->val$query:Ljava/lang/String;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 6

    .line 787
    iget-object v0, p0, Lin/startv/hotstar/FileExplorerActivity$7;->this$0:Lin/startv/hotstar/FileExplorerActivity;

    new-instance v1, Ljava/io/File;

    iget-object v2, p0, Lin/startv/hotstar/FileExplorerActivity$7;->this$0:Lin/startv/hotstar/FileExplorerActivity;

    iget-object v2, v2, Lin/startv/hotstar/FileExplorerActivity;->currentPath:Ljava/lang/String;

    invoke-direct {v1, v2}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    iget-object v2, p0, Lin/startv/hotstar/FileExplorerActivity$7;->val$lowerQuery:Ljava/lang/String;

    iget-boolean v3, p0, Lin/startv/hotstar/FileExplorerActivity$7;->val$searchContent:Z

    iget-object v4, p0, Lin/startv/hotstar/FileExplorerActivity$7;->val$results:Ljava/util/ArrayList;

    const/4 v5, 0x0

    invoke-virtual/range {v0 .. v5}, Lin/startv/hotstar/FileExplorerActivity;->searchRecursive(Ljava/io/File;Ljava/lang/String;ZLjava/util/ArrayList;I)V

    .line 789
    iget-object v0, p0, Lin/startv/hotstar/FileExplorerActivity$7;->this$0:Lin/startv/hotstar/FileExplorerActivity;

    new-instance v1, Lin/startv/hotstar/FileExplorerActivity$7$1;

    invoke-direct {v1, p0}, Lin/startv/hotstar/FileExplorerActivity$7$1;-><init>(Lin/startv/hotstar/FileExplorerActivity$7;)V

    invoke-virtual {v0, v1}, Lin/startv/hotstar/FileExplorerActivity;->runOnUiThread(Ljava/lang/Runnable;)V

    .line 795
    return-void
.end method
