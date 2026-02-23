.class public Lin/startv/hotstar/LogViewerActivity;
.super Landroid/app/Activity;
.source "LogViewerActivity.java"

.field public filePath:Ljava/lang/String;
.field public textView:Landroid/widget/TextView;
.field public statusText:Landroid/widget/TextView;
.field public logScrollView:Landroid/widget/ScrollView;
.field public searchContainer:Landroid/widget/LinearLayout;
.field public searchInput:Landroid/widget/EditText;
.field public matchCountText:Landroid/widget/TextView;
.field public handler:Landroid/os/Handler;
.field public isStreaming:Z
.field public streamBtn:Landroid/widget/TextView;
.field public logContent:Ljava/lang/String;

.method public constructor <init>()V
    .locals 0
    invoke-direct {p0}, Landroid/app/Activity;-><init>()V
    return-void
.end method

# Read last maxBytes of file (tail approach)
.method public static readFileTail(Ljava/lang/String;I)Ljava/lang/String;
    .locals 8
    :try_start
    new-instance v0, Ljava/io/File;
    invoke-direct {v0, p0}, Ljava/io/File;-><init>(Ljava/lang/String;)V
    invoke-virtual {v0}, Ljava/io/File;->exists()Z
    move-result v1
    if-nez v1, :file_exists_lv
    const-string v0, "(File not found)"
    return-object v0
    :file_exists_lv
    invoke-virtual {v0}, Ljava/io/File;->length()J
    move-result-wide v1
    # v1 = file length (long)
    new-instance v3, Ljava/io/RandomAccessFile;
    const-string v4, "r"
    invoke-direct {v3, v0, v4}, Ljava/io/RandomAccessFile;-><init>(Ljava/io/File;Ljava/lang/String;)V
    int-to-long v4, p1
    cmp-long v6, v1, v4
    if-lez v6, :read_all_lv
    # Seek to (length - maxBytes)
    sub-long v4, v1, v4
    invoke-virtual {v3, v4, v5}, Ljava/io/RandomAccessFile;->seek(J)V
    # Skip partial line
    invoke-virtual {v3}, Ljava/io/RandomAccessFile;->readLine()Ljava/lang/String;
    # Read remaining
    invoke-virtual {v3}, Ljava/io/RandomAccessFile;->getFilePointer()J
    move-result-wide v4
    sub-long v4, v1, v4
    long-to-int v6, v4
    goto :do_read_lv
    :read_all_lv
    long-to-int v6, v1
    const-wide/16 v4, 0x0
    invoke-virtual {v3, v4, v5}, Ljava/io/RandomAccessFile;->seek(J)V
    :do_read_lv
    new-array v7, v6, [B
    invoke-virtual {v3, v7}, Ljava/io/RandomAccessFile;->readFully([B)V
    invoke-virtual {v3}, Ljava/io/RandomAccessFile;->close()V
    new-instance v0, Ljava/lang/String;
    const-string v4, "UTF-8"
    invoke-direct {v0, v7, v4}, Ljava/lang/String;-><init>([BLjava/lang/String;)V
    :try_end
    .catch Ljava/lang/Exception; {:try_start .. :try_end} :catch_lv
    return-object v0
    :catch_lv
    move-exception v0
    invoke-virtual {v0}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;
    move-result-object v0
    new-instance v1, Ljava/lang/StringBuilder;
    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V
    const-string v2, "(Error: "
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v2, ")"
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    return-object v0
.end method

.method public refreshLog()V
    .locals 5
    iget-object v0, p0, Lin/startv/hotstar/LogViewerActivity;->filePath:Ljava/lang/String;
    if-eqz v0, :no_file_rl
    # Read last 512KB
    const v1, 0x80000
    invoke-static {v0, v1}, Lin/startv/hotstar/LogViewerActivity;->readFileTail(Ljava/lang/String;I)Ljava/lang/String;
    move-result-object v0
    iput-object v0, p0, Lin/startv/hotstar/LogViewerActivity;->logContent:Ljava/lang/String;
    iget-object v1, p0, Lin/startv/hotstar/LogViewerActivity;->textView:Landroid/widget/TextView;
    invoke-virtual {v1, v0}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    # Update status
    new-instance v1, Ljava/io/File;
    iget-object v2, p0, Lin/startv/hotstar/LogViewerActivity;->filePath:Ljava/lang/String;
    invoke-direct {v1, v2}, Ljava/io/File;-><init>(Ljava/lang/String;)V
    invoke-virtual {v1}, Ljava/io/File;->length()J
    move-result-wide v2
    invoke-static {v2, v3}, Lin/startv/hotstar/FileExplorerActivity;->formatSize(J)Ljava/lang/String;
    move-result-object v1
    # Count lines
    const-string v2, "\n"
    invoke-virtual {v0, v2}, Ljava/lang/String;->split(Ljava/lang/String;)[Ljava/lang/String;
    move-result-object v2
    array-length v2, v2
    new-instance v3, Ljava/lang/StringBuilder;
    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V
    const-string v4, "Lines: "
    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v3, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    const-string v4, " | File: "
    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v3, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v1
    iget-object v2, p0, Lin/startv/hotstar/LogViewerActivity;->statusText:Landroid/widget/TextView;
    invoke-virtual {v2, v1}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    # Scroll to bottom
    iget-object v0, p0, Lin/startv/hotstar/LogViewerActivity;->logScrollView:Landroid/widget/ScrollView;
    if-eqz v0, :no_file_rl
    const/16 v1, 0x82
    invoke-virtual {v0, v1}, Landroid/widget/ScrollView;->fullScroll(I)Z
    :no_file_rl
    return-void
.end method

.method public toggleSearch()V
    .locals 2
    iget-object v0, p0, Lin/startv/hotstar/LogViewerActivity;->searchContainer:Landroid/widget/LinearLayout;
    invoke-virtual {v0}, Landroid/view/View;->getVisibility()I
    move-result v1
    if-nez v1, :show_lv
    const/16 v1, 0x8
    invoke-virtual {v0, v1}, Landroid/view/View;->setVisibility(I)V
    goto :done_ts_lv
    :show_lv
    const/4 v1, 0x0
    invoke-virtual {v0, v1}, Landroid/view/View;->setVisibility(I)V
    iget-object v0, p0, Lin/startv/hotstar/LogViewerActivity;->searchInput:Landroid/widget/EditText;
    invoke-virtual {v0}, Landroid/view/View;->requestFocus()Z
    :done_ts_lv
    return-void
.end method

.method public findNextLog()V
    .locals 9
    iget-object v0, p0, Lin/startv/hotstar/LogViewerActivity;->searchInput:Landroid/widget/EditText;
    invoke-virtual {v0}, Landroid/widget/EditText;->getText()Landroid/text/Editable;
    move-result-object v0
    invoke-virtual {v0}, Ljava/lang/Object;->toString()Ljava/lang/String;
    move-result-object v0
    invoke-virtual {v0}, Ljava/lang/String;->length()I
    move-result v1
    if-gtz v1, :has_q_lv
    return-void
    :has_q_lv
    iget-object v1, p0, Lin/startv/hotstar/LogViewerActivity;->logContent:Ljava/lang/String;
    if-nez v1, :has_content_lv
    return-void
    :has_content_lv
    invoke-virtual {v1}, Ljava/lang/String;->toLowerCase()Ljava/lang/String;
    move-result-object v2
    invoke-virtual {v0}, Ljava/lang/String;->toLowerCase()Ljava/lang/String;
    move-result-object v3
    # Use textView selection
    iget-object v4, p0, Lin/startv/hotstar/LogViewerActivity;->textView:Landroid/widget/TextView;
    invoke-virtual {v4}, Landroid/widget/TextView;->getSelectionEnd()I
    move-result v5
    if-gez v5, :pos_ok_lv
    const/4 v5, 0x0
    :pos_ok_lv
    invoke-virtual {v2, v3, v5}, Ljava/lang/String;->indexOf(Ljava/lang/String;I)I
    move-result v6
    if-gez v6, :found_lv
    const/4 v5, 0x0
    invoke-virtual {v2, v3, v5}, Ljava/lang/String;->indexOf(Ljava/lang/String;I)I
    move-result v6
    if-gez v6, :found_lv
    iget-object v7, p0, Lin/startv/hotstar/LogViewerActivity;->matchCountText:Landroid/widget/TextView;
    const-string v8, "0"
    invoke-virtual {v7, v8}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    const-string v7, "Not found"
    const/4 v8, 0x0
    invoke-static {p0, v7, v8}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;
    move-result-object v7
    invoke-virtual {v7}, Landroid/widget/Toast;->show()V
    return-void
    :found_lv
    # Highlight using Selection on spannable
    invoke-virtual {v0}, Ljava/lang/String;->length()I
    move-result v7
    add-int v8, v6, v7
    invoke-virtual {v4}, Landroid/widget/TextView;->getText()Ljava/lang/CharSequence;
    move-result-object v7
    check-cast v7, Landroid/text/Spannable;
    invoke-static {v7, v6, v8}, Landroid/text/Selection;->setSelection(Landroid/text/Spannable;II)V
    invoke-virtual {v4}, Landroid/view/View;->requestFocus()Z
    # Count total
    const/4 v5, 0x0
    const/4 v7, 0x0
    :cnt_lp_lv
    invoke-virtual {v2, v3, v7}, Ljava/lang/String;->indexOf(Ljava/lang/String;I)I
    move-result v7
    if-ltz v7, :cnt_dn_lv
    add-int/lit8 v5, v5, 0x1
    add-int/lit8 v7, v7, 0x1
    goto :cnt_lp_lv
    :cnt_dn_lv
    invoke-static {v5}, Ljava/lang/String;->valueOf(I)Ljava/lang/String;
    move-result-object v7
    iget-object v8, p0, Lin/startv/hotstar/LogViewerActivity;->matchCountText:Landroid/widget/TextView;
    invoke-virtual {v8, v7}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    return-void
.end method

.method public toggleStreaming()V
    .locals 4
    iget-boolean v0, p0, Lin/startv/hotstar/LogViewerActivity;->isStreaming:Z
    if-eqz v0, :start_stream_lv
    # Stop
    const/4 v0, 0x0
    iput-boolean v0, p0, Lin/startv/hotstar/LogViewerActivity;->isStreaming:Z
    iget-object v0, p0, Lin/startv/hotstar/LogViewerActivity;->handler:Landroid/os/Handler;
    const/4 v1, 0x0
    invoke-virtual {v0, v1}, Landroid/os/Handler;->removeCallbacksAndMessages(Ljava/lang/Object;)V
    iget-object v0, p0, Lin/startv/hotstar/LogViewerActivity;->streamBtn:Landroid/widget/TextView;
    const-string v1, " \u25b6 "
    invoke-virtual {v0, v1}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    const-string v0, "Stream stopped"
    const/4 v1, 0x0
    invoke-static {p0, v0, v1}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;
    move-result-object v0
    invoke-virtual {v0}, Landroid/widget/Toast;->show()V
    return-void
    :start_stream_lv
    const/4 v0, 0x1
    iput-boolean v0, p0, Lin/startv/hotstar/LogViewerActivity;->isStreaming:Z
    iget-object v0, p0, Lin/startv/hotstar/LogViewerActivity;->streamBtn:Landroid/widget/TextView;
    const-string v1, " \u23f8 "
    invoke-virtual {v0, v1}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    # Post repeating refresh
    new-instance v0, Lin/startv/hotstar/LogViewerActivity$StreamRunnable;
    invoke-direct {v0, p0}, Lin/startv/hotstar/LogViewerActivity$StreamRunnable;-><init>(Lin/startv/hotstar/LogViewerActivity;)V
    iget-object v1, p0, Lin/startv/hotstar/LogViewerActivity;->handler:Landroid/os/Handler;
    const-wide/16 v2, 0x5dc
    invoke-virtual {v1, v0, v2, v3}, Landroid/os/Handler;->postDelayed(Ljava/lang/Runnable;J)Z
    invoke-virtual {p0}, Lin/startv/hotstar/LogViewerActivity;->refreshLog()V
    const-string v0, "Streaming (1.5s)"
    const/4 v1, 0x0
    invoke-static {p0, v0, v1}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;
    move-result-object v0
    invoke-virtual {v0}, Landroid/widget/Toast;->show()V
    return-void
.end method

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
    if-nez v0, :has_path_lv
    const-string v0, "request_logs.txt"
    invoke-static {v0}, Lin/startv/hotstar/HSPatchConfig;->getFilePath(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v0
    :has_path_lv
    iput-object v0, v12, Lin/startv/hotstar/LogViewerActivity;->filePath:Ljava/lang/String;

    # Handler
    new-instance v0, Landroid/os/Handler;
    invoke-static {}, Landroid/os/Looper;->getMainLooper()Landroid/os/Looper;
    move-result-object v1
    invoke-direct {v0, v1}, Landroid/os/Handler;-><init>(Landroid/os/Looper;)V
    iput-object v0, v12, Lin/startv/hotstar/LogViewerActivity;->handler:Landroid/os/Handler;

    invoke-virtual {v12}, Landroid/app/Activity;->getResources()Landroid/content/res/Resources;
    move-result-object v0
    invoke-virtual {v0}, Landroid/content/res/Resources;->getDisplayMetrics()Landroid/util/DisplayMetrics;
    move-result-object v0
    iget v5, v0, Landroid/util/DisplayMetrics;->density:F

    # ROOT
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

    # Back 28sp
    new-instance v3, Landroid/widget/TextView;
    invoke-direct {v3, v12}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V
    const-string v4, " \u2190 "
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    const/high16 v4, 0x41e00000
    const/4 v6, 0x0
    invoke-virtual {v3, v6, v4}, Landroid/widget/TextView;->setTextSize(IF)V
    const v4, -0x1
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setTextColor(I)V
    const/16 v4, 0x10
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setGravity(I)V
    new-instance v4, Landroid/widget/LinearLayout$LayoutParams;
    const/4 v6, -0x2
    const/4 v7, -0x1
    invoke-direct {v4, v6, v7}, Landroid/widget/LinearLayout$LayoutParams;-><init>(II)V
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V
    new-instance v4, Lin/startv/hotstar/LogViewerActivity$ActionListener;
    const/4 v6, 0x0
    invoke-direct {v4, v12, v6}, Lin/startv/hotstar/LogViewerActivity$ActionListener;-><init>(Lin/startv/hotstar/LogViewerActivity;I)V
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setOnClickListener(Landroid/view/View$OnClickListener;)V
    invoke-virtual {v2, v3}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # Title 18sp
    new-instance v3, Landroid/widget/TextView;
    invoke-direct {v3, v12}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V
    const-string v4, "\ud83d\udccb Log Viewer"
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
    const/16 v4, 0x10
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setGravity(I)V
    new-instance v4, Landroid/widget/LinearLayout$LayoutParams;
    const/4 v6, -0x2
    const/4 v7, -0x1
    invoke-direct {v4, v6, v7}, Landroid/widget/LinearLayout$LayoutParams;-><init>(II)V
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V
    new-instance v4, Lin/startv/hotstar/LogViewerActivity$ActionListener;
    const/4 v6, 0x1
    invoke-direct {v4, v12, v6}, Lin/startv/hotstar/LogViewerActivity$ActionListener;-><init>(Lin/startv/hotstar/LogViewerActivity;I)V
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setOnClickListener(Landroid/view/View$OnClickListener;)V
    invoke-virtual {v2, v3}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # Stream toggle 22sp
    new-instance v3, Landroid/widget/TextView;
    invoke-direct {v3, v12}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V
    iput-object v3, v12, Lin/startv/hotstar/LogViewerActivity;->streamBtn:Landroid/widget/TextView;
    const-string v4, " \u25b6 "
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    const/high16 v4, 0x41b00000
    const/4 v6, 0x0
    invoke-virtual {v3, v6, v4}, Landroid/widget/TextView;->setTextSize(IF)V
    const v4, -0x1
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setTextColor(I)V
    const/16 v4, 0x10
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setGravity(I)V
    new-instance v4, Landroid/widget/LinearLayout$LayoutParams;
    const/4 v6, -0x2
    const/4 v7, -0x1
    invoke-direct {v4, v6, v7}, Landroid/widget/LinearLayout$LayoutParams;-><init>(II)V
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V
    new-instance v4, Lin/startv/hotstar/LogViewerActivity$ActionListener;
    const/4 v6, 0x4
    invoke-direct {v4, v12, v6}, Lin/startv/hotstar/LogViewerActivity$ActionListener;-><init>(Lin/startv/hotstar/LogViewerActivity;I)V
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setOnClickListener(Landroid/view/View$OnClickListener;)V
    invoke-virtual {v2, v3}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # Refresh 22sp
    new-instance v3, Landroid/widget/TextView;
    invoke-direct {v3, v12}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V
    const-string v4, " \ud83d\udd04 "
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    const/high16 v4, 0x41b00000
    const/4 v6, 0x0
    invoke-virtual {v3, v6, v4}, Landroid/widget/TextView;->setTextSize(IF)V
    const v4, -0x1
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setTextColor(I)V
    const/16 v4, 0x10
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setGravity(I)V
    new-instance v4, Landroid/widget/LinearLayout$LayoutParams;
    const/4 v6, -0x2
    const/4 v7, -0x1
    invoke-direct {v4, v6, v7}, Landroid/widget/LinearLayout$LayoutParams;-><init>(II)V
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V
    new-instance v4, Lin/startv/hotstar/LogViewerActivity$ActionListener;
    const/4 v6, 0x3
    invoke-direct {v4, v12, v6}, Lin/startv/hotstar/LogViewerActivity$ActionListener;-><init>(Lin/startv/hotstar/LogViewerActivity;I)V
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setOnClickListener(Landroid/view/View$OnClickListener;)V
    invoke-virtual {v2, v3}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # Bottom scroll 22sp
    new-instance v3, Landroid/widget/TextView;
    invoke-direct {v3, v12}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V
    const-string v4, " \u2193 "
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    const/high16 v4, 0x41b00000
    const/4 v6, 0x0
    invoke-virtual {v3, v6, v4}, Landroid/widget/TextView;->setTextSize(IF)V
    const v4, -0x1
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setTextColor(I)V
    const/16 v4, 0x10
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setGravity(I)V
    new-instance v4, Landroid/widget/LinearLayout$LayoutParams;
    const/4 v6, -0x2
    const/4 v7, -0x1
    invoke-direct {v4, v6, v7}, Landroid/widget/LinearLayout$LayoutParams;-><init>(II)V
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V
    new-instance v4, Lin/startv/hotstar/LogViewerActivity$ActionListener;
    const/4 v6, 0x5
    invoke-direct {v4, v12, v6}, Lin/startv/hotstar/LogViewerActivity$ActionListener;-><init>(Lin/startv/hotstar/LogViewerActivity;I)V
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

    # SEARCH BAR (GONE)
    new-instance v2, Landroid/widget/LinearLayout;
    invoke-direct {v2, v12}, Landroid/widget/LinearLayout;-><init>(Landroid/content/Context;)V
    const/4 v0, 0x0
    invoke-virtual {v2, v0}, Landroid/widget/LinearLayout;->setOrientation(I)V
    const/16 v0, 0x10
    invoke-virtual {v2, v0}, Landroid/widget/LinearLayout;->setGravity(I)V
    const v0, -0xebe6e1
    invoke-virtual {v2, v0}, Landroid/widget/LinearLayout;->setBackgroundColor(I)V
    const/16 v0, 0xa
    int-to-float v3, v0
    mul-float/2addr v3, v5
    float-to-int v3, v3
    invoke-virtual {v2, v3, v3, v3, v3}, Landroid/widget/LinearLayout;->setPadding(IIII)V
    const/16 v0, 0x8
    invoke-virtual {v2, v0}, Landroid/widget/LinearLayout;->setVisibility(I)V
    iput-object v2, v12, Lin/startv/hotstar/LogViewerActivity;->searchContainer:Landroid/widget/LinearLayout;

    # Search input
    new-instance v4, Landroid/widget/EditText;
    invoke-direct {v4, v12}, Landroid/widget/EditText;-><init>(Landroid/content/Context;)V
    iput-object v4, v12, Lin/startv/hotstar/LogViewerActivity;->searchInput:Landroid/widget/EditText;
    const-string v6, "Search log..."
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
    invoke-virtual {v2, v4}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # Find btn
    new-instance v4, Landroid/widget/TextView;
    invoke-direct {v4, v12}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V
    const-string v6, " Find "
    invoke-virtual {v4, v6}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    const/high16 v6, 0x41800000
    const/4 v7, 0x0
    invoke-virtual {v4, v7, v6}, Landroid/widget/TextView;->setTextSize(IF)V
    const v6, -0x1e96
    invoke-virtual {v4, v6}, Landroid/widget/TextView;->setTextColor(I)V
    new-instance v6, Lin/startv/hotstar/LogViewerActivity$ActionListener;
    const/4 v7, 0x2
    invoke-direct {v6, v12, v7}, Lin/startv/hotstar/LogViewerActivity$ActionListener;-><init>(Lin/startv/hotstar/LogViewerActivity;I)V
    invoke-virtual {v4, v6}, Landroid/widget/TextView;->setOnClickListener(Landroid/view/View$OnClickListener;)V
    invoke-virtual {v2, v4}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # Count
    new-instance v4, Landroid/widget/TextView;
    invoke-direct {v4, v12}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V
    iput-object v4, v12, Lin/startv/hotstar/LogViewerActivity;->matchCountText:Landroid/widget/TextView;
    const-string v6, " "
    invoke-virtual {v4, v6}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    const/high16 v6, 0x41700000
    const/4 v7, 0x0
    invoke-virtual {v4, v7, v6}, Landroid/widget/TextView;->setTextSize(IF)V
    const v6, -0x6d6d6e
    invoke-virtual {v4, v6}, Landroid/widget/TextView;->setTextColor(I)V
    invoke-virtual {v2, v4}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # Close
    new-instance v4, Landroid/widget/TextView;
    invoke-direct {v4, v12}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V
    const-string v6, " \u2715 "
    invoke-virtual {v4, v6}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    const/high16 v6, 0x41b00000
    const/4 v7, 0x0
    invoke-virtual {v4, v7, v6}, Landroid/widget/TextView;->setTextSize(IF)V
    const v6, -0x1
    invoke-virtual {v4, v6}, Landroid/widget/TextView;->setTextColor(I)V
    new-instance v6, Lin/startv/hotstar/LogViewerActivity$ActionListener;
    const/4 v7, 0x6
    invoke-direct {v6, v12, v7}, Lin/startv/hotstar/LogViewerActivity$ActionListener;-><init>(Lin/startv/hotstar/LogViewerActivity;I)V
    invoke-virtual {v4, v6}, Landroid/widget/TextView;->setOnClickListener(Landroid/view/View$OnClickListener;)V
    invoke-virtual {v2, v4}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V
    invoke-virtual {v1, v2}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # PATH BAR 14sp
    new-instance v2, Landroid/widget/TextView;
    invoke-direct {v2, v12}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V
    iget-object v0, v12, Lin/startv/hotstar/LogViewerActivity;->filePath:Ljava/lang/String;
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
    const/16 v0, 0xa
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

    # LOG SCROLLVIEW
    new-instance v2, Landroid/widget/ScrollView;
    invoke-direct {v2, v12}, Landroid/widget/ScrollView;-><init>(Landroid/content/Context;)V
    iput-object v2, v12, Lin/startv/hotstar/LogViewerActivity;->logScrollView:Landroid/widget/ScrollView;
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

    # Log TextView
    new-instance v3, Landroid/widget/TextView;
    invoke-direct {v3, v12}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V
    iput-object v3, v12, Lin/startv/hotstar/LogViewerActivity;->textView:Landroid/widget/TextView;
    new-instance v0, Landroid/widget/FrameLayout$LayoutParams;
    const/4 v4, -0x1
    const/4 v6, -0x2
    invoke-direct {v0, v4, v6}, Landroid/widget/FrameLayout$LayoutParams;-><init>(II)V
    invoke-virtual {v3, v0}, Landroid/widget/TextView;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V
    const/high16 v0, 0x41700000
    const/4 v4, 0x0
    invoke-virtual {v3, v4, v0}, Landroid/widget/TextView;->setTextSize(IF)V
    const v0, -0x362e27
    invoke-virtual {v3, v0}, Landroid/widget/TextView;->setTextColor(I)V
    const v0, -0xe9e4de
    invoke-virtual {v3, v0}, Landroid/widget/TextView;->setBackgroundColor(I)V
    sget-object v0, Landroid/graphics/Typeface;->MONOSPACE:Landroid/graphics/Typeface;
    invoke-virtual {v3, v0}, Landroid/widget/TextView;->setTypeface(Landroid/graphics/Typeface;)V
    const/16 v0, 0xc
    int-to-float v4, v0
    mul-float/2addr v4, v5
    float-to-int v4, v4
    invoke-virtual {v3, v4, v4, v4, v4}, Landroid/widget/TextView;->setPadding(IIII)V
    const/4 v0, 0x1
    invoke-virtual {v3, v0}, Landroid/widget/TextView;->setTextIsSelectable(Z)V
    const/high16 v0, 0x40800000
    const/high16 v4, 0x3f800000
    invoke-virtual {v3, v0, v4}, Landroid/widget/TextView;->setLineSpacing(FF)V
    const-string v0, "Loading..."
    invoke-virtual {v3, v0}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

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

    # STATUS BAR
    new-instance v2, Landroid/widget/TextView;
    invoke-direct {v2, v12}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V
    iput-object v2, v12, Lin/startv/hotstar/LogViewerActivity;->statusText:Landroid/widget/TextView;
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

    # Load content
    invoke-virtual {v12}, Lin/startv/hotstar/LogViewerActivity;->refreshLog()V

    return-void
.end method

.method public onDestroy()V
    .locals 1
    iget-boolean v0, p0, Lin/startv/hotstar/LogViewerActivity;->isStreaming:Z
    if-eqz v0, :skip_stop_lv
    const/4 v0, 0x0
    iput-boolean v0, p0, Lin/startv/hotstar/LogViewerActivity;->isStreaming:Z
    iget-object v0, p0, Lin/startv/hotstar/LogViewerActivity;->handler:Landroid/os/Handler;
    const/4 v1, 0x0
    invoke-virtual {v0, v1}, Landroid/os/Handler;->removeCallbacksAndMessages(Ljava/lang/Object;)V
    :skip_stop_lv
    invoke-super {p0}, Landroid/app/Activity;->onDestroy()V
    return-void
.end method
