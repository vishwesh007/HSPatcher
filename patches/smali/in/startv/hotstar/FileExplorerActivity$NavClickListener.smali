.class Lin/startv/hotstar/FileExplorerActivity$NavClickListener;
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
    name = "NavClickListener"
.end annotation


# instance fields
.field activity:Lin/startv/hotstar/FileExplorerActivity;

.field path:Ljava/lang/String;

.field final synthetic this$0:Lin/startv/hotstar/FileExplorerActivity;


# direct methods
.method constructor <init>(Lin/startv/hotstar/FileExplorerActivity;Lin/startv/hotstar/FileExplorerActivity;Ljava/lang/String;)V
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

    .line 914
    iput-object p1, p0, Lin/startv/hotstar/FileExplorerActivity$NavClickListener;->this$0:Lin/startv/hotstar/FileExplorerActivity;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p2, p0, Lin/startv/hotstar/FileExplorerActivity$NavClickListener;->activity:Lin/startv/hotstar/FileExplorerActivity;

    iput-object p3, p0, Lin/startv/hotstar/FileExplorerActivity$NavClickListener;->path:Ljava/lang/String;

    return-void
.end method


# virtual methods
.method public onClick(Landroid/view/View;)V
    .locals 1

    .line 915
    iget-object p1, p0, Lin/startv/hotstar/FileExplorerActivity$NavClickListener;->activity:Lin/startv/hotstar/FileExplorerActivity;

    iget-object v0, p0, Lin/startv/hotstar/FileExplorerActivity$NavClickListener;->path:Ljava/lang/String;

    invoke-virtual {p1, v0}, Lin/startv/hotstar/FileExplorerActivity;->navigateTo(Ljava/lang/String;)V

    return-void
.end method
