.class public Lin/startv/hotstar/DebugPanelActivity$OpenFileExplorerListener;
.super Ljava/lang/Object;
.source "DebugPanelActivity.java"

.implements Landroid/view/View$OnClickListener;

.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lin/startv/hotstar/DebugPanelActivity;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "OpenFileExplorerListener"
.end annotation

.field public outer:Lin/startv/hotstar/DebugPanelActivity;

.method public constructor <init>(Lin/startv/hotstar/DebugPanelActivity;)V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lin/startv/hotstar/DebugPanelActivity$OpenFileExplorerListener;->outer:Lin/startv/hotstar/DebugPanelActivity;
    return-void
.end method

.method public onClick(Landroid/view/View;)V
    .locals 3

    iget-object v0, p0, Lin/startv/hotstar/DebugPanelActivity$OpenFileExplorerListener;->outer:Lin/startv/hotstar/DebugPanelActivity;

    # Create intent for FileExplorerActivity
    new-instance v1, Landroid/content/Intent;
    const-class v2, Lin/startv/hotstar/FileExplorerActivity;
    invoke-direct {v1, v0, v2}, Landroid/content/Intent;-><init>(Landroid/content/Context;Ljava/lang/Class;)V

    # Pass current path from pathInput as starting directory
    iget-object v2, v0, Lin/startv/hotstar/DebugPanelActivity;->pathInput:Landroid/widget/EditText;
    invoke-virtual {v2}, Landroid/widget/EditText;->getText()Landroid/text/Editable;
    move-result-object v2
    invoke-virtual {v2}, Ljava/lang/Object;->toString()Ljava/lang/String;
    move-result-object v2
    invoke-virtual {v2}, Ljava/lang/String;->trim()Ljava/lang/String;
    move-result-object v2

    const-string v3, "path"
    invoke-virtual {v1, v3, v2}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    invoke-virtual {v0, v1}, Landroid/app/Activity;->startActivity(Landroid/content/Intent;)V
    return-void
.end method
