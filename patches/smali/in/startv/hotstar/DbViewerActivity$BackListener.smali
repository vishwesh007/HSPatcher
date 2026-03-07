.class public Lin/startv/hotstar/DbViewerActivity$BackListener;
.super Ljava/lang/Object;
.source "DbViewerActivity.java"

# interfaces
.implements Landroid/view/View$OnClickListener;

# instance fields
.field public final synthetic this$0:Lin/startv/hotstar/DbViewerActivity;

# direct methods
.method public constructor <init>(Lin/startv/hotstar/DbViewerActivity;)V
    .locals 0
    iput-object p1, p0, Lin/startv/hotstar/DbViewerActivity$BackListener;->this$0:Lin/startv/hotstar/DbViewerActivity;
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    return-void
.end method

# virtual methods
.method public onClick(Landroid/view/View;)V
    .locals 1
    iget-object v0, p0, Lin/startv/hotstar/DbViewerActivity$BackListener;->this$0:Lin/startv/hotstar/DbViewerActivity;
    invoke-virtual {v0}, Landroid/app/Activity;->finish()V
    return-void
.end method
