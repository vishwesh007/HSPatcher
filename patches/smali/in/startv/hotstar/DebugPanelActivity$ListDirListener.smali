.class public Lin/startv/hotstar/DebugPanelActivity$ListDirListener;
.super Ljava/lang/Object;
.source "DebugPanelActivity.java"

# interfaces
.implements Landroid/view/View$OnClickListener;

# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lin/startv/hotstar/DebugPanelActivity;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "ListDirListener"
.end annotation


# instance fields
.field public outer:Lin/startv/hotstar/DebugPanelActivity;


# direct methods
.method public constructor <init>(Lin/startv/hotstar/DebugPanelActivity;)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lin/startv/hotstar/DebugPanelActivity$ListDirListener;->outer:Lin/startv/hotstar/DebugPanelActivity;
    return-void
.end method


# virtual methods
.method public onClick(Landroid/view/View;)V
    .locals 4

    iget-object v0, p0, Lin/startv/hotstar/DebugPanelActivity$ListDirListener;->outer:Lin/startv/hotstar/DebugPanelActivity;

    # Get path from pathInput
    iget-object v1, v0, Lin/startv/hotstar/DebugPanelActivity;->pathInput:Landroid/widget/EditText;
    invoke-virtual {v1}, Landroid/widget/EditText;->getText()Landroid/text/Editable;
    move-result-object v1
    invoke-virtual {v1}, Ljava/lang/Object;->toString()Ljava/lang/String;
    move-result-object v1
    invoke-virtual {v1}, Ljava/lang/String;->trim()Ljava/lang/String;
    move-result-object v1

    # Build ls command: "ls -laR <path> 2>&1 | head -500"
    new-instance v2, Ljava/lang/StringBuilder;
    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V
    const-string v3, "ls -laR '"
    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v2, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v3, "' 2>&1 | head -500"
    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v2

    # Execute command
    invoke-static {v2}, Lin/startv/hotstar/ProfileManager;->shellExecOutput(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v2

    # Add header
    new-instance v3, Ljava/lang/StringBuilder;
    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V
    const-string v1, "=== Directory Listing ===\nPath: "
    invoke-virtual {v3, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    iget-object v1, v0, Lin/startv/hotstar/DebugPanelActivity;->pathInput:Landroid/widget/EditText;
    invoke-virtual {v1}, Landroid/widget/EditText;->getText()Landroid/text/Editable;
    move-result-object v1
    invoke-virtual {v1}, Ljava/lang/Object;->toString()Ljava/lang/String;
    move-result-object v1
    invoke-virtual {v3, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v1, "\n\n"
    invoke-virtual {v3, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v3, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v1

    # Show in log view
    iget-object v2, v0, Lin/startv/hotstar/DebugPanelActivity;->logView:Landroid/widget/TextView;
    invoke-virtual {v2, v1}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    # Set currentLogFile to null (not a file)
    const/4 v1, 0x0
    iput-object v1, v0, Lin/startv/hotstar/DebugPanelActivity;->currentLogFile:Ljava/lang/String;

    # Scroll to top
    iget-object v1, v0, Lin/startv/hotstar/DebugPanelActivity;->logScrollView:Landroid/widget/ScrollView;
    if-eqz v1, :done
    const/16 v2, 0x21
    invoke-virtual {v1, v2}, Landroid/widget/ScrollView;->fullScroll(I)Z

    :done
    return-void
.end method
