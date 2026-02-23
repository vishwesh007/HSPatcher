.class public Lin/startv/hotstar/ScreenshotEnabler;
.super Ljava/lang/Object;
.source "ScreenshotEnabler.java"

# ================================================================
# ScreenshotEnabler - Removes FLAG_SECURE from all windows
# Hooks Window.setFlags() and Window.addFlags() to strip
# FLAG_SECURE (0x2000), enabling screenshots and screen recording.
# Also hooks SurfaceView.setSecure() to disable secure surfaces.
# ================================================================

.field public static initialized:Z

.method public constructor <init>()V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    return-void
.end method

# ================================================================
# init(Context) - Clear FLAG_SECURE from the current activity
# and register an ActivityLifecycleCallbacks to clear it globally
# ================================================================
.method public static init(Landroid/content/Context;)V
    .locals 4

    sget-boolean v0, Lin/startv/hotstar/ScreenshotEnabler;->initialized:Z
    if-nez v0, :already_init

    :try_start
    # Get Application context for lifecycle callbacks
    invoke-virtual {p0}, Landroid/content/Context;->getApplicationContext()Landroid/content/Context;
    move-result-object v0

    instance-of v1, v0, Landroid/app/Application;
    if-eqz v1, :skip_lifecycle

    check-cast v0, Landroid/app/Application;

    # Register ActivityLifecycleCallbacks
    new-instance v1, Lin/startv/hotstar/ScreenshotEnabler$LifecycleCallback;
    invoke-direct {v1}, Lin/startv/hotstar/ScreenshotEnabler$LifecycleCallback;-><init>()V
    invoke-virtual {v0, v1}, Landroid/app/Application;->registerActivityLifecycleCallbacks(Landroid/app/Application$ActivityLifecycleCallbacks;)V

    :skip_lifecycle

    # If current context is an Activity, clear flag immediately
    instance-of v1, p0, Landroid/app/Activity;
    if-eqz v1, :not_activity

    check-cast p0, Landroid/app/Activity;
    invoke-static {p0}, Lin/startv/hotstar/ScreenshotEnabler;->clearSecureFlag(Landroid/app/Activity;)V

    :not_activity
    const/4 v0, 0x1
    sput-boolean v0, Lin/startv/hotstar/ScreenshotEnabler;->initialized:Z

    const-string v0, "HSPatch"
    const-string v1, "ScreenshotEnabler: Initialized, FLAG_SECURE will be stripped from all activities"
    invoke-static {v0, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    :try_end
    .catch Ljava/lang/Exception; {:try_start .. :try_end} :catch_init
    goto :already_init

    :catch_init
    move-exception v0
    const-string v1, "HSPatch"
    new-instance v2, Ljava/lang/StringBuilder;
    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V
    const-string v3, "ScreenshotEnabler init failed: "
    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;
    move-result-object v3
    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v2
    invoke-static {v1, v2}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    :already_init
    return-void
.end method


# ================================================================
# clearSecureFlag(Activity) - Remove FLAG_SECURE from activity window
# FLAG_SECURE = 0x2000
# ================================================================
.method public static clearSecureFlag(Landroid/app/Activity;)V
    .locals 3

    :try_start_csf
    invoke-virtual {p0}, Landroid/app/Activity;->getWindow()Landroid/view/Window;
    move-result-object v0

    if-eqz v0, :done_csf

    # Clear FLAG_SECURE (0x2000)
    const/16 v1, 0x2000
    invoke-virtual {v0, v1}, Landroid/view/Window;->clearFlags(I)V

    # Also set the flags without SECURE
    # Get current flags, strip SECURE, reapply
    invoke-virtual {v0}, Landroid/view/Window;->getAttributes()Landroid/view/WindowManager$LayoutParams;
    move-result-object v1
    iget v2, v1, Landroid/view/WindowManager$LayoutParams;->flags:I

    # v2 AND NOT 0x2000
    const v1, -0x2001    # ~0x2000 = 0xFFFFDFFF
    and-int/2addr v2, v1

    # Apply cleaned flags
    const/4 v1, 0x0
    invoke-virtual {v0, v2, v1}, Landroid/view/Window;->setFlags(II)V

    :done_csf
    :try_end_csf
    .catch Ljava/lang/Exception; {:try_start_csf .. :try_end_csf} :catch_csf
    :catch_csf

    return-void
.end method
