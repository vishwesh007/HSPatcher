.class Lin/startv/hotstar/FileViewerActivity$TextChangeWatcher$2;
.super Ljava/lang/Object;
.source "FileViewerActivity.java"

# interfaces
.implements Ljava/lang/Runnable;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lin/startv/hotstar/FileViewerActivity$TextChangeWatcher;->afterTextChanged(Landroid/text/Editable;)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$1:Lin/startv/hotstar/FileViewerActivity$TextChangeWatcher;


# direct methods
.method constructor <init>(Lin/startv/hotstar/FileViewerActivity$TextChangeWatcher;)V
    .locals 0
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x8010
        }
        names = {
            null
        }
    .end annotation

    .line 1232
    iput-object p1, p0, Lin/startv/hotstar/FileViewerActivity$TextChangeWatcher$2;->this$1:Lin/startv/hotstar/FileViewerActivity$TextChangeWatcher;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 1

    .line 1235
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity$TextChangeWatcher$2;->this$1:Lin/startv/hotstar/FileViewerActivity$TextChangeWatcher;

    iget-object v0, v0, Lin/startv/hotstar/FileViewerActivity$TextChangeWatcher;->activity:Lin/startv/hotstar/FileViewerActivity;

    invoke-virtual {v0}, Lin/startv/hotstar/FileViewerActivity;->applySyntaxHighlighting()V

    .line 1236
    return-void
.end method
