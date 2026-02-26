.class public Lin/startv/hotstar/DebugPanelActivity;
.super Landroid/app/Activity;
.source "DebugPanelActivity.java"


# instance fields
.field public logView:Landroid/widget/TextView;
.field public rulesEdit:Landroid/widget/EditText;
.field public rootLayout:Landroid/widget/LinearLayout;
.field public scrollView:Landroid/widget/ScrollView;
.field public currentLogFile:Ljava/lang/String;
.field public handler:Landroid/os/Handler;
.field public isStreaming:Z
.field public streamButton:Landroid/widget/Button;
.field public logScrollView:Landroid/widget/ScrollView;
.field public pathInput:Landroid/widget/EditText;


# direct methods
.method public constructor <init>()V
    .locals 0
    invoke-direct {p0}, Landroid/app/Activity;-><init>()V
    return-void
.end method

.method public readFile(Ljava/lang/String;)Ljava/lang/String;
    .locals 5

    :try_start
    new-instance v0, Ljava/io/File;
    invoke-direct {v0, p1}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    invoke-virtual {v0}, Ljava/io/File;->exists()Z
    move-result v1
    if-nez v1, :file_exists

    const-string v0, "(File not found)"
    return-object v0

    :file_exists
    new-instance v1, Ljava/lang/StringBuilder;
    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    new-instance v2, Ljava/io/BufferedReader;
    new-instance v3, Ljava/io/FileReader;
    invoke-direct {v3, v0}, Ljava/io/FileReader;-><init>(Ljava/io/File;)V
    invoke-direct {v2, v3}, Ljava/io/BufferedReader;-><init>(Ljava/io/Reader;)V

    :loop
    invoke-virtual {v2}, Ljava/io/BufferedReader;->readLine()Ljava/lang/String;
    move-result-object v3

    if-eqz v3, :end_loop

    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v4, "\n"
    invoke-virtual {v1, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    goto :loop

    :end_loop
    invoke-virtual {v2}, Ljava/io/BufferedReader;->close()V

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0

    # Limit to last 5000 chars to avoid OOM
    invoke-virtual {v0}, Ljava/lang/String;->length()I
    move-result v1
    const/16 v2, 0x1388
    if-le v1, v2, :no_trim

    sub-int v2, v1, v2
    invoke-virtual {v0, v2}, Ljava/lang/String;->substring(I)Ljava/lang/String;
    move-result-object v0

    new-instance v1, Ljava/lang/StringBuilder;
    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V
    const-string v2, "... (showing last 5000 chars) ...\n"
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0

    :no_trim
    return-object v0

    :try_end
    .catchall {:try_start .. :try_end} :catch_block

    :catch_block
    move-exception v0
    invoke-virtual {v0}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;
    move-result-object v0
    return-object v0
.end method

.method public writeFile(Ljava/lang/String;Ljava/lang/String;)V
    .locals 3

    :try_start
    new-instance v0, Ljava/io/File;
    invoke-direct {v0, p1}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    invoke-virtual {v0}, Ljava/io/File;->getParentFile()Ljava/io/File;
    move-result-object v1
    if-eqz v1, :skip_mkdir
    invoke-virtual {v1}, Ljava/io/File;->mkdirs()Z
    :skip_mkdir

    new-instance v1, Ljava/io/FileWriter;
    const/4 v2, 0x0
    invoke-direct {v1, v0, v2}, Ljava/io/FileWriter;-><init>(Ljava/io/File;Z)V
    invoke-virtual {v1, p2}, Ljava/io/Writer;->write(Ljava/lang/String;)V
    invoke-virtual {v1}, Ljava/io/Writer;->flush()V
    invoke-virtual {v1}, Ljava/io/Writer;->close()V
    :try_end
    .catchall {:try_start .. :try_end} :catch_block
    goto :after
    :catch_block
    move-exception v0
    :after

    return-void
.end method

.method public clearFile(Ljava/lang/String;)V
    .locals 1

    const-string v0, ""
    invoke-virtual {p0, p1, v0}, Lin/startv/hotstar/DebugPanelActivity;->writeFile(Ljava/lang/String;Ljava/lang/String;)V
    return-void
.end method

.method private createButton(Ljava/lang/String;I)Landroid/widget/Button;
    .locals 4

    new-instance v0, Landroid/widget/Button;
    invoke-direct {v0, p0}, Landroid/widget/Button;-><init>(Landroid/content/Context;)V

    invoke-virtual {v0, p1}, Landroid/widget/Button;->setText(Ljava/lang/CharSequence;)V

    # Set text color white
    const/4 v1, -0x1
    invoke-virtual {v0, v1}, Landroid/widget/Button;->setTextColor(I)V

    # Rounded background using GradientDrawable
    new-instance v1, Landroid/graphics/drawable/GradientDrawable;
    invoke-direct {v1}, Landroid/graphics/drawable/GradientDrawable;-><init>()V
    invoke-virtual {v1, p2}, Landroid/graphics/drawable/GradientDrawable;->setColor(I)V
    # Corner radius: 12px
    const/high16 v2, 0x41400000    # 12.0f
    invoke-virtual {v1, v2}, Landroid/graphics/drawable/GradientDrawable;->setCornerRadius(F)V
    invoke-virtual {v0, v1}, Landroid/view/View;->setBackground(Landroid/graphics/drawable/Drawable;)V

    # Padding
    const/16 v1, 0x18
    const/16 v2, 0x10
    invoke-virtual {v0, v1, v2, v1, v2}, Landroid/view/View;->setPadding(IIII)V

    # Text size
    const/high16 v1, 0x41700000    # 15.0f
    invoke-virtual {v0, v1}, Landroid/widget/TextView;->setTextSize(F)V

    # All caps off
    const/4 v1, 0x0
    invoke-virtual {v0, v1}, Landroid/widget/Button;->setAllCaps(Z)V

    # Clip to rounded corners
    const/4 v1, 0x1
    invoke-virtual {v0, v1}, Landroid/view/View;->setClipToOutline(Z)V

    # State list animator null for flat look
    const/4 v1, 0x0
    invoke-virtual {v0, v1}, Landroid/view/View;->setStateListAnimator(Landroid/animation/StateListAnimator;)V

    # Layout params with margin
    new-instance v1, Landroid/widget/LinearLayout$LayoutParams;
    const/4 v2, -0x1
    const/4 v3, -0x2
    invoke-direct {v1, v2, v3}, Landroid/widget/LinearLayout$LayoutParams;-><init>(II)V
    const/16 v2, 0x8
    const/16 v3, 0x6
    invoke-virtual {v1, v2, v3, v2, v3}, Landroid/widget/LinearLayout$LayoutParams;->setMargins(IIII)V
    invoke-virtual {v0, v1}, Landroid/view/View;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V

    return-object v0
.end method

# Helper: Create a section header with icon
.method private createSectionHeader(Ljava/lang/String;)Landroid/widget/TextView;
    .locals 3

    new-instance v0, Landroid/widget/TextView;
    invoke-direct {v0, p0}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V
    invoke-virtual {v0, p1}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    const/high16 v1, 0x41900000    # 18.0f
    invoke-virtual {v0, v1}, Landroid/widget/TextView;->setTextSize(F)V
    const v1, -0x1e96    # yellow accent
    invoke-virtual {v0, v1}, Landroid/widget/TextView;->setTextColor(I)V
    sget-object v1, Landroid/graphics/Typeface;->DEFAULT_BOLD:Landroid/graphics/Typeface;
    invoke-virtual {v0, v1}, Landroid/widget/TextView;->setTypeface(Landroid/graphics/Typeface;)V
    const/16 v1, 0x0
    const/16 v2, 0x10
    invoke-virtual {v0, v1, v2, v1, v2}, Landroid/view/View;->setPadding(IIII)V

    return-object v0
.end method

# Helper: Create a section card container
.method private createSectionCard()Landroid/widget/LinearLayout;
    .locals 4

    new-instance v0, Landroid/widget/LinearLayout;
    invoke-direct {v0, p0}, Landroid/widget/LinearLayout;-><init>(Landroid/content/Context;)V
    const/4 v1, 0x1
    invoke-virtual {v0, v1}, Landroid/widget/LinearLayout;->setOrientation(I)V

    # Rounded card background
    new-instance v1, Landroid/graphics/drawable/GradientDrawable;
    invoke-direct {v1}, Landroid/graphics/drawable/GradientDrawable;-><init>()V
    const v2, -0xeae5df    # 0xFF151A21 darker card bg
    invoke-virtual {v1, v2}, Landroid/graphics/drawable/GradientDrawable;->setColor(I)V
    const/high16 v2, 0x41800000    # 16.0f radius
    invoke-virtual {v1, v2}, Landroid/graphics/drawable/GradientDrawable;->setCornerRadius(F)V
    const/4 v2, 0x1
    const v3, -0xcfc9c3    # border
    invoke-virtual {v1, v2, v3}, Landroid/graphics/drawable/GradientDrawable;->setStroke(II)V
    invoke-virtual {v0, v1}, Landroid/view/View;->setBackground(Landroid/graphics/drawable/Drawable;)V

    # Padding inside card
    const/16 v1, 0x10
    invoke-virtual {v0, v1, v1, v1, v1}, Landroid/view/View;->setPadding(IIII)V

    # LayoutParams with margin
    new-instance v1, Landroid/widget/LinearLayout$LayoutParams;
    const/4 v2, -0x1
    const/4 v3, -0x2
    invoke-direct {v1, v2, v3}, Landroid/widget/LinearLayout$LayoutParams;-><init>(II)V
    const/16 v2, 0x8
    const/16 v3, 0x6
    invoke-virtual {v1, v2, v3, v2, v3}, Landroid/widget/LinearLayout$LayoutParams;->setMargins(IIII)V
    invoke-virtual {v0, v1}, Landroid/view/View;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V

    const/4 v1, 0x1
    invoke-virtual {v0, v1}, Landroid/view/View;->setClipToOutline(Z)V

    return-object v0
.end method

.method public refreshLog()V
    .locals 2

    iget-object v0, p0, Lin/startv/hotstar/DebugPanelActivity;->currentLogFile:Ljava/lang/String;
    if-eqz v0, :no_file

    invoke-virtual {p0, v0}, Lin/startv/hotstar/DebugPanelActivity;->readFile(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v0

    iget-object v1, p0, Lin/startv/hotstar/DebugPanelActivity;->logView:Landroid/widget/TextView;
    invoke-virtual {v1, v0}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    # Auto-scroll
    iget-object v0, p0, Lin/startv/hotstar/DebugPanelActivity;->logScrollView:Landroid/widget/ScrollView;
    if-eqz v0, :no_file
    const/16 v1, 0x82
    invoke-virtual {v0, v1}, Landroid/widget/ScrollView;->fullScroll(I)Z

    :no_file
    return-void
.end method

.method public startStreaming()V
    .locals 4

    const/4 v0, 0x1
    iput-boolean v0, p0, Lin/startv/hotstar/DebugPanelActivity;->isStreaming:Z

    iget-object v0, p0, Lin/startv/hotstar/DebugPanelActivity;->streamButton:Landroid/widget/Button;
    const-string v1, "\u23f8 Stop Stream"
    invoke-virtual {v0, v1}, Landroid/widget/Button;->setText(Ljava/lang/CharSequence;)V
    const v1, -0x340000
    invoke-virtual {v0, v1}, Landroid/view/View;->setBackgroundColor(I)V

    new-instance v0, Lin/startv/hotstar/DebugPanelActivity$StreamRunnable;
    invoke-direct {v0, p0}, Lin/startv/hotstar/DebugPanelActivity$StreamRunnable;-><init>(Lin/startv/hotstar/DebugPanelActivity;)V

    iget-object v1, p0, Lin/startv/hotstar/DebugPanelActivity;->handler:Landroid/os/Handler;
    const-wide/16 v2, 0x5dc
    invoke-virtual {v1, v0, v2, v3}, Landroid/os/Handler;->postDelayed(Ljava/lang/Runnable;J)Z

    invoke-virtual {p0}, Lin/startv/hotstar/DebugPanelActivity;->refreshLog()V

    const-string v0, "\u25b6 Streaming started (1.5s refresh)"
    const/4 v1, 0x0
    invoke-static {p0, v0, v1}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;
    move-result-object v0
    invoke-virtual {v0}, Landroid/widget/Toast;->show()V

    return-void
.end method

.method public stopStreaming()V
    .locals 2

    const/4 v0, 0x0
    iput-boolean v0, p0, Lin/startv/hotstar/DebugPanelActivity;->isStreaming:Z

    iget-object v0, p0, Lin/startv/hotstar/DebugPanelActivity;->streamButton:Landroid/widget/Button;
    const-string v1, "\u25b6 Stream Logs"
    invoke-virtual {v0, v1}, Landroid/widget/Button;->setText(Ljava/lang/CharSequence;)V
    const v1, -0xcc4a1a
    invoke-virtual {v0, v1}, Landroid/view/View;->setBackgroundColor(I)V

    iget-object v0, p0, Lin/startv/hotstar/DebugPanelActivity;->handler:Landroid/os/Handler;
    const/4 v1, 0x0
    invoke-virtual {v0, v1}, Landroid/os/Handler;->removeCallbacksAndMessages(Ljava/lang/Object;)V

    return-void
.end method


# virtual methods
.method public onCreate(Landroid/os/Bundle;)V
    .locals 12

    invoke-super {p0, p1}, Landroid/app/Activity;->onCreate(Landroid/os/Bundle;)V

    # Root ScrollView
    new-instance v0, Landroid/widget/ScrollView;
    invoke-direct {v0, p0}, Landroid/widget/ScrollView;-><init>(Landroid/content/Context;)V
    iput-object v0, p0, Lin/startv/hotstar/DebugPanelActivity;->scrollView:Landroid/widget/ScrollView;

    # Root LinearLayout
    new-instance v1, Landroid/widget/LinearLayout;
    invoke-direct {v1, p0}, Landroid/widget/LinearLayout;-><init>(Landroid/content/Context;)V
    const/4 v2, 0x1
    invoke-virtual {v1, v2}, Landroid/widget/LinearLayout;->setOrientation(I)V
    iput-object v1, p0, Lin/startv/hotstar/DebugPanelActivity;->rootLayout:Landroid/widget/LinearLayout;

    const v2, -0xe9e4de    # 0xFF161B22
    invoke-virtual {v1, v2}, Landroid/view/View;->setBackgroundColor(I)V

    const/16 v2, 0x18
    const/16 v3, 0x10
    invoke-virtual {v1, v2, v3, v2, v3}, Landroid/view/View;->setPadding(IIII)V

    # Handler
    new-instance v2, Landroid/os/Handler;
    invoke-static {}, Landroid/os/Looper;->getMainLooper()Landroid/os/Looper;
    move-result-object v3
    invoke-direct {v2, v3}, Landroid/os/Handler;-><init>(Landroid/os/Looper;)V
    iput-object v2, p0, Lin/startv/hotstar/DebugPanelActivity;->handler:Landroid/os/Handler;

    # ===== TITLE =====
    new-instance v2, Landroid/widget/TextView;
    invoke-direct {v2, p0}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V
    const-string v3, "\ud83d\udd27 HSPatch Debug Panel"
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    const/high16 v3, 0x41c00000    # 24.0f
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setTextSize(F)V
    const v3, -0x1e96
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setTextColor(I)V
    const/16 v3, 0x11
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setGravity(I)V
    sget-object v4, Landroid/graphics/Typeface;->DEFAULT_BOLD:Landroid/graphics/Typeface;
    invoke-virtual {v2, v4}, Landroid/widget/TextView;->setTypeface(Landroid/graphics/Typeface;)V
    const/16 v3, 0x0
    const/16 v4, 0x4
    invoke-virtual {v2, v3, v4, v3, v4}, Landroid/view/View;->setPadding(IIII)V
    invoke-virtual {v1, v2}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # Subtitle
    new-instance v2, Landroid/widget/TextView;
    invoke-direct {v2, p0}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V
    const-string v3, "View logs \u2022 Edit rules \u2022 Manage profiles \u2022 Spoof device"
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    const/high16 v3, 0x41600000    # 14.0f
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setTextSize(F)V
    const v3, -0x6d6d6e
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setTextColor(I)V
    const/16 v3, 0x11
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setGravity(I)V
    const/16 v3, 0x0
    const/16 v4, 0x4
    const/16 v5, 0x0
    const/16 v6, 0x14
    invoke-virtual {v2, v3, v4, v5, v6}, Landroid/view/View;->setPadding(IIII)V
    invoke-virtual {v1, v2}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # ============================================================
    # SECTION 1: LOG VIEWERS (opens LogViewerActivity)
    # ============================================================
    const-string v7, "\ud83d\udcca  Log Viewers"
    invoke-direct {p0, v7}, Lin/startv/hotstar/DebugPanelActivity;->createSectionHeader(Ljava/lang/String;)Landroid/widget/TextView;
    move-result-object v2
    invoke-virtual {v1, v2}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    invoke-direct {p0}, Lin/startv/hotstar/DebugPanelActivity;->createSectionCard()Landroid/widget/LinearLayout;
    move-result-object v10

    # Request Logs
    const-string v7, "\ud83c\udf10 Request Logs"
    const v8, -0xff6634
    invoke-direct {p0, v7, v8}, Lin/startv/hotstar/DebugPanelActivity;->createButton(Ljava/lang/String;I)Landroid/widget/Button;
    move-result-object v2
    new-instance v3, Lin/startv/hotstar/DebugPanelActivity$LogClickListener;
    const-string v4, "request_logs.txt"
    invoke-static {v4}, Lin/startv/hotstar/HSPatchConfig;->getFilePath(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v4
    invoke-direct {v3, p0, v4}, Lin/startv/hotstar/DebugPanelActivity$LogClickListener;-><init>(Lin/startv/hotstar/DebugPanelActivity;Ljava/lang/String;)V
    invoke-virtual {v2, v3}, Landroid/view/View;->setOnClickListener(Landroid/view/View$OnClickListener;)V
    invoke-virtual {v10, v2}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # Activity Logs
    const-string v7, "\ud83d\udcf1 Activity Logs"
    const v8, -0xcc4a1a
    invoke-direct {p0, v7, v8}, Lin/startv/hotstar/DebugPanelActivity;->createButton(Ljava/lang/String;I)Landroid/widget/Button;
    move-result-object v2
    new-instance v3, Lin/startv/hotstar/DebugPanelActivity$LogClickListener;
    const-string v4, "activity_logs.txt"
    invoke-static {v4}, Lin/startv/hotstar/HSPatchConfig;->getFilePath(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v4
    invoke-direct {v3, p0, v4}, Lin/startv/hotstar/DebugPanelActivity$LogClickListener;-><init>(Lin/startv/hotstar/DebugPanelActivity;Ljava/lang/String;)V
    invoke-virtual {v2, v3}, Landroid/view/View;->setOnClickListener(Landroid/view/View$OnClickListener;)V
    invoke-virtual {v10, v2}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # URL Logs
    const-string v7, "\ud83d\udd17 URL Patch Logs"
    const v8, -0xbb5578
    invoke-direct {p0, v7, v8}, Lin/startv/hotstar/DebugPanelActivity;->createButton(Ljava/lang/String;I)Landroid/widget/Button;
    move-result-object v2
    new-instance v3, Lin/startv/hotstar/DebugPanelActivity$LogClickListener;
    const-string v4, "urllogs.txt"
    invoke-static {v4}, Lin/startv/hotstar/HSPatchConfig;->getFilePath(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v4
    invoke-direct {v3, p0, v4}, Lin/startv/hotstar/DebugPanelActivity$LogClickListener;-><init>(Lin/startv/hotstar/DebugPanelActivity;Ljava/lang/String;)V
    invoke-virtual {v2, v3}, Landroid/view/View;->setOnClickListener(Landroid/view/View$OnClickListener;)V
    invoke-virtual {v10, v2}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # Blocked URLs
    const-string v7, "\ud83d\udeab Blocked URLs"
    const v8, -0x340000
    invoke-direct {p0, v7, v8}, Lin/startv/hotstar/DebugPanelActivity;->createButton(Ljava/lang/String;I)Landroid/widget/Button;
    move-result-object v2
    new-instance v3, Lin/startv/hotstar/DebugPanelActivity$LogClickListener;
    const-string v4, "blocked_urls.txt"
    invoke-static {v4}, Lin/startv/hotstar/HSPatchConfig;->getFilePath(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v4
    invoke-direct {v3, p0, v4}, Lin/startv/hotstar/DebugPanelActivity$LogClickListener;-><init>(Lin/startv/hotstar/DebugPanelActivity;Ljava/lang/String;)V
    invoke-virtual {v2, v3}, Landroid/view/View;->setOnClickListener(Landroid/view/View$OnClickListener;)V
    invoke-virtual {v10, v2}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    invoke-virtual {v1, v10}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # ============================================================
    # SECTION 2: RULES EDITOR
    # ============================================================
    const-string v7, "\u2699\ufe0f  Blocking Rules"
    invoke-direct {p0, v7}, Lin/startv/hotstar/DebugPanelActivity;->createSectionHeader(Ljava/lang/String;)Landroid/widget/TextView;
    move-result-object v2
    invoke-virtual {v1, v2}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    invoke-direct {p0}, Lin/startv/hotstar/DebugPanelActivity;->createSectionCard()Landroid/widget/LinearLayout;
    move-result-object v10

    # Rules hint
    new-instance v2, Landroid/widget/TextView;
    invoke-direct {v2, p0}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V
    const-string v3, "Enter find:replace pairs per line"
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    const/high16 v3, 0x41400000    # 12.0f
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setTextSize(F)V
    const v3, -0x6d6d6e
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setTextColor(I)V
    const/16 v3, 0x4
    invoke-virtual {v2, v3, v3, v3, v3}, Landroid/view/View;->setPadding(IIII)V
    invoke-virtual {v10, v2}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # Rules EditText
    new-instance v2, Landroid/widget/EditText;
    invoke-direct {v2, p0}, Landroid/widget/EditText;-><init>(Landroid/content/Context;)V
    iput-object v2, p0, Lin/startv/hotstar/DebugPanelActivity;->rulesEdit:Landroid/widget/EditText;

    invoke-static {}, Lin/startv/hotstar/HSPatchConfig;->getBlockingFilePath()Ljava/lang/String;
    move-result-object v3
    if-eqz v3, :no_rules_file
    invoke-virtual {p0, v3}, Lin/startv/hotstar/DebugPanelActivity;->readFile(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v3
    goto :rules_loaded
    :no_rules_file
    const-string v3, ""
    :rules_loaded
    invoke-virtual {v2, v3}, Landroid/widget/EditText;->setText(Ljava/lang/CharSequence;)V

    const/high16 v3, 0x41400000
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setTextSize(F)V
    const/4 v3, -0x1
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setTextColor(I)V
    new-instance v3, Landroid/graphics/drawable/GradientDrawable;
    invoke-direct {v3}, Landroid/graphics/drawable/GradientDrawable;-><init>()V
    const v4, -0xf2eee9
    invoke-virtual {v3, v4}, Landroid/graphics/drawable/GradientDrawable;->setColor(I)V
    const/high16 v4, 0x41000000
    invoke-virtual {v3, v4}, Landroid/graphics/drawable/GradientDrawable;->setCornerRadius(F)V
    const/4 v4, 0x1
    const v5, -0xcfc9c3
    invoke-virtual {v3, v4, v5}, Landroid/graphics/drawable/GradientDrawable;->setStroke(II)V
    invoke-virtual {v2, v3}, Landroid/view/View;->setBackground(Landroid/graphics/drawable/Drawable;)V
    const/16 v3, 0x10
    invoke-virtual {v2, v3, v3, v3, v3}, Landroid/view/View;->setPadding(IIII)V
    const/16 v3, 0x6
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setMinLines(I)V
    const/4 v3, 0x3
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setGravity(I)V
    sget-object v3, Landroid/graphics/Typeface;->MONOSPACE:Landroid/graphics/Typeface;
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setTypeface(Landroid/graphics/Typeface;)V
    const-string v3, "ads:bds\ntrack:truck\nBLOCK:doubleclick"
    invoke-virtual {v2, v3}, Landroid/widget/EditText;->setHint(Ljava/lang/CharSequence;)V

    new-instance v3, Landroid/widget/LinearLayout$LayoutParams;
    const/4 v4, -0x1
    const/4 v5, -0x2
    invoke-direct {v3, v4, v5}, Landroid/widget/LinearLayout$LayoutParams;-><init>(II)V
    const/16 v4, 0x4
    invoke-virtual {v3, v4, v4, v4, v4}, Landroid/widget/LinearLayout$LayoutParams;->setMargins(IIII)V
    invoke-virtual {v2, v3}, Landroid/view/View;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V
    invoke-virtual {v10, v2}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # Save Rules
    const-string v7, "\ud83d\udcbe Save Rules"
    const v8, -0xcc4a1a
    invoke-direct {p0, v7, v8}, Lin/startv/hotstar/DebugPanelActivity;->createButton(Ljava/lang/String;I)Landroid/widget/Button;
    move-result-object v2
    new-instance v3, Lin/startv/hotstar/DebugPanelActivity$SaveRulesListener;
    invoke-direct {v3, p0}, Lin/startv/hotstar/DebugPanelActivity$SaveRulesListener;-><init>(Lin/startv/hotstar/DebugPanelActivity;)V
    invoke-virtual {v2, v3}, Landroid/view/View;->setOnClickListener(Landroid/view/View$OnClickListener;)V
    invoke-virtual {v10, v2}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    invoke-virtual {v1, v10}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # ============================================================
    # SECTION 3: LOG CONTROLS
    # ============================================================
    const-string v7, "\ud83d\udee0\ufe0f  Log Controls"
    invoke-direct {p0, v7}, Lin/startv/hotstar/DebugPanelActivity;->createSectionHeader(Ljava/lang/String;)Landroid/widget/TextView;
    move-result-object v2
    invoke-virtual {v1, v2}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    invoke-direct {p0}, Lin/startv/hotstar/DebugPanelActivity;->createSectionCard()Landroid/widget/LinearLayout;
    move-result-object v10

    # Clear All Logs
    const-string v7, "\ud83d\uddd1\ufe0f Clear All Logs"
    const v8, -0x340000
    invoke-direct {p0, v7, v8}, Lin/startv/hotstar/DebugPanelActivity;->createButton(Ljava/lang/String;I)Landroid/widget/Button;
    move-result-object v2
    new-instance v3, Lin/startv/hotstar/DebugPanelActivity$ClearLogsListener;
    invoke-direct {v3, p0}, Lin/startv/hotstar/DebugPanelActivity$ClearLogsListener;-><init>(Lin/startv/hotstar/DebugPanelActivity;)V
    invoke-virtual {v2, v3}, Landroid/view/View;->setOnClickListener(Landroid/view/View$OnClickListener;)V
    invoke-virtual {v10, v2}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # Refresh
    const-string v7, "\ud83d\udd04 Refresh Log View"
    const v8, -0xbb5578
    invoke-direct {p0, v7, v8}, Lin/startv/hotstar/DebugPanelActivity;->createButton(Ljava/lang/String;I)Landroid/widget/Button;
    move-result-object v2
    new-instance v3, Lin/startv/hotstar/DebugPanelActivity$RefreshListener;
    invoke-direct {v3, p0}, Lin/startv/hotstar/DebugPanelActivity$RefreshListener;-><init>(Lin/startv/hotstar/DebugPanelActivity;)V
    invoke-virtual {v2, v3}, Landroid/view/View;->setOnClickListener(Landroid/view/View$OnClickListener;)V
    invoke-virtual {v10, v2}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # Stream Toggle
    const-string v7, "\u25b6 Stream Logs"
    const v8, -0xcc4a1a
    invoke-direct {p0, v7, v8}, Lin/startv/hotstar/DebugPanelActivity;->createButton(Ljava/lang/String;I)Landroid/widget/Button;
    move-result-object v2
    iput-object v2, p0, Lin/startv/hotstar/DebugPanelActivity;->streamButton:Landroid/widget/Button;
    new-instance v3, Lin/startv/hotstar/DebugPanelActivity$StreamToggleListener;
    invoke-direct {v3, p0}, Lin/startv/hotstar/DebugPanelActivity$StreamToggleListener;-><init>(Lin/startv/hotstar/DebugPanelActivity;)V
    invoke-virtual {v2, v3}, Landroid/view/View;->setOnClickListener(Landroid/view/View$OnClickListener;)V
    invoke-virtual {v10, v2}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    invoke-virtual {v1, v10}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # ============================================================
    # SECTION 4: PROFILE MANAGER
    # ============================================================
    const-string v7, "\ud83d\udc64  Profile Manager"
    invoke-direct {p0, v7}, Lin/startv/hotstar/DebugPanelActivity;->createSectionHeader(Ljava/lang/String;)Landroid/widget/TextView;
    move-result-object v2
    invoke-virtual {v1, v2}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    invoke-direct {p0}, Lin/startv/hotstar/DebugPanelActivity;->createSectionCard()Landroid/widget/LinearLayout;
    move-result-object v10

    # Save Profile
    const-string v7, "\ud83d\udcbe Save Profile"
    const v8, -0xcc4a1a
    invoke-direct {p0, v7, v8}, Lin/startv/hotstar/DebugPanelActivity;->createButton(Ljava/lang/String;I)Landroid/widget/Button;
    move-result-object v2
    new-instance v3, Lin/startv/hotstar/DebugPanelActivity$ProfileSaveListener;
    invoke-direct {v3, p0}, Lin/startv/hotstar/DebugPanelActivity$ProfileSaveListener;-><init>(Lin/startv/hotstar/DebugPanelActivity;)V
    invoke-virtual {v2, v3}, Landroid/view/View;->setOnClickListener(Landroid/view/View$OnClickListener;)V
    invoke-virtual {v10, v2}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # Load Profile
    const-string v7, "\ud83d\udcc2 Load Profile"
    const v8, -0xff6634
    invoke-direct {p0, v7, v8}, Lin/startv/hotstar/DebugPanelActivity;->createButton(Ljava/lang/String;I)Landroid/widget/Button;
    move-result-object v2
    new-instance v3, Lin/startv/hotstar/DebugPanelActivity$ProfileLoadListener;
    invoke-direct {v3, p0}, Lin/startv/hotstar/DebugPanelActivity$ProfileLoadListener;-><init>(Lin/startv/hotstar/DebugPanelActivity;)V
    invoke-virtual {v2, v3}, Landroid/view/View;->setOnClickListener(Landroid/view/View$OnClickListener;)V
    invoke-virtual {v10, v2}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # New Profile
    const-string v7, "\u2728 New Profile (Fresh Start)"
    const v8, -0xbb5578
    invoke-direct {p0, v7, v8}, Lin/startv/hotstar/DebugPanelActivity;->createButton(Ljava/lang/String;I)Landroid/widget/Button;
    move-result-object v2
    new-instance v3, Lin/startv/hotstar/DebugPanelActivity$ProfileNewListener;
    invoke-direct {v3, p0}, Lin/startv/hotstar/DebugPanelActivity$ProfileNewListener;-><init>(Lin/startv/hotstar/DebugPanelActivity;)V
    invoke-virtual {v2, v3}, Landroid/view/View;->setOnClickListener(Landroid/view/View$OnClickListener;)V
    invoke-virtual {v10, v2}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # Delete Profile
    const-string v7, "\ud83d\uddd1 Delete Profile"
    const v8, -0x340000
    invoke-direct {p0, v7, v8}, Lin/startv/hotstar/DebugPanelActivity;->createButton(Ljava/lang/String;I)Landroid/widget/Button;
    move-result-object v2
    new-instance v3, Lin/startv/hotstar/DebugPanelActivity$ProfileDeleteListener;
    invoke-direct {v3, p0}, Lin/startv/hotstar/DebugPanelActivity$ProfileDeleteListener;-><init>(Lin/startv/hotstar/DebugPanelActivity;)V
    invoke-virtual {v2, v3}, Landroid/view/View;->setOnClickListener(Landroid/view/View$OnClickListener;)V
    invoke-virtual {v10, v2}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # Export Profiles
    const-string v7, "\ud83d\udce4 Export All Profiles"
    const v8, -0x996634
    invoke-direct {p0, v7, v8}, Lin/startv/hotstar/DebugPanelActivity;->createButton(Ljava/lang/String;I)Landroid/widget/Button;
    move-result-object v2
    new-instance v3, Lin/startv/hotstar/DebugPanelActivity$ProfileExportListener;
    invoke-direct {v3, p0}, Lin/startv/hotstar/DebugPanelActivity$ProfileExportListener;-><init>(Lin/startv/hotstar/DebugPanelActivity;)V
    invoke-virtual {v2, v3}, Landroid/view/View;->setOnClickListener(Landroid/view/View$OnClickListener;)V
    invoke-virtual {v10, v2}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # Import All Profiles
    const-string v7, "\ud83d\udce5 Import All Profiles"
    const v8, -0x886644
    invoke-direct {p0, v7, v8}, Lin/startv/hotstar/DebugPanelActivity;->createButton(Ljava/lang/String;I)Landroid/widget/Button;
    move-result-object v2
    new-instance v3, Lin/startv/hotstar/DebugPanelActivity$ProfileImportListener;
    invoke-direct {v3, p0}, Lin/startv/hotstar/DebugPanelActivity$ProfileImportListener;-><init>(Lin/startv/hotstar/DebugPanelActivity;)V
    invoke-virtual {v2, v3}, Landroid/view/View;->setOnClickListener(Landroid/view/View$OnClickListener;)V
    invoke-virtual {v10, v2}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    invoke-virtual {v1, v10}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # ============================================================
    # SECTION 5: FILE EXPLORER
    # ============================================================
    const-string v7, "\ud83d\udcc1  File Explorer"
    invoke-direct {p0, v7}, Lin/startv/hotstar/DebugPanelActivity;->createSectionHeader(Ljava/lang/String;)Landroid/widget/TextView;
    move-result-object v2
    invoke-virtual {v1, v2}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    invoke-direct {p0}, Lin/startv/hotstar/DebugPanelActivity;->createSectionCard()Landroid/widget/LinearLayout;
    move-result-object v10

    # Path input
    new-instance v2, Landroid/widget/EditText;
    invoke-direct {v2, p0}, Landroid/widget/EditText;-><init>(Landroid/content/Context;)V
    iput-object v2, p0, Lin/startv/hotstar/DebugPanelActivity;->pathInput:Landroid/widget/EditText;

    invoke-virtual {p0}, Landroid/content/Context;->getApplicationInfo()Landroid/content/pm/ApplicationInfo;
    move-result-object v3
    iget-object v3, v3, Landroid/content/pm/ApplicationInfo;->dataDir:Ljava/lang/String;
    invoke-virtual {v2, v3}, Landroid/widget/EditText;->setText(Ljava/lang/CharSequence;)V

    const/high16 v3, 0x41400000
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setTextSize(F)V
    const/4 v3, -0x1
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setTextColor(I)V
    new-instance v3, Landroid/graphics/drawable/GradientDrawable;
    invoke-direct {v3}, Landroid/graphics/drawable/GradientDrawable;-><init>()V
    const v4, -0xf2eee9
    invoke-virtual {v3, v4}, Landroid/graphics/drawable/GradientDrawable;->setColor(I)V
    const/high16 v4, 0x41000000
    invoke-virtual {v3, v4}, Landroid/graphics/drawable/GradientDrawable;->setCornerRadius(F)V
    const/4 v4, 0x1
    const v5, -0xcfc9c3
    invoke-virtual {v3, v4, v5}, Landroid/graphics/drawable/GradientDrawable;->setStroke(II)V
    invoke-virtual {v2, v3}, Landroid/view/View;->setBackground(Landroid/graphics/drawable/Drawable;)V
    const/16 v3, 0xc
    invoke-virtual {v2, v3, v3, v3, v3}, Landroid/view/View;->setPadding(IIII)V
    const/4 v3, 0x1
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setSingleLine(Z)V
    sget-object v3, Landroid/graphics/Typeface;->MONOSPACE:Landroid/graphics/Typeface;
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setTypeface(Landroid/graphics/Typeface;)V
    const-string v3, "Enter file/directory path..."
    invoke-virtual {v2, v3}, Landroid/widget/EditText;->setHint(Ljava/lang/CharSequence;)V

    new-instance v3, Landroid/widget/LinearLayout$LayoutParams;
    const/4 v4, -0x1
    const/4 v5, -0x2
    invoke-direct {v3, v4, v5}, Landroid/widget/LinearLayout$LayoutParams;-><init>(II)V
    const/16 v4, 0x4
    invoke-virtual {v3, v4, v4, v4, v4}, Landroid/widget/LinearLayout$LayoutParams;->setMargins(IIII)V
    invoke-virtual {v2, v3}, Landroid/view/View;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V
    invoke-virtual {v10, v2}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # List Dir
    const-string v7, "\ud83d\udcc2 List Directory"
    const v8, -0xff6634
    invoke-direct {p0, v7, v8}, Lin/startv/hotstar/DebugPanelActivity;->createButton(Ljava/lang/String;I)Landroid/widget/Button;
    move-result-object v2
    new-instance v3, Lin/startv/hotstar/DebugPanelActivity$ListDirListener;
    invoke-direct {v3, p0}, Lin/startv/hotstar/DebugPanelActivity$ListDirListener;-><init>(Lin/startv/hotstar/DebugPanelActivity;)V
    invoke-virtual {v2, v3}, Landroid/view/View;->setOnClickListener(Landroid/view/View$OnClickListener;)V
    invoke-virtual {v10, v2}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # Read File
    const-string v7, "\ud83d\udcd6 Read File"
    const v8, -0xcc4a1a
    invoke-direct {p0, v7, v8}, Lin/startv/hotstar/DebugPanelActivity;->createButton(Ljava/lang/String;I)Landroid/widget/Button;
    move-result-object v2
    new-instance v3, Lin/startv/hotstar/DebugPanelActivity$ReadPathListener;
    invoke-direct {v3, p0}, Lin/startv/hotstar/DebugPanelActivity$ReadPathListener;-><init>(Lin/startv/hotstar/DebugPanelActivity;)V
    invoke-virtual {v2, v3}, Landroid/view/View;->setOnClickListener(Landroid/view/View$OnClickListener;)V
    invoke-virtual {v10, v2}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # Write to Path
    const-string v7, "\ud83d\udcdd Write to Path"
    const v8, -0x996634
    invoke-direct {p0, v7, v8}, Lin/startv/hotstar/DebugPanelActivity;->createButton(Ljava/lang/String;I)Landroid/widget/Button;
    move-result-object v2
    new-instance v3, Lin/startv/hotstar/DebugPanelActivity$WritePathListener;
    invoke-direct {v3, p0}, Lin/startv/hotstar/DebugPanelActivity$WritePathListener;-><init>(Lin/startv/hotstar/DebugPanelActivity;)V
    invoke-virtual {v2, v3}, Landroid/view/View;->setOnClickListener(Landroid/view/View$OnClickListener;)V
    invoke-virtual {v10, v2}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # Open File Explorer
    const-string v7, "\ud83d\udcc1 Open File Explorer"
    const v8, -0xcc6634
    invoke-direct {p0, v7, v8}, Lin/startv/hotstar/DebugPanelActivity;->createButton(Ljava/lang/String;I)Landroid/widget/Button;
    move-result-object v2
    new-instance v3, Lin/startv/hotstar/DebugPanelActivity$OpenFileExplorerListener;
    invoke-direct {v3, p0}, Lin/startv/hotstar/DebugPanelActivity$OpenFileExplorerListener;-><init>(Lin/startv/hotstar/DebugPanelActivity;)V
    invoke-virtual {v2, v3}, Landroid/view/View;->setOnClickListener(Landroid/view/View$OnClickListener;)V
    invoke-virtual {v10, v2}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    invoke-virtual {v1, v10}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # ============================================================
    # SECTION 6: TOOLS
    # ============================================================
    const-string v7, "\ud83d\udee0\ufe0f  Tools"
    invoke-direct {p0, v7}, Lin/startv/hotstar/DebugPanelActivity;->createSectionHeader(Ljava/lang/String;)Landroid/widget/TextView;
    move-result-object v2
    invoke-virtual {v1, v2}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    invoke-direct {p0}, Lin/startv/hotstar/DebugPanelActivity;->createSectionCard()Landroid/widget/LinearLayout;
    move-result-object v10

    # Frida Status
    const-string v7, "\ud83d\udd0d Frida Status Check"
    const v8, -0x340000
    invoke-direct {p0, v7, v8}, Lin/startv/hotstar/DebugPanelActivity;->createButton(Ljava/lang/String;I)Landroid/widget/Button;
    move-result-object v2
    new-instance v3, Lin/startv/hotstar/DebugPanelActivity$FridaCheckListener;
    invoke-direct {v3, p0}, Lin/startv/hotstar/DebugPanelActivity$FridaCheckListener;-><init>(Lin/startv/hotstar/DebugPanelActivity;)V
    invoke-virtual {v2, v3}, Landroid/view/View;->setOnClickListener(Landroid/view/View$OnClickListener;)V
    invoke-virtual {v10, v2}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # Device Spoofer Toggle
    const-string v7, "\ud83d\udd12 Reset Device Fingerprint"
    const v8, -0x996634
    invoke-direct {p0, v7, v8}, Lin/startv/hotstar/DebugPanelActivity;->createButton(Ljava/lang/String;I)Landroid/widget/Button;
    move-result-object v2
    new-instance v3, Lin/startv/hotstar/DebugPanelActivity$DeviceSpoofResetListener;
    invoke-direct {v3, p0}, Lin/startv/hotstar/DebugPanelActivity$DeviceSpoofResetListener;-><init>(Lin/startv/hotstar/DebugPanelActivity;)V
    invoke-virtual {v2, v3}, Landroid/view/View;->setOnClickListener(Landroid/view/View$OnClickListener;)V
    invoke-virtual {v10, v2}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # --- Auto-Reset Fingerprint Toggle (Switch) ---
    # Container row: horizontal layout with label + switch
    new-instance v2, Landroid/widget/LinearLayout;
    invoke-direct {v2, p0}, Landroid/widget/LinearLayout;-><init>(Landroid/content/Context;)V
    const/4 v3, 0x0
    invoke-virtual {v2, v3}, Landroid/widget/LinearLayout;->setOrientation(I)V
    const/16 v3, 0x10
    invoke-virtual {v2, v3}, Landroid/widget/LinearLayout;->setGravity(I)V
    const/16 v3, 0x8
    const/16 v4, 0xc
    invoke-virtual {v2, v3, v4, v3, v4}, Landroid/view/View;->setPadding(IIII)V

    # Label
    new-instance v3, Landroid/widget/TextView;
    invoke-direct {v3, p0}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V
    const-string v4, "\ud83d\udd04 Auto-Reset Fingerprint on New Profile"
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    const/high16 v4, 0x41600000    # 14.0f
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setTextSize(F)V
    const/4 v4, -0x1
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setTextColor(I)V

    new-instance v4, Landroid/widget/LinearLayout$LayoutParams;
    const/4 v5, 0x0
    const/4 v6, -0x2
    const/high16 v7, 0x3f800000    # 1.0f weight
    invoke-direct {v4, v5, v6, v7}, Landroid/widget/LinearLayout$LayoutParams;-><init>(IIF)V
    invoke-virtual {v3, v4}, Landroid/view/View;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V
    invoke-virtual {v2, v3}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # Switch toggle
    new-instance v3, Landroid/widget/Switch;
    invoke-direct {v3, p0}, Landroid/widget/Switch;-><init>(Landroid/content/Context;)V
    sget-boolean v4, Lin/startv/hotstar/HSPatchConfig;->autoResetFingerprint:Z
    invoke-virtual {v3, v4}, Landroid/widget/CompoundButton;->setChecked(Z)V

    # Listener
    new-instance v4, Lin/startv/hotstar/DebugPanelActivity$AutoResetToggleListener;
    invoke-direct {v4, p0}, Lin/startv/hotstar/DebugPanelActivity$AutoResetToggleListener;-><init>(Lin/startv/hotstar/DebugPanelActivity;)V
    invoke-virtual {v3, v4}, Landroid/widget/CompoundButton;->setOnCheckedChangeListener(Landroid/widget/CompoundButton$OnCheckedChangeListener;)V

    invoke-virtual {v2, v3}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V
    invoke-virtual {v10, v2}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # --- Persistent Debug Notification Toggle (Switch) ---
    # Container row: horizontal layout with label + switch
    new-instance v2, Landroid/widget/LinearLayout;
    invoke-direct {v2, p0}, Landroid/widget/LinearLayout;-><init>(Landroid/content/Context;)V
    const/4 v3, 0x0
    invoke-virtual {v2, v3}, Landroid/widget/LinearLayout;->setOrientation(I)V
    const/16 v3, 0x10
    invoke-virtual {v2, v3}, Landroid/widget/LinearLayout;->setGravity(I)V
    const/16 v3, 0x8
    const/16 v4, 0xc
    invoke-virtual {v2, v3, v4, v3, v4}, Landroid/view/View;->setPadding(IIII)V

    # Label
    new-instance v3, Landroid/widget/TextView;
    invoke-direct {v3, p0}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V
    const-string v4, "\ud83d\udd14 Persistent Debug Notification"
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    const/high16 v4, 0x41600000    # 14.0f
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setTextSize(F)V
    const/4 v4, -0x1
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setTextColor(I)V

    new-instance v4, Landroid/widget/LinearLayout$LayoutParams;
    const/4 v5, 0x0
    const/4 v6, -0x2
    const/high16 v7, 0x3f800000    # 1.0f weight
    invoke-direct {v4, v5, v6, v7}, Landroid/widget/LinearLayout$LayoutParams;-><init>(IIF)V
    invoke-virtual {v3, v4}, Landroid/view/View;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V
    invoke-virtual {v2, v3}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # Switch toggle
    new-instance v3, Landroid/widget/Switch;
    invoke-direct {v3, p0}, Landroid/widget/Switch;-><init>(Landroid/content/Context;)V
    sget-boolean v4, Lin/startv/hotstar/HSPatchConfig;->debugNotificationPersistent:Z
    invoke-virtual {v3, v4}, Landroid/widget/CompoundButton;->setChecked(Z)V

    # Listener
    new-instance v4, Lin/startv/hotstar/DebugPanelActivity$PersistentNotifToggleListener;
    invoke-direct {v4, p0}, Lin/startv/hotstar/DebugPanelActivity$PersistentNotifToggleListener;-><init>(Lin/startv/hotstar/DebugPanelActivity;)V
    invoke-virtual {v3, v4}, Landroid/widget/CompoundButton;->setOnCheckedChangeListener(Landroid/widget/CompoundButton$OnCheckedChangeListener;)V

    invoke-virtual {v2, v3}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V
    invoke-virtual {v10, v2}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # Network Monitor Button
    const-string v7, "\ud83c\udf10 Network Monitor"
    const v8, -0xff6634    # blue
    invoke-direct {p0, v7, v8}, Lin/startv/hotstar/DebugPanelActivity;->createButton(Ljava/lang/String;I)Landroid/widget/Button;
    move-result-object v2
    new-instance v3, Lin/startv/hotstar/DebugPanelActivity$NetworkMonitorListener;
    invoke-direct {v3, p0}, Lin/startv/hotstar/DebugPanelActivity$NetworkMonitorListener;-><init>(Lin/startv/hotstar/DebugPanelActivity;)V
    invoke-virtual {v2, v3}, Landroid/view/View;->setOnClickListener(Landroid/view/View$OnClickListener;)V
    invoke-virtual {v10, v2}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    invoke-virtual {v1, v10}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # ============================================================
    # SECTION 7: INLINE LOG OUTPUT (kept for quick view)
    # ============================================================
    const-string v7, "\ud83d\udcdd  Quick Log Output"
    invoke-direct {p0, v7}, Lin/startv/hotstar/DebugPanelActivity;->createSectionHeader(Ljava/lang/String;)Landroid/widget/TextView;
    move-result-object v2
    invoke-virtual {v1, v2}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # Log ScrollView
    new-instance v9, Landroid/widget/ScrollView;
    invoke-direct {v9, p0}, Landroid/widget/ScrollView;-><init>(Landroid/content/Context;)V
    iput-object v9, p0, Lin/startv/hotstar/DebugPanelActivity;->logScrollView:Landroid/widget/ScrollView;

    new-instance v3, Landroid/graphics/drawable/GradientDrawable;
    invoke-direct {v3}, Landroid/graphics/drawable/GradientDrawable;-><init>()V
    const v4, -0xf2eee9
    invoke-virtual {v3, v4}, Landroid/graphics/drawable/GradientDrawable;->setColor(I)V
    const/high16 v4, 0x41800000
    invoke-virtual {v3, v4}, Landroid/graphics/drawable/GradientDrawable;->setCornerRadius(F)V
    const/4 v4, 0x2
    const v5, -0xcfc9c3
    invoke-virtual {v3, v4, v5}, Landroid/graphics/drawable/GradientDrawable;->setStroke(II)V
    invoke-virtual {v9, v3}, Landroid/view/View;->setBackground(Landroid/graphics/drawable/Drawable;)V

    const/4 v3, 0x1
    invoke-virtual {v9, v3}, Landroid/view/View;->setVerticalScrollBarEnabled(Z)V
    const/4 v3, 0x0
    invoke-virtual {v9, v3}, Landroid/view/View;->setScrollbarFadingEnabled(Z)V
    const v3, 0x01000000
    invoke-virtual {v9, v3}, Landroid/view/View;->setScrollBarStyle(I)V
    const/4 v3, 0x1
    invoke-virtual {v9, v3}, Landroid/view/View;->setClipToOutline(Z)V

    new-instance v3, Landroid/widget/LinearLayout$LayoutParams;
    const/4 v4, -0x1
    const/16 v5, 0x384    # 900px height (smaller since logs now have dedicated viewer)
    invoke-direct {v3, v4, v5}, Landroid/widget/LinearLayout$LayoutParams;-><init>(II)V
    const/16 v4, 0x8
    invoke-virtual {v3, v4, v4, v4, v4}, Landroid/widget/LinearLayout$LayoutParams;->setMargins(IIII)V
    invoke-virtual {v9, v3}, Landroid/view/View;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V
    const/16 v3, 0x4
    invoke-virtual {v9, v3, v3, v3, v3}, Landroid/view/View;->setPadding(IIII)V

    # Log TextView
    new-instance v2, Landroid/widget/TextView;
    invoke-direct {v2, p0}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V
    iput-object v2, p0, Lin/startv/hotstar/DebugPanelActivity;->logView:Landroid/widget/TextView;

    const-string v3, "\u2502 Tap a log button above to view in Log Viewer...\n\u2502 Or use controls for inline quick view"
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    sget-object v3, Landroid/graphics/Typeface;->MONOSPACE:Landroid/graphics/Typeface;
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setTypeface(Landroid/graphics/Typeface;)V
    const/high16 v3, 0x41400000
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setTextSize(F)V
    const v3, -0x362e27
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setTextColor(I)V
    const/16 v3, 0x10
    invoke-virtual {v2, v3, v3, v3, v3}, Landroid/view/View;->setPadding(IIII)V
    const/high16 v3, 0x40800000
    const/high16 v4, 0x3f800000
    invoke-virtual {v2, v3, v4}, Landroid/widget/TextView;->setLineSpacing(FF)V
    const v3, 0x2710
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setMaxLines(I)V
    const/4 v3, 0x1
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setTextIsSelectable(Z)V

    invoke-virtual {v9, v2}, Landroid/widget/ScrollView;->addView(Landroid/view/View;)V
    invoke-virtual {v1, v9}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # Set content
    invoke-virtual {v0, v1}, Landroid/widget/ScrollView;->addView(Landroid/view/View;)V
    invoke-virtual {p0, v0}, Landroid/app/Activity;->setContentView(Landroid/view/View;)V

    return-void
.end method

.method public onDestroy()V
    .locals 1

    iget-boolean v0, p0, Lin/startv/hotstar/DebugPanelActivity;->isStreaming:Z
    if-eqz v0, :skip_stop
    invoke-virtual {p0}, Lin/startv/hotstar/DebugPanelActivity;->stopStreaming()V
    :skip_stop

    invoke-super {p0}, Landroid/app/Activity;->onDestroy()V
    return-void
.end method
