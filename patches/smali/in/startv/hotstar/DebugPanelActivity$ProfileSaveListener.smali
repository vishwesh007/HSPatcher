.class public Lin/startv/hotstar/DebugPanelActivity$ProfileSaveListener;
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
    name = "ProfileSaveListener"
.end annotation


# instance fields
.field public outer:Lin/startv/hotstar/DebugPanelActivity;
.field public input:Landroid/widget/EditText;


# direct methods
.method public constructor <init>(Lin/startv/hotstar/DebugPanelActivity;)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lin/startv/hotstar/DebugPanelActivity$ProfileSaveListener;->outer:Lin/startv/hotstar/DebugPanelActivity;
    return-void
.end method


# virtual methods
# onClick(View) - shows the save dialog
.method public onClick(Landroid/view/View;)V
    .locals 4

    iget-object v0, p0, Lin/startv/hotstar/DebugPanelActivity$ProfileSaveListener;->outer:Lin/startv/hotstar/DebugPanelActivity;

    # Create AlertDialog.Builder
    new-instance v1, Landroid/app/AlertDialog$Builder;
    invoke-direct {v1, v0}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    # Set title
    const-string v2, "\ud83d\udcbe Save Profile"
    invoke-virtual {v1, v2}, Landroid/app/AlertDialog$Builder;->setTitle(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    # Create EditText input
    new-instance v2, Landroid/widget/EditText;
    invoke-direct {v2, v0}, Landroid/widget/EditText;-><init>(Landroid/content/Context;)V
    iput-object v2, p0, Lin/startv/hotstar/DebugPanelActivity$ProfileSaveListener;->input:Landroid/widget/EditText;

    const-string v3, "Enter profile name"
    invoke-virtual {v2, v3}, Landroid/widget/EditText;->setHint(Ljava/lang/CharSequence;)V

    # Padding
    const/16 v3, 0x20
    invoke-virtual {v2, v3, v3, v3, v3}, Landroid/view/View;->setPadding(IIII)V

    invoke-virtual {v1, v2}, Landroid/app/AlertDialog$Builder;->setView(Landroid/view/View;)Landroid/app/AlertDialog$Builder;

    # Positive button = Save (uses this as DialogInterface.OnClickListener)
    const-string v2, "Save"
    invoke-virtual {v1, v2, p0}, Landroid/app/AlertDialog$Builder;->setPositiveButton(Ljava/lang/CharSequence;Landroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    # Negative button = Cancel
    const-string v2, "Cancel"
    const/4 v3, 0x0
    invoke-virtual {v1, v2, v3}, Landroid/app/AlertDialog$Builder;->setNegativeButton(Ljava/lang/CharSequence;Landroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    # Show
    invoke-virtual {v1}, Landroid/app/AlertDialog$Builder;->show()Landroid/app/AlertDialog;

    return-void
.end method

# onClick(DialogInterface, int) - handles the save action
.method public onClick(Landroid/content/DialogInterface;I)V
    .locals 3

    iget-object v0, p0, Lin/startv/hotstar/DebugPanelActivity$ProfileSaveListener;->outer:Lin/startv/hotstar/DebugPanelActivity;
    iget-object v1, p0, Lin/startv/hotstar/DebugPanelActivity$ProfileSaveListener;->input:Landroid/widget/EditText;

    # Get text
    invoke-virtual {v1}, Landroid/widget/EditText;->getText()Landroid/text/Editable;
    move-result-object v1
    invoke-virtual {v1}, Ljava/lang/Object;->toString()Ljava/lang/String;
    move-result-object v1
    invoke-virtual {v1}, Ljava/lang/String;->trim()Ljava/lang/String;
    move-result-object v1

    # Check empty
    invoke-virtual {v1}, Ljava/lang/String;->isEmpty()Z
    move-result v2
    if-nez v2, :empty

    # Save profile
    invoke-static {v0, v1}, Lin/startv/hotstar/ProfileManager;->saveProfile(Landroid/content/Context;Ljava/lang/String;)V

    # Toast
    new-instance v2, Ljava/lang/StringBuilder;
    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V
    const-string p1, "Profile saved: "
    invoke-virtual {v2, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v2, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v1

    const/4 v2, 0x0
    invoke-static {v0, v1, v2}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;
    move-result-object v0
    invoke-virtual {v0}, Landroid/widget/Toast;->show()V

    :empty
    return-void
.end method
