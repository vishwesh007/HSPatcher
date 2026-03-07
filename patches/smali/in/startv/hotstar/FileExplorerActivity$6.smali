.class Lin/startv/hotstar/FileExplorerActivity$6;
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

.field final synthetic val$queryInput:Landroid/widget/EditText;

.field final synthetic val$selectedMode:[I


# direct methods
.method constructor <init>(Lin/startv/hotstar/FileExplorerActivity;Landroid/widget/EditText;[I)V
    .locals 0
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x8010,
            0x1010,
            0x1010
        }
        names = {
            null,
            null,
            null
        }
    .end annotation

    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()V"
        }
    .end annotation

    .line 763
    iput-object p1, p0, Lin/startv/hotstar/FileExplorerActivity$6;->this$0:Lin/startv/hotstar/FileExplorerActivity;

    iput-object p2, p0, Lin/startv/hotstar/FileExplorerActivity$6;->val$queryInput:Landroid/widget/EditText;

    iput-object p3, p0, Lin/startv/hotstar/FileExplorerActivity$6;->val$selectedMode:[I

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onClick(Landroid/content/DialogInterface;I)V
    .locals 3

    .line 766
    iget-object p1, p0, Lin/startv/hotstar/FileExplorerActivity$6;->val$queryInput:Landroid/widget/EditText;

    invoke-virtual {p1}, Landroid/widget/EditText;->getText()Landroid/text/Editable;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object p1

    .line 767
    invoke-virtual {p1}, Ljava/lang/String;->isEmpty()Z

    move-result p2

    if-nez p2, :cond_1

    .line 768
    iget-object p2, p0, Lin/startv/hotstar/FileExplorerActivity$6;->this$0:Lin/startv/hotstar/FileExplorerActivity;

    iget-object v0, p0, Lin/startv/hotstar/FileExplorerActivity$6;->val$selectedMode:[I

    const/4 v1, 0x0

    aget v0, v0, v1

    const/4 v2, 0x1

    if-ne v0, v2, :cond_0

    const/4 v1, 0x1

    :cond_0
    invoke-virtual {p2, p1, v1}, Lin/startv/hotstar/FileExplorerActivity;->performRecursiveSearch(Ljava/lang/String;Z)V

    .line 770
    :cond_1
    return-void
.end method
