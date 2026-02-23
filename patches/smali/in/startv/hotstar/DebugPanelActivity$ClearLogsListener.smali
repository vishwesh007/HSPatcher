.class Lin/startv/hotstar/DebugPanelActivity$ClearLogsListener;
.super Ljava/lang/Object;
.source "DebugPanelActivity.java"

.implements Landroid/view/View$OnClickListener;

.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lin/startv/hotstar/DebugPanelActivity;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = "ClearLogsListener"
.end annotation


# instance fields
.field final synthetic this$0:Lin/startv/hotstar/DebugPanelActivity;


# direct methods
.method constructor <init>(Lin/startv/hotstar/DebugPanelActivity;)V
    .locals 0
    iput-object p1, p0, Lin/startv/hotstar/DebugPanelActivity$ClearLogsListener;->this$0:Lin/startv/hotstar/DebugPanelActivity;
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    return-void
.end method


# virtual methods
.method public onClick(Landroid/view/View;)V
    .locals 2

    iget-object v0, p0, Lin/startv/hotstar/DebugPanelActivity$ClearLogsListener;->this$0:Lin/startv/hotstar/DebugPanelActivity;

    # Clear all log files
    const-string v1, "request_logs.txt"
    invoke-static {v1}, Lin/startv/hotstar/HSPatchConfig;->getFilePath(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v1
    invoke-virtual {v0, v1}, Lin/startv/hotstar/DebugPanelActivity;->clearFile(Ljava/lang/String;)V

    const-string v1, "activity_logs.txt"
    invoke-static {v1}, Lin/startv/hotstar/HSPatchConfig;->getFilePath(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v1
    invoke-virtual {v0, v1}, Lin/startv/hotstar/DebugPanelActivity;->clearFile(Ljava/lang/String;)V

    const-string v1, "urllogs.txt"
    invoke-static {v1}, Lin/startv/hotstar/HSPatchConfig;->getFilePath(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v1
    invoke-virtual {v0, v1}, Lin/startv/hotstar/DebugPanelActivity;->clearFile(Ljava/lang/String;)V

    const-string v1, "blocked_urls.txt"
    invoke-static {v1}, Lin/startv/hotstar/HSPatchConfig;->getFilePath(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v1
    invoke-virtual {v0, v1}, Lin/startv/hotstar/DebugPanelActivity;->clearFile(Ljava/lang/String;)V

    # Clear log view
    iget-object v1, v0, Lin/startv/hotstar/DebugPanelActivity;->logView:Landroid/widget/TextView;
    const-string p1, "All logs cleared!"
    invoke-virtual {v1, p1}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    # Toast
    const-string v1, "\ud83d\uddd1\ufe0f All logs cleared!"
    const/4 p1, 0x0
    invoke-static {v0, v1, p1}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;
    move-result-object v1
    invoke-virtual {v1}, Landroid/widget/Toast;->show()V

    return-void
.end method