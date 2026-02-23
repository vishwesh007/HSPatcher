.class public Lin/startv/hotstar/FileExplorerActivity$ScrollEndRunnable;
.super Ljava/lang/Object;
.source "FileExplorerActivity.java"

.implements Ljava/lang/Runnable;

.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lin/startv/hotstar/FileExplorerActivity;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "ScrollEndRunnable"
.end annotation

.field public scrollView:Landroid/widget/HorizontalScrollView;

.method public constructor <init>(Landroid/widget/HorizontalScrollView;)V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lin/startv/hotstar/FileExplorerActivity$ScrollEndRunnable;->scrollView:Landroid/widget/HorizontalScrollView;
    return-void
.end method

.method public run()V
    .locals 2
    iget-object v0, p0, Lin/startv/hotstar/FileExplorerActivity$ScrollEndRunnable;->scrollView:Landroid/widget/HorizontalScrollView;

    # FOCUS_RIGHT = 0x42 (66)
    const/16 v1, 0x42
    invoke-virtual {v0, v1}, Landroid/widget/HorizontalScrollView;->fullScroll(I)Z
    return-void
.end method
