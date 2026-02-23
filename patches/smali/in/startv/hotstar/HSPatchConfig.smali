.class public Lin/startv/hotstar/HSPatchConfig;
.super Ljava/lang/Object;
.source "HSPatchConfig.java"

# ================================================================
# HSPatchConfig - Central configuration for all HSPatch modules
# Holds the dynamic files directory path, initialized once at startup
# All other classes reference this instead of hardcoded paths
# ================================================================

# static fields
.field public static filesDir:Ljava/lang/String;
.field public static initialized:Z
.field public static autoResetFingerprint:Z


# direct methods
.method public constructor <init>()V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    return-void
.end method


# ================================================================
# init(Context) - Called first in Application.onCreate()
# Sets filesDir to the app's external files directory
# ================================================================
.method public static init(Landroid/content/Context;)V
    .locals 3

    sget-boolean v0, Lin/startv/hotstar/HSPatchConfig;->initialized:Z
    if-nez v0, :already_init

    :try_start
    # Get external files dir (works for ANY app)
    const/4 v0, 0x0
    invoke-virtual {p0, v0}, Landroid/content/Context;->getExternalFilesDir(Ljava/lang/String;)Ljava/io/File;
    move-result-object v0

    if-eqz v0, :try_internal

    invoke-virtual {v0}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;
    move-result-object v0
    goto :dir_resolved

    :try_internal
    # Fallback to internal data dir
    invoke-virtual {p0}, Landroid/content/Context;->getApplicationInfo()Landroid/content/pm/ApplicationInfo;
    move-result-object v0
    iget-object v0, v0, Landroid/content/pm/ApplicationInfo;->dataDir:Ljava/lang/String;

    new-instance v1, Ljava/lang/StringBuilder;
    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v2, "/files"
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0

    :dir_resolved
    sput-object v0, Lin/startv/hotstar/HSPatchConfig;->filesDir:Ljava/lang/String;

    # Ensure directory exists
    new-instance v1, Ljava/io/File;
    invoke-direct {v1, v0}, Ljava/io/File;-><init>(Ljava/lang/String;)V
    invoke-virtual {v1}, Ljava/io/File;->mkdirs()Z

    const/4 v0, 0x1
    sput-boolean v0, Lin/startv/hotstar/HSPatchConfig;->initialized:Z

    # Load autoResetFingerprint toggle from SharedPreferences
    const-string v0, "hspatch_settings"
    const/4 v1, 0x0
    invoke-virtual {p0, v0, v1}, Landroid/content/Context;->getSharedPreferences(Ljava/lang/String;I)Landroid/content/SharedPreferences;
    move-result-object v0
    const-string v1, "auto_reset_fingerprint"
    const/4 v2, 0x1
    invoke-interface {v0, v1, v2}, Landroid/content/SharedPreferences;->getBoolean(Ljava/lang/String;Z)Z
    move-result v1
    sput-boolean v1, Lin/startv/hotstar/HSPatchConfig;->autoResetFingerprint:Z

    const-string v0, "HSPatch"
    new-instance v1, Ljava/lang/StringBuilder;
    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V
    const-string v2, "Config initialized, filesDir="
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    sget-object v2, Lin/startv/hotstar/HSPatchConfig;->filesDir:Ljava/lang/String;
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v1
    invoke-static {v0, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    :try_end
    .catchall {:try_start .. :try_end} :catch_init
    goto :after_init

    :catch_init
    move-exception v0
    # Ultimate fallback
    const-string v0, "/storage/emulated/0/Download/hspatch_logs"
    sput-object v0, Lin/startv/hotstar/HSPatchConfig;->filesDir:Ljava/lang/String;
    new-instance v1, Ljava/io/File;
    invoke-direct {v1, v0}, Ljava/io/File;-><init>(Ljava/lang/String;)V
    invoke-virtual {v1}, Ljava/io/File;->mkdirs()Z

    :after_init
    :already_init
    return-void
.end method


# ================================================================
# getFilePath(String) - Build full path from filesDir + filename
# Returns: filesDir + "/" + filename
# ================================================================
.method public static getFilePath(Ljava/lang/String;)Ljava/lang/String;
    .locals 2

    sget-object v0, Lin/startv/hotstar/HSPatchConfig;->filesDir:Ljava/lang/String;
    if-nez v0, :has_dir

    # Not initialized yet, return filename as-is
    return-object p0

    :has_dir
    new-instance v1, Ljava/lang/StringBuilder;
    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v0, "/"
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0

    return-object v0
.end method


# ================================================================
# setAutoResetFingerprint(Context, boolean) - Persist toggle
# ================================================================
.method public static setAutoResetFingerprint(Landroid/content/Context;Z)V
    .locals 3

    sput-boolean p1, Lin/startv/hotstar/HSPatchConfig;->autoResetFingerprint:Z

    const-string v0, "hspatch_settings"
    const/4 v1, 0x0
    invoke-virtual {p0, v0, v1}, Landroid/content/Context;->getSharedPreferences(Ljava/lang/String;I)Landroid/content/SharedPreferences;
    move-result-object v0
    invoke-interface {v0}, Landroid/content/SharedPreferences;->edit()Landroid/content/SharedPreferences$Editor;
    move-result-object v1
    const-string v2, "auto_reset_fingerprint"
    invoke-interface {v1, v2, p1}, Landroid/content/SharedPreferences$Editor;->putBoolean(Ljava/lang/String;Z)Landroid/content/SharedPreferences$Editor;
    invoke-interface {v1}, Landroid/content/SharedPreferences$Editor;->apply()V

    return-void
.end method
