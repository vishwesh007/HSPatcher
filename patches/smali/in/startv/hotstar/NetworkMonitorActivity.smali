.class public Lin/startv/hotstar/NetworkMonitorActivity;
.super Landroid/app/Activity;
.source "NetworkMonitorActivity.java"

# ================================================================
# NetworkMonitorActivity - In-app network traffic inspector
# Reads HSPatch-Net tagged logcat entries in real-time
# Inspired by NetBare-Android architecture
# ================================================================

# instance fields
.field public rootLayout:Landroid/widget/LinearLayout;
.field public logTextView:Landroid/widget/TextView;
.field public scrollView:Landroid/widget/ScrollView;
.field public statusText:Landroid/widget/TextView;
.field public filterEdit:Landroid/widget/EditText;
.field public handler:Landroid/os/Handler;
.field public isCapturing:Z
.field public captureThread:Ljava/lang/Thread;
.field public logBuffer:Ljava/lang/StringBuilder;
.field public requestCount:I
.field public captureButton:Landroid/widget/Button;
.field public clearButton:Landroid/widget/Button;


.method public constructor <init>()V
    .locals 0
    invoke-direct {p0}, Landroid/app/Activity;-><init>()V
    return-void
.end method


.method public onCreate(Landroid/os/Bundle;)V
    .locals 12

    invoke-super {p0, p1}, Landroid/app/Activity;->onCreate(Landroid/os/Bundle;)V

    # Initialize log buffer
    new-instance v0, Ljava/lang/StringBuilder;
    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V
    iput-object v0, p0, Lin/startv/hotstar/NetworkMonitorActivity;->logBuffer:Ljava/lang/StringBuilder;

    # Handler
    new-instance v0, Landroid/os/Handler;
    invoke-static {}, Landroid/os/Looper;->getMainLooper()Landroid/os/Looper;
    move-result-object v1
    invoke-direct {v0, v1}, Landroid/os/Handler;-><init>(Landroid/os/Looper;)V
    iput-object v0, p0, Lin/startv/hotstar/NetworkMonitorActivity;->handler:Landroid/os/Handler;

    # Root ScrollView
    new-instance v10, Landroid/widget/ScrollView;
    invoke-direct {v10, p0}, Landroid/widget/ScrollView;-><init>(Landroid/content/Context;)V

    # Root Layout
    new-instance v1, Landroid/widget/LinearLayout;
    invoke-direct {v1, p0}, Landroid/widget/LinearLayout;-><init>(Landroid/content/Context;)V
    const/4 v2, 0x1
    invoke-virtual {v1, v2}, Landroid/widget/LinearLayout;->setOrientation(I)V
    iput-object v1, p0, Lin/startv/hotstar/NetworkMonitorActivity;->rootLayout:Landroid/widget/LinearLayout;

    # Dark background
    const v2, -0xe9e4de    # 0xFF161B22
    invoke-virtual {v1, v2}, Landroid/view/View;->setBackgroundColor(I)V
    const/16 v2, 0x18
    const/16 v3, 0x10
    invoke-virtual {v1, v2, v3, v2, v3}, Landroid/view/View;->setPadding(IIII)V

    # ===== TITLE =====
    new-instance v2, Landroid/widget/TextView;
    invoke-direct {v2, p0}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V
    const-string v3, "\ud83c\udf10 Network Monitor"
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    const/high16 v3, 0x41c00000    # 24.0f
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setTextSize(F)V
    const v3, -0x1e96    # yellow accent
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setTextColor(I)V
    const/16 v3, 0x11
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setGravity(I)V
    sget-object v4, Landroid/graphics/Typeface;->DEFAULT_BOLD:Landroid/graphics/Typeface;
    invoke-virtual {v2, v4}, Landroid/widget/TextView;->setTypeface(Landroid/graphics/Typeface;)V
    const/16 v3, 0x0
    const/16 v4, 0x8
    invoke-virtual {v2, v3, v4, v3, v4}, Landroid/view/View;->setPadding(IIII)V
    invoke-virtual {v1, v2}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # Subtitle
    new-instance v2, Landroid/widget/TextView;
    invoke-direct {v2, p0}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V
    const-string v3, "Real-time HTTP/HTTPS traffic inspector \u2022 Frida hooks"
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    const/high16 v3, 0x41400000    # 12.0f
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

    # ===== STATUS BAR =====
    new-instance v2, Landroid/widget/TextView;
    invoke-direct {v2, p0}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V
    iput-object v2, p0, Lin/startv/hotstar/NetworkMonitorActivity;->statusText:Landroid/widget/TextView;
    const-string v3, "\u23f8 Stopped \u2022 0 requests"
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    const/high16 v3, 0x41600000    # 14.0f
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setTextSize(F)V
    const v3, -0x33cd00    # green
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setTextColor(I)V

    new-instance v3, Landroid/graphics/drawable/GradientDrawable;
    invoke-direct {v3}, Landroid/graphics/drawable/GradientDrawable;-><init>()V
    const v4, -0xeae5df    # dark bg
    invoke-virtual {v3, v4}, Landroid/graphics/drawable/GradientDrawable;->setColor(I)V
    const/high16 v4, 0x41000000    # 8.0f radius
    invoke-virtual {v3, v4}, Landroid/graphics/drawable/GradientDrawable;->setCornerRadius(F)V
    invoke-virtual {v2, v3}, Landroid/view/View;->setBackground(Landroid/graphics/drawable/Drawable;)V
    const/16 v3, 0x10
    const/16 v4, 0x8
    invoke-virtual {v2, v3, v4, v3, v4}, Landroid/view/View;->setPadding(IIII)V

    new-instance v3, Landroid/widget/LinearLayout$LayoutParams;
    const/4 v4, -0x1
    const/4 v5, -0x2
    invoke-direct {v3, v4, v5}, Landroid/widget/LinearLayout$LayoutParams;-><init>(II)V
    const/16 v4, 0x4
    const/16 v5, 0x8
    invoke-virtual {v3, v4, v5, v4, v5}, Landroid/widget/LinearLayout$LayoutParams;->setMargins(IIII)V
    invoke-virtual {v2, v3}, Landroid/view/View;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V
    invoke-virtual {v1, v2}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # ===== FILTER INPUT =====
    new-instance v2, Landroid/widget/EditText;
    invoke-direct {v2, p0}, Landroid/widget/EditText;-><init>(Landroid/content/Context;)V
    iput-object v2, p0, Lin/startv/hotstar/NetworkMonitorActivity;->filterEdit:Landroid/widget/EditText;
    const-string v3, "Filter (e.g. api.hotstar, .m3u8, POST)..."
    invoke-virtual {v2, v3}, Landroid/widget/EditText;->setHint(Ljava/lang/CharSequence;)V
    const/high16 v3, 0x41400000    # 12.0f
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setTextSize(F)V
    const/4 v3, -0x1
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setTextColor(I)V
    const/4 v3, 0x1
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setSingleLine(Z)V
    sget-object v3, Landroid/graphics/Typeface;->MONOSPACE:Landroid/graphics/Typeface;
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setTypeface(Landroid/graphics/Typeface;)V

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

    new-instance v3, Landroid/widget/LinearLayout$LayoutParams;
    const/4 v4, -0x1
    const/4 v5, -0x2
    invoke-direct {v3, v4, v5}, Landroid/widget/LinearLayout$LayoutParams;-><init>(II)V
    const/16 v4, 0x4
    invoke-virtual {v3, v4, v4, v4, v4}, Landroid/widget/LinearLayout$LayoutParams;->setMargins(IIII)V
    invoke-virtual {v2, v3}, Landroid/view/View;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V
    invoke-virtual {v1, v2}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # ===== BUTTON ROW =====
    new-instance v8, Landroid/widget/LinearLayout;
    invoke-direct {v8, p0}, Landroid/widget/LinearLayout;-><init>(Landroid/content/Context;)V
    const/4 v2, 0x0
    invoke-virtual {v8, v2}, Landroid/widget/LinearLayout;->setOrientation(I)V

    # Capture toggle button
    new-instance v2, Landroid/widget/Button;
    invoke-direct {v2, p0}, Landroid/widget/Button;-><init>(Landroid/content/Context;)V
    iput-object v2, p0, Lin/startv/hotstar/NetworkMonitorActivity;->captureButton:Landroid/widget/Button;
    const-string v3, "\u25b6 Start Capture"
    invoke-virtual {v2, v3}, Landroid/widget/Button;->setText(Ljava/lang/CharSequence;)V
    const/4 v3, -0x1
    invoke-virtual {v2, v3}, Landroid/widget/Button;->setTextColor(I)V
    const/4 v3, 0x0
    invoke-virtual {v2, v3}, Landroid/widget/Button;->setAllCaps(Z)V
    const/high16 v3, 0x41400000
    invoke-virtual {v2, v3}, Landroid/widget/Button;->setTextSize(F)V

    new-instance v3, Landroid/graphics/drawable/GradientDrawable;
    invoke-direct {v3}, Landroid/graphics/drawable/GradientDrawable;-><init>()V
    const v4, -0xcc4a1a    # teal
    invoke-virtual {v3, v4}, Landroid/graphics/drawable/GradientDrawable;->setColor(I)V
    const/high16 v4, 0x41400000
    invoke-virtual {v3, v4}, Landroid/graphics/drawable/GradientDrawable;->setCornerRadius(F)V
    invoke-virtual {v2, v3}, Landroid/view/View;->setBackground(Landroid/graphics/drawable/Drawable;)V
    const/16 v3, 0x10
    const/16 v4, 0x8
    invoke-virtual {v2, v3, v4, v3, v4}, Landroid/view/View;->setPadding(IIII)V
    const/4 v3, 0x0
    invoke-virtual {v2, v3}, Landroid/view/View;->setStateListAnimator(Landroid/animation/StateListAnimator;)V

    new-instance v3, Landroid/widget/LinearLayout$LayoutParams;
    const/4 v4, 0x0
    const/4 v5, -0x2
    const/high16 v6, 0x3f800000    # weight 1.0
    invoke-direct {v3, v4, v5, v6}, Landroid/widget/LinearLayout$LayoutParams;-><init>(IIF)V
    const/16 v4, 0x4
    invoke-virtual {v3, v4, v4, v4, v4}, Landroid/widget/LinearLayout$LayoutParams;->setMargins(IIII)V
    invoke-virtual {v2, v3}, Landroid/view/View;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V

    new-instance v3, Lin/startv/hotstar/NetworkMonitorActivity$CaptureToggleListener;
    invoke-direct {v3, p0}, Lin/startv/hotstar/NetworkMonitorActivity$CaptureToggleListener;-><init>(Lin/startv/hotstar/NetworkMonitorActivity;)V
    invoke-virtual {v2, v3}, Landroid/view/View;->setOnClickListener(Landroid/view/View$OnClickListener;)V
    invoke-virtual {v8, v2}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # Clear button
    new-instance v2, Landroid/widget/Button;
    invoke-direct {v2, p0}, Landroid/widget/Button;-><init>(Landroid/content/Context;)V
    iput-object v2, p0, Lin/startv/hotstar/NetworkMonitorActivity;->clearButton:Landroid/widget/Button;
    const-string v3, "\ud83d\uddd1 Clear"
    invoke-virtual {v2, v3}, Landroid/widget/Button;->setText(Ljava/lang/CharSequence;)V
    const/4 v3, -0x1
    invoke-virtual {v2, v3}, Landroid/widget/Button;->setTextColor(I)V
    const/4 v3, 0x0
    invoke-virtual {v2, v3}, Landroid/widget/Button;->setAllCaps(Z)V
    const/high16 v3, 0x41400000
    invoke-virtual {v2, v3}, Landroid/widget/Button;->setTextSize(F)V

    new-instance v3, Landroid/graphics/drawable/GradientDrawable;
    invoke-direct {v3}, Landroid/graphics/drawable/GradientDrawable;-><init>()V
    const v4, -0x340000    # red
    invoke-virtual {v3, v4}, Landroid/graphics/drawable/GradientDrawable;->setColor(I)V
    const/high16 v4, 0x41400000
    invoke-virtual {v3, v4}, Landroid/graphics/drawable/GradientDrawable;->setCornerRadius(F)V
    invoke-virtual {v2, v3}, Landroid/view/View;->setBackground(Landroid/graphics/drawable/Drawable;)V
    const/16 v3, 0x10
    const/16 v4, 0x8
    invoke-virtual {v2, v3, v4, v3, v4}, Landroid/view/View;->setPadding(IIII)V
    const/4 v3, 0x0
    invoke-virtual {v2, v3}, Landroid/view/View;->setStateListAnimator(Landroid/animation/StateListAnimator;)V

    new-instance v3, Landroid/widget/LinearLayout$LayoutParams;
    const/4 v4, 0x0
    const/4 v5, -0x2
    const/high16 v6, 0x3f800000
    invoke-direct {v3, v4, v5, v6}, Landroid/widget/LinearLayout$LayoutParams;-><init>(IIF)V
    const/16 v4, 0x4
    invoke-virtual {v3, v4, v4, v4, v4}, Landroid/widget/LinearLayout$LayoutParams;->setMargins(IIII)V
    invoke-virtual {v2, v3}, Landroid/view/View;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V

    new-instance v3, Lin/startv/hotstar/NetworkMonitorActivity$ClearListener;
    invoke-direct {v3, p0}, Lin/startv/hotstar/NetworkMonitorActivity$ClearListener;-><init>(Lin/startv/hotstar/NetworkMonitorActivity;)V
    invoke-virtual {v2, v3}, Landroid/view/View;->setOnClickListener(Landroid/view/View$OnClickListener;)V
    invoke-virtual {v8, v2}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # Export button
    new-instance v2, Landroid/widget/Button;
    invoke-direct {v2, p0}, Landroid/widget/Button;-><init>(Landroid/content/Context;)V
    const-string v3, "\ud83d\udcbe Export"
    invoke-virtual {v2, v3}, Landroid/widget/Button;->setText(Ljava/lang/CharSequence;)V
    const/4 v3, -0x1
    invoke-virtual {v2, v3}, Landroid/widget/Button;->setTextColor(I)V
    const/4 v3, 0x0
    invoke-virtual {v2, v3}, Landroid/widget/Button;->setAllCaps(Z)V
    const/high16 v3, 0x41400000
    invoke-virtual {v2, v3}, Landroid/widget/Button;->setTextSize(F)V

    new-instance v3, Landroid/graphics/drawable/GradientDrawable;
    invoke-direct {v3}, Landroid/graphics/drawable/GradientDrawable;-><init>()V
    const v4, -0x996634    # orange
    invoke-virtual {v3, v4}, Landroid/graphics/drawable/GradientDrawable;->setColor(I)V
    const/high16 v4, 0x41400000
    invoke-virtual {v3, v4}, Landroid/graphics/drawable/GradientDrawable;->setCornerRadius(F)V
    invoke-virtual {v2, v3}, Landroid/view/View;->setBackground(Landroid/graphics/drawable/Drawable;)V
    const/16 v3, 0x10
    const/16 v4, 0x8
    invoke-virtual {v2, v3, v4, v3, v4}, Landroid/view/View;->setPadding(IIII)V
    const/4 v3, 0x0
    invoke-virtual {v2, v3}, Landroid/view/View;->setStateListAnimator(Landroid/animation/StateListAnimator;)V

    new-instance v3, Landroid/widget/LinearLayout$LayoutParams;
    const/4 v4, 0x0
    const/4 v5, -0x2
    const/high16 v6, 0x3f800000
    invoke-direct {v3, v4, v5, v6}, Landroid/widget/LinearLayout$LayoutParams;-><init>(IIF)V
    const/16 v4, 0x4
    invoke-virtual {v3, v4, v4, v4, v4}, Landroid/widget/LinearLayout$LayoutParams;->setMargins(IIII)V
    invoke-virtual {v2, v3}, Landroid/view/View;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V

    new-instance v3, Lin/startv/hotstar/NetworkMonitorActivity$ExportListener;
    invoke-direct {v3, p0}, Lin/startv/hotstar/NetworkMonitorActivity$ExportListener;-><init>(Lin/startv/hotstar/NetworkMonitorActivity;)V
    invoke-virtual {v2, v3}, Landroid/view/View;->setOnClickListener(Landroid/view/View$OnClickListener;)V
    invoke-virtual {v8, v2}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    invoke-virtual {v1, v8}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # ===== LOG OUTPUT AREA =====
    new-instance v9, Landroid/widget/ScrollView;
    invoke-direct {v9, p0}, Landroid/widget/ScrollView;-><init>(Landroid/content/Context;)V
    iput-object v9, p0, Lin/startv/hotstar/NetworkMonitorActivity;->scrollView:Landroid/widget/ScrollView;

    new-instance v3, Landroid/graphics/drawable/GradientDrawable;
    invoke-direct {v3}, Landroid/graphics/drawable/GradientDrawable;-><init>()V
    const v4, -0xf2eee9
    invoke-virtual {v3, v4}, Landroid/graphics/drawable/GradientDrawable;->setColor(I)V
    const/high16 v4, 0x41800000    # 16.0f radius
    invoke-virtual {v3, v4}, Landroid/graphics/drawable/GradientDrawable;->setCornerRadius(F)V
    const/4 v4, 0x2
    const v5, -0xcfc9c3
    invoke-virtual {v3, v4, v5}, Landroid/graphics/drawable/GradientDrawable;->setStroke(II)V
    invoke-virtual {v9, v3}, Landroid/view/View;->setBackground(Landroid/graphics/drawable/Drawable;)V

    const/4 v3, 0x1
    invoke-virtual {v9, v3}, Landroid/view/View;->setVerticalScrollBarEnabled(Z)V
    const/4 v3, 0x0
    invoke-virtual {v9, v3}, Landroid/view/View;->setScrollbarFadingEnabled(Z)V
    const/4 v3, 0x1
    invoke-virtual {v9, v3}, Landroid/view/View;->setClipToOutline(Z)V

    # Fill remaining space
    new-instance v3, Landroid/widget/LinearLayout$LayoutParams;
    const/4 v4, -0x1
    const/4 v5, 0x0
    const/high16 v6, 0x3f800000    # weight 1.0
    invoke-direct {v3, v4, v5, v6}, Landroid/widget/LinearLayout$LayoutParams;-><init>(IIF)V
    const/16 v4, 0x4
    const/16 v5, 0x8
    invoke-virtual {v3, v4, v5, v4, v5}, Landroid/widget/LinearLayout$LayoutParams;->setMargins(IIII)V
    invoke-virtual {v9, v3}, Landroid/view/View;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V

    # Log TextView
    new-instance v2, Landroid/widget/TextView;
    invoke-direct {v2, p0}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V
    iput-object v2, p0, Lin/startv/hotstar/NetworkMonitorActivity;->logTextView:Landroid/widget/TextView;

    const-string v3, "\u2502 Tap Start Capture to begin monitoring network traffic...\n\u2502 Frida hooks capture URL, OkHttp, Socket, WebView requests"
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    sget-object v3, Landroid/graphics/Typeface;->MONOSPACE:Landroid/graphics/Typeface;
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setTypeface(Landroid/graphics/Typeface;)V
    const/high16 v3, 0x41200000    # 10.0f - small for dense log view
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setTextSize(F)V
    const v3, -0x362e27    # light green text
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setTextColor(I)V
    const/16 v3, 0xc
    invoke-virtual {v2, v3, v3, v3, v3}, Landroid/view/View;->setPadding(IIII)V
    const/high16 v3, 0x40800000
    const/high16 v4, 0x3f800000
    invoke-virtual {v2, v3, v4}, Landroid/widget/TextView;->setLineSpacing(FF)V
    const v3, 0x7530    # 30000 max lines
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setMaxLines(I)V
    const/4 v3, 0x1
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setTextIsSelectable(Z)V

    invoke-virtual {v9, v2}, Landroid/widget/ScrollView;->addView(Landroid/view/View;)V
    invoke-virtual {v1, v9}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # Set content
    invoke-virtual {v10, v1}, Landroid/widget/ScrollView;->addView(Landroid/view/View;)V
    invoke-virtual {p0, v10}, Landroid/app/Activity;->setContentView(Landroid/view/View;)V

    return-void
