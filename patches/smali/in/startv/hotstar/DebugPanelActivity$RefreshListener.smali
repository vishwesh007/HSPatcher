.class Lin/startv/hotstar/DebugPanelActivity$RefreshListener;
.super Ljava/lang/Object;
.source "DebugPanelActivity.java"

.implements Landroid/view/View$OnClickListener;

.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lin/startv/hotstar/DebugPanelActivity;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = "RefreshListener"
.end annotation


# instance fields
.field final synthetic this$0:Lin/startv/hotstar/DebugPanelActivity;


# direct methods
.method constructor <init>(Lin/startv/hotstar/DebugPanelActivity;)V
    .locals 0
    iput-object p1, p0, Lin/startv/hotstar/DebugPanelActivity$RefreshListener;->this$0:Lin/startv/hotstar/DebugPanelActivity;
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    return-void
.end method


# virtual methods
.method public onClick(Landroid/view/View;)V
    .locals 2

    iget-object v0, p0, Lin/startv/hotstar/DebugPanelActivity$RefreshListener;->this$0:Lin/startv/hotstar/DebugPanelActivity;
    invoke-virtual {v0}, Lin/startv/hotstar/DebugPanelActivity;->refreshLog()V

    const-string v1, "\ud83d\udd04 Refreshed"
    const/4 p1, 0x0
    invoke-static {v0, v1, p1}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;
    move-result-object v1
    invoke-virtual {v1}, Landroid/widget/Toast;->show()V

    return-void
.end method