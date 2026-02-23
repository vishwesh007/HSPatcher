.class public Lin/startv/hotstar/LogViewerActivity$ActionListener;
.super Ljava/lang/Object;
.source "LogViewerActivity.java"
.implements Landroid/view/View$OnClickListener;

.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lin/startv/hotstar/LogViewerActivity;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x1
    name = "ActionListener"
.end annotation

.field public outer:Lin/startv/hotstar/LogViewerActivity;
.field public action:I

.method public constructor <init>(Lin/startv/hotstar/LogViewerActivity;I)V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lin/startv/hotstar/LogViewerActivity$ActionListener;->outer:Lin/startv/hotstar/LogViewerActivity;
    iput p2, p0, Lin/startv/hotstar/LogViewerActivity$ActionListener;->action:I
    return-void
.end method

# Actions: 0=back, 1=toggleSearch, 2=findNext, 3=refresh, 4=toggleStream, 5=scrollBottom, 6=closeSearch
.method public onClick(Landroid/view/View;)V
    .locals 3
    iget v0, p0, Lin/startv/hotstar/LogViewerActivity$ActionListener;->action:I
    iget-object v1, p0, Lin/startv/hotstar/LogViewerActivity$ActionListener;->outer:Lin/startv/hotstar/LogViewerActivity;

    if-nez v0, :check1
    # 0 = back
    invoke-virtual {v1}, Landroid/app/Activity;->finish()V
    return-void

    :check1
    const/4 v2, 0x1
    if-ne v0, v2, :check2
    # 1 = toggleSearch
    invoke-virtual {v1}, Lin/startv/hotstar/LogViewerActivity;->toggleSearch()V
    return-void

    :check2
    const/4 v2, 0x2
    if-ne v0, v2, :check3
    # 2 = findNext
    invoke-virtual {v1}, Lin/startv/hotstar/LogViewerActivity;->findNextLog()V
    return-void

    :check3
    const/4 v2, 0x3
    if-ne v0, v2, :check4
    # 3 = refresh
    invoke-virtual {v1}, Lin/startv/hotstar/LogViewerActivity;->refreshLog()V
    return-void

    :check4
    const/4 v2, 0x4
    if-ne v0, v2, :check5
    # 4 = toggleStream
    invoke-virtual {v1}, Lin/startv/hotstar/LogViewerActivity;->toggleStreaming()V
    return-void

    :check5
    const/4 v2, 0x5
    if-ne v0, v2, :check6
    # 5 = scroll bottom
    iget-object v2, v1, Lin/startv/hotstar/LogViewerActivity;->logScrollView:Landroid/widget/ScrollView;
    if-eqz v2, :end_act
    const/16 v0, 0x82
    invoke-virtual {v2, v0}, Landroid/widget/ScrollView;->fullScroll(I)Z
    return-void

    :check6
    const/4 v2, 0x6
    if-ne v0, v2, :end_act
    # 6 = close search
    iget-object v2, v1, Lin/startv/hotstar/LogViewerActivity;->searchContainer:Landroid/widget/LinearLayout;
    if-eqz v2, :end_act
    const/16 v0, 0x8
    invoke-virtual {v2, v0}, Landroid/view/View;->setVisibility(I)V

    :end_act
    return-void
.end method
