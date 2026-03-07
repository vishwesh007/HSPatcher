.class public Lin/startv/hotstar/DbViewerActivity$TableClickListener;
.super Ljava/lang/Object;
.source "DbViewerActivity.java"

# interfaces
.implements Landroid/view/View$OnClickListener;

# instance fields
.field public final synthetic this$0:Lin/startv/hotstar/DbViewerActivity;
.field public tableName:Ljava/lang/String;

# direct methods
.method public constructor <init>(Lin/startv/hotstar/DbViewerActivity;Ljava/lang/String;)V
    .locals 0
    iput-object p1, p0, Lin/startv/hotstar/DbViewerActivity$TableClickListener;->this$0:Lin/startv/hotstar/DbViewerActivity;
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p2, p0, Lin/startv/hotstar/DbViewerActivity$TableClickListener;->tableName:Ljava/lang/String;
    return-void
.end method

# virtual methods
.method public onClick(Landroid/view/View;)V
    .locals 3

    iget-object v0, p0, Lin/startv/hotstar/DbViewerActivity$TableClickListener;->this$0:Lin/startv/hotstar/DbViewerActivity;
    iget-object v1, p0, Lin/startv/hotstar/DbViewerActivity$TableClickListener;->tableName:Ljava/lang/String;

    # Build: SELECT * FROM "tableName" LIMIT 500
    new-instance v2, Ljava/lang/StringBuilder;
    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V
    const-string v3, "SELECT * FROM \""
    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v2, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v3, "\" LIMIT 500"
    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v2

    # Also set query input text
    iget-object v3, v0, Lin/startv/hotstar/DbViewerActivity;->queryInput:Landroid/widget/EditText;
    if-eqz v3, :no_input
    invoke-virtual {v3, v2}, Landroid/widget/EditText;->setText(Ljava/lang/CharSequence;)V
    :no_input

    invoke-virtual {v0, v2}, Lin/startv/hotstar/DbViewerActivity;->executeQuery(Ljava/lang/String;)V
    return-void
.end method
