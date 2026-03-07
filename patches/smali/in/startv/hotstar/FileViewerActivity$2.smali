.class Lin/startv/hotstar/FileViewerActivity$2;
.super Ljava/lang/Object;
.source "FileViewerActivity.java"

# interfaces
.implements Ljava/lang/Runnable;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lin/startv/hotstar/FileViewerActivity;->onCreate(Landroid/os/Bundle;)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lin/startv/hotstar/FileViewerActivity;


# direct methods
.method constructor <init>(Lin/startv/hotstar/FileViewerActivity;)V
    .locals 0
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x8010
        }
        names = {
            null
        }
    .end annotation

    .line 833
    iput-object p1, p0, Lin/startv/hotstar/FileViewerActivity$2;->this$0:Lin/startv/hotstar/FileViewerActivity;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 1

    .line 836
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity$2;->this$0:Lin/startv/hotstar/FileViewerActivity;

    invoke-virtual {v0}, Lin/startv/hotstar/FileViewerActivity;->applySyntaxHighlighting()V

    .line 837
    return-void
.end method
