.class public Lin/startv/hotstar/DebugPanelActivity$LogClickListener;
.super Ljava/lang/Object;
.source "DebugPanelActivity.java"

# interfaces
.implements Landroid/view/View$OnClickListener;

# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lin/startv/hotstar/DebugPanelActivity;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x1
    name = "LogClickListener"
.end annotation


# instance fields
.field public this$0:Lin/startv/hotstar/DebugPanelActivity;
.field public filePath:Ljava/lang/String;


# direct methods
.method public constructor <init>(Lin/startv/hotstar/DebugPanelActivity;Ljava/lang/String;)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lin/startv/hotstar/DebugPanelActivity$LogClickListener;->this$0:Lin/startv/hotstar/DebugPanelActivity;
    iput-object p2, p0, Lin/startv/hotstar/DebugPanelActivity$LogClickListener;->filePath:Ljava/lang/String;
    return-void
.end method


# virtual methods
.method public onClick(Landroid/view/View;)V
    .locals 3

    iget-object v0, p0, Lin/startv/hotstar/DebugPanelActivity$LogClickListener;->this$0:Lin/startv/hotstar/DebugPanelActivity;
    iget-object v1, p0, Lin/startv/hotstar/DebugPanelActivity$LogClickListener;->filePath:Ljava/lang/String;

    # Launch LogViewerActivity with file path
    new-instance v2, Landroid/content/Intent;
    const-class v3, Lin/startv/hotstar/LogViewerActivity;
    invoke-direct {v2, v0, v3}, Landroid/content/Intent;-><init>(Landroid/content/Context;Ljava/lang/Class;)V
    const-string v3, "path"
    invoke-virtual {v2, v3, v1}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;
    invoke-virtual {v0, v2}, Landroid/app/Activity;->startActivity(Landroid/content/Intent;)V

    return-void
.end method