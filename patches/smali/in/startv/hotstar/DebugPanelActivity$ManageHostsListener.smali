.class public Lin/startv/hotstar/DebugPanelActivity$ManageHostsListener;
.super Ljava/lang/Object;
.source "DebugPanelActivity.java"

# implements View.OnClickListener
.implements Landroid/view/View$OnClickListener;

# instance fields
.field public outer:Lin/startv/hotstar/DebugPanelActivity;

.method public constructor <init>(Lin/startv/hotstar/DebugPanelActivity;)V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lin/startv/hotstar/DebugPanelActivity$ManageHostsListener;->outer:Lin/startv/hotstar/DebugPanelActivity;
    return-void
.end method

.method public onClick(Landroid/view/View;)V
    .locals 3

    iget-object v0, p0, Lin/startv/hotstar/DebugPanelActivity$ManageHostsListener;->outer:Lin/startv/hotstar/DebugPanelActivity;

    new-instance v1, Landroid/content/Intent;
    const-class v2, Lin/startv/hotstar/HostFilterActivity;
    invoke-direct {v1, v0, v2}, Landroid/content/Intent;-><init>(Landroid/content/Context;Ljava/lang/Class;)V
    invoke-virtual {v0, v1}, Landroid/app/Activity;->startActivity(Landroid/content/Intent;)V

    return-void
.end method
