.class Lin/startv/hotstar/FileViewerActivity$DiscardClickListener;
.super Ljava/lang/Object;
.source "FileViewerActivity.java"

# interfaces
.implements Landroid/content/DialogInterface$OnClickListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lin/startv/hotstar/FileViewerActivity;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = "DiscardClickListener"
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

    .line 971
    iput-object p1, p0, Lin/startv/hotstar/FileViewerActivity$DiscardClickListener;->this$0:Lin/startv/hotstar/FileViewerActivity;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p2, p0, Lin/startv/hotstar/FileViewerActivity$DiscardClickListener;->activity:Lin/startv/hotstar/FileViewerActivity;

    return-void
.end method


# virtual methods
.method public onClick(Landroid/content/DialogInterface;I)V
    .locals 0

    .line 973
    iget-object p1, p0, Lin/startv/hotstar/FileViewerActivity$DiscardClickListener;->activity:Lin/startv/hotstar/FileViewerActivity;

    invoke-virtual {p1}, Lin/startv/hotstar/FileViewerActivity;->finish()V

    .line 974
    return-void
.end method
