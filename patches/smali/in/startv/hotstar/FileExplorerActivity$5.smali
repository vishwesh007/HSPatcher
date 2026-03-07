.class Lin/startv/hotstar/FileExplorerActivity$5;
.super Ljava/lang/Object;
.source "FileExplorerActivity.java"

# interfaces
.implements Landroid/content/DialogInterface$OnClickListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lin/startv/hotstar/FileExplorerActivity;->showSearchDialog()V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lin/startv/hotstar/FileExplorerActivity;

.field final synthetic val$selectedMode:[I


# direct methods
.method constructor <init>(Lin/startv/hotstar/FileExplorerActivity;[I)V
    .locals 0
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x8010,
            0x1010
        }
        names = {
            null,
            null
        }
    .end annotation

    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()V"
        }
    .end annotation

    .line 755
    iput-object p1, p0, Lin/startv/hotstar/FileExplorerActivity$5;->this$0:Lin/startv/hotstar/FileExplorerActivity;

    iput-object p2, p0, Lin/startv/hotstar/FileExplorerActivity$5;->val$selectedMode:[I

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onClick(Landroid/content/DialogInterface;I)V
    .locals 1

    .line 758
    iget-object p1, p0, Lin/startv/hotstar/FileExplorerActivity$5;->val$selectedMode:[I

    const/4 v0, 0x0

    aput p2, p1, v0

    .line 759
    return-void
.end method
