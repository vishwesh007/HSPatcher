.class public Lin/startv/hotstar/DbViewerActivity$RunQueryListener;
.super Ljava/lang/Object;
.source "DbViewerActivity.java"

# interfaces
.implements Landroid/view/View$OnClickListener;

# instance fields
.field public final synthetic this$0:Lin/startv/hotstar/DbViewerActivity;

# direct methods
.method public constructor <init>(Lin/startv/hotstar/DbViewerActivity;)V
    .locals 0
    iput-object p1, p0, Lin/startv/hotstar/DbViewerActivity$RunQueryListener;->this$0:Lin/startv/hotstar/DbViewerActivity;
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    return-void
.end method

# virtual methods
.method public onClick(Landroid/view/View;)V
    .locals 3

    iget-object v0, p0, Lin/startv/hotstar/DbViewerActivity$RunQueryListener;->this$0:Lin/startv/hotstar/DbViewerActivity;

    iget-object v1, v0, Lin/startv/hotstar/DbViewerActivity;->queryInput:Landroid/widget/EditText;
    if-eqz v1, :no_input

    invoke-virtual {v1}, Landroid/widget/EditText;->getText()Landroid/text/Editable;
    move-result-object v2
    invoke-virtual {v2}, Ljava/lang/Object;->toString()Ljava/lang/String;
    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/String;->trim()Ljava/lang/String;
    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/String;->length()I
    move-result v3
    if-lez v3, :empty

    invoke-virtual {v0, v2}, Lin/startv/hotstar/DbViewerActivity;->executeQuery(Ljava/lang/String;)V
    goto :done

    :empty
    const-string v2, "Enter a SQL query first"
    const/4 v3, 0x0
    invoke-static {v0, v2, v3}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;
    move-result-object v2
    invoke-virtual {v2}, Landroid/widget/Toast;->show()V

    :no_input
    :done
    return-void
.end method
