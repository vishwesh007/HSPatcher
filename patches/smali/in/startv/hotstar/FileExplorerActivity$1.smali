.class Lin/startv/hotstar/FileExplorerActivity$1;
.super Ljava/lang/Object;
.source "FileExplorerActivity.java"

# interfaces
.implements Landroid/view/View$OnClickListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lin/startv/hotstar/FileExplorerActivity;->onCreate(Landroid/os/Bundle;)V
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

    .line 520
    iput-object p1, p0, Lin/startv/hotstar/FileExplorerActivity$1;->this$0:Lin/startv/hotstar/FileExplorerActivity;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onClick(Landroid/view/View;)V
    .locals 0

    .line 523
    iget-object p1, p0, Lin/startv/hotstar/FileExplorerActivity$1;->this$0:Lin/startv/hotstar/FileExplorerActivity;

    invoke-virtual {p1}, Lin/startv/hotstar/FileExplorerActivity;->showNewFileDialog()V

    .line 524
    return-void
.end method
