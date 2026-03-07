.class Lin/startv/hotstar/FileExplorerActivity$8;
.super Ljava/lang/Object;
.source "FileExplorerActivity.java"

# interfaces
.implements Landroid/view/View$OnClickListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lin/startv/hotstar/FileExplorerActivity;->showSearchResults(Ljava/util/ArrayList;Ljava/lang/String;)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lin/startv/hotstar/FileExplorerActivity;


# direct methods
.method constructor <init>(Lin/startv/hotstar/FileExplorerActivity;)V
    .locals 0
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x8010
        }
        names = {
            null
        }
    .end annotation

    .line 860
    iput-object p1, p0, Lin/startv/hotstar/FileExplorerActivity$8;->this$0:Lin/startv/hotstar/FileExplorerActivity;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onClick(Landroid/view/View;)V
    .locals 1

    .line 863
    iget-object p1, p0, Lin/startv/hotstar/FileExplorerActivity$8;->this$0:Lin/startv/hotstar/FileExplorerActivity;

    iget-object v0, p0, Lin/startv/hotstar/FileExplorerActivity$8;->this$0:Lin/startv/hotstar/FileExplorerActivity;

    iget-object v0, v0, Lin/startv/hotstar/FileExplorerActivity;->currentPath:Ljava/lang/String;

    invoke-virtual {p1, v0}, Lin/startv/hotstar/FileExplorerActivity;->navigateTo(Ljava/lang/String;)V

    .line 864
    return-void
.end method
