.class public Lin/startv/hotstar/DebugPanelActivity$ProfileDeleteListener;
.super Ljava/lang/Object;
.source "DebugPanelActivity.java"

# interfaces
.implements Landroid/view/View$OnClickListener;
.implements Landroid/content/DialogInterface$OnClickListener;

# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lin/startv/hotstar/DebugPanelActivity;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "ProfileDeleteListener"
.end annotation


# instance fields
.field public outer:Lin/startv/hotstar/DebugPanelActivity;
.field public profiles:[Ljava/lang/String;


# direct methods
.method public constructor <init>(Lin/startv/hotstar/DebugPanelActivity;)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lin/startv/hotstar/DebugPanelActivity$ProfileDeleteListener;->outer:Lin/startv/hotstar/DebugPanelActivity;
    return-void
.end method


# virtual methods
# onClick(View) - shows delete list dialog
.method public onClick(Landroid/view/View;)V
    .locals 4

    iget-object v0, p0, Lin/startv/hotstar/DebugPanelActivity$ProfileDeleteListener;->outer:Lin/startv/hotstar/DebugPanelActivity;

    # Get profiles
    invoke-static {v0}, Lin/startv/hotstar/ProfileManager;->listProfiles(Landroid/content/Context;)[Ljava/lang/String;
    move-result-object v1
    iput-object v1, p0, Lin/startv/hotstar/DebugPanelActivity$ProfileDeleteListener;->profiles:[Ljava/lang/String;

    # Check empty
    array-length v2, v1
    if-nez v2, :has_profiles

    const-string v1, "No profiles to delete"
    const/4 v2, 0x0
    invoke-static {v0, v1, v2}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;
    move-result-object v0
    invoke-virtual {v0}, Landroid/widget/Toast;->show()V
    return-void

    :has_profiles
    # Create dialog
    new-instance v2, Landroid/app/AlertDialog$Builder;
    invoke-direct {v2, v0}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    const-string v3, "\ud83d\uddd1 Delete Profile"
    invoke-virtual {v2, v3}, Landroid/app/AlertDialog$Builder;->setTitle(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    invoke-virtual {v2, v1, p0}, Landroid/app/AlertDialog$Builder;->setItems([Ljava/lang/CharSequence;Landroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    const-string v3, "Cancel"
    const/4 v1, 0x0
    invoke-virtual {v2, v3, v1}, Landroid/app/AlertDialog$Builder;->setNegativeButton(Ljava/lang/CharSequence;Landroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    invoke-virtual {v2}, Landroid/app/AlertDialog$Builder;->show()Landroid/app/AlertDialog;

    return-void
.end method

# onClick(DialogInterface, int) - deletes the selected profile
.method public onClick(Landroid/content/DialogInterface;I)V
    .locals 3

    iget-object v0, p0, Lin/startv/hotstar/DebugPanelActivity$ProfileDeleteListener;->outer:Lin/startv/hotstar/DebugPanelActivity;
    iget-object v1, p0, Lin/startv/hotstar/DebugPanelActivity$ProfileDeleteListener;->profiles:[Ljava/lang/String;

    # Get selected name
    aget-object v1, v1, p2

    # Delete profile
    invoke-static {v0, v1}, Lin/startv/hotstar/ProfileManager;->deleteProfile(Landroid/content/Context;Ljava/lang/String;)V

    # Toast
    new-instance v2, Ljava/lang/StringBuilder;
    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V
    const-string p1, "Profile deleted: "
    invoke-virtual {v2, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v2, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v1

    const/4 v2, 0x0
    invoke-static {v0, v1, v2}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;
    move-result-object v0
    invoke-virtual {v0}, Landroid/widget/Toast;->show()V

    return-void
.end method
