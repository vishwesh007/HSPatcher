.class public Lin/startv/hotstar/FileExplorerActivity$HomeClickListener;
.super Ljava/lang/Object;
.source "FileExplorerActivity.java"

.implements Landroid/view/View$OnClickListener;

.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lin/startv/hotstar/FileExplorerActivity;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "HomeClickListener"
.end annotation

.field public outer:Lin/startv/hotstar/FileExplorerActivity;

.method public constructor <init>(Lin/startv/hotstar/FileExplorerActivity;)V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lin/startv/hotstar/FileExplorerActivity$HomeClickListener;->outer:Lin/startv/hotstar/FileExplorerActivity;
    return-void
.end method

.method public onClick(Landroid/view/View;)V
    .locals 2
    iget-object v0, p0, Lin/startv/hotstar/FileExplorerActivity$HomeClickListener;->outer:Lin/startv/hotstar/FileExplorerActivity;

    # Navigate to app data dir
    invoke-virtual {v0}, Landroid/content/Context;->getApplicationInfo()Landroid/content/pm/ApplicationInfo;
    move-result-object v1
    iget-object v1, v1, Landroid/content/pm/ApplicationInfo;->dataDir:Ljava/lang/String;
    invoke-virtual {v0, v1}, Lin/startv/hotstar/FileExplorerActivity;->navigateTo(Ljava/lang/String;)V
    return-void
.end method
