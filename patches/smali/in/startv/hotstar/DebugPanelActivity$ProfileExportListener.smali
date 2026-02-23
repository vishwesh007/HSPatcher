.class public Lin/startv/hotstar/DebugPanelActivity$ProfileExportListener;
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
    name = "ProfileExportListener"
.end annotation


# instance fields
.field public outer:Lin/startv/hotstar/DebugPanelActivity;


# direct methods
.method public constructor <init>(Lin/startv/hotstar/DebugPanelActivity;)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lin/startv/hotstar/DebugPanelActivity$ProfileExportListener;->outer:Lin/startv/hotstar/DebugPanelActivity;
    return-void
.end method


# virtual methods
.method public onClick(Landroid/view/View;)V
    .locals 3

    iget-object v0, p0, Lin/startv/hotstar/DebugPanelActivity$ProfileExportListener;->outer:Lin/startv/hotstar/DebugPanelActivity;

    # Export all profiles
    invoke-static {v0}, Lin/startv/hotstar/ProfileManager;->exportAllProfiles(Landroid/content/Context;)Ljava/lang/String;
    move-result-object v1

    # Show result in AlertDialog (so user can see the full path)
    new-instance v2, Landroid/app/AlertDialog$Builder;
    invoke-direct {v2, v0}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    const-string v0, "\ud83d\udce4 Export Result"
    invoke-virtual {v2, v0}, Landroid/app/AlertDialog$Builder;->setTitle(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    invoke-virtual {v2, v1}, Landroid/app/AlertDialog$Builder;->setMessage(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    const-string v0, "OK"
    const/4 v1, 0x0
    invoke-virtual {v2, v0, v1}, Landroid/app/AlertDialog$Builder;->setPositiveButton(Ljava/lang/CharSequence;Landroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    invoke-virtual {v2}, Landroid/app/AlertDialog$Builder;->show()Landroid/app/AlertDialog;

    return-void
.end method
