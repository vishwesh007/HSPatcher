.class Lin/startv/hotstar/FileExplorerActivity$2;
.super Ljava/lang/Object;
.source "FileExplorerActivity.java"

# interfaces
.implements Landroid/content/DialogInterface$OnClickListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lin/startv/hotstar/FileExplorerActivity;->showNewFileDialog()V
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

    .line 623
    iput-object p1, p0, Lin/startv/hotstar/FileExplorerActivity$2;->this$0:Lin/startv/hotstar/FileExplorerActivity;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onClick(Landroid/content/DialogInterface;I)V
    .locals 1

    .line 626
    iget-object p1, p0, Lin/startv/hotstar/FileExplorerActivity$2;->this$0:Lin/startv/hotstar/FileExplorerActivity;

    const/4 v0, 0x1

    if-ne p2, v0, :cond_0

    goto :goto_0

    :cond_0
    const/4 v0, 0x0

    :goto_0
    invoke-virtual {p1, v0}, Lin/startv/hotstar/FileExplorerActivity;->showNameInputDialog(Z)V

    .line 627
    return-void
.end method
