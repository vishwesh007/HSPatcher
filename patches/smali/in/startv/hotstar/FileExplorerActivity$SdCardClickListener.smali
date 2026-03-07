.class Lin/startv/hotstar/FileExplorerActivity$SdCardClickListener;
.super Ljava/lang/Object;
.source "FileExplorerActivity.java"

# interfaces
.implements Landroid/view/View$OnClickListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lin/startv/hotstar/FileExplorerActivity;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = "SdCardClickListener"
.end annotation


# instance fields
.field activity:Lin/startv/hotstar/FileExplorerActivity;

.field final synthetic this$0:Lin/startv/hotstar/FileExplorerActivity;


# direct methods
.method constructor <init>(Lin/startv/hotstar/FileExplorerActivity;Lin/startv/hotstar/FileExplorerActivity;)V
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

    .line 773
    iput-object p1, p0, Lin/startv/hotstar/FileExplorerActivity$SdCardClickListener;->this$0:Lin/startv/hotstar/FileExplorerActivity;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p2, p0, Lin/startv/hotstar/FileExplorerActivity$SdCardClickListener;->activity:Lin/startv/hotstar/FileExplorerActivity;

    return-void
.end method


# virtual methods
.method public onClick(Landroid/view/View;)V
    .locals 1

    .line 774
    iget-object p1, p0, Lin/startv/hotstar/FileExplorerActivity$SdCardClickListener;->activity:Lin/startv/hotstar/FileExplorerActivity;

    const-string v0, "/sdcard"

    invoke-virtual {p1, v0}, Lin/startv/hotstar/FileExplorerActivity;->navigateTo(Ljava/lang/String;)V

    return-void
.end method
