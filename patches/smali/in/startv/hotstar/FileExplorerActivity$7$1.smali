.class Lin/startv/hotstar/FileExplorerActivity$7$1;
.super Ljava/lang/Object;
.source "FileExplorerActivity.java"

# interfaces
.implements Ljava/lang/Runnable;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lin/startv/hotstar/FileExplorerActivity$7;->run()V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$1:Lin/startv/hotstar/FileExplorerActivity$7;


# direct methods
.method constructor <init>(Lin/startv/hotstar/FileExplorerActivity$7;)V
    .locals 0
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x8010
        }
        names = {
            null
        }
    .end annotation

    .line 789
    iput-object p1, p0, Lin/startv/hotstar/FileExplorerActivity$7$1;->this$1:Lin/startv/hotstar/FileExplorerActivity$7;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 3

    .line 792
    iget-object v0, p0, Lin/startv/hotstar/FileExplorerActivity$7$1;->this$1:Lin/startv/hotstar/FileExplorerActivity$7;

    iget-object v0, v0, Lin/startv/hotstar/FileExplorerActivity$7;->this$0:Lin/startv/hotstar/FileExplorerActivity;

    iget-object v1, p0, Lin/startv/hotstar/FileExplorerActivity$7$1;->this$1:Lin/startv/hotstar/FileExplorerActivity$7;

    iget-object v1, v1, Lin/startv/hotstar/FileExplorerActivity$7;->val$results:Ljava/util/ArrayList;

    iget-object v2, p0, Lin/startv/hotstar/FileExplorerActivity$7$1;->this$1:Lin/startv/hotstar/FileExplorerActivity$7;

    iget-object v2, v2, Lin/startv/hotstar/FileExplorerActivity$7;->val$query:Ljava/lang/String;

    invoke-virtual {v0, v1, v2}, Lin/startv/hotstar/FileExplorerActivity;->showSearchResults(Ljava/util/ArrayList;Ljava/lang/String;)V

    .line 793
    return-void
.end method
