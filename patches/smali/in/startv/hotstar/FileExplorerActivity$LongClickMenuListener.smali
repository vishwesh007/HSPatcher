.class public Lin/startv/hotstar/FileExplorerActivity$LongClickMenuListener;
.super Ljava/lang/Object;
.source "FileExplorerActivity.java"

.implements Landroid/content/DialogInterface$OnClickListener;

.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lin/startv/hotstar/FileExplorerActivity;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "LongClickMenuListener"
.end annotation

.field public outer:Lin/startv/hotstar/FileExplorerActivity;
.field public filePath:Ljava/lang/String;
.field public fileName:Ljava/lang/String;

.method public constructor <init>(Lin/startv/hotstar/FileExplorerActivity;Ljava/lang/String;Ljava/lang/String;)V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lin/startv/hotstar/FileExplorerActivity$LongClickMenuListener;->outer:Lin/startv/hotstar/FileExplorerActivity;
    iput-object p2, p0, Lin/startv/hotstar/FileExplorerActivity$LongClickMenuListener;->filePath:Ljava/lang/String;
    iput-object p3, p0, Lin/startv/hotstar/FileExplorerActivity$LongClickMenuListener;->fileName:Ljava/lang/String;
    return-void
.end method

.method public onClick(Landroid/content/DialogInterface;I)V
    .locals 6

    iget-object v0, p0, Lin/startv/hotstar/FileExplorerActivity$LongClickMenuListener;->outer:Lin/startv/hotstar/FileExplorerActivity;
    iget-object v1, p0, Lin/startv/hotstar/FileExplorerActivity$LongClickMenuListener;->filePath:Ljava/lang/String;
    iget-object v2, p0, Lin/startv/hotstar/FileExplorerActivity$LongClickMenuListener;->fileName:Ljava/lang/String;

    packed-switch p2, :pswitch_data

    goto :done

    :pswitch_copy
    # Copy path to clipboard
    const-string v3, "clipboard"
    invoke-virtual {v0, v3}, Landroid/content/Context;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;
    move-result-object v3
    check-cast v3, Landroid/content/ClipboardManager;

    const-string v4, "FilePath"
    invoke-static {v4, v1}, Landroid/content/ClipData;->newPlainText(Ljava/lang/CharSequence;Ljava/lang/CharSequence;)Landroid/content/ClipData;
    move-result-object v4
    invoke-virtual {v3, v4}, Landroid/content/ClipboardManager;->setPrimaryClip(Landroid/content/ClipData;)V

    const-string v3, "\u2705 Path copied!"
    const/4 v4, 0x0
    invoke-static {v0, v3, v4}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;
    move-result-object v3
    invoke-virtual {v3}, Landroid/widget/Toast;->show()V
    goto :done

    :pswitch_delete
    # Confirm delete dialog
    new-instance v3, Landroid/app/AlertDialog$Builder;
    invoke-direct {v3, v0}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    const-string v4, "Delete?"
    invoke-virtual {v3, v4}, Landroid/app/AlertDialog$Builder;->setTitle(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    new-instance v4, Ljava/lang/StringBuilder;
    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V
    const-string v5, "Delete '"
    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v4, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v5, "'?\nThis cannot be undone."
    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v4
    invoke-virtual {v3, v4}, Landroid/app/AlertDialog$Builder;->setMessage(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    const-string v4, "Delete"
    new-instance v5, Lin/startv/hotstar/FileExplorerActivity$DeleteConfirmListener;
    invoke-direct {v5, v0, v1}, Lin/startv/hotstar/FileExplorerActivity$DeleteConfirmListener;-><init>(Lin/startv/hotstar/FileExplorerActivity;Ljava/lang/String;)V
    invoke-virtual {v3, v4, v5}, Landroid/app/AlertDialog$Builder;->setPositiveButton(Ljava/lang/CharSequence;Landroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    const-string v4, "Cancel"
    const/4 v5, 0x0
    invoke-virtual {v3, v4, v5}, Landroid/app/AlertDialog$Builder;->setNegativeButton(Ljava/lang/CharSequence;Landroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    invoke-virtual {v3}, Landroid/app/AlertDialog$Builder;->show()Landroid/app/AlertDialog;
    goto :done

    :pswitch_properties
    # Show properties
    new-instance v3, Ljava/io/File;
    invoke-direct {v3, v1}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    new-instance v4, Ljava/lang/StringBuilder;
    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    const-string v5, "Name: "
    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v4, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v5, "\n\nPath: "
    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v4, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v5, "\n\nSize: "
    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v3}, Ljava/io/File;->length()J
    move-result-wide v5
    invoke-static {v5, v6}, Lin/startv/hotstar/FileExplorerActivity;->formatSize(J)Ljava/lang/String;
    move-result-object v5
    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v5, "\n\nModified: "
    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v3}, Ljava/io/File;->lastModified()J
    move-result-wide v5
    invoke-static {v5, v6}, Lin/startv/hotstar/FileExplorerActivity;->formatDate(J)Ljava/lang/String;
    move-result-object v5
    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v5, "\n\nReadable: "
    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v3}, Ljava/io/File;->canRead()Z
    move-result v5
    if-eqz v5, :not_readable
    const-string v5, "Yes"
    goto :after_readable
    :not_readable
    const-string v5, "No"
    :after_readable
    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v5, "\nWritable: "
    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v3}, Ljava/io/File;->canWrite()Z
    move-result v5
    if-eqz v5, :not_writable
    const-string v5, "Yes"
    goto :after_writable
    :not_writable
    const-string v5, "No"
    :after_writable
    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v5, "\nDirectory: "
    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v3}, Ljava/io/File;->isDirectory()Z
    move-result v5
    if-eqz v5, :not_directory
    const-string v5, "Yes"
    goto :after_directory
    :not_directory
    const-string v5, "No"
    :after_directory
    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v4

    new-instance v5, Landroid/app/AlertDialog$Builder;
    invoke-direct {v5, v0}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V
    const-string v3, "\u2139\ufe0f Properties"
    invoke-virtual {v5, v3}, Landroid/app/AlertDialog$Builder;->setTitle(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;
    invoke-virtual {v5, v4}, Landroid/app/AlertDialog$Builder;->setMessage(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;
    const-string v3, "OK"
    const/4 v4, 0x0
    invoke-virtual {v5, v3, v4}, Landroid/app/AlertDialog$Builder;->setPositiveButton(Ljava/lang/CharSequence;Landroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;
    invoke-virtual {v5}, Landroid/app/AlertDialog$Builder;->show()Landroid/app/AlertDialog;

    :done
    return-void

    :pswitch_data
    .packed-switch 0x0
        :pswitch_copy
        :pswitch_delete
        :pswitch_properties
    .end packed-switch
.end method
