.class Lin/startv/hotstar/FileViewerActivity$1;
.super Ljava/lang/Object;
.source "FileViewerActivity.java"

# interfaces
.implements Landroid/view/View$OnClickListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lin/startv/hotstar/FileViewerActivity;->createSymbolButton(Ljava/lang/String;)Landroid/widget/TextView;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lin/startv/hotstar/FileViewerActivity;

.field final synthetic val$insertText:Ljava/lang/String;


# direct methods
.method constructor <init>(Lin/startv/hotstar/FileViewerActivity;Ljava/lang/String;)V
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

    .line 492
    iput-object p1, p0, Lin/startv/hotstar/FileViewerActivity$1;->this$0:Lin/startv/hotstar/FileViewerActivity;

    iput-object p2, p0, Lin/startv/hotstar/FileViewerActivity$1;->val$insertText:Ljava/lang/String;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onClick(Landroid/view/View;)V
    .locals 2

    .line 495
    iget-object p1, p0, Lin/startv/hotstar/FileViewerActivity$1;->this$0:Lin/startv/hotstar/FileViewerActivity;

    iget-object p1, p1, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    if-eqz p1, :cond_0

    .line 496
    iget-object p1, p0, Lin/startv/hotstar/FileViewerActivity$1;->this$0:Lin/startv/hotstar/FileViewerActivity;

    iget-object p1, p1, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    invoke-virtual {p1}, Landroid/widget/EditText;->getSelectionStart()I

    move-result p1

    .line 497
    if-ltz p1, :cond_0

    .line 498
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity$1;->this$0:Lin/startv/hotstar/FileViewerActivity;

    iget-object v0, v0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    invoke-virtual {v0}, Landroid/widget/EditText;->getText()Landroid/text/Editable;

    move-result-object v0

    iget-object v1, p0, Lin/startv/hotstar/FileViewerActivity$1;->val$insertText:Ljava/lang/String;

    invoke-interface {v0, p1, v1}, Landroid/text/Editable;->insert(ILjava/lang/CharSequence;)Landroid/text/Editable;

    .line 501
    :cond_0
    return-void
.end method
