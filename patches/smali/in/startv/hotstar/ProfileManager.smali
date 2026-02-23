.class public Lin/startv/hotstar/ProfileManager;
.super Ljava/lang/Object;
.source "ProfileManager.java"


# direct methods
.method public constructor <init>()V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    return-void
.end method

# ===== Shell helper: runs /system/bin/sh -c <cmd> =====
.method private static shellExec(Ljava/lang/String;)V
    .locals 4

    :try_start
    invoke-static {}, Ljava/lang/Runtime;->getRuntime()Ljava/lang/Runtime;
    move-result-object v0

    const/4 v1, 0x3
    new-array v1, v1, [Ljava/lang/String;

    const/4 v2, 0x0
    const-string v3, "/system/bin/sh"
    aput-object v3, v1, v2

    const/4 v2, 0x1
    const-string v3, "-c"
    aput-object v3, v1, v2

    const/4 v2, 0x2
    aput-object p0, v1, v2

    invoke-virtual {v0, v1}, Ljava/lang/Runtime;->exec([Ljava/lang/String;)Ljava/lang/Process;
    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/Process;->waitFor()I
    :try_end
    .catchall {:try_start .. :try_end} :catch
    goto :done
    :catch
    move-exception v0
    :done

    return-void
.end method

# ===== Shell helper: runs command and returns stdout =====
.method public static shellExecOutput(Ljava/lang/String;)Ljava/lang/String;
    .locals 6

    :try_start
    invoke-static {}, Ljava/lang/Runtime;->getRuntime()Ljava/lang/Runtime;
    move-result-object v0

    const/4 v1, 0x3
    new-array v1, v1, [Ljava/lang/String;

    const/4 v2, 0x0
    const-string v3, "/system/bin/sh"
    aput-object v3, v1, v2

    const/4 v2, 0x1
    const-string v3, "-c"
    aput-object v3, v1, v2

    const/4 v2, 0x2
    aput-object p0, v1, v2

    invoke-virtual {v0, v1}, Ljava/lang/Runtime;->exec([Ljava/lang/String;)Ljava/lang/Process;
    move-result-object v0

    # Read stdout
    invoke-virtual {v0}, Ljava/lang/Process;->getInputStream()Ljava/io/InputStream;
    move-result-object v1

    new-instance v2, Ljava/io/BufferedReader;
    new-instance v3, Ljava/io/InputStreamReader;
    invoke-direct {v3, v1}, Ljava/io/InputStreamReader;-><init>(Ljava/io/InputStream;)V
    invoke-direct {v2, v3}, Ljava/io/BufferedReader;-><init>(Ljava/io/Reader;)V

    new-instance v3, Ljava/lang/StringBuilder;
    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    :read_loop
    invoke-virtual {v2}, Ljava/io/BufferedReader;->readLine()Ljava/lang/String;
    move-result-object v4

    if-eqz v4, :read_done

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v5, "\n"
    invoke-virtual {v3, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    goto :read_loop

    :read_done
    invoke-virtual {v2}, Ljava/io/BufferedReader;->close()V
    invoke-virtual {v0}, Ljava/lang/Process;->waitFor()I

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0

    return-object v0

    :try_end
    .catchall {:try_start .. :try_end} :catch

    :catch
    move-exception v0
    invoke-virtual {v0}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;
    move-result-object v0
    new-instance v1, Ljava/lang/StringBuilder;
    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V
    const-string v2, "Error: "
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    return-object v0
.end method

# ===== Copy helper: copies srcBase/srcName to dstBase/dstName if exists =====
.method private static copySubdir(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    .locals 3
    # p0 = srcBase, p1 = dstBase, p2 = srcName, p3 = dstName

    # Build source path
    new-instance v0, Ljava/lang/StringBuilder;
    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V
    invoke-virtual {v0, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v1, "/"
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0

    # Check exists
    new-instance v1, Ljava/io/File;
    invoke-direct {v1, v0}, Ljava/io/File;-><init>(Ljava/lang/String;)V
    invoke-virtual {v1}, Ljava/io/File;->exists()Z
    move-result v1
    if-eqz v1, :skip

    # Build: "cp -rf srcBase/srcName dstBase/dstName"
    new-instance v1, Ljava/lang/StringBuilder;
    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V
    const-string v2, "cp -rf "
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v2, " "
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v2, "/"
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1, p3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0

    invoke-static {v0}, Lin/startv/hotstar/ProfileManager;->shellExec(Ljava/lang/String;)V

    :skip
    return-void
.end method

# ===== Restore helper: rm -rf dstBase/dstName then cp from profile =====
.method private static restoreSubdir(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    .locals 3
    # p0 = profilePath, p1 = dataPath, p2 = srcName (in profile), p3 = dstName (in data)

    # Build source: profilePath/srcName
    new-instance v0, Ljava/lang/StringBuilder;
    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V
    invoke-virtual {v0, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v1, "/"
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0

    # Check exists
    new-instance v1, Ljava/io/File;
    invoke-direct {v1, v0}, Ljava/io/File;-><init>(Ljava/lang/String;)V
    invoke-virtual {v1}, Ljava/io/File;->exists()Z
    move-result v1
    if-eqz v1, :skip

    # rm -rf dataPath/dstName
    new-instance v1, Ljava/lang/StringBuilder;
    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V
    const-string v2, "rm -rf "
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v2, "/"
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1, p3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v1
    invoke-static {v1}, Lin/startv/hotstar/ProfileManager;->shellExec(Ljava/lang/String;)V

    # cp -rf profilePath/srcName dataPath/dstName
    new-instance v1, Ljava/lang/StringBuilder;
    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V
    const-string v2, "cp -rf "
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v2, " "
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v2, "/"
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1, p3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    invoke-static {v0}, Lin/startv/hotstar/ProfileManager;->shellExec(Ljava/lang/String;)V

    :skip
    return-void
.end method

# ===== Apply pending profile at startup (before any app init) =====
.method public static applyPendingProfile(Landroid/content/Context;)V
    .locals 6

    :try_start
    # Get external files dir
    const/4 v0, 0x0
    invoke-virtual {p0, v0}, Landroid/content/Context;->getExternalFilesDir(Ljava/lang/String;)Ljava/io/File;
    move-result-object v0
    if-nez v0, :ext_ok
    return-void
    :ext_ok

    # Check pending file
    new-instance v1, Ljava/io/File;
    const-string v2, "hspatch_profiles/.pending_profile"
    invoke-direct {v1, v0, v2}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    invoke-virtual {v1}, Ljava/io/File;->exists()Z
    move-result v2
    if-nez v2, :has_pending
    return-void
    :has_pending

    # Read profile name
    new-instance v2, Ljava/io/BufferedReader;
    new-instance v3, Ljava/io/FileReader;
    invoke-direct {v3, v1}, Ljava/io/FileReader;-><init>(Ljava/io/File;)V
    invoke-direct {v2, v3}, Ljava/io/BufferedReader;-><init>(Ljava/io/Reader;)V

    invoke-virtual {v2}, Ljava/io/BufferedReader;->readLine()Ljava/lang/String;
    move-result-object v3
    invoke-virtual {v2}, Ljava/io/BufferedReader;->close()V

    # Delete pending file
    invoke-virtual {v1}, Ljava/io/File;->delete()Z

    # Validate name
    if-eqz v3, :done
    invoke-virtual {v3}, Ljava/lang/String;->trim()Ljava/lang/String;
    move-result-object v3
    invoke-virtual {v3}, Ljava/lang/String;->isEmpty()Z
    move-result v1
    if-nez v1, :done

    # Check profile dir exists
    new-instance v1, Ljava/lang/StringBuilder;
    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V
    const-string v2, "hspatch_profiles/"
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v1

    new-instance v2, Ljava/io/File;
    invoke-direct {v2, v0, v1}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    invoke-virtual {v2}, Ljava/io/File;->exists()Z
    move-result v0
    if-nez v0, :profile_exists
    return-void
    :profile_exists

    # Get paths
    invoke-virtual {v2}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;
    move-result-object v0
    # v0 = profileDirPath

    invoke-virtual {p0}, Landroid/content/Context;->getDataDir()Ljava/io/File;
    move-result-object v1
    invoke-virtual {v1}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;
    move-result-object v1
    # v1 = dataPath

    # === FULL RESTORE: Wipe everything in data dir except lib/ and code_cache/, then copy profile back ===
    # Step 1: Remove all data dir contents except lib/ and code_cache/
    new-instance v4, Ljava/lang/StringBuilder;
    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V
    const-string v5, "for d in "
    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v4, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v5, "/*; do bn=$(basename \"$d\"); if [ \"$bn\" != \"lib\" ] && [ \"$bn\" != \"code_cache\" ]; then rm -rf \"$d\"; fi; done"
    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v4
    invoke-static {v4}, Lin/startv/hotstar/ProfileManager;->shellExec(Ljava/lang/String;)V

    # Step 2: Copy everything from profile dir back to data dir
    new-instance v4, Ljava/lang/StringBuilder;
    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V
    const-string v5, "cp -rf "
    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v4, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v5, "/* "
    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v4, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v5, "/"
    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v4
    invoke-static {v4}, Lin/startv/hotstar/ProfileManager;->shellExec(Ljava/lang/String;)V

    # Log success
    const-string v0, "HSPatch"
    new-instance v1, Ljava/lang/StringBuilder;
    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V
    const-string v2, "Profile restored (full data/data): "
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v1
    invoke-static {v0, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    :try_end
    .catchall {:try_start .. :try_end} :catch
    goto :done
    :catch
    move-exception v0
    const-string v1, "HSPatch"
    const-string v2, "Profile apply error"
    invoke-static {v1, v2, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I
    :done

    return-void
.end method

# ===== Save current app data as a named profile =====
.method public static saveProfile(Landroid/content/Context;Ljava/lang/String;)V
    .locals 5

    :try_start
    # Get ext dir
    const/4 v0, 0x0
    invoke-virtual {p0, v0}, Landroid/content/Context;->getExternalFilesDir(Ljava/lang/String;)Ljava/io/File;
    move-result-object v0
    if-nez v0, :ext_ok
    return-void
    :ext_ok

    # Build profileDir path
    new-instance v1, Ljava/lang/StringBuilder;
    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V
    const-string v2, "hspatch_profiles/"
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v1

    new-instance v2, Ljava/io/File;
    invoke-direct {v2, v0, v1}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    # Remove old profile
    new-instance v0, Ljava/lang/StringBuilder;
    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V
    const-string v1, "rm -rf "
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v2}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;
    move-result-object v1
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    invoke-static {v0}, Lin/startv/hotstar/ProfileManager;->shellExec(Ljava/lang/String;)V

    # Create profile dir
    invoke-virtual {v2}, Ljava/io/File;->mkdirs()Z

    # Get data dir path
    invoke-virtual {p0}, Landroid/content/Context;->getDataDir()Ljava/io/File;
    move-result-object v0
    invoke-virtual {v0}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;
    move-result-object v0

    invoke-virtual {v2}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;
    move-result-object v1

    # Copy ENTIRE data/data dir (excluding lib/ and code_cache/)
    # Command: for d in <dataDir>/*; do bn=$(basename $d); if [ "$bn" != "lib" ] && [ "$bn" != "code_cache" ]; then cp -rf $d <profileDir>/; fi; done
    new-instance v3, Ljava/lang/StringBuilder;
    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V
    const-string v4, "for d in "
    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v3, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v4, "/*; do bn=$(basename \"$d\"); if [ \"$bn\" != \"lib\" ] && [ \"$bn\" != \"code_cache\" ]; then cp -rf \"$d\" "
    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v3, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v4, "/; fi; done"
    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v3
    invoke-static {v3}, Lin/startv/hotstar/ProfileManager;->shellExec(Ljava/lang/String;)V

    # Log with size
    new-instance v3, Ljava/lang/StringBuilder;
    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V
    const-string v4, "du -sh "
    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v3, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v3
    invoke-static {v3}, Lin/startv/hotstar/ProfileManager;->shellExecOutput(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v3

    const-string v0, "HSPatch"
    new-instance v1, Ljava/lang/StringBuilder;
    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V
    const-string v2, "Profile saved (full data/data): "
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v2, " | Size: "
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v3}, Ljava/lang/String;->trim()Ljava/lang/String;
    move-result-object v3
    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v1
    invoke-static {v0, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    :try_end
    .catchall {:try_start .. :try_end} :catch
    goto :done
    :catch
    move-exception v0
    :done

    return-void
.end method

# ===== List all saved profile names =====
.method public static listProfiles(Landroid/content/Context;)[Ljava/lang/String;
    .locals 6

    :try_start
    # Get ext dir
    const/4 v0, 0x0
    invoke-virtual {p0, v0}, Landroid/content/Context;->getExternalFilesDir(Ljava/lang/String;)Ljava/io/File;
    move-result-object v0
    if-nez v0, :ext_ok

    const/4 v0, 0x0
    new-array v0, v0, [Ljava/lang/String;
    return-object v0

    :ext_ok
    # Profiles dir
    new-instance v1, Ljava/io/File;
    const-string v2, "hspatch_profiles"
    invoke-direct {v1, v0, v2}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    invoke-virtual {v1}, Ljava/io/File;->exists()Z
    move-result v0
    if-nez v0, :dir_exists

    const/4 v0, 0x0
    new-array v0, v0, [Ljava/lang/String;
    return-object v0

    :dir_exists
    invoke-virtual {v1}, Ljava/io/File;->listFiles()[Ljava/io/File;
    move-result-object v0
    if-nez v0, :files_ok

    const/4 v0, 0x0
    new-array v0, v0, [Ljava/lang/String;
    return-object v0

    :files_ok
    # Build ArrayList of names
    new-instance v1, Ljava/util/ArrayList;
    invoke-direct {v1}, Ljava/util/ArrayList;-><init>()V

    array-length v2, v0
    const/4 v3, 0x0

    :loop
    if-ge v3, v2, :end_loop

    aget-object v4, v0, v3

    # Check isDirectory
    invoke-virtual {v4}, Ljava/io/File;->isDirectory()Z
    move-result v5
    if-eqz v5, :next

    # Check not starts with "."
    invoke-virtual {v4}, Ljava/io/File;->getName()Ljava/lang/String;
    move-result-object v4
    const-string v5, "."
    invoke-virtual {v4, v5}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z
    move-result v5
    if-nez v5, :next

    # Add name to list
    invoke-virtual {v1, v4}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    :next
    add-int/lit8 v3, v3, 0x1
    goto :loop

    :end_loop
    # Convert to String[]
    const/4 v0, 0x0
    new-array v0, v0, [Ljava/lang/String;
    invoke-virtual {v1, v0}, Ljava/util/ArrayList;->toArray([Ljava/lang/Object;)[Ljava/lang/Object;
    move-result-object v0
    check-cast v0, [Ljava/lang/String;
    return-object v0

    :try_end
    .catchall {:try_start .. :try_end} :catch
    :catch
    move-exception v0
    const/4 v0, 0x0
    new-array v0, v0, [Ljava/lang/String;
    return-object v0
.end method

# ===== Delete a saved profile =====
.method public static deleteProfile(Landroid/content/Context;Ljava/lang/String;)V
    .locals 3

    :try_start
    const/4 v0, 0x0
    invoke-virtual {p0, v0}, Landroid/content/Context;->getExternalFilesDir(Ljava/lang/String;)Ljava/io/File;
    move-result-object v0
    if-nez v0, :ext_ok
    return-void
    :ext_ok

    # Build profile path
    new-instance v1, Ljava/lang/StringBuilder;
    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V
    const-string v2, "hspatch_profiles/"
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v1

    new-instance v2, Ljava/io/File;
    invoke-direct {v2, v0, v1}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    # rm -rf
    new-instance v0, Ljava/lang/StringBuilder;
    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V
    const-string v1, "rm -rf "
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v2}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;
    move-result-object v1
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    invoke-static {v0}, Lin/startv/hotstar/ProfileManager;->shellExec(Ljava/lang/String;)V

    # Log
    const-string v0, "HSPatch"
    new-instance v1, Ljava/lang/StringBuilder;
    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V
    const-string v2, "Profile deleted: "
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v1
    invoke-static {v0, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    :try_end
    .catchall {:try_start .. :try_end} :catch
    goto :done
    :catch
    move-exception v0
    :done

    return-void
.end method

# ===== Load profile: write pending flag + restart app =====
.method public static loadProfile(Landroid/content/Context;Ljava/lang/String;)V
    .locals 4

    :try_start
    # Get ext dir
    const/4 v0, 0x0
    invoke-virtual {p0, v0}, Landroid/content/Context;->getExternalFilesDir(Ljava/lang/String;)Ljava/io/File;
    move-result-object v0
    if-nez v0, :ext_ok
    return-void
    :ext_ok

    # Create pending file
    new-instance v1, Ljava/io/File;
    const-string v2, "hspatch_profiles/.pending_profile"
    invoke-direct {v1, v0, v2}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    # Ensure parent dir exists
    invoke-virtual {v1}, Ljava/io/File;->getParentFile()Ljava/io/File;
    move-result-object v2
    if-eqz v2, :skip_mkdir
    invoke-virtual {v2}, Ljava/io/File;->mkdirs()Z
    :skip_mkdir

    # Write profile name
    new-instance v0, Ljava/io/FileWriter;
    invoke-direct {v0, v1}, Ljava/io/FileWriter;-><init>(Ljava/io/File;)V
    invoke-virtual {v0, p1}, Ljava/io/Writer;->write(Ljava/lang/String;)V
    invoke-virtual {v0}, Ljava/io/Writer;->close()V

    # Log
    const-string v0, "HSPatch"
    new-instance v1, Ljava/lang/StringBuilder;
    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V
    const-string v2, "Profile load pending, restarting: "
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v1
    invoke-static {v0, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    # Get launch intent
    invoke-virtual {p0}, Landroid/content/Context;->getPackageManager()Landroid/content/pm/PackageManager;
    move-result-object v0
    invoke-virtual {p0}, Landroid/content/Context;->getPackageName()Ljava/lang/String;
    move-result-object v1
    invoke-virtual {v0, v1}, Landroid/content/pm/PackageManager;->getLaunchIntentForPackage(Ljava/lang/String;)Landroid/content/Intent;
    move-result-object v0

    if-eqz v0, :done

    # FLAG_ACTIVITY_NEW_TASK | FLAG_ACTIVITY_CLEAR_TASK = 0x10008000
    const v1, 0x10008000
    invoke-virtual {v0, v1}, Landroid/content/Intent;->addFlags(I)Landroid/content/Intent;

    # Start activity
    invoke-virtual {p0, v0}, Landroid/content/Context;->startActivity(Landroid/content/Intent;)V

    # Kill current process
    invoke-static {}, Landroid/os/Process;->myPid()I
    move-result v0
    invoke-static {v0}, Landroid/os/Process;->killProcess(I)V

    :try_end
    .catchall {:try_start .. :try_end} :catch
    goto :done
    :catch
    move-exception v0
    :done

    return-void
.end method

# ===== Create new profile: save current state first, then clear app data for fresh start =====
.method public static createNewProfile(Landroid/content/Context;Ljava/lang/String;)V
    .locals 4

    :try_start
    # First save current state as the given profile name
    invoke-static {p0, p1}, Lin/startv/hotstar/ProfileManager;->saveProfile(Landroid/content/Context;Ljava/lang/String;)V

    # Now clear ENTIRE data/data for true fresh start (keep lib/ only)
    invoke-virtual {p0}, Landroid/content/Context;->getDataDir()Ljava/io/File;
    move-result-object v0
    invoke-virtual {v0}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;
    move-result-object v0

    # Delete everything except lib/ directory
    new-instance v1, Ljava/lang/StringBuilder;
    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V
    const-string v2, "for d in "
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v2, "/*; do bn=$(basename \"$d\"); if [ \"$bn\" != \"lib\" ]; then rm -rf \"$d\"; fi; done"
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v1
    invoke-static {v1}, Lin/startv/hotstar/ProfileManager;->shellExec(Ljava/lang/String;)V

    # Log
    const-string v0, "HSPatch"
    new-instance v1, Ljava/lang/StringBuilder;
    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V
    const-string v2, "New profile: saved current as '"
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v2, "', FULL data/data wiped for fresh start"
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v1
    invoke-static {v0, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    :try_end
    .catchall {:try_start .. :try_end} :catch
    goto :done
    :catch
    move-exception v0
    :done

    return-void
.end method

# ===== Export all profiles as tar.gz =====
.method public static exportAllProfiles(Landroid/content/Context;)Ljava/lang/String;
    .locals 6

    :try_start
    # Get ext dir
    const/4 v0, 0x0
    invoke-virtual {p0, v0}, Landroid/content/Context;->getExternalFilesDir(Ljava/lang/String;)Ljava/io/File;
    move-result-object v0
    if-nez v0, :ext_ok

    const-string v0, "Error: no external storage"
    return-object v0

    :ext_ok
    # Profiles dir
    new-instance v1, Ljava/io/File;
    const-string v2, "hspatch_profiles"
    invoke-direct {v1, v0, v2}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    invoke-virtual {v1}, Ljava/io/File;->exists()Z
    move-result v2
    if-nez v2, :dir_exists

    const-string v0, "No profiles to export"
    return-object v0

    :dir_exists
    invoke-virtual {v1}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;
    move-result-object v1

    # Output path
    new-instance v2, Ljava/io/File;
    const-string v3, "hspatch_profiles_export.tar.gz"
    invoke-direct {v2, v0, v3}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    invoke-virtual {v2}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;
    move-result-object v3

    # Build tar command
    new-instance v4, Ljava/lang/StringBuilder;
    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V
    const-string v5, "tar czf "
    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v4, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v5, " -C "
    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;
    move-result-object v0
    invoke-virtual {v4, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v5, " hspatch_profiles"
    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0

    invoke-static {v0}, Lin/startv/hotstar/ProfileManager;->shellExec(Ljava/lang/String;)V

    # Check if file created
    invoke-virtual {v2}, Ljava/io/File;->exists()Z
    move-result v0
    if-nez v0, :export_ok

    const-string v0, "Export failed - tar not available"
    return-object v0

    :export_ok
    # Try to copy to Downloads folder
    new-instance v0, Ljava/lang/StringBuilder;
    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V
    const-string v1, "cp "
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v1, " /storage/emulated/0/Download/hspatch_profiles_export.tar.gz"
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    invoke-static {v0}, Lin/startv/hotstar/ProfileManager;->shellExec(Ljava/lang/String;)V

    # Check if Downloads copy exists
    new-instance v0, Ljava/io/File;
    const-string v1, "/storage/emulated/0/Download/hspatch_profiles_export.tar.gz"
    invoke-direct {v0, v1}, Ljava/io/File;-><init>(Ljava/lang/String;)V
    invoke-virtual {v0}, Ljava/io/File;->exists()Z
    move-result v4
    if-eqz v4, :keep_ext_path

    # Use Downloads path instead
    const-string v3, "/storage/emulated/0/Download/hspatch_profiles_export.tar.gz"
    move-object v2, v0

    :keep_ext_path
    # Get size
    invoke-virtual {v2}, Ljava/io/File;->length()J
    move-result-wide v0

    # Build result string
    new-instance v4, Ljava/lang/StringBuilder;
    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V
    const-string v5, "Exported to:\n"
    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v4, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v5, "\nSize: "
    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-wide/16 v2, 0x400
    div-long/2addr v0, v2
    invoke-virtual {v4, v0, v1}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;
    const-string v5, " KB"
    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0

    const-string v1, "HSPatch"
    invoke-static {v1, v0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    return-object v0

    :try_end
    .catchall {:try_start .. :try_end} :catch
    :catch
    move-exception v0
    invoke-virtual {v0}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;
    move-result-object v0
    return-object v0
.end method

# ===== Import all profiles from tar.gz =====
.method public static importAllProfiles(Landroid/content/Context;)Ljava/lang/String;
    .locals 7

    :try_start_imp
    # Get external files dir
    const/4 v0, 0x0
    invoke-virtual {p0, v0}, Landroid/content/Context;->getExternalFilesDir(Ljava/lang/String;)Ljava/io/File;
    move-result-object v0
    if-nez v0, :ext_ok_imp
    const-string v0, "Error: no external storage"
    return-object v0

    :ext_ok_imp
    # Check Downloads folder first
    new-instance v1, Ljava/io/File;
    const-string v2, "/storage/emulated/0/Download/hspatch_profiles_export.tar.gz"
    invoke-direct {v1, v2}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    invoke-virtual {v1}, Ljava/io/File;->exists()Z
    move-result v2
    if-nez v2, :found_import_file

    # Check ext files dir
    new-instance v1, Ljava/io/File;
    const-string v2, "hspatch_profiles_export.tar.gz"
    invoke-direct {v1, v0, v2}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    invoke-virtual {v1}, Ljava/io/File;->exists()Z
    move-result v2
    if-nez v2, :found_import_file

    # Not found
    new-instance v2, Ljava/lang/StringBuilder;
    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V
    const-string v3, "No export file found.\n\nPlace hspatch_profiles_export.tar.gz in:\n\u2022 /storage/emulated/0/Download/\n\u2022 "
    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;
    move-result-object v3
    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v2
    return-object v2

    :found_import_file
    # Extract tar.gz to ext dir
    invoke-virtual {v1}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;
    move-result-object v2

    new-instance v3, Ljava/lang/StringBuilder;
    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V
    const-string v4, "tar xzf "
    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v3, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v4, " -C "
    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;
    move-result-object v4
    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v3

    invoke-static {v3}, Lin/startv/hotstar/ProfileManager;->shellExec(Ljava/lang/String;)V

    # Verify profiles dir
    new-instance v3, Ljava/io/File;
    const-string v4, "hspatch_profiles"
    invoke-direct {v3, v0, v4}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    invoke-virtual {v3}, Ljava/io/File;->exists()Z
    move-result v4
    if-eqz v4, :import_failed

    invoke-virtual {v3}, Ljava/io/File;->isDirectory()Z
    move-result v4
    if-eqz v4, :import_failed

    # Count profiles
    invoke-virtual {v3}, Ljava/io/File;->list()[Ljava/lang/String;
    move-result-object v4
    if-nez v4, :has_list
    const/4 v5, 0x0
    goto :build_result
    :has_list
    array-length v5, v4

    :build_result
    new-instance v4, Ljava/lang/StringBuilder;
    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V
    const-string v6, "\u2705 Imported successfully!\n\nProfiles found: "
    invoke-virtual {v4, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    const-string v6, "\nSource: "
    invoke-virtual {v4, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v4, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v6, "\nProfiles dir: "
    invoke-virtual {v4, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v3}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;
    move-result-object v3
    invoke-virtual {v4, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v3
    return-object v3

    :import_failed
    const-string v3, "\u274c Import may have failed.\nProfiles directory not found after extraction."
    return-object v3

    :try_end_imp
    .catchall {:try_start_imp .. :try_end_imp} :catch_imp
    :catch_imp
    move-exception v0
    invoke-virtual {v0}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;
    move-result-object v0
    new-instance v1, Ljava/lang/StringBuilder;
    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V
    const-string v2, "Error: "
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    return-object v0
.end method