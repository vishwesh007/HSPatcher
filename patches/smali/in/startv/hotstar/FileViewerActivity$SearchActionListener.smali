.class public Lin/startv/hotstar/FileViewerActivity$SearchActionListener;
.super Ljava/lang/Object;
.source "FileViewerActivity.java"

.implements Landroid/view/View$OnClickListener;

.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lin/startv/hotstar/FileViewerActivity;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "SearchActionListener"
.end annotation

.field public outer:Lin/startv/hotstar/FileViewerActivity;
.field public action:I

.method public constructor <init>(Lin/startv/hotstar/FileViewerActivity;I)V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;->outer:Lin/startv/hotstar/FileViewerActivity;
    iput p2, p0, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;->action:I
    return-void
.end method

.method public onClick(Landroid/view/View;)V
    .locals 3
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;->outer:Lin/startv/hotstar/FileViewerActivity;
    iget v1, p0, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;->action:I

    # action 0 = toggle search
    if-nez v1, :not_0
    invoke-virtual {v0}, Lin/startv/hotstar/FileViewerActivity;->toggleSearch()V
    return-void

    # action 1 = find next
    :not_0
    const/4 v2, 0x1
    if-ne v1, v2, :not_1
    invoke-virtual {v0}, Lin/startv/hotstar/FileViewerActivity;->findNext()V
    return-void

    # action 2 = find prev
    :not_1
    const/4 v2, 0x2
    if-ne v1, v2, :not_2
    invoke-virtual {v0}, Lin/startv/hotstar/FileViewerActivity;->findPrev()V
    return-void

    # action 3 = replace
    :not_2
    const/4 v2, 0x3
    if-ne v1, v2, :not_3
    invoke-virtual {v0}, Lin/startv/hotstar/FileViewerActivity;->doReplace()V
    return-void

    # action 4 = replace all
    :not_3
    const/4 v2, 0x4
    if-ne v1, v2, :not_4
    invoke-virtual {v0}, Lin/startv/hotstar/FileViewerActivity;->doReplaceAll()V
    return-void

    # action 5 = close search
    :not_4
    const/4 v2, 0x5
    if-ne v1, v2, :not_5
    iget-object v0, v0, Lin/startv/hotstar/FileViewerActivity;->searchContainer:Landroid/widget/LinearLayout;
    const/16 v1, 0x8
    invoke-virtual {v0, v1}, Landroid/view/View;->setVisibility(I)V
    return-void

    # action 6 = zoom in
    :not_5
    const/4 v2, 0x6
    if-ne v1, v2, :not_6
    invoke-virtual {v0}, Lin/startv/hotstar/FileViewerActivity;->zoomIn()V
    return-void

    # action 7 = zoom out
    :not_6
    invoke-virtual {v0}, Lin/startv/hotstar/FileViewerActivity;->zoomOut()V
    return-void
.end method
