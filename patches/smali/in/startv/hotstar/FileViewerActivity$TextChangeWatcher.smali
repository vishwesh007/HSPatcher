.class Lin/startv/hotstar/FileViewerActivity$TextChangeWatcher;
.super Ljava/lang/Object;
.source "FileViewerActivity.java"

# interfaces
.implements Landroid/text/TextWatcher;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lin/startv/hotstar/FileViewerActivity;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = "TextChangeWatcher"
.end annotation


# instance fields
.field activity:Lin/startv/hotstar/FileViewerActivity;

.field final synthetic this$0:Lin/startv/hotstar/FileViewerActivity;


# direct methods
.method constructor <init>(Lin/startv/hotstar/FileViewerActivity;Lin/startv/hotstar/FileViewerActivity;)V
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

    .line 980
    iput-object p1, p0, Lin/startv/hotstar/FileViewerActivity$TextChangeWatcher;->this$0:Lin/startv/hotstar/FileViewerActivity;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p2, p0, Lin/startv/hotstar/FileViewerActivity$TextChangeWatcher;->activity:Lin/startv/hotstar/FileViewerActivity;

    return-void
.end method


# virtual methods
.method public afterTextChanged(Landroid/text/Editable;)V
    .locals 3

    .line 985
    iget-object p1, p0, Lin/startv/hotstar/FileViewerActivity$TextChangeWatcher;->activity:Lin/startv/hotstar/FileViewerActivity;

    const/4 v0, 0x1

    iput-boolean v0, p1, Lin/startv/hotstar/FileViewerActivity;->isEdited:Z

    .line 986
    iget-object p1, p0, Lin/startv/hotstar/FileViewerActivity$TextChangeWatcher;->activity:Lin/startv/hotstar/FileViewerActivity;

    invoke-virtual {p1}, Lin/startv/hotstar/FileViewerActivity;->updateLineNumbers()V

    .line 987
    iget-object p1, p0, Lin/startv/hotstar/FileViewerActivity$TextChangeWatcher;->activity:Lin/startv/hotstar/FileViewerActivity;

    invoke-virtual {p1}, Lin/startv/hotstar/FileViewerActivity;->updateStatusBar()V

    .line 990
    iget-object p1, p0, Lin/startv/hotstar/FileViewerActivity$TextChangeWatcher;->activity:Lin/startv/hotstar/FileViewerActivity;

    iget-object p1, p1, Lin/startv/hotstar/FileViewerActivity;->highlightRunnable:Ljava/lang/Runnable;

    if-eqz p1, :cond_0

    .line 991
    iget-object p1, p0, Lin/startv/hotstar/FileViewerActivity$TextChangeWatcher;->activity:Lin/startv/hotstar/FileViewerActivity;

    iget-object p1, p1, Lin/startv/hotstar/FileViewerActivity;->handler:Landroid/os/Handler;

    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity$TextChangeWatcher;->activity:Lin/startv/hotstar/FileViewerActivity;

    iget-object v0, v0, Lin/startv/hotstar/FileViewerActivity;->highlightRunnable:Ljava/lang/Runnable;

    invoke-virtual {p1, v0}, Landroid/os/Handler;->removeCallbacks(Ljava/lang/Runnable;)V

    .line 993
    :cond_0
    iget-object p1, p0, Lin/startv/hotstar/FileViewerActivity$TextChangeWatcher;->activity:Lin/startv/hotstar/FileViewerActivity;

    new-instance v0, Lin/startv/hotstar/FileViewerActivity$TextChangeWatcher$1;

    invoke-direct {v0, p0}, Lin/startv/hotstar/FileViewerActivity$TextChangeWatcher$1;-><init>(Lin/startv/hotstar/FileViewerActivity$TextChangeWatcher;)V

    iput-object v0, p1, Lin/startv/hotstar/FileViewerActivity;->highlightRunnable:Ljava/lang/Runnable;

    .line 999
    iget-object p1, p0, Lin/startv/hotstar/FileViewerActivity$TextChangeWatcher;->activity:Lin/startv/hotstar/FileViewerActivity;

    iget-object p1, p1, Lin/startv/hotstar/FileViewerActivity;->handler:Landroid/os/Handler;

    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity$TextChangeWatcher;->activity:Lin/startv/hotstar/FileViewerActivity;

    iget-object v0, v0, Lin/startv/hotstar/FileViewerActivity;->highlightRunnable:Ljava/lang/Runnable;

    const-wide/16 v1, 0x3e8

    invoke-virtual {p1, v0, v1, v2}, Landroid/os/Handler;->postDelayed(Ljava/lang/Runnable;J)Z

    .line 1000
    return-void
.end method

.method public beforeTextChanged(Ljava/lang/CharSequence;III)V
    .locals 0

    .line 982
    return-void
.end method

.method public onTextChanged(Ljava/lang/CharSequence;III)V
    .locals 0

    .line 983
    return-void
.end method