.end method


# ================================================================
# startCapture() - Start logcat reader thread for HSPatch-Net tag
# ================================================================
.method public startCapture()V
    .locals 4

    iget-boolean v0, p0, Lin/startv/hotstar/NetworkMonitorActivity;->isCapturing:Z
    if-eqz v0, :start_cap
    return-void
    :start_cap

    const/4 v0, 0x1
    iput-boolean v0, p0, Lin/startv/hotstar/NetworkMonitorActivity;->isCapturing:Z
    const/4 v0, 0x0
    iput v0, p0, Lin/startv/hotstar/NetworkMonitorActivity;->requestCount:I

    # Update button
    iget-object v0, p0, Lin/startv/hotstar/NetworkMonitorActivity;->captureButton:Landroid/widget/Button;
    const-string v1, "\u23f8 Stop Capture"
    invoke-virtual {v0, v1}, Landroid/widget/Button;->setText(Ljava/lang/CharSequence;)V

    # Update status
    iget-object v0, p0, Lin/startv/hotstar/NetworkMonitorActivity;->statusText:Landroid/widget/TextView;
    const-string v1, "\ud83d\udfe2 Capturing \u2022 0 requests"
    invoke-virtual {v0, v1}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    const v1, -0x33cd00
    invoke-virtual {v0, v1}, Landroid/widget/TextView;->setTextColor(I)V

    # Clear logcat for our tag first
    :try_start_clear
    invoke-static {}, Ljava/lang/Runtime;->getRuntime()Ljava/lang/Runtime;
    move-result-object v0
    const-string v1, "logcat -c"
    invoke-virtual {v0, v1}, Ljava/lang/Runtime;->exec(Ljava/lang/String;)Ljava/lang/Process;
    :try_end_clear
    .catch Ljava/lang/Exception; {:try_start_clear .. :try_end_clear} :catch_clear
    :catch_clear

    # Start reader thread
    new-instance v0, Lin/startv/hotstar/NetworkMonitorActivity$LogcatReaderThread;
    invoke-direct {v0, p0}, Lin/startv/hotstar/NetworkMonitorActivity$LogcatReaderThread;-><init>(Lin/startv/hotstar/NetworkMonitorActivity;)V
    iput-object v0, p0, Lin/startv/hotstar/NetworkMonitorActivity;->captureThread:Ljava/lang/Thread;
    invoke-virtual {v0}, Ljava/lang/Thread;->start()V

    return-void
