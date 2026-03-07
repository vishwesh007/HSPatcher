.class Lin/startv/hotstar/FileViewerActivity$SearchActionListener;
.super Ljava/lang/Object;
.source "FileViewerActivity.java"

# interfaces
.implements Landroid/view/View$OnClickListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lin/startv/hotstar/FileViewerActivity;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = "SearchActionListener"
.end annotation


# instance fields
.field public action:I

.field activity:Lin/startv/hotstar/FileViewerActivity;

.field final synthetic this$0:Lin/startv/hotstar/FileViewerActivity;


# direct methods
.method constructor <init>(Lin/startv/hotstar/FileViewerActivity;Lin/startv/hotstar/FileViewerActivity;I)V
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

    .line 1008
    iput-object p1, p0, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;->this$0:Lin/startv/hotstar/FileViewerActivity;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 1009
    iput-object p2, p0, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;->activity:Lin/startv/hotstar/FileViewerActivity;

    .line 1010
    iput p3, p0, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;->action:I

    .line 1011
    return-void
.end method


# virtual methods
.method public onClick(Landroid/view/View;)V
    .locals 0

    .line 1014
    iget p1, p0, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;->action:I

    packed-switch p1, :pswitch_data_0

    goto :goto_0

    .line 1022
    :pswitch_0
    iget-object p1, p0, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;->activity:Lin/startv/hotstar/FileViewerActivity;

    invoke-virtual {p1}, Lin/startv/hotstar/FileViewerActivity;->zoomOut()V

    goto :goto_0

    .line 1021
    :pswitch_1
    iget-object p1, p0, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;->activity:Lin/startv/hotstar/FileViewerActivity;

    invoke-virtual {p1}, Lin/startv/hotstar/FileViewerActivity;->zoomIn()V

    goto :goto_0

    .line 1020
    :pswitch_2
    iget-object p1, p0, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;->activity:Lin/startv/hotstar/FileViewerActivity;

    invoke-virtual {p1}, Lin/startv/hotstar/FileViewerActivity;->toggleSearch()V

    goto :goto_0

    .line 1019
    :pswitch_3
    iget-object p1, p0, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;->activity:Lin/startv/hotstar/FileViewerActivity;

    invoke-virtual {p1}, Lin/startv/hotstar/FileViewerActivity;->doReplaceAll()V

    goto :goto_0

    .line 1018
    :pswitch_4
    iget-object p1, p0, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;->activity:Lin/startv/hotstar/FileViewerActivity;

    invoke-virtual {p1}, Lin/startv/hotstar/FileViewerActivity;->doReplace()V

    goto :goto_0

    .line 1017
    :pswitch_5
    iget-object p1, p0, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;->activity:Lin/startv/hotstar/FileViewerActivity;

    invoke-virtual {p1}, Lin/startv/hotstar/FileViewerActivity;->findPrev()V

    goto :goto_0

    .line 1016
    :pswitch_6
    iget-object p1, p0, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;->activity:Lin/startv/hotstar/FileViewerActivity;

    invoke-virtual {p1}, Lin/startv/hotstar/FileViewerActivity;->findNext()V

    goto :goto_0

    .line 1015
    :pswitch_7
    iget-object p1, p0, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;->activity:Lin/startv/hotstar/FileViewerActivity;

    invoke-virtual {p1}, Lin/startv/hotstar/FileViewerActivity;->toggleSearch()V

    .line 1024
    :goto_0
    return-void

    :pswitch_data_0
    .packed-switch 0x0
        :pswitch_7
        :pswitch_6
        :pswitch_5
        :pswitch_4
        :pswitch_3
        :pswitch_2
        :pswitch_1
        :pswitch_0
    .end packed-switch
.end method
