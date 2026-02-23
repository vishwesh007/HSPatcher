.class public Lin/startv/hotstar/FileExplorerActivity$NavClickListener;
.super Ljava/lang/Object;
.source "FileExplorerActivity.java"

.implements Landroid/view/View$OnClickListener;

.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lin/startv/hotstar/FileExplorerActivity;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "NavClickListener"
.end annotation

.field public outer:Lin/startv/hotstar/FileExplorerActivity;
.field public path:Ljava/lang/String;

.method public constructor <init>(Lin/startv/hotstar/FileExplorerActivity;Ljava/lang/String;)V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lin/startv/hotstar/FileExplorerActivity$NavClickListener;->outer:Lin/startv/hotstar/FileExplorerActivity;
    iput-object p2, p0, Lin/startv/hotstar/FileExplorerActivity$NavClickListener;->path:Ljava/lang/String;
    return-void
.end method

.method public onClick(Landroid/view/View;)V
    .locals 2
    iget-object v0, p0, Lin/startv/hotstar/FileExplorerActivity$NavClickListener;->outer:Lin/startv/hotstar/FileExplorerActivity;
    iget-object v1, p0, Lin/startv/hotstar/FileExplorerActivity$NavClickListener;->path:Ljava/lang/String;
    invoke-virtual {v0, v1}, Lin/startv/hotstar/FileExplorerActivity;->navigateTo(Ljava/lang/String;)V
    return-void
.end method