.end method


# ================================================================
# stopCapture() - Stop the logcat reader thread
# ================================================================
.method public stopCapture()V
    .locals 2

    const/4 v0, 0x0
    iput-boolean v0, p0, Lin/startv/hotstar/NetworkMonitorActivity;->isCapturing:Z

    iget-object v0, p0, Lin/startv/hotstar/NetworkMonitorActivity;->captureThread:Ljava/lang/Thread;
    if-eqz v0, :no_thread
    invoke-virtual {v0}, Ljava/lang/Thread;->interrupt()V
    :no_thread

    # Update button
    iget-object v0, p0, Lin/startv/hotstar/NetworkMonitorActivity;->captureButton:Landroid/widget/Button;
    const-string v1, "\u25b6 Start Capture"
    invoke-virtual {v0, v1}, Landroid/widget/Button;->setText(Ljava/lang/CharSequence;)V

    # Update status
    iget-object v0, p0, Lin/startv/hotstar/NetworkMonitorActivity;->statusText:Landroid/widget/TextView;
    new-instance v1, Ljava/lang/StringBuilder;
    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V
    const-string v0, "\u23f8 Stopped \u2022 "
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    iget v0, p0, Lin/startv/hotstar/NetworkMonitorActivity;->requestCount:I
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    const-string v0, " requests captured"
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    iget-object v1, p0, Lin/startv/hotstar/NetworkMonitorActivity;->statusText:Landroid/widget/TextView;
    invoke-virtual {v1, v0}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    return-void
