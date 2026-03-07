.class Lin/startv/hotstar/FileExplorerActivity$ScrollEndRunnable;
.super Ljava/lang/Object;
.source "FileExplorerActivity.java"

# interfaces
.implements Ljava/lang/Runnable;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lin/startv/hotstar/FileExplorerActivity;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = "ScrollEndRunnable"
.end annotation


# instance fields
.field scrollView:Landroid/widget/HorizontalScrollView;

.field final synthetic this$0:Lin/startv/hotstar/FileExplorerActivity;


# direct methods
.method constructor <init>(Lin/startv/hotstar/FileExplorerActivity;Landroid/widget/HorizontalScrollView;)V
    .locals 0
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x8010,
            0x0
        }
        names = {
            null,
            null
        }
    .end annotation

    .line 921
    iput-object p1, p0, Lin/startv/hotstar/FileExplorerActivity$ScrollEndRunnable;->this$0:Lin/startv/hotstar/FileExplorerActivity;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p2, p0, Lin/startv/hotstar/FileExplorerActivity$ScrollEndRunnable;->scrollView:Landroid/widget/HorizontalScrollView;

    return-void
.end method


# virtual methods
.method public run()V
    .locals 2

    .line 923
    iget-object v0, p0, Lin/startv/hotstar/FileExplorerActivity$ScrollEndRunnable;->scrollView:Landroid/widget/HorizontalScrollView;

    const/16 v1, 0x42

    invoke-virtual {v0, v1}, Landroid/widget/HorizontalScrollView;->fullScroll(I)Z

    .line 924
    return-void
.end method
