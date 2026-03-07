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

    .line 1247
    iput-object p1, p0, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;->this$0:Lin/startv/hotstar/FileViewerActivity;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 1248
    iput-object p2, p0, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;->activity:Lin/startv/hotstar/FileViewerActivity;

    .line 1249
    iput p3, p0, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;->action:I

    .line 1250
    return-void
.end method


# virtual methods
.method public onClick(Landroid/view/View;)V
    .locals 0

    .line 1253
    iget p1, p0, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;->action:I

    packed-switch p1, :pswitch_data_0

    goto :goto_0

    .line 1266
    :pswitch_0
    iget-object p1, p0, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;->activity:Lin/startv/hotstar/FileViewerActivity;

    invoke-virtual {p1}, Lin/startv/hotstar/FileViewerActivity;->toggleRegex()V

    goto :goto_0

    .line 1265
    :pswitch_1
    iget-object p1, p0, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;->activity:Lin/startv/hotstar/FileViewerActivity;

    invoke-virtual {p1}, Lin/startv/hotstar/FileViewerActivity;->toggleWholeWord()V

    goto :goto_0

    .line 1264
    :pswitch_2
    iget-object p1, p0, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;->activity:Lin/startv/hotstar/FileViewerActivity;

    invoke-virtual {p1}, Lin/startv/hotstar/FileViewerActivity;->toggleMatchCase()V

    goto :goto_0

    .line 1263
    :pswitch_3
    iget-object p1, p0, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;->activity:Lin/startv/hotstar/FileViewerActivity;

    invoke-virtual {p1}, Lin/startv/hotstar/FileViewerActivity;->redo()V

    goto :goto_0

    .line 1262
    :pswitch_4
    iget-object p1, p0, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;->activity:Lin/startv/hotstar/FileViewerActivity;

    invoke-virtual {p1}, Lin/startv/hotstar/FileViewerActivity;->undo()V

    goto :goto_0

    .line 1261
    :pswitch_5
    iget-object p1, p0, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;->activity:Lin/startv/hotstar/FileViewerActivity;

    invoke-virtual {p1}, Lin/startv/hotstar/FileViewerActivity;->zoomOut()V

    goto :goto_0

    .line 1260
    :pswitch_6
    iget-object p1, p0, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;->activity:Lin/startv/hotstar/FileViewerActivity;

    invoke-virtual {p1}, Lin/startv/hotstar/FileViewerActivity;->zoomIn()V

    goto :goto_0

    .line 1259
    :pswitch_7
    iget-object p1, p0, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;->activity:Lin/startv/hotstar/FileViewerActivity;

    invoke-virtual {p1}, Lin/startv/hotstar/FileViewerActivity;->toggleSearch()V

    goto :goto_0

    .line 1258
    :pswitch_8
    iget-object p1, p0, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;->activity:Lin/startv/hotstar/FileViewerActivity;

    invoke-virtual {p1}, Lin/startv/hotstar/FileViewerActivity;->doReplaceAll()V

    goto :goto_0

    .line 1257
    :pswitch_9
    iget-object p1, p0, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;->activity:Lin/startv/hotstar/FileViewerActivity;

    invoke-virtual {p1}, Lin/startv/hotstar/FileViewerActivity;->doReplace()V

    goto :goto_0

    .line 1256
    :pswitch_a
    iget-object p1, p0, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;->activity:Lin/startv/hotstar/FileViewerActivity;

    invoke-virtual {p1}, Lin/startv/hotstar/FileViewerActivity;->findPrev()V

    goto :goto_0

    .line 1255
    :pswitch_b
    iget-object p1, p0, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;->activity:Lin/startv/hotstar/FileViewerActivity;

    invoke-virtual {p1}, Lin/startv/hotstar/FileViewerActivity;->findNext()V

    goto :goto_0

    .line 1254
    :pswitch_c
    iget-object p1, p0, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;->activity:Lin/startv/hotstar/FileViewerActivity;

    invoke-virtual {p1}, Lin/startv/hotstar/FileViewerActivity;->toggleSearch()V

    .line 1268
    :goto_0
    return-void

    :pswitch_data_0
    .packed-switch 0x0
        :pswitch_c
        :pswitch_b
        :pswitch_a
        :pswitch_9
        :pswitch_8
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