.end method


# ================================================================
# appendLog(String) - Append a line to the log view (on UI thread)
# ================================================================
.method public appendLog(Ljava/lang/String;)V
    .locals 4

    # Apply filter if set
    iget-object v0, p0, Lin/startv/hotstar/NetworkMonitorActivity;->filterEdit:Landroid/widget/EditText;
    invoke-virtual {v0}, Landroid/widget/EditText;->getText()Landroid/text/Editable;
    move-result-object v0
    invoke-virtual {v0}, Ljava/lang/Object;->toString()Ljava/lang/String;
    move-result-object v0
    invoke-virtual {v0}, Ljava/lang/String;->trim()Ljava/lang/String;
    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/String;->length()I
    move-result v1
    if-lez v1, :no_filter

    # Check if line contains filter text (case insensitive)
    invoke-virtual {p1}, Ljava/lang/String;->toLowerCase()Ljava/lang/String;
    move-result-object v1
    invoke-virtual {v0}, Ljava/lang/String;->toLowerCase()Ljava/lang/String;
    move-result-object v2
    invoke-virtual {v1, v2}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v1
    if-nez v1, :no_filter
    return-void    # filtered out

    :no_filter

    # Increment request count
    iget v0, p0, Lin/startv/hotstar/NetworkMonitorActivity;->requestCount:I
    add-int/lit8 v0, v0, 0x1
    iput v0, p0, Lin/startv/hotstar/NetworkMonitorActivity;->requestCount:I

    # Add to buffer
    iget-object v0, p0, Lin/startv/hotstar/NetworkMonitorActivity;->logBuffer:Ljava/lang/StringBuilder;
    invoke-virtual {v0, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v1, "\n"
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    # Trim buffer if > 100KB
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->length()I
    move-result v1
    const v2, 0x19000    # 100KB
    if-le v1, v2, :no_trim

    sub-int v2, v1, v2
    invoke-virtual {v0, 0x0, v2}, Ljava/lang/StringBuilder;->delete(II)Ljava/lang/StringBuilder;

    :no_trim

    # Post UI update
    new-instance v1, Lin/startv/hotstar/NetworkMonitorActivity$UIUpdateRunnable;
    invoke-direct {v1, p0}, Lin/startv/hotstar/NetworkMonitorActivity$UIUpdateRunnable;-><init>(Lin/startv/hotstar/NetworkMonitorActivity;)V
    iget-object v2, p0, Lin/startv/hotstar/NetworkMonitorActivity;->handler:Landroid/os/Handler;
    invoke-virtual {v2, v1}, Landroid/os/Handler;->post(Ljava/lang/Runnable;)Z

    return-void
.end method


# ================================================================
# exportLog() - Save captured log to file
# ================================================================
.method public exportLog()V
    .locals 5

    :try_start_export
    const-string v0, "network_capture.txt"
    invoke-static {v0}, Lin/startv/hotstar/HSPatchConfig;->getFilePath(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v0

    new-instance v1, Ljava/io/FileWriter;
    new-instance v2, Ljava/io/File;
    invoke-direct {v2, v0}, Ljava/io/File;-><init>(Ljava/lang/String;)V
    const/4 v3, 0x0
    invoke-direct {v1, v2, v3}, Ljava/io/FileWriter;-><init>(Ljava/io/File;Z)V

    iget-object v2, p0, Lin/startv/hotstar/NetworkMonitorActivity;->logBuffer:Ljava/lang/StringBuilder;
    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v2
    invoke-virtual {v1, v2}, Ljava/io/Writer;->write(Ljava/lang/String;)V
    invoke-virtual {v1}, Ljava/io/Writer;->flush()V
    invoke-virtual {v1}, Ljava/io/Writer;->close()V

    # Toast
    new-instance v1, Ljava/lang/StringBuilder;
    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V
    const-string v2, "\u2705 Exported to: "
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    const/4 v1, 0x1
    invoke-static {p0, v0, v1}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;
    move-result-object v0
    invoke-virtual {v0}, Landroid/widget/Toast;->show()V

    :try_end_export
    .catch Ljava/lang/Exception; {:try_start_export .. :try_end_export} :catch_export
    goto :done_export

    :catch_export
    move-exception v0
    const-string v1, "Export failed"
    const/4 v2, 0x0
    invoke-static {p0, v1, v2}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;
    move-result-object v1
    invoke-virtual {v1}, Landroid/widget/Toast;->show()V

    :done_export
    return-void
.end method


.method public onDestroy()V
    .locals 0

    invoke-virtual {p0}, Lin/startv/hotstar/NetworkMonitorActivity;->stopCapture()V
    invoke-super {p0}, Landroid/app/Activity;->onDestroy()V
    return-void
.end method
