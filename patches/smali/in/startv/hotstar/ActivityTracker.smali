.class public Lin/startv/hotstar/ActivityTracker;
.super Ljava/lang/Object;
.source "ActivityTracker.java"

# interfaces
.implements Landroid/app/Application$ActivityLifecycleCallbacks;


# static fields
.field private static instance:Lin/startv/hotstar/ActivityTracker;
.field private static appContext:Landroid/content/Context;
.field private static permissionRequested:Z


# direct methods
.method public constructor <init>()V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    return-void
.end method

.method public static register(Landroid/app/Application;)V
    .locals 2

    # Save app context
    sput-object p0, Lin/startv/hotstar/ActivityTracker;->appContext:Landroid/content/Context;

    # Create instance
    new-instance v0, Lin/startv/hotstar/ActivityTracker;
    invoke-direct {v0}, Lin/startv/hotstar/ActivityTracker;-><init>()V
    sput-object v0, Lin/startv/hotstar/ActivityTracker;->instance:Lin/startv/hotstar/ActivityTracker;

    # Register as lifecycle callback
    invoke-virtual {p0, v0}, Landroid/app/Application;->registerActivityLifecycleCallbacks(Landroid/app/Application$ActivityLifecycleCallbacks;)V

    # Log registration
    const-string v1, "HSPatch"
    const-string v0, "ActivityTracker registered"
    invoke-static {v1, v0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    return-void
.end method

.method private showToast(Landroid/app/Activity;Ljava/lang/String;)V
    .locals 3

    # Build message: "📱 ActivityName"
    new-instance v0, Ljava/lang/StringBuilder;
    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V
    const-string v1, "\ud83d\udcf1 "
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0

    # Show toast
    const/4 v1, 0x0
    invoke-static {p1, v0, v1}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;
    move-result-object v2
    invoke-virtual {v2}, Landroid/widget/Toast;->show()V

    return-void
.end method

.method private logToFile(Ljava/lang/String;)V
    .locals 5

    :try_start
    new-instance v0, Ljava/io/File;
    const-string v1, "activity_logs.txt"
    invoke-static {v1}, Lin/startv/hotstar/HSPatchConfig;->getFilePath(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v1
    invoke-direct {v0, v1}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    # Ensure parent exists
    invoke-virtual {v0}, Ljava/io/File;->getParentFile()Ljava/io/File;
    move-result-object v2
    if-eqz v2, :skip_mkdir
    invoke-virtual {v2}, Ljava/io/File;->mkdirs()Z
    :skip_mkdir

    new-instance v1, Ljava/io/FileWriter;
    const/4 v2, 0x1
    invoke-direct {v1, v0, v2}, Ljava/io/FileWriter;-><init>(Ljava/io/File;Z)V

    # Write timestamp
    new-instance v2, Ljava/text/SimpleDateFormat;
    const-string v3, "HH:mm:ss.SSS"
    invoke-direct {v2, v3}, Ljava/text/SimpleDateFormat;-><init>(Ljava/lang/String;)V
    new-instance v3, Ljava/util/Date;
    invoke-direct {v3}, Ljava/util/Date;-><init>()V
    invoke-virtual {v2, v3}, Ljava/text/SimpleDateFormat;->format(Ljava/util/Date;)Ljava/lang/String;
    move-result-object v2

    new-instance v3, Ljava/lang/StringBuilder;
    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V
    const-string v4, "["
    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v3, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v4, "] "
    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v3, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v4, "\n"
    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/io/Writer;->write(Ljava/lang/String;)V
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

.method private getShortName(Ljava/lang/String;)Ljava/lang/String;
    .locals 2

    const-string v0, "."
    invoke-virtual {p1, v0}, Ljava/lang/String;->lastIndexOf(Ljava/lang/String;)I
    move-result v0

    const/4 v1, -0x1
    if-eq v0, v1, :return_full

    add-int/lit8 v0, v0, 0x1
    invoke-virtual {p1, v0}, Ljava/lang/String;->substring(I)Ljava/lang/String;
    move-result-object p1

    :return_full
    return-object p1
.end method


# virtual methods - ActivityLifecycleCallbacks

.method public onActivityCreated(Landroid/app/Activity;Landroid/os/Bundle;)V
    .locals 2

    invoke-virtual {p1}, Ljava/lang/Object;->getClass()Ljava/lang/Class;
    move-result-object v0
    invoke-virtual {v0}, Ljava/lang/Class;->getName()Ljava/lang/String;
    move-result-object v0

    new-instance v1, Ljava/lang/StringBuilder;
    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V
    const-string p2, "CREATED: "
    invoke-virtual {v1, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v1

    invoke-direct {p0, v1}, Lin/startv/hotstar/ActivityTracker;->logToFile(Ljava/lang/String;)V

    return-void
.end method

.method public onActivityResumed(Landroid/app/Activity;)V
    .locals 3

    # === HSPatch: Request POST_NOTIFICATIONS permission on first activity ===
    sget-boolean v0, Lin/startv/hotstar/ActivityTracker;->permissionRequested:Z
    if-nez v0, :skip_notif_perm

    const/4 v0, 0x1
    sput-boolean v0, Lin/startv/hotstar/ActivityTracker;->permissionRequested:Z

    # Check Android 13+ (API 33)
    sget v0, Landroid/os/Build$VERSION;->SDK_INT:I
    const/16 v1, 0x21
    if-lt v0, v1, :skip_notif_perm

    # Check if permission already granted (0 = GRANTED)
    const-string v0, "android.permission.POST_NOTIFICATIONS"
    invoke-virtual {p1, v0}, Landroid/app/Activity;->checkSelfPermission(Ljava/lang/String;)I
    move-result v1
    if-eqz v1, :skip_notif_perm

    # Request the permission
    const/4 v1, 0x1
    new-array v1, v1, [Ljava/lang/String;
    const/4 v2, 0x0
    aput-object v0, v1, v2
    const/16 v2, 0x3e9
    invoke-virtual {p1, v1, v2}, Landroid/app/Activity;->requestPermissions([Ljava/lang/String;I)V

    :skip_notif_perm

    invoke-virtual {p1}, Ljava/lang/Object;->getClass()Ljava/lang/Class;
    move-result-object v0
    invoke-virtual {v0}, Ljava/lang/Class;->getName()Ljava/lang/String;
    move-result-object v0

    # Get short name for toast
    invoke-direct {p0, v0}, Lin/startv/hotstar/ActivityTracker;->getShortName(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v1

    # Show toast
    invoke-direct {p0, p1, v1}, Lin/startv/hotstar/ActivityTracker;->showToast(Landroid/app/Activity;Ljava/lang/String;)V

    # Log
    new-instance v1, Ljava/lang/StringBuilder;
    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V
    const-string v2, "RESUMED: "
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v1

    invoke-direct {p0, v1}, Lin/startv/hotstar/ActivityTracker;->logToFile(Ljava/lang/String;)V

    # Also log to Android logcat
    const-string v1, "HSPatch"
    new-instance v2, Ljava/lang/StringBuilder;
    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V
    const-string p1, "Activity: "
    invoke-virtual {v2, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v2, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v2
    invoke-static {v1, v2}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    return-void
.end method

.method public onActivityPaused(Landroid/app/Activity;)V
    .locals 2

    invoke-virtual {p1}, Ljava/lang/Object;->getClass()Ljava/lang/Class;
    move-result-object v0
    invoke-virtual {v0}, Ljava/lang/Class;->getName()Ljava/lang/String;
    move-result-object v0

    new-instance v1, Ljava/lang/StringBuilder;
    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V
    const-string p1, "PAUSED: "
    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v1

    invoke-direct {p0, v1}, Lin/startv/hotstar/ActivityTracker;->logToFile(Ljava/lang/String;)V

    return-void
.end method

.method public onActivityStarted(Landroid/app/Activity;)V
    .locals 0
    return-void
.end method

.method public onActivityStopped(Landroid/app/Activity;)V
    .locals 0
    return-void
.end method

.method public onActivitySaveInstanceState(Landroid/app/Activity;Landroid/os/Bundle;)V
    .locals 0
    return-void
.end method

.method public onActivityDestroyed(Landroid/app/Activity;)V
    .locals 2

    invoke-virtual {p1}, Ljava/lang/Object;->getClass()Ljava/lang/Class;
    move-result-object v0
    invoke-virtual {v0}, Ljava/lang/Class;->getName()Ljava/lang/String;
    move-result-object v0

    new-instance v1, Ljava/lang/StringBuilder;
    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V
    const-string p1, "DESTROYED: "
    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v1

    invoke-direct {p0, v1}, Lin/startv/hotstar/ActivityTracker;->logToFile(Ljava/lang/String;)V

    return-void
.end method