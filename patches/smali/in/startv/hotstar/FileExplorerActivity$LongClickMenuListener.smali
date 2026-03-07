.class Lin/startv/hotstar/FileExplorerActivity$LongClickMenuListener;
.super Ljava/lang/Object;
.source "FileExplorerActivity.java"

# interfaces
.implements Landroid/content/DialogInterface$OnClickListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lin/startv/hotstar/FileExplorerActivity;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = "LongClickMenuListener"
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

    .line 819
    iput-object p1, p0, Lin/startv/hotstar/FileExplorerActivity$LongClickMenuListener;->this$0:Lin/startv/hotstar/FileExplorerActivity;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 820
    iput-object p2, p0, Lin/startv/hotstar/FileExplorerActivity$LongClickMenuListener;->activity:Lin/startv/hotstar/FileExplorerActivity;

    .line 821
    iput-object p3, p0, Lin/startv/hotstar/FileExplorerActivity$LongClickMenuListener;->path:Ljava/lang/String;

    .line 822
    iput-object p4, p0, Lin/startv/hotstar/FileExplorerActivity$LongClickMenuListener;->name:Ljava/lang/String;

    .line 823
    return-void
.end method

.method private showRenameDialog()V
    .locals 8

    .line 848
    new-instance v0, Landroid/app/AlertDialog$Builder;

    iget-object v1, p0, Lin/startv/hotstar/FileExplorerActivity$LongClickMenuListener;->activity:Lin/startv/hotstar/FileExplorerActivity;

    invoke-direct {v0, v1}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    .line 849
    const-string v1, "Rename"

    invoke-virtual {v0, v1}, Landroid/app/AlertDialog$Builder;->setTitle(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    .line 851
    new-instance v2, Landroid/widget/EditText;

    iget-object v3, p0, Lin/startv/hotstar/FileExplorerActivity$LongClickMenuListener;->activity:Lin/startv/hotstar/FileExplorerActivity;

    invoke-direct {v2, v3}, Landroid/widget/EditText;-><init>(Landroid/content/Context;)V

    .line 852
    iget-object v3, p0, Lin/startv/hotstar/FileExplorerActivity$LongClickMenuListener;->name:Ljava/lang/String;

    invoke-virtual {v2, v3}, Landroid/widget/EditText;->setText(Ljava/lang/CharSequence;)V

    .line 853
    iget-object v3, p0, Lin/startv/hotstar/FileExplorerActivity$LongClickMenuListener;->activity:Lin/startv/hotstar/FileExplorerActivity;

    const/16 v4, 0x10

    invoke-virtual {v3, v4}, Lin/startv/hotstar/FileExplorerActivity;->dpToPx(I)I

    move-result v3

    iget-object v5, p0, Lin/startv/hotstar/FileExplorerActivity$LongClickMenuListener;->activity:Lin/startv/hotstar/FileExplorerActivity;

    const/16 v6, 0x8

    invoke-virtual {v5, v6}, Lin/startv/hotstar/FileExplorerActivity;->dpToPx(I)I

    move-result v5

    iget-object v7, p0, Lin/startv/hotstar/FileExplorerActivity$LongClickMenuListener;->activity:Lin/startv/hotstar/FileExplorerActivity;

    invoke-virtual {v7, v4}, Lin/startv/hotstar/FileExplorerActivity;->dpToPx(I)I

    move-result v4

    iget-object v7, p0, Lin/startv/hotstar/FileExplorerActivity$LongClickMenuListener;->activity:Lin/startv/hotstar/FileExplorerActivity;

    invoke-virtual {v7, v6}, Lin/startv/hotstar/FileExplorerActivity;->dpToPx(I)I

    move-result v6

    invoke-virtual {v2, v3, v5, v4, v6}, Landroid/widget/EditText;->setPadding(IIII)V

    .line 854
    invoke-virtual {v0, v2}, Landroid/app/AlertDialog$Builder;->setView(Landroid/view/View;)Landroid/app/AlertDialog$Builder;

    .line 856
    new-instance v3, Lin/startv/hotstar/FileExplorerActivity$LongClickMenuListener$1;

    invoke-direct {v3, p0, v2}, Lin/startv/hotstar/FileExplorerActivity$LongClickMenuListener$1;-><init>(Lin/startv/hotstar/FileExplorerActivity$LongClickMenuListener;Landroid/widget/EditText;)V

    invoke-virtual {v0, v1, v3}, Landroid/app/AlertDialog$Builder;->setPositiveButton(Ljava/lang/CharSequence;Landroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    .line 871
    const-string v1, "Cancel"

    const/4 v2, 0x0

    invoke-virtual {v0, v1, v2}, Landroid/app/AlertDialog$Builder;->setNegativeButton(Ljava/lang/CharSequence;Landroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    .line 872
    invoke-virtual {v0}, Landroid/app/AlertDialog$Builder;->show()Landroid/app/AlertDialog;

    .line 873
    return-void
.end method


# virtual methods
.method public onClick(Landroid/content/DialogInterface;I)V
    .locals 4

    .line 825
    packed-switch p2, :pswitch_data_0

    goto :goto_0

    .line 842
    :pswitch_0
    invoke-direct {p0}, Lin/startv/hotstar/FileExplorerActivity$LongClickMenuListener;->showRenameDialog()V

    goto :goto_0

    .line 834
    :pswitch_1
    new-instance p1, Landroid/app/AlertDialog$Builder;

    iget-object p2, p0, Lin/startv/hotstar/FileExplorerActivity$LongClickMenuListener;->activity:Lin/startv/hotstar/FileExplorerActivity;

    invoke-direct {p1, p2}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    .line 835
    const-string p2, "Delete"

    invoke-virtual {p1, p2}, Landroid/app/AlertDialog$Builder;->setTitle(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object p1

    iget-object v0, p0, Lin/startv/hotstar/FileExplorerActivity$LongClickMenuListener;->name:Ljava/lang/String;

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "Delete "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, "?"

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    .line 836
    invoke-virtual {p1, v0}, Landroid/app/AlertDialog$Builder;->setMessage(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object p1

    new-instance v0, Lin/startv/hotstar/FileExplorerActivity$DeleteConfirmListener;

    iget-object v1, p0, Lin/startv/hotstar/FileExplorerActivity$LongClickMenuListener;->this$0:Lin/startv/hotstar/FileExplorerActivity;

    iget-object v2, p0, Lin/startv/hotstar/FileExplorerActivity$LongClickMenuListener;->activity:Lin/startv/hotstar/FileExplorerActivity;

    iget-object v3, p0, Lin/startv/hotstar/FileExplorerActivity$LongClickMenuListener;->path:Ljava/lang/String;

    invoke-direct {v0, v1, v2, v3}, Lin/startv/hotstar/FileExplorerActivity$DeleteConfirmListener;-><init>(Lin/startv/hotstar/FileExplorerActivity;Lin/startv/hotstar/FileExplorerActivity;Ljava/lang/String;)V

    .line 837
    invoke-virtual {p1, p2, v0}, Landroid/app/AlertDialog$Builder;->setPositiveButton(Ljava/lang/CharSequence;Landroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object p1

    .line 838
    const-string p2, "Cancel"

    const/4 v0, 0x0

    invoke-virtual {p1, p2, v0}, Landroid/app/AlertDialog$Builder;->setNegativeButton(Ljava/lang/CharSequence;Landroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object p1

    .line 839
    invoke-virtual {p1}, Landroid/app/AlertDialog$Builder;->show()Landroid/app/AlertDialog;

    .line 840
    goto :goto_0

    .line 827
    :pswitch_2
    iget-object p1, p0, Lin/startv/hotstar/FileExplorerActivity$LongClickMenuListener;->activity:Lin/startv/hotstar/FileExplorerActivity;

    const-string p2, "clipboard"

    invoke-virtual {p1, p2}, Lin/startv/hotstar/FileExplorerActivity;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object p1

    check-cast p1, Landroid/content/ClipboardManager;

    .line 828
    if-eqz p1, :cond_0

    .line 829
    const-string p2, "path"

    iget-object v0, p0, Lin/startv/hotstar/FileExplorerActivity$LongClickMenuListener;->path:Ljava/lang/String;

    invoke-static {p2, v0}, Landroid/content/ClipData;->newPlainText(Ljava/lang/CharSequence;Ljava/lang/CharSequence;)Landroid/content/ClipData;

    move-result-object p2

    invoke-virtual {p1, p2}, Landroid/content/ClipboardManager;->setPrimaryClip(Landroid/content/ClipData;)V

    .line 830
    iget-object p1, p0, Lin/startv/hotstar/FileExplorerActivity$LongClickMenuListener;->activity:Lin/startv/hotstar/FileExplorerActivity;

    const-string p2, "Path copied"

    const/4 v0, 0x0

    invoke-static {p1, p2, v0}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;

    move-result-object p1

    invoke-virtual {p1}, Landroid/widget/Toast;->show()V

    .line 845
    :cond_0
    :goto_0
    return-void

    :pswitch_data_0
    .packed-switch 0x0
        :pswitch_2
        :pswitch_1
        :pswitch_0
    .end packed-switch
.end method
