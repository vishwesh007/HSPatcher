.class public Lin/startv/hotstar/DebugPanelActivity$ProfileNewListener;
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
    name = "ProfileNewListener"
.end annotation


# instance fields
.field public outer:Lin/startv/hotstar/DebugPanelActivity;
.field public input:Landroid/widget/EditText;


# direct methods
.method public constructor <init>(Lin/startv/hotstar/DebugPanelActivity;)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lin/startv/hotstar/DebugPanelActivity$ProfileNewListener;->outer:Lin/startv/hotstar/DebugPanelActivity;
    return-void
.end method


# virtual methods
# onClick(View) - shows dialog asking for name of current profile to save before wiping
.method public onClick(Landroid/view/View;)V
    .locals 4

    iget-object v0, p0, Lin/startv/hotstar/DebugPanelActivity$ProfileNewListener;->outer:Lin/startv/hotstar/DebugPanelActivity;

    # Create AlertDialog.Builder
    new-instance v1, Landroid/app/AlertDialog$Builder;
    invoke-direct {v1, v0}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    # Set title
    const-string v2, "\u2728 New Profile (Fresh Start)"
    invoke-virtual {v1, v2}, Landroid/app/AlertDialog$Builder;->setTitle(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    # Message
    const-string v2, "This will SAVE your current data as a profile, then WIPE app data for a fresh start. The app will restart.\n\nEnter a name to save your current state:"
    invoke-virtual {v1, v2}, Landroid/app/AlertDialog$Builder;->setMessage(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    # Create EditText input
    new-instance v2, Landroid/widget/EditText;
    invoke-direct {v2, v0}, Landroid/widget/EditText;-><init>(Landroid/content/Context;)V
    iput-object v2, p0, Lin/startv/hotstar/DebugPanelActivity$ProfileNewListener;->input:Landroid/widget/EditText;

    const-string v3, "e.g. account1, main, backup..."
    invoke-virtual {v2, v3}, Landroid/widget/EditText;->setHint(Ljava/lang/CharSequence;)V

    const/16 v3, 0x20
    invoke-virtual {v2, v3, v3, v3, v3}, Landroid/view/View;->setPadding(IIII)V

    invoke-virtual {v1, v2}, Landroid/app/AlertDialog$Builder;->setView(Landroid/view/View;)Landroid/app/AlertDialog$Builder;

    # Positive button
    const-string v2, "Save & Wipe"
    invoke-virtual {v1, v2, p0}, Landroid/app/AlertDialog$Builder;->setPositiveButton(Ljava/lang/CharSequence;Landroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    # Negative button
    const-string v2, "Cancel"
    const/4 v3, 0x0
    invoke-virtual {v1, v2, v3}, Landroid/app/AlertDialog$Builder;->setNegativeButton(Ljava/lang/CharSequence;Landroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    invoke-virtual {v1}, Landroid/app/AlertDialog$Builder;->show()Landroid/app/AlertDialog;

    return-void
.end method

# onClick(DialogInterface, int) - handles the save & wipe action
.method public onClick(Landroid/content/DialogInterface;I)V
    .locals 3

    iget-object v0, p0, Lin/startv/hotstar/DebugPanelActivity$ProfileNewListener;->outer:Lin/startv/hotstar/DebugPanelActivity;
    iget-object v1, p0, Lin/startv/hotstar/DebugPanelActivity$ProfileNewListener;->input:Landroid/widget/EditText;

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

    # Toast
    new-instance v2, Ljava/lang/StringBuilder;
    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V
    const-string p1, "Saving as '"
    invoke-virtual {v2, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v2, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string p1, "' & restarting fresh..."
    invoke-virtual {v2, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v2

    const/4 p1, 0x1
    invoke-static {v0, v2, p1}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;
    move-result-object v2
    invoke-virtual {v2}, Landroid/widget/Toast;->show()V

    # Save current + clear data
    invoke-static {v0, v1}, Lin/startv/hotstar/ProfileManager;->createNewProfile(Landroid/content/Context;Ljava/lang/String;)V

    # Restart app
    invoke-virtual {v0}, Landroid/content/Context;->getPackageManager()Landroid/content/pm/PackageManager;
    move-result-object v1
    invoke-virtual {v0}, Landroid/content/Context;->getPackageName()Ljava/lang/String;
    move-result-object v2
    invoke-virtual {v1, v2}, Landroid/content/pm/PackageManager;->getLaunchIntentForPackage(Ljava/lang/String;)Landroid/content/Intent;
    move-result-object v1

    if-eqz v1, :empty

    const v2, 0x10008000
    invoke-virtual {v1, v2}, Landroid/content/Intent;->addFlags(I)Landroid/content/Intent;
    invoke-virtual {v0, v1}, Landroid/content/Context;->startActivity(Landroid/content/Intent;)V

    invoke-static {}, Landroid/os/Process;->myPid()I
    move-result v0
    invoke-static {v0}, Landroid/os/Process;->killProcess(I)V

    :empty
    return-void
.end method
