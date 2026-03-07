.class Lin/startv/hotstar/FileExplorerActivity$FileLongClickListener;
.super Ljava/lang/Object;
.source "FileExplorerActivity.java"

# interfaces
.implements Landroid/view/View$OnLongClickListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lin/startv/hotstar/FileExplorerActivity;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = "FileLongClickListener"
.end annotation


# instance fields
.field activity:Lin/startv/hotstar/FileExplorerActivity;

.field name:Ljava/lang/String;

.field path:Ljava/lang/String;

.field final synthetic this$0:Lin/startv/hotstar/FileExplorerActivity;


# direct methods
.method constructor <init>(Lin/startv/hotstar/FileExplorerActivity;Lin/startv/hotstar/FileExplorerActivity;Ljava/lang/String;Ljava/lang/String;)V
    .locals 0
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x8010,
            0x0,
            0x0,
            0x0
        }
        names = {
            null,
            null,
            null,
            null
        }
    .end annotation

    .line 798
    iput-object p1, p0, Lin/startv/hotstar/FileExplorerActivity$FileLongClickListener;->this$0:Lin/startv/hotstar/FileExplorerActivity;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 799
    iput-object p2, p0, Lin/startv/hotstar/FileExplorerActivity$FileLongClickListener;->activity:Lin/startv/hotstar/FileExplorerActivity;

    .line 800
    iput-object p3, p0, Lin/startv/hotstar/FileExplorerActivity$FileLongClickListener;->path:Ljava/lang/String;

    .line 801
    iput-object p4, p0, Lin/startv/hotstar/FileExplorerActivity$FileLongClickListener;->name:Ljava/lang/String;

    .line 802
    return-void
.end method


# virtual methods
.method public onLongClick(Landroid/view/View;)Z
    .locals 7

    .line 804
    new-instance p1, Landroid/app/AlertDialog$Builder;

    iget-object v0, p0, Lin/startv/hotstar/FileExplorerActivity$FileLongClickListener;->activity:Lin/startv/hotstar/FileExplorerActivity;

    invoke-direct {p1, v0}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    .line 805
    iget-object v0, p0, Lin/startv/hotstar/FileExplorerActivity$FileLongClickListener;->name:Ljava/lang/String;

    invoke-virtual {p1, v0}, Landroid/app/AlertDialog$Builder;->setTitle(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    .line 807
    const/4 v0, 0x3

    new-array v0, v0, [Ljava/lang/String;

    const/4 v1, 0x0

    const-string v2, "Copy Path"

    aput-object v2, v0, v1

    const-string v1, "Delete"

    const/4 v2, 0x1

    aput-object v1, v0, v2

    const/4 v1, 0x2

    const-string v3, "Rename"

    aput-object v3, v0, v1

    .line 808
    new-instance v1, Lin/startv/hotstar/FileExplorerActivity$LongClickMenuListener;

    iget-object v3, p0, Lin/startv/hotstar/FileExplorerActivity$FileLongClickListener;->this$0:Lin/startv/hotstar/FileExplorerActivity;

    iget-object v4, p0, Lin/startv/hotstar/FileExplorerActivity$FileLongClickListener;->activity:Lin/startv/hotstar/FileExplorerActivity;

    iget-object v5, p0, Lin/startv/hotstar/FileExplorerActivity$FileLongClickListener;->path:Ljava/lang/String;

    iget-object v6, p0, Lin/startv/hotstar/FileExplorerActivity$FileLongClickListener;->name:Ljava/lang/String;

    invoke-direct {v1, v3, v4, v5, v6}, Lin/startv/hotstar/FileExplorerActivity$LongClickMenuListener;-><init>(Lin/startv/hotstar/FileExplorerActivity;Lin/startv/hotstar/FileExplorerActivity;Ljava/lang/String;Ljava/lang/String;)V

    invoke-virtual {p1, v0, v1}, Landroid/app/AlertDialog$Builder;->setItems([Ljava/lang/CharSequence;Landroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    .line 809
    invoke-virtual {p1}, Landroid/app/AlertDialog$Builder;->show()Landroid/app/AlertDialog;

    .line 810
    return v2
.end method
