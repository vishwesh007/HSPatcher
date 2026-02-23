.class public Lin/startv/hotstar/FileViewerActivity;
.super Landroid/app/Activity;
.source "FileViewerActivity.java"

# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lin/startv/hotstar/FileViewerActivity$BackClickListener;,
        Lin/startv/hotstar/FileViewerActivity$SaveClickListener;,
        Lin/startv/hotstar/FileViewerActivity$TextChangeWatcher;,
        Lin/startv/hotstar/FileViewerActivity$DiscardClickListener;,
        Lin/startv/hotstar/FileViewerActivity$SearchActionListener;
    }
.end annotation

# instance fields
.field public filePath:Ljava/lang/String;
.field public editText:Landroid/widget/EditText;
.field public statusText:Landroid/widget/TextView;
.field public isBinary:Z
.field public isEdited:Z
.field public searchContainer:Landroid/widget/LinearLayout;
.field public searchInput:Landroid/widget/EditText;
.field public replaceInput:Landroid/widget/EditText;
.field public matchCountText:Landroid/widget/TextView;
.field public currentTextSize:F


# direct methods
.method public constructor <init>()V
    .locals 0
    invoke-direct {p0}, Landroid/app/Activity;-><init>()V
    return-void
.end method

# ===== Static: read file content (max 5MB, detect binary) =====
.method public static readFileContent(Ljava/lang/String;)Ljava/lang/String;
    .locals 7

    :try_start
    new-instance v0, Ljava/io/File;
    invoke-direct {v0, p0}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    invoke-virtual {v0}, Ljava/io/File;->exists()Z
    move-result v1
    if-nez v1, :exists
    const/4 v0, 0x0
    return-object v0

    :exists
    invoke-virtual {v0}, Ljava/io/File;->length()J
    move-result-wide v1
    const-wide/32 v3, 0x500000
    cmp-long v5, v1, v3
    if-lez v5, :size_ok
    const/4 v0, 0x0
    return-object v0

    :size_ok
    new-instance v1, Ljava/io/FileInputStream;
    invoke-direct {v1, v0}, Ljava/io/FileInputStream;-><init>(Ljava/io/File;)V
    invoke-virtual {v0}, Ljava/io/File;->length()J
    move-result-wide v2
    long-to-int v2, v2
    new-array v3, v2, [B
    invoke-virtual {v1, v3}, Ljava/io/FileInputStream;->read([B)I
    invoke-virtual {v1}, Ljava/io/FileInputStream;->close()V

    const/4 v4, 0x0
    const/16 v5, 0x200
    if-le v2, v5, :check_all
    move v2, v5
    :check_all
    const/4 v5, 0x0
    :bin_loop
    if-ge v5, v2, :not_binary
    aget-byte v6, v3, v5
    if-eqz v6, :is_binary
    add-int/lit8 v5, v5, 0x1
    goto :bin_loop

    :is_binary
    const/4 v0, 0x0
    return-object v0

    :not_binary
    new-instance v0, Ljava/lang/String;
    const-string v1, "UTF-8"
    invoke-direct {v0, v3, v1}, Ljava/lang/String;-><init>([BLjava/lang/String;)V
    return-object v0

    :try_end
    .catchall {:try_start .. :try_end} :catch
    :catch
    const/4 v0, 0x0
    return-object v0
.end method

# ===== Static: write content to file =====
.method public static writeFileContent(Ljava/lang/String;Ljava/lang/String;)Z
    .locals 3

    :try_start
    new-instance v0, Ljava/io/FileOutputStream;
    invoke-direct {v0, p0}, Ljava/io/FileOutputStream;-><init>(Ljava/lang/String;)V
    const-string v1, "UTF-8"
    invoke-virtual {p1, v1}, Ljava/lang/String;->getBytes(Ljava/lang/String;)[B
    move-result-object v1
    invoke-virtual {v0, v1}, Ljava/io/FileOutputStream;->write([B)V
    invoke-virtual {v0}, Ljava/io/FileOutputStream;->close()V
    const/4 v0, 0x1
    return v0
    :try_end
    .catchall {:try_start .. :try_end} :catch
    :catch
    const/4 v0, 0x0
    return v0
.end method

# ===== Static: extract file name from path =====
.method public static getFileName(Ljava/lang/String;)Ljava/lang/String;
    .locals 2
    const-string v0, "/"
    invoke-virtual {p0, v0}, Ljava/lang/String;->lastIndexOf(Ljava/lang/String;)I
    move-result v0
    if-ltz v0, :no_slash
    add-int/lit8 v0, v0, 0x1
    invoke-virtual {p0}, Ljava/lang/String;->length()I
    move-result v1
    invoke-virtual {p0, v0, v1}, Ljava/lang/String;->substring(II)Ljava/lang/String;
    move-result-object p0
    :no_slash
    return-object p0
.end method

# ===== Instance: save file =====
.method public saveFile()V
    .locals 4
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->filePath:Ljava/lang/String;
    iget-object v1, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;
    invoke-virtual {v1}, Landroid/widget/EditText;->getText()Landroid/text/Editable;
    move-result-object v1
    invoke-virtual {v1}, Ljava/lang/Object;->toString()Ljava/lang/String;
    move-result-object v1
    invoke-static {v0, v1}, Lin/startv/hotstar/FileViewerActivity;->writeFileContent(Ljava/lang/String;Ljava/lang/String;)Z
    move-result v2
    if-eqz v2, :save_failed
    const-string v3, "\u2705 File saved"
    const/4 v2, 0x0
    invoke-static {p0, v3, v2}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;
    move-result-object v3
    invoke-virtual {v3}, Landroid/widget/Toast;->show()V
    const/4 v2, 0x0
    iput-boolean v2, p0, Lin/startv/hotstar/FileViewerActivity;->isEdited:Z
    iget-object v2, p0, Lin/startv/hotstar/FileViewerActivity;->statusText:Landroid/widget/TextView;
    const-string v3, "Saved"
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    goto :save_done
    :save_failed
    const-string v3, "\u274c Failed to save"
    const/4 v2, 0x1
    invoke-static {p0, v3, v2}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;
    move-result-object v3
    invoke-virtual {v3}, Landroid/widget/Toast;->show()V
    :save_done
    return-void
.end method

# ===== Toggle search bar =====
.method public toggleSearch()V
    .locals 2
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->searchContainer:Landroid/widget/LinearLayout;
    invoke-virtual {v0}, Landroid/view/View;->getVisibility()I
    move-result v1
    if-nez v1, :show_it
    const/16 v1, 0x8
    invoke-virtual {v0, v1}, Landroid/view/View;->setVisibility(I)V
    goto :toggle_done
    :show_it
    const/4 v1, 0x0
    invoke-virtual {v0, v1}, Landroid/view/View;->setVisibility(I)V
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->searchInput:Landroid/widget/EditText;
    invoke-virtual {v0}, Landroid/view/View;->requestFocus()Z
    :toggle_done
    return-void
.end method

# ===== Find next =====
.method public findNext()V
    .locals 9
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->searchInput:Landroid/widget/EditText;
    invoke-virtual {v0}, Landroid/widget/EditText;->getText()Landroid/text/Editable;
    move-result-object v0
    invoke-virtual {v0}, Ljava/lang/Object;->toString()Ljava/lang/String;
    move-result-object v0
    invoke-virtual {v0}, Ljava/lang/String;->length()I
    move-result v1
    if-gtz v1, :has_query_fn
    return-void
    :has_query_fn
    iget-object v1, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;
    invoke-virtual {v1}, Landroid/widget/EditText;->getText()Landroid/text/Editable;
    move-result-object v2
    invoke-virtual {v2}, Ljava/lang/Object;->toString()Ljava/lang/String;
    move-result-object v2
    invoke-virtual {v2}, Ljava/lang/String;->toLowerCase()Ljava/lang/String;
    move-result-object v3
    invoke-virtual {v0}, Ljava/lang/String;->toLowerCase()Ljava/lang/String;
    move-result-object v4
    invoke-virtual {v1}, Landroid/widget/EditText;->getSelectionEnd()I
    move-result v5
    invoke-virtual {v3, v4, v5}, Ljava/lang/String;->indexOf(Ljava/lang/String;I)I
    move-result v6
    if-gez v6, :found_fn
    const/4 v5, 0x0
    invoke-virtual {v3, v4, v5}, Ljava/lang/String;->indexOf(Ljava/lang/String;I)I
    move-result v6
    if-gez v6, :found_fn
    iget-object v7, p0, Lin/startv/hotstar/FileViewerActivity;->matchCountText:Landroid/widget/TextView;
    const-string v8, "0"
    invoke-virtual {v7, v8}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    const-string v7, "Not found"
    const/4 v8, 0x0
    invoke-static {p0, v7, v8}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;
    move-result-object v7
    invoke-virtual {v7}, Landroid/widget/Toast;->show()V
    return-void
    :found_fn
    invoke-virtual {v0}, Ljava/lang/String;->length()I
    move-result v7
    add-int v8, v6, v7
    invoke-virtual {v1, v6, v8}, Landroid/widget/EditText;->setSelection(II)V
    invoke-virtual {v1}, Landroid/view/View;->requestFocus()Z
    const/4 v5, 0x0
    const/4 v7, 0x0
    :count_loop_fn
    invoke-virtual {v3, v4, v7}, Ljava/lang/String;->indexOf(Ljava/lang/String;I)I
    move-result v7
    if-ltz v7, :count_done_fn
    add-int/lit8 v5, v5, 0x1
    add-int/lit8 v7, v7, 0x1
    goto :count_loop_fn
    :count_done_fn
    invoke-static {v5}, Ljava/lang/String;->valueOf(I)Ljava/lang/String;
    move-result-object v7
    iget-object v8, p0, Lin/startv/hotstar/FileViewerActivity;->matchCountText:Landroid/widget/TextView;
    invoke-virtual {v8, v7}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    return-void
.end method

# ===== Find previous =====
.method public findPrev()V
    .locals 8
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->searchInput:Landroid/widget/EditText;
    invoke-virtual {v0}, Landroid/widget/EditText;->getText()Landroid/text/Editable;
    move-result-object v0
    invoke-virtual {v0}, Ljava/lang/Object;->toString()Ljava/lang/String;
    move-result-object v0
    invoke-virtual {v0}, Ljava/lang/String;->length()I
    move-result v1
    if-gtz v1, :has_query_fp
    return-void
    :has_query_fp
    iget-object v1, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;
    invoke-virtual {v1}, Landroid/widget/EditText;->getText()Landroid/text/Editable;
    move-result-object v2
    invoke-virtual {v2}, Ljava/lang/Object;->toString()Ljava/lang/String;
    move-result-object v2
    invoke-virtual {v2}, Ljava/lang/String;->toLowerCase()Ljava/lang/String;
    move-result-object v3
    invoke-virtual {v0}, Ljava/lang/String;->toLowerCase()Ljava/lang/String;
    move-result-object v4
    invoke-virtual {v1}, Landroid/widget/EditText;->getSelectionStart()I
    move-result v5
    add-int/lit8 v5, v5, -0x1
    if-gez v5, :pos_ok_fp
    invoke-virtual {v3}, Ljava/lang/String;->length()I
    move-result v5
    :pos_ok_fp
    invoke-virtual {v3, v4, v5}, Ljava/lang/String;->lastIndexOf(Ljava/lang/String;I)I
    move-result v6
    if-gez v6, :found_prev_fp
    invoke-virtual {v3}, Ljava/lang/String;->length()I
    move-result v5
    invoke-virtual {v3, v4, v5}, Ljava/lang/String;->lastIndexOf(Ljava/lang/String;I)I
    move-result v6
    if-gez v6, :found_prev_fp
    const-string v7, "Not found"
    const/4 v5, 0x0
    invoke-static {p0, v7, v5}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;
    move-result-object v7
    invoke-virtual {v7}, Landroid/widget/Toast;->show()V
    return-void
    :found_prev_fp
    invoke-virtual {v0}, Ljava/lang/String;->length()I
    move-result v7
    add-int v7, v6, v7
    invoke-virtual {v1, v6, v7}, Landroid/widget/EditText;->setSelection(II)V
    invoke-virtual {v1}, Landroid/view/View;->requestFocus()Z
    return-void
.end method

# ===== Replace single =====
.method public doReplace()V
    .locals 6
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->searchInput:Landroid/widget/EditText;
    invoke-virtual {v0}, Landroid/widget/EditText;->getText()Landroid/text/Editable;
    move-result-object v0
    invoke-virtual {v0}, Ljava/lang/Object;->toString()Ljava/lang/String;
    move-result-object v0
    invoke-virtual {v0}, Ljava/lang/String;->length()I
    move-result v1
    if-gtz v1, :has_search_dr
    return-void
    :has_search_dr
    iget-object v1, p0, Lin/startv/hotstar/FileViewerActivity;->replaceInput:Landroid/widget/EditText;
    invoke-virtual {v1}, Landroid/widget/EditText;->getText()Landroid/text/Editable;
    move-result-object v1
    invoke-virtual {v1}, Ljava/lang/Object;->toString()Ljava/lang/String;
    move-result-object v1
    iget-object v2, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;
    invoke-virtual {v2}, Landroid/widget/EditText;->getSelectionStart()I
    move-result v3
    invoke-virtual {v2}, Landroid/widget/EditText;->getSelectionEnd()I
    move-result v4
    if-eq v3, v4, :find_first_dr
    invoke-virtual {v2}, Landroid/widget/EditText;->getText()Landroid/text/Editable;
    move-result-object v5
    invoke-interface {v5, v3, v4}, Ljava/lang/CharSequence;->subSequence(II)Ljava/lang/CharSequence;
    move-result-object v5
    invoke-virtual {v5}, Ljava/lang/Object;->toString()Ljava/lang/String;
    move-result-object v5
    invoke-virtual {v5}, Ljava/lang/String;->toLowerCase()Ljava/lang/String;
    move-result-object v5
    invoke-virtual {v0}, Ljava/lang/String;->toLowerCase()Ljava/lang/String;
    move-result-object v0
    invoke-virtual {v5, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v5
    if-eqz v5, :find_first_dr
    invoke-virtual {v2}, Landroid/widget/EditText;->getText()Landroid/text/Editable;
    move-result-object v5
    invoke-interface {v5, v3, v4, v1}, Landroid/text/Editable;->replace(IILjava/lang/CharSequence;)Landroid/text/Editable;
    invoke-virtual {p0}, Lin/startv/hotstar/FileViewerActivity;->findNext()V
    return-void
    :find_first_dr
    invoke-virtual {p0}, Lin/startv/hotstar/FileViewerActivity;->findNext()V
    return-void
.end method

# ===== Replace all =====
.method public doReplaceAll()V
    .locals 7
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->searchInput:Landroid/widget/EditText;
    invoke-virtual {v0}, Landroid/widget/EditText;->getText()Landroid/text/Editable;
    move-result-object v0
    invoke-virtual {v0}, Ljava/lang/Object;->toString()Ljava/lang/String;
    move-result-object v0
    invoke-virtual {v0}, Ljava/lang/String;->length()I
    move-result v1
    if-gtz v1, :has_search_dra
    return-void
    :has_search_dra
    iget-object v1, p0, Lin/startv/hotstar/FileViewerActivity;->replaceInput:Landroid/widget/EditText;
    invoke-virtual {v1}, Landroid/widget/EditText;->getText()Landroid/text/Editable;
    move-result-object v1
    invoke-virtual {v1}, Ljava/lang/Object;->toString()Ljava/lang/String;
    move-result-object v1
    iget-object v2, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;
    invoke-virtual {v2}, Landroid/widget/EditText;->getText()Landroid/text/Editable;
    move-result-object v3
    invoke-virtual {v3}, Ljava/lang/Object;->toString()Ljava/lang/String;
    move-result-object v3
    invoke-virtual {v3, v0, v1}, Ljava/lang/String;->replace(Ljava/lang/CharSequence;Ljava/lang/CharSequence;)Ljava/lang/String;
    move-result-object v4
    invoke-virtual {v3, v4}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v5
    if-eqz v5, :did_replace_dra
    const-string v5, "No matches found"
    const/4 v6, 0x0
    invoke-static {p0, v5, v6}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;
    move-result-object v5
    invoke-virtual {v5}, Landroid/widget/Toast;->show()V
    return-void
    :did_replace_dra
    invoke-virtual {v2, v4}, Landroid/widget/EditText;->setText(Ljava/lang/CharSequence;)V
    const-string v5, "\u2705 Replaced all"
    const/4 v6, 0x0
    invoke-static {p0, v5, v6}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;
    move-result-object v5
    invoke-virtual {v5}, Landroid/widget/Toast;->show()V
    iget-object v5, p0, Lin/startv/hotstar/FileViewerActivity;->matchCountText:Landroid/widget/TextView;
    const-string v6, "0"
    invoke-virtual {v5, v6}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    return-void
.end method

# ===== Zoom in: increase text size =====
.method public zoomIn()V
    .locals 3
    iget v0, p0, Lin/startv/hotstar/FileViewerActivity;->currentTextSize:F
    const/high16 v1, 0x40000000
    add-float/2addr v0, v1
    const/high16 v1, 0x42200000
    cmpg-float v2, v0, v1
    if-lez v2, :ok_in
    move v0, v1
    :ok_in
    iput v0, p0, Lin/startv/hotstar/FileViewerActivity;->currentTextSize:F
    iget-object v1, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;
    const/4 v2, 0x0
    invoke-virtual {v1, v2, v0}, Landroid/widget/EditText;->setTextSize(IF)V
    return-void
.end method

# ===== Zoom out: decrease text size =====
.method public zoomOut()V
    .locals 3
    iget v0, p0, Lin/startv/hotstar/FileViewerActivity;->currentTextSize:F
    const/high16 v1, 0x40000000
    sub-float/2addr v0, v1
    const/high16 v1, 0x41200000
    cmpl-float v2, v0, v1
    if-gez v2, :ok_out
    move v0, v1
    :ok_out
    iput v0, p0, Lin/startv/hotstar/FileViewerActivity;->currentTextSize:F
    iget-object v1, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;
    const/4 v2, 0x0
    invoke-virtual {v1, v2, v0}, Landroid/widget/EditText;->setTextSize(IF)V
    return-void
.end method

# ===== onCreate =====
.method public onCreate(Landroid/os/Bundle;)V
    .locals 14
    move-object/from16 v12, p0
    move-object/from16 v13, p1
    invoke-super {v12, v13}, Landroid/app/Activity;->onCreate(Landroid/os/Bundle;)V

    invoke-virtual {v12}, Landroid/app/Activity;->getIntent()Landroid/content/Intent;
    move-result-object v0
    const-string v1, "path"
    invoke-virtual {v0, v1}, Landroid/content/Intent;->getStringExtra(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v0
    if-nez v0, :has_path
    sget-object v0, Lin/startv/hotstar/HSPatchConfig;->filesDir:Ljava/lang/String;
    if-nez v0, :has_path
    const-string v0, "/storage/emulated/0/Download/hspatch_logs"
    :has_path
    iput-object v0, v12, Lin/startv/hotstar/FileViewerActivity;->filePath:Ljava/lang/String;

    invoke-virtual {v12}, Landroid/app/Activity;->getResources()Landroid/content/res/Resources;
    move-result-object v0
    invoke-virtual {v0}, Landroid/content/res/Resources;->getDisplayMetrics()Landroid/util/DisplayMetrics;
    move-result-object v0
    iget v5, v0, Landroid/util/DisplayMetrics;->density:F

    # Initialize zoom level to 18sp
    const/high16 v0, 0x41900000
    iput v0, v12, Lin/startv/hotstar/FileViewerActivity;->currentTextSize:F

    # ROOT LAYOUT
    new-instance v1, Landroid/widget/LinearLayout;
    invoke-direct {v1, v12}, Landroid/widget/LinearLayout;-><init>(Landroid/content/Context;)V
    const/4 v0, 0x1
    invoke-virtual {v1, v0}, Landroid/widget/LinearLayout;->setOrientation(I)V
    const v0, -0x1
    new-instance v3, Landroid/widget/LinearLayout$LayoutParams;
    invoke-direct {v3, v0, v0}, Landroid/widget/LinearLayout$LayoutParams;-><init>(II)V
    invoke-virtual {v1, v3}, Landroid/widget/LinearLayout;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V
    const v0, -0xf2eee9
    invoke-virtual {v1, v0}, Landroid/widget/LinearLayout;->setBackgroundColor(I)V

    # TOOLBAR 64dp
    new-instance v2, Landroid/widget/LinearLayout;
    invoke-direct {v2, v12}, Landroid/widget/LinearLayout;-><init>(Landroid/content/Context;)V
    const/4 v0, 0x0
    invoke-virtual {v2, v0}, Landroid/widget/LinearLayout;->setOrientation(I)V
    const v0, -0xeae5df
    invoke-virtual {v2, v0}, Landroid/widget/LinearLayout;->setBackgroundColor(I)V
    const/16 v0, 0x40
    int-to-float v3, v0
    mul-float/2addr v3, v5
    float-to-int v3, v3
    const v0, -0x1
    new-instance v4, Landroid/widget/LinearLayout$LayoutParams;
    invoke-direct {v4, v0, v3}, Landroid/widget/LinearLayout$LayoutParams;-><init>(II)V
    invoke-virtual {v2, v4}, Landroid/widget/LinearLayout;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V
    const/16 v0, 0x10
    invoke-virtual {v2, v0}, Landroid/widget/LinearLayout;->setGravity(I)V
    const/16 v0, 0xc
    int-to-float v3, v0
    mul-float/2addr v3, v5
    float-to-int v3, v3
    invoke-virtual {v2, v3, v3, v3, v3}, Landroid/widget/LinearLayout;->setPadding(IIII)V

    # Back button 28sp
    new-instance v3, Landroid/widget/TextView;
    invoke-direct {v3, v12}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V
    const-string v4, " \u2190 "
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    const/high16 v4, 0x41e00000
    const/4 v6, 0x0
    invoke-virtual {v3, v6, v4}, Landroid/widget/TextView;->setTextSize(IF)V
    const v4, -0x1
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setTextColor(I)V
    const/16 v4, 0x11
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setGravity(I)V
    new-instance v4, Landroid/widget/LinearLayout$LayoutParams;
    const/4 v6, -0x2
    const/4 v7, -0x1
    invoke-direct {v4, v6, v7}, Landroid/widget/LinearLayout$LayoutParams;-><init>(II)V
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V
    new-instance v4, Lin/startv/hotstar/FileViewerActivity$BackClickListener;
    invoke-direct {v4, v12}, Lin/startv/hotstar/FileViewerActivity$BackClickListener;-><init>(Lin/startv/hotstar/FileViewerActivity;)V
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setOnClickListener(Landroid/view/View$OnClickListener;)V
    invoke-virtual {v2, v3}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # Title 18sp
    new-instance v3, Landroid/widget/TextView;
    invoke-direct {v3, v12}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V
    iget-object v4, v12, Lin/startv/hotstar/FileViewerActivity;->filePath:Ljava/lang/String;
    invoke-static {v4}, Lin/startv/hotstar/FileViewerActivity;->getFileName(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v4
    new-instance v6, Ljava/lang/StringBuilder;
    invoke-direct {v6}, Ljava/lang/StringBuilder;-><init>()V
    const-string v7, "\ud83d\udcdd "
    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v6, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v6}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v4
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    const/high16 v4, 0x41900000
    const/4 v6, 0x0
    invoke-virtual {v3, v6, v4}, Landroid/widget/TextView;->setTextSize(IF)V
    const v4, -0x1
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setTextColor(I)V
    new-instance v4, Landroid/widget/LinearLayout$LayoutParams;
    const/4 v6, 0x0
    const/4 v7, -0x1
    const/high16 v8, 0x3f800000
    invoke-direct {v4, v6, v7, v8}, Landroid/widget/LinearLayout$LayoutParams;-><init>(IIF)V
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V
    const/4 v4, 0x1
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setSingleLine(Z)V
    const/16 v4, 0xc
    int-to-float v6, v4
    mul-float/2addr v6, v5
    float-to-int v6, v6
    const/4 v7, 0x0
    invoke-virtual {v3, v6, v7, v6, v7}, Landroid/widget/TextView;->setPadding(IIII)V
    invoke-virtual {v2, v3}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # Zoom out button (A-) 20sp
    new-instance v3, Landroid/widget/TextView;
    invoke-direct {v3, v12}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V
    const-string v4, " A\u2212 "
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    const/high16 v4, 0x41a00000
    const/4 v6, 0x0
    invoke-virtual {v3, v6, v4}, Landroid/widget/TextView;->setTextSize(IF)V
    const v4, -0x6d6d6e
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setTextColor(I)V
    const/16 v4, 0x11
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setGravity(I)V
    new-instance v4, Landroid/widget/LinearLayout$LayoutParams;
    const/16 v6, 0x2c
    int-to-float v7, v6
    mul-float/2addr v7, v5
    float-to-int v7, v7
    const/4 v8, -0x1
    invoke-direct {v4, v7, v8}, Landroid/widget/LinearLayout$LayoutParams;-><init>(II)V
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V
    new-instance v4, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;
    const/4 v6, 0x7
    invoke-direct {v4, v12, v6}, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;-><init>(Lin/startv/hotstar/FileViewerActivity;I)V
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setOnClickListener(Landroid/view/View$OnClickListener;)V
    invoke-virtual {v2, v3}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # Zoom in button (A+) 20sp
    new-instance v3, Landroid/widget/TextView;
    invoke-direct {v3, v12}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V
    const-string v4, " A+ "
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    const/high16 v4, 0x41a00000
    const/4 v6, 0x0
    invoke-virtual {v3, v6, v4}, Landroid/widget/TextView;->setTextSize(IF)V
    const v4, -0x6d6d6e
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setTextColor(I)V
    const/16 v4, 0x11
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setGravity(I)V
    new-instance v4, Landroid/widget/LinearLayout$LayoutParams;
    const/16 v6, 0x2c
    int-to-float v7, v6
    mul-float/2addr v7, v5
    float-to-int v7, v7
    const/4 v8, -0x1
    invoke-direct {v4, v7, v8}, Landroid/widget/LinearLayout$LayoutParams;-><init>(II)V
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V
    new-instance v4, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;
    const/4 v6, 0x6
    invoke-direct {v4, v12, v6}, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;-><init>(Lin/startv/hotstar/FileViewerActivity;I)V
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setOnClickListener(Landroid/view/View$OnClickListener;)V
    invoke-virtual {v2, v3}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # Search toggle 24sp
    new-instance v3, Landroid/widget/TextView;
    invoke-direct {v3, v12}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V
    const-string v4, " \ud83d\udd0d "
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    const/high16 v4, 0x41c00000
    const/4 v6, 0x0
    invoke-virtual {v3, v6, v4}, Landroid/widget/TextView;->setTextSize(IF)V
    const v4, -0x1
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setTextColor(I)V
    const/16 v4, 0x11
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setGravity(I)V
    new-instance v4, Landroid/widget/LinearLayout$LayoutParams;
    const/4 v6, -0x2
    const/4 v7, -0x1
    invoke-direct {v4, v6, v7}, Landroid/widget/LinearLayout$LayoutParams;-><init>(II)V
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V
    new-instance v4, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;
    const/4 v6, 0x0
    invoke-direct {v4, v12, v6}, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;-><init>(Lin/startv/hotstar/FileViewerActivity;I)V
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setOnClickListener(Landroid/view/View$OnClickListener;)V
    invoke-virtual {v2, v3}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # Save button styled green 16sp
    new-instance v3, Landroid/widget/TextView;
    invoke-direct {v3, v12}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V
    const-string v4, "\ud83d\udcbe Save"
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    const/high16 v4, 0x41800000
    const/4 v6, 0x0
    invoke-virtual {v3, v6, v4}, Landroid/widget/TextView;->setTextSize(IF)V
    const v4, -0x1
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setTextColor(I)V
    new-instance v4, Landroid/graphics/drawable/GradientDrawable;
    invoke-direct {v4}, Landroid/graphics/drawable/GradientDrawable;-><init>()V
    const v6, -0xd25bb2
    invoke-virtual {v4, v6}, Landroid/graphics/drawable/GradientDrawable;->setColor(I)V
    const/high16 v6, 0x41800000
    invoke-virtual {v4, v6}, Landroid/graphics/drawable/GradientDrawable;->setCornerRadius(F)V
    invoke-virtual {v3, v4}, Landroid/view/View;->setBackground(Landroid/graphics/drawable/Drawable;)V
    const/16 v4, 0x14
    int-to-float v6, v4
    mul-float/2addr v6, v5
    float-to-int v6, v6
    const/16 v4, 0xa
    int-to-float v7, v4
    mul-float/2addr v7, v5
    float-to-int v7, v7
    invoke-virtual {v3, v6, v7, v6, v7}, Landroid/widget/TextView;->setPadding(IIII)V
    const/16 v4, 0x11
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setGravity(I)V
    new-instance v4, Lin/startv/hotstar/FileViewerActivity$SaveClickListener;
    invoke-direct {v4, v12}, Lin/startv/hotstar/FileViewerActivity$SaveClickListener;-><init>(Lin/startv/hotstar/FileViewerActivity;)V
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setOnClickListener(Landroid/view/View$OnClickListener;)V
    invoke-virtual {v2, v3}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V
    invoke-virtual {v1, v2}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # DIVIDER
    new-instance v2, Landroid/view/View;
    invoke-direct {v2, v12}, Landroid/view/View;-><init>(Landroid/content/Context;)V
    const v0, -0x1
    const/4 v3, 0x1
    new-instance v4, Landroid/widget/LinearLayout$LayoutParams;
    invoke-direct {v4, v0, v3}, Landroid/widget/LinearLayout$LayoutParams;-><init>(II)V
    invoke-virtual {v2, v4}, Landroid/view/View;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V
    const v0, -0xcfc9c3
    invoke-virtual {v2, v0}, Landroid/view/View;->setBackgroundColor(I)V
    invoke-virtual {v1, v2}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # SEARCH CONTAINER (GONE)
    new-instance v2, Landroid/widget/LinearLayout;
    invoke-direct {v2, v12}, Landroid/widget/LinearLayout;-><init>(Landroid/content/Context;)V
    const/4 v0, 0x1
    invoke-virtual {v2, v0}, Landroid/widget/LinearLayout;->setOrientation(I)V
    const v0, -0xebe6e1
    invoke-virtual {v2, v0}, Landroid/widget/LinearLayout;->setBackgroundColor(I)V
    const/16 v0, 0xa
    int-to-float v3, v0
    mul-float/2addr v3, v5
    float-to-int v3, v3
    invoke-virtual {v2, v3, v3, v3, v3}, Landroid/widget/LinearLayout;->setPadding(IIII)V
    const/16 v0, 0x8
    invoke-virtual {v2, v0}, Landroid/widget/LinearLayout;->setVisibility(I)V
    iput-object v2, v12, Lin/startv/hotstar/FileViewerActivity;->searchContainer:Landroid/widget/LinearLayout;

    # Search row
    new-instance v3, Landroid/widget/LinearLayout;
    invoke-direct {v3, v12}, Landroid/widget/LinearLayout;-><init>(Landroid/content/Context;)V
    const/4 v0, 0x0
    invoke-virtual {v3, v0}, Landroid/widget/LinearLayout;->setOrientation(I)V
    const/16 v0, 0x10
    invoke-virtual {v3, v0}, Landroid/widget/LinearLayout;->setGravity(I)V

    # Search input 16sp
    new-instance v4, Landroid/widget/EditText;
    invoke-direct {v4, v12}, Landroid/widget/EditText;-><init>(Landroid/content/Context;)V
    iput-object v4, v12, Lin/startv/hotstar/FileViewerActivity;->searchInput:Landroid/widget/EditText;
    const-string v6, "Search..."
    invoke-virtual {v4, v6}, Landroid/widget/EditText;->setHint(Ljava/lang/CharSequence;)V
    const/high16 v6, 0x41800000
    const/4 v7, 0x0
    invoke-virtual {v4, v7, v6}, Landroid/widget/EditText;->setTextSize(IF)V
    const v6, -0x1
    invoke-virtual {v4, v6}, Landroid/widget/EditText;->setTextColor(I)V
    const v6, -0x6d6d6e
    invoke-virtual {v4, v6}, Landroid/widget/EditText;->setHintTextColor(I)V
    const v6, -0xf2eee9
    invoke-virtual {v4, v6}, Landroid/widget/EditText;->setBackgroundColor(I)V
    sget-object v6, Landroid/graphics/Typeface;->MONOSPACE:Landroid/graphics/Typeface;
    invoke-virtual {v4, v6}, Landroid/widget/EditText;->setTypeface(Landroid/graphics/Typeface;)V
    const/4 v6, 0x1
    invoke-virtual {v4, v6}, Landroid/widget/EditText;->setSingleLine(Z)V
    const/16 v6, 0xc
    int-to-float v7, v6
    mul-float/2addr v7, v5
    float-to-int v7, v7
    invoke-virtual {v4, v7, v7, v7, v7}, Landroid/widget/EditText;->setPadding(IIII)V
    new-instance v6, Landroid/widget/LinearLayout$LayoutParams;
    const/4 v7, 0x0
    const/4 v8, -0x2
    const/high16 v9, 0x3f800000
    invoke-direct {v6, v7, v8, v9}, Landroid/widget/LinearLayout$LayoutParams;-><init>(IIF)V
    invoke-virtual {v4, v6}, Landroid/widget/EditText;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V
    invoke-virtual {v3, v4}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # Prev btn 22sp
    new-instance v4, Landroid/widget/TextView;
    invoke-direct {v4, v12}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V
    const-string v6, " \u25b2 "
    invoke-virtual {v4, v6}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    const/high16 v6, 0x41b00000
    const/4 v7, 0x0
    invoke-virtual {v4, v7, v6}, Landroid/widget/TextView;->setTextSize(IF)V
    const v6, -0x1
    invoke-virtual {v4, v6}, Landroid/widget/TextView;->setTextColor(I)V
    const/16 v6, 0x11
    invoke-virtual {v4, v6}, Landroid/widget/TextView;->setGravity(I)V
    const/16 v6, 0x30
    int-to-float v7, v6
    mul-float/2addr v7, v5
    float-to-int v7, v7
    invoke-virtual {v4, v7}, Landroid/widget/TextView;->setMinWidth(I)V
    const/16 v6, 0x28
    int-to-float v7, v6
    mul-float/2addr v7, v5
    float-to-int v7, v7
    invoke-virtual {v4, v7}, Landroid/widget/TextView;->setMinHeight(I)V
    new-instance v6, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;
    const/4 v7, 0x2
    invoke-direct {v6, v12, v7}, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;-><init>(Lin/startv/hotstar/FileViewerActivity;I)V
    invoke-virtual {v4, v6}, Landroid/widget/TextView;->setOnClickListener(Landroid/view/View$OnClickListener;)V
    invoke-virtual {v3, v4}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # Next btn 22sp
    new-instance v4, Landroid/widget/TextView;
    invoke-direct {v4, v12}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V
    const-string v6, " \u25bc "
    invoke-virtual {v4, v6}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    const/high16 v6, 0x41b00000
    const/4 v7, 0x0
    invoke-virtual {v4, v7, v6}, Landroid/widget/TextView;->setTextSize(IF)V
    const v6, -0x1
    invoke-virtual {v4, v6}, Landroid/widget/TextView;->setTextColor(I)V
    const/16 v6, 0x11
    invoke-virtual {v4, v6}, Landroid/widget/TextView;->setGravity(I)V
    const/16 v6, 0x30
    int-to-float v7, v6
    mul-float/2addr v7, v5
    float-to-int v7, v7
    invoke-virtual {v4, v7}, Landroid/widget/TextView;->setMinWidth(I)V
    new-instance v6, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;
    const/4 v7, 0x1
    invoke-direct {v6, v12, v7}, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;-><init>(Lin/startv/hotstar/FileViewerActivity;I)V
    invoke-virtual {v4, v6}, Landroid/widget/TextView;->setOnClickListener(Landroid/view/View$OnClickListener;)V
    invoke-virtual {v3, v4}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # Match count 15sp
    new-instance v4, Landroid/widget/TextView;
    invoke-direct {v4, v12}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V
    iput-object v4, v12, Lin/startv/hotstar/FileViewerActivity;->matchCountText:Landroid/widget/TextView;
    const-string v6, "  "
    invoke-virtual {v4, v6}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    const/high16 v6, 0x41700000
    const/4 v7, 0x0
    invoke-virtual {v4, v7, v6}, Landroid/widget/TextView;->setTextSize(IF)V
    const v6, -0x6d6d6e
    invoke-virtual {v4, v6}, Landroid/widget/TextView;->setTextColor(I)V
    const/16 v6, 0x11
    invoke-virtual {v4, v6}, Landroid/widget/TextView;->setGravity(I)V
    const/16 v6, 0x30
    int-to-float v7, v6
    mul-float/2addr v7, v5
    float-to-int v7, v7
    invoke-virtual {v4, v7}, Landroid/widget/TextView;->setMinWidth(I)V
    invoke-virtual {v3, v4}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # Close btn 22sp
    new-instance v4, Landroid/widget/TextView;
    invoke-direct {v4, v12}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V
    const-string v6, " \u2715 "
    invoke-virtual {v4, v6}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    const/high16 v6, 0x41b00000
    const/4 v7, 0x0
    invoke-virtual {v4, v7, v6}, Landroid/widget/TextView;->setTextSize(IF)V
    const v6, -0x1
    invoke-virtual {v4, v6}, Landroid/widget/TextView;->setTextColor(I)V
    const/16 v6, 0x11
    invoke-virtual {v4, v6}, Landroid/widget/TextView;->setGravity(I)V
    new-instance v6, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;
    const/4 v7, 0x5
    invoke-direct {v6, v12, v7}, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;-><init>(Lin/startv/hotstar/FileViewerActivity;I)V
    invoke-virtual {v4, v6}, Landroid/widget/TextView;->setOnClickListener(Landroid/view/View$OnClickListener;)V
    invoke-virtual {v3, v4}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V
    invoke-virtual {v2, v3}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # Replace row
    new-instance v3, Landroid/widget/LinearLayout;
    invoke-direct {v3, v12}, Landroid/widget/LinearLayout;-><init>(Landroid/content/Context;)V
    const/4 v0, 0x0
    invoke-virtual {v3, v0}, Landroid/widget/LinearLayout;->setOrientation(I)V
    const/16 v0, 0x10
    invoke-virtual {v3, v0}, Landroid/widget/LinearLayout;->setGravity(I)V
    new-instance v4, Landroid/widget/LinearLayout$LayoutParams;
    const/4 v6, -0x1
    const/4 v7, -0x2
    invoke-direct {v4, v6, v7}, Landroid/widget/LinearLayout$LayoutParams;-><init>(II)V
    const/16 v6, 0x8
    int-to-float v7, v6
    mul-float/2addr v7, v5
    float-to-int v7, v7
    const/4 v8, 0x0
    invoke-virtual {v4, v8, v7, v8, v8}, Landroid/widget/LinearLayout$LayoutParams;->setMargins(IIII)V
    invoke-virtual {v3, v4}, Landroid/widget/LinearLayout;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V

    # Replace input 16sp
    new-instance v4, Landroid/widget/EditText;
    invoke-direct {v4, v12}, Landroid/widget/EditText;-><init>(Landroid/content/Context;)V
    iput-object v4, v12, Lin/startv/hotstar/FileViewerActivity;->replaceInput:Landroid/widget/EditText;
    const-string v6, "Replace..."
    invoke-virtual {v4, v6}, Landroid/widget/EditText;->setHint(Ljava/lang/CharSequence;)V
    const/high16 v6, 0x41800000
    const/4 v7, 0x0
    invoke-virtual {v4, v7, v6}, Landroid/widget/EditText;->setTextSize(IF)V
    const v6, -0x1
    invoke-virtual {v4, v6}, Landroid/widget/EditText;->setTextColor(I)V
    const v6, -0x6d6d6e
    invoke-virtual {v4, v6}, Landroid/widget/EditText;->setHintTextColor(I)V
    const v6, -0xf2eee9
    invoke-virtual {v4, v6}, Landroid/widget/EditText;->setBackgroundColor(I)V
    sget-object v6, Landroid/graphics/Typeface;->MONOSPACE:Landroid/graphics/Typeface;
    invoke-virtual {v4, v6}, Landroid/widget/EditText;->setTypeface(Landroid/graphics/Typeface;)V
    const/4 v6, 0x1
    invoke-virtual {v4, v6}, Landroid/widget/EditText;->setSingleLine(Z)V
    const/16 v6, 0xc
    int-to-float v7, v6
    mul-float/2addr v7, v5
    float-to-int v7, v7
    invoke-virtual {v4, v7, v7, v7, v7}, Landroid/widget/EditText;->setPadding(IIII)V
    new-instance v6, Landroid/widget/LinearLayout$LayoutParams;
    const/4 v7, 0x0
    const/4 v8, -0x2
    const/high16 v9, 0x3f800000
    invoke-direct {v6, v7, v8, v9}, Landroid/widget/LinearLayout$LayoutParams;-><init>(IIF)V
    invoke-virtual {v4, v6}, Landroid/widget/EditText;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V
    invoke-virtual {v3, v4}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # Replace btn 16sp
    new-instance v4, Landroid/widget/TextView;
    invoke-direct {v4, v12}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V
    const-string v6, " Replace "
    invoke-virtual {v4, v6}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    const/high16 v6, 0x41800000
    const/4 v7, 0x0
    invoke-virtual {v4, v7, v6}, Landroid/widget/TextView;->setTextSize(IF)V
    const v6, -0x1e96
    invoke-virtual {v4, v6}, Landroid/widget/TextView;->setTextColor(I)V
    const/16 v6, 0x11
    invoke-virtual {v4, v6}, Landroid/widget/TextView;->setGravity(I)V
    new-instance v6, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;
    const/4 v7, 0x3
    invoke-direct {v6, v12, v7}, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;-><init>(Lin/startv/hotstar/FileViewerActivity;I)V
    invoke-virtual {v4, v6}, Landroid/widget/TextView;->setOnClickListener(Landroid/view/View$OnClickListener;)V
    invoke-virtual {v3, v4}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # Replace all btn 16sp
    new-instance v4, Landroid/widget/TextView;
    invoke-direct {v4, v12}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V
    const-string v6, " All "
    invoke-virtual {v4, v6}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    const/high16 v6, 0x41800000
    const/4 v7, 0x0
    invoke-virtual {v4, v7, v6}, Landroid/widget/TextView;->setTextSize(IF)V
    const v6, -0x1e96
    invoke-virtual {v4, v6}, Landroid/widget/TextView;->setTextColor(I)V
    const/16 v6, 0x11
    invoke-virtual {v4, v6}, Landroid/widget/TextView;->setGravity(I)V
    new-instance v6, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;
    const/4 v7, 0x4
    invoke-direct {v6, v12, v7}, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;-><init>(Lin/startv/hotstar/FileViewerActivity;I)V
    invoke-virtual {v4, v6}, Landroid/widget/TextView;->setOnClickListener(Landroid/view/View$OnClickListener;)V
    invoke-virtual {v3, v4}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V
    invoke-virtual {v2, v3}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V
    invoke-virtual {v1, v2}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # PATH BAR 14sp
    new-instance v2, Landroid/widget/TextView;
    invoke-direct {v2, v12}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V
    iget-object v0, v12, Lin/startv/hotstar/FileViewerActivity;->filePath:Ljava/lang/String;
    invoke-virtual {v2, v0}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    const/high16 v0, 0x41600000
    const/4 v3, 0x0
    invoke-virtual {v2, v3, v0}, Landroid/widget/TextView;->setTextSize(IF)V
    const v0, -0x1e96
    invoke-virtual {v2, v0}, Landroid/widget/TextView;->setTextColor(I)V
    const v0, -0xebe6e1
    invoke-virtual {v2, v0}, Landroid/widget/TextView;->setBackgroundColor(I)V
    sget-object v0, Landroid/graphics/Typeface;->MONOSPACE:Landroid/graphics/Typeface;
    invoke-virtual {v2, v0}, Landroid/widget/TextView;->setTypeface(Landroid/graphics/Typeface;)V
    const/16 v0, 0xc
    int-to-float v3, v0
    mul-float/2addr v3, v5
    float-to-int v3, v3
    invoke-virtual {v2, v3, v3, v3, v3}, Landroid/widget/TextView;->setPadding(IIII)V
    const/4 v0, 0x1
    invoke-virtual {v2, v0}, Landroid/widget/TextView;->setSingleLine(Z)V
    invoke-virtual {v1, v2}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # DIVIDER
    new-instance v2, Landroid/view/View;
    invoke-direct {v2, v12}, Landroid/view/View;-><init>(Landroid/content/Context;)V
    const v0, -0x1
    const/4 v3, 0x1
    new-instance v4, Landroid/widget/LinearLayout$LayoutParams;
    invoke-direct {v4, v0, v3}, Landroid/widget/LinearLayout$LayoutParams;-><init>(II)V
    invoke-virtual {v2, v4}, Landroid/view/View;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V
    const v0, -0xcfc9c3
    invoke-virtual {v2, v0}, Landroid/view/View;->setBackgroundColor(I)V
    invoke-virtual {v1, v2}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # SCROLLVIEW + EDITTEXT 18sp
    new-instance v2, Landroid/widget/ScrollView;
    invoke-direct {v2, v12}, Landroid/widget/ScrollView;-><init>(Landroid/content/Context;)V
    new-instance v0, Landroid/widget/LinearLayout$LayoutParams;
    const/4 v3, -0x1
    const/4 v4, 0x0
    const/high16 v6, 0x3f800000
    invoke-direct {v0, v3, v4, v6}, Landroid/widget/LinearLayout$LayoutParams;-><init>(IIF)V
    invoke-virtual {v2, v0}, Landroid/widget/ScrollView;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V
    const/4 v0, 0x1
    invoke-virtual {v2, v0}, Landroid/widget/ScrollView;->setFillViewport(Z)V
    const/4 v0, 0x0
    invoke-virtual {v2, v0}, Landroid/widget/ScrollView;->setScrollbarFadingEnabled(Z)V

    new-instance v3, Landroid/widget/EditText;
    invoke-direct {v3, v12}, Landroid/widget/EditText;-><init>(Landroid/content/Context;)V
    iput-object v3, v12, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;
    new-instance v0, Landroid/widget/FrameLayout$LayoutParams;
    const/4 v4, -0x1
    const/4 v6, -0x2
    invoke-direct {v0, v4, v6}, Landroid/widget/FrameLayout$LayoutParams;-><init>(II)V
    invoke-virtual {v3, v0}, Landroid/widget/EditText;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V
    const/high16 v0, 0x41900000
    const/4 v4, 0x0
    invoke-virtual {v3, v4, v0}, Landroid/widget/EditText;->setTextSize(IF)V
    const v0, -0x1
    invoke-virtual {v3, v0}, Landroid/widget/EditText;->setTextColor(I)V
    const v0, -0x6d6d6e
    invoke-virtual {v3, v0}, Landroid/widget/EditText;->setHintTextColor(I)V
    const v0, -0xe9e4de
    invoke-virtual {v3, v0}, Landroid/widget/EditText;->setBackgroundColor(I)V
    sget-object v0, Landroid/graphics/Typeface;->MONOSPACE:Landroid/graphics/Typeface;
    invoke-virtual {v3, v0}, Landroid/widget/EditText;->setTypeface(Landroid/graphics/Typeface;)V
    const/16 v0, 0x10
    int-to-float v4, v0
    mul-float/2addr v4, v5
    float-to-int v4, v4
    invoke-virtual {v3, v4, v4, v4, v4}, Landroid/widget/EditText;->setPadding(IIII)V
    const/16 v0, 0x33
    invoke-virtual {v3, v0}, Landroid/widget/EditText;->setGravity(I)V
    const v0, 0xa0001
    invoke-virtual {v3, v0}, Landroid/widget/EditText;->setInputType(I)V
    new-instance v0, Lin/startv/hotstar/FileViewerActivity$TextChangeWatcher;
    invoke-direct {v0, v12}, Lin/startv/hotstar/FileViewerActivity$TextChangeWatcher;-><init>(Lin/startv/hotstar/FileViewerActivity;)V
    invoke-virtual {v3, v0}, Landroid/widget/EditText;->addTextChangedListener(Landroid/text/TextWatcher;)V
    invoke-virtual {v2, v3}, Landroid/widget/ScrollView;->addView(Landroid/view/View;)V
    invoke-virtual {v1, v2}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # DIVIDER
    new-instance v2, Landroid/view/View;
    invoke-direct {v2, v12}, Landroid/view/View;-><init>(Landroid/content/Context;)V
    const v0, -0x1
    const/4 v3, 0x1
    new-instance v4, Landroid/widget/LinearLayout$LayoutParams;
    invoke-direct {v4, v0, v3}, Landroid/widget/LinearLayout$LayoutParams;-><init>(II)V
    invoke-virtual {v2, v4}, Landroid/view/View;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V
    const v0, -0xcfc9c3
    invoke-virtual {v2, v0}, Landroid/view/View;->setBackgroundColor(I)V
    invoke-virtual {v1, v2}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # STATUS BAR 15sp
    new-instance v2, Landroid/widget/TextView;
    invoke-direct {v2, v12}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V
    iput-object v2, v12, Lin/startv/hotstar/FileViewerActivity;->statusText:Landroid/widget/TextView;
    const-string v0, "Loading..."
    invoke-virtual {v2, v0}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    const/high16 v0, 0x41700000
    const/4 v3, 0x0
    invoke-virtual {v2, v3, v0}, Landroid/widget/TextView;->setTextSize(IF)V
    const v0, -0x6d6d6e
    invoke-virtual {v2, v0}, Landroid/widget/TextView;->setTextColor(I)V
    const v0, -0xebe6e1
    invoke-virtual {v2, v0}, Landroid/widget/TextView;->setBackgroundColor(I)V
    sget-object v0, Landroid/graphics/Typeface;->MONOSPACE:Landroid/graphics/Typeface;
    invoke-virtual {v2, v0}, Landroid/widget/TextView;->setTypeface(Landroid/graphics/Typeface;)V
    const/16 v0, 0xc
    int-to-float v3, v0
    mul-float/2addr v3, v5
    float-to-int v3, v3
    invoke-virtual {v2, v3, v3, v3, v3}, Landroid/widget/TextView;->setPadding(IIII)V
    invoke-virtual {v1, v2}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    invoke-virtual {v12, v1}, Landroid/app/Activity;->setContentView(Landroid/view/View;)V

    # LOAD FILE
    iget-object v0, v12, Lin/startv/hotstar/FileViewerActivity;->filePath:Ljava/lang/String;
    invoke-static {v0}, Lin/startv/hotstar/FileViewerActivity;->readFileContent(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v0
    if-nez v0, :show_text_content
    const/4 v2, 0x1
    iput-boolean v2, v12, Lin/startv/hotstar/FileViewerActivity;->isBinary:Z
    iget-object v2, v12, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;
    const-string v3, "[Binary file or file too large (>5MB)]\n\nCannot display in text editor."
    invoke-virtual {v2, v3}, Landroid/widget/EditText;->setText(Ljava/lang/CharSequence;)V
    const/4 v3, 0x0
    invoke-virtual {v2, v3}, Landroid/widget/EditText;->setEnabled(Z)V
    iget-object v2, v12, Lin/startv/hotstar/FileViewerActivity;->statusText:Landroid/widget/TextView;
    new-instance v3, Ljava/io/File;
    iget-object v4, v12, Lin/startv/hotstar/FileViewerActivity;->filePath:Ljava/lang/String;
    invoke-direct {v3, v4}, Ljava/io/File;-><init>(Ljava/lang/String;)V
    invoke-virtual {v3}, Ljava/io/File;->length()J
    move-result-wide v4
    invoke-static {v4, v5}, Lin/startv/hotstar/FileExplorerActivity;->formatSize(J)Ljava/lang/String;
    move-result-object v3
    new-instance v4, Ljava/lang/StringBuilder;
    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V
    const-string v6, "Binary | Size: "
    invoke-virtual {v4, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v4, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v6, " | Read-only"
    invoke-virtual {v4, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v3
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    goto :load_done

    :show_text_content
    const/4 v2, 0x0
    iput-boolean v2, v12, Lin/startv/hotstar/FileViewerActivity;->isBinary:Z
    iget-object v2, v12, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;
    invoke-virtual {v2, v0}, Landroid/widget/EditText;->setText(Ljava/lang/CharSequence;)V
    const-string v3, "\n"
    invoke-virtual {v0, v3}, Ljava/lang/String;->split(Ljava/lang/String;)[Ljava/lang/String;
    move-result-object v3
    array-length v3, v3
    new-instance v4, Ljava/io/File;
    iget-object v6, v12, Lin/startv/hotstar/FileViewerActivity;->filePath:Ljava/lang/String;
    invoke-direct {v4, v6}, Ljava/io/File;-><init>(Ljava/lang/String;)V
    invoke-virtual {v4}, Ljava/io/File;->length()J
    move-result-wide v6
    invoke-static {v6, v7}, Lin/startv/hotstar/FileExplorerActivity;->formatSize(J)Ljava/lang/String;
    move-result-object v4
    new-instance v6, Ljava/lang/StringBuilder;
    invoke-direct {v6}, Ljava/lang/StringBuilder;-><init>()V
    const-string v7, "Lines: "
    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v6, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    const-string v7, " | Size: "
    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v6, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v7, " | UTF-8"
    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v6}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v3
    iget-object v4, v12, Lin/startv/hotstar/FileViewerActivity;->statusText:Landroid/widget/TextView;
    invoke-virtual {v4, v3}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    const/4 v3, 0x0
    iput-boolean v3, v12, Lin/startv/hotstar/FileViewerActivity;->isEdited:Z
    :load_done
    return-void
.end method

# ===== onBackPressed =====
.method public onBackPressed()V
    .locals 3
    iget-boolean v0, p0, Lin/startv/hotstar/FileViewerActivity;->isEdited:Z
    if-eqz v0, :just_finish
    new-instance v0, Landroid/app/AlertDialog$Builder;
    invoke-direct {v0, p0}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V
    const-string v1, "Unsaved Changes"
    invoke-virtual {v0, v1}, Landroid/app/AlertDialog$Builder;->setTitle(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;
    const-string v1, "You have unsaved changes. Discard and go back?"
    invoke-virtual {v0, v1}, Landroid/app/AlertDialog$Builder;->setMessage(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;
    const-string v1, "Discard"
    new-instance v2, Lin/startv/hotstar/FileViewerActivity$DiscardClickListener;
    invoke-direct {v2, p0}, Lin/startv/hotstar/FileViewerActivity$DiscardClickListener;-><init>(Lin/startv/hotstar/FileViewerActivity;)V
    invoke-virtual {v0, v1, v2}, Landroid/app/AlertDialog$Builder;->setPositiveButton(Ljava/lang/CharSequence;Landroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;
    const-string v1, "Cancel"
    const/4 v2, 0x0
    invoke-virtual {v0, v1, v2}, Landroid/app/AlertDialog$Builder;->setNegativeButton(Ljava/lang/CharSequence;Landroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;
    invoke-virtual {v0}, Landroid/app/AlertDialog$Builder;->show()Landroid/app/AlertDialog;
    move-result-object v0
    invoke-virtual {v0}, Landroid/app/AlertDialog;->getWindow()Landroid/view/Window;
    move-result-object v1
    if-eqz v1, :dialog_done
    invoke-virtual {v1}, Landroid/view/Window;->getDecorView()Landroid/view/View;
    move-result-object v1
    const v2, -0xe9e4de
    invoke-virtual {v1, v2}, Landroid/view/View;->setBackgroundColor(I)V
    :dialog_done
    return-void
    :just_finish
    invoke-virtual {p0}, Landroid/app/Activity;->finish()V
    return-void
.end method
