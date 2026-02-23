.class Lin/startv/hotstar/DebugPanelActivity$SaveRulesListener;
.super Ljava/lang/Object;
.source "DebugPanelActivity.java"

.implements Landroid/view/View$OnClickListener;

.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lin/startv/hotstar/DebugPanelActivity;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = "SaveRulesListener"
.end annotation


# instance fields
.field final synthetic this$0:Lin/startv/hotstar/DebugPanelActivity;


# direct methods
.method constructor <init>(Lin/startv/hotstar/DebugPanelActivity;)V
    .locals 0
    iput-object p1, p0, Lin/startv/hotstar/DebugPanelActivity$SaveRulesListener;->this$0:Lin/startv/hotstar/DebugPanelActivity;
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    return-void
.end method


# virtual methods
.method public onClick(Landroid/view/View;)V
    .locals 3

    iget-object v0, p0, Lin/startv/hotstar/DebugPanelActivity$SaveRulesListener;->this$0:Lin/startv/hotstar/DebugPanelActivity;

    # Get text from EditText
    iget-object v1, v0, Lin/startv/hotstar/DebugPanelActivity;->rulesEdit:Landroid/widget/EditText;
    invoke-virtual {v1}, Landroid/widget/EditText;->getText()Landroid/text/Editable;
    move-result-object v1
    invoke-virtual {v1}, Ljava/lang/Object;->toString()Ljava/lang/String;
    move-result-object v1

    # Write to file
    const-string v2, "blocking_hotstar.txt"
    invoke-static {v2}, Lin/startv/hotstar/HSPatchConfig;->getFilePath(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v2
    invoke-virtual {v0, v2, v1}, Lin/startv/hotstar/DebugPanelActivity;->writeFile(Ljava/lang/String;Ljava/lang/String;)V

    # Toast
    const-string v1, "\u2705 Rules saved!"
    const/4 v2, 0x0
    invoke-static {v0, v1, v2}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;
    move-result-object v1
    invoke-virtual {v1}, Landroid/widget/Toast;->show()V

    return-void
.end method