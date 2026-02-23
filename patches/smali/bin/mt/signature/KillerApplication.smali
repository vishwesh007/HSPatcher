.class public Lbin/mt/signature/KillerApplication;
.super Ljava/lang/Object;

# ApkSignatureKillerEx integration for HSPatcher
# Based on https://github.com/L-JINBIN/ApkSignatureKillerEx
#
# Two-pronged signature kill:
#   killPM  — hooks PackageInfo.CREATOR to return fake original signature
#   killOpen — native PLT hooks on open/openat to redirect APK reads to original
#
# Native methods are in libSignatureKiller.so (built from xhook PLT hooking library)


# ===== init: main entry point called by HSPatchInit =====

.method public static init(Ljava/lang/String;Ljava/lang/String;)V
    .locals 2
    .param p0, "packageName"
    .param p1, "signatureData"

    const-string v0, "HSPatch"
    const-string v1, "SignatureKiller: initializing..."
    invoke-static {v0, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    # killPM: hook PackageManager signature queries
    :try_pm
    invoke-static {p0, p1}, Lbin/mt/signature/KillerApplication;->killPM(Ljava/lang/String;Ljava/lang/String;)V
    :try_pm_end
    .catch Ljava/lang/Throwable; {:try_pm .. :try_pm_end} :catch_pm
    const-string v0, "HSPatch"
    const-string v1, "SignatureKiller: killPM OK"
    invoke-static {v0, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    goto :after_pm
    :catch_pm
    move-exception v0
    invoke-virtual {v0}, Ljava/lang/Throwable;->toString()Ljava/lang/String;
    move-result-object v0
    const-string v1, "HSPatch"
    invoke-static {v1, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I
    :after_pm

    # killOpen: hook native file open calls
    :try_open
    invoke-static {p0}, Lbin/mt/signature/KillerApplication;->killOpen(Ljava/lang/String;)V
    :try_open_end
    .catch Ljava/lang/Throwable; {:try_open .. :try_open_end} :catch_open
    const-string v0, "HSPatch"
    const-string v1, "SignatureKiller: killOpen OK"
    invoke-static {v0, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    goto :after_open
    :catch_open
    move-exception v0
    invoke-virtual {v0}, Ljava/lang/Throwable;->toString()Ljava/lang/String;
    move-result-object v0
    const-string v1, "HSPatch"
    invoke-static {v1, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I
    :after_open

    const-string v0, "HSPatch"
    const-string v1, "SignatureKiller: init complete"
    invoke-static {v0, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    return-void
.end method


# ===== killPM: hook PackageInfo.CREATOR =====

.method private static killPM(Ljava/lang/String;Ljava/lang/String;)V
    .locals 5
    .param p0, "packageName"
    .param p1, "signatureData"

    # Decode base64 signature data → byte[]
    const/4 v0, 0x0
    invoke-static {p1, v0}, Landroid/util/Base64;->decode(Ljava/lang/String;I)[B
    move-result-object v0
    # v0 = byte[] decoded sig

    # Create fake Signature
    new-instance v1, Landroid/content/pm/Signature;
    invoke-direct {v1, v0}, Landroid/content/pm/Signature;-><init>([B)V
    # v1 = fakeSignature

    # Get original CREATOR
    sget-object v2, Landroid/content/pm/PackageInfo;->CREATOR:Landroid/os/Parcelable$Creator;
    # v2 = originalCreator

    # Create our SignatureCreator(originalCreator, packageName, fakeSignature)
    new-instance v3, Lbin/mt/signature/SignatureCreator;
    invoke-direct {v3, v2, p0, v1}, Lbin/mt/signature/SignatureCreator;-><init>(Landroid/os/Parcelable$Creator;Ljava/lang/String;Landroid/content/pm/Signature;)V
    # v3 = our creator

    # Set PackageInfo.CREATOR to our creator via reflection
    const-class v4, Landroid/content/pm/PackageInfo;
    const-string v0, "CREATOR"
    invoke-static {v4, v0}, Lbin/mt/signature/KillerApplication;->findField(Ljava/lang/Class;Ljava/lang/String;)Ljava/lang/reflect/Field;
    move-result-object v0
    const/4 v4, 0x0
    invoke-virtual {v0, v4, v3}, Ljava/lang/reflect/Field;->set(Ljava/lang/Object;Ljava/lang/Object;)V

    # Try to add hidden API exemptions (Android P+)
    :try_hidden_api
    sget v0, Landroid/os/Build$VERSION;->SDK_INT:I
    const/16 v1, 0x1c
    if-lt v0, v1, :skip_hidden_api

    # Use reflection to call VMRuntime.setHiddenApiExemptions
    # VMRuntime.getRuntime().setHiddenApiExemptions(new String[]{"L"})
    const-string v0, "dalvik.system.VMRuntime"
    invoke-static {v0}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;
    move-result-object v0
    # v0 = VMRuntime.class

    const-string v1, "getRuntime"
    const/4 v2, 0x0
    new-array v2, v2, [Ljava/lang/Class;
    invoke-virtual {v0, v1, v2}, Ljava/lang/Class;->getDeclaredMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;
    move-result-object v1
    # v1 = getRuntime method

    const/4 v2, 0x0
    new-array v3, v2, [Ljava/lang/Object;
    invoke-virtual {v1, v2, v3}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;
    move-result-object v2
    # v2 = VMRuntime instance

    const-string v1, "setHiddenApiExemptions"
    const/4 v3, 0x1
    new-array v4, v3, [Ljava/lang/Class;
    const-class v3, [Ljava/lang/String;
    const/4 v3, 0x0
    # Get String[].class for parameter type
    const/4 v3, 0x0
    new-array v3, v3, [Ljava/lang/String;
    invoke-virtual {v3}, Ljava/lang/Object;->getClass()Ljava/lang/Class;
    move-result-object v3
    const/4 v4, 0x1
    new-array v4, v4, [Ljava/lang/Class;
    const/4 p1, 0x0
    aput-object v3, v4, p1
    invoke-virtual {v0, v1, v4}, Ljava/lang/Class;->getDeclaredMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;
    move-result-object v1
    # v1 = setHiddenApiExemptions method

    # Build args: new String[]{"L"}
    const/4 v3, 0x1
    new-array v3, v3, [Ljava/lang/String;
    const-string v4, "L"
    const/4 p1, 0x0
    aput-object v4, v3, p1

    # Invoke: runtime.setHiddenApiExemptions(new String[]{"L"})
    const/4 v4, 0x1
    new-array v4, v4, [Ljava/lang/Object;
    const/4 p1, 0x0
    aput-object v3, v4, p1
    invoke-virtual {v1, v2, v4}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "HSPatch"
    const-string v1, "SignatureKiller: hidden API exemptions set"
    invoke-static {v0, v1}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    :skip_hidden_api
    :try_hidden_api_end
    .catch Ljava/lang/Throwable; {:try_hidden_api .. :try_hidden_api_end} :catch_hidden_api
    goto :after_hidden_api
    :catch_hidden_api
    move-exception v0
    # Non-critical — log and continue
    const-string v1, "HSPatch"
    const-string v0, "SignatureKiller: hidden API bypass skipped"
    invoke-static {v1, v0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I
    :after_hidden_api

    # Clear PackageManager cache
    :try_cache1
    const-class v0, Landroid/content/pm/PackageManager;
    const-string v1, "sPackageInfoCache"
    invoke-static {v0, v1}, Lbin/mt/signature/KillerApplication;->findField(Ljava/lang/Class;Ljava/lang/String;)Ljava/lang/reflect/Field;
    move-result-object v0
    const/4 v1, 0x0
    invoke-virtual {v0, v1}, Ljava/lang/reflect/Field;->get(Ljava/lang/Object;)Ljava/lang/Object;
    move-result-object v0
    const-string v1, "clear"
    const/4 v2, 0x0
    new-array v2, v2, [Ljava/lang/Class;
    invoke-virtual {v0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;
    move-result-object v3
    invoke-virtual {v3, v1, v2}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;
    move-result-object v1
    const/4 v2, 0x0
    new-array v2, v2, [Ljava/lang/Object;
    invoke-virtual {v1, v0, v2}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;
    :try_cache1_end
    .catch Ljava/lang/Throwable; {:try_cache1 .. :try_cache1_end} :catch_cache1
    :catch_cache1

    # Clear Parcel.mCreators
    :try_cache2
    const-class v0, Landroid/os/Parcel;
    const-string v1, "mCreators"
    invoke-static {v0, v1}, Lbin/mt/signature/KillerApplication;->findField(Ljava/lang/Class;Ljava/lang/String;)Ljava/lang/reflect/Field;
    move-result-object v0
    const/4 v1, 0x0
    invoke-virtual {v0, v1}, Ljava/lang/reflect/Field;->get(Ljava/lang/Object;)Ljava/lang/Object;
    move-result-object v0
    check-cast v0, Ljava/util/Map;
    invoke-interface {v0}, Ljava/util/Map;->clear()V
    :try_cache2_end
    .catch Ljava/lang/Throwable; {:try_cache2 .. :try_cache2_end} :catch_cache2
    :catch_cache2

    # Clear Parcel.sPairedCreators
    :try_cache3
    const-class v0, Landroid/os/Parcel;
    const-string v1, "sPairedCreators"
    invoke-static {v0, v1}, Lbin/mt/signature/KillerApplication;->findField(Ljava/lang/Class;Ljava/lang/String;)Ljava/lang/reflect/Field;
    move-result-object v0
    const/4 v1, 0x0
    invoke-virtual {v0, v1}, Ljava/lang/reflect/Field;->get(Ljava/lang/Object;)Ljava/lang/Object;
    move-result-object v0
    check-cast v0, Ljava/util/Map;
    invoke-interface {v0}, Ljava/util/Map;->clear()V
    :try_cache3_end
    .catch Ljava/lang/Throwable; {:try_cache3 .. :try_cache3_end} :catch_cache3
    :catch_cache3

    return-void
.end method


# ===== killOpen: native file open hook =====

.method private static killOpen(Ljava/lang/String;)V
    .locals 7
    .param p0, "packageName"

    # Load native library
    :try_load
    const-string v0, "SignatureKiller"
    invoke-static {v0}, Ljava/lang/System;->loadLibrary(Ljava/lang/String;)V
    :try_load_end
    .catch Ljava/lang/Throwable; {:try_load .. :try_load_end} :catch_load
    goto :after_load
    :catch_load
    move-exception v0
    const-string v1, "HSPatch"
    const-string v0, "SignatureKiller: libSignatureKiller.so not found"
    invoke-static {v1, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I
    return-void
    :after_load

    # Get APK path from /proc/self/maps
    invoke-static {p0}, Lbin/mt/signature/KillerApplication;->getApkPath(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v0
    # v0 = apkPath

    if-nez v0, :have_path
    const-string v1, "HSPatch"
    const-string v0, "SignatureKiller: could not find APK path"
    invoke-static {v1, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I
    return-void
    :have_path

    # apkFile = new File(apkPath)
    new-instance v1, Ljava/io/File;
    invoke-direct {v1, v0}, Ljava/io/File;-><init>(Ljava/lang/String;)V
    # v1 = apkFile

    # repFile = new File(getDataFile(packageName), "origin.apk")
    invoke-static {p0}, Lbin/mt/signature/KillerApplication;->getDataFile(Ljava/lang/String;)Ljava/io/File;
    move-result-object v2
    const-string v3, "origin.apk"
    new-instance v4, Ljava/io/File;
    invoke-direct {v4, v2, v3}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V
    # v4 = repFile

    # Extract origin.apk from assets if needed
    :try_extract
    new-instance v2, Ljava/util/zip/ZipFile;
    invoke-direct {v2, v1}, Ljava/util/zip/ZipFile;-><init>(Ljava/io/File;)V
    # v2 = zipFile

    const-string v3, "assets/SignatureKiller/origin.apk"
    invoke-virtual {v2, v3}, Ljava/util/zip/ZipFile;->getEntry(Ljava/lang/String;)Ljava/util/zip/ZipEntry;
    move-result-object v3
    # v3 = entry

    if-nez v3, :have_entry
    invoke-virtual {v2}, Ljava/util/zip/ZipFile;->close()V
    const-string v0, "HSPatch"
    const-string v1, "SignatureKiller: assets/SignatureKiller/origin.apk not found in APK"
    invoke-static {v0, v1}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I
    return-void
    :have_entry

    # Check if repFile already exists with correct size
    invoke-virtual {v4}, Ljava/io/File;->exists()Z
    move-result v5
    if-eqz v5, :need_extract

    invoke-virtual {v4}, Ljava/io/File;->length()J
    move-result-wide v5
    invoke-virtual {v3}, Ljava/util/zip/ZipEntry;->getSize()J
    move-result-wide v6
    # Can't do wide comparison in 7 locals easily; just always extract
    # (simpler and handles corruption)

    :need_extract
    # Extract origin.apk to data dir
    invoke-virtual {v2, v3}, Ljava/util/zip/ZipFile;->getInputStream(Ljava/util/zip/ZipEntry;)Ljava/io/InputStream;
    move-result-object v5
    # v5 = inputStream

    new-instance v6, Ljava/io/FileOutputStream;
    invoke-direct {v6, v4}, Ljava/io/FileOutputStream;-><init>(Ljava/io/File;)V
    # v6 = outputStream

    # Copy loop
    const/16 v3, 0x1000
    new-array v3, v3, [B
    # v3 = buffer

    :copy_loop
    invoke-virtual {v5, v3}, Ljava/io/InputStream;->read([B)I
    move-result p0
    # reuse p0 as len (packageName no longer needed)

    const/4 v0, -0x1
    if-eq p0, v0, :copy_done

    const/4 v0, 0x0
    invoke-virtual {v6, v3, v0, p0}, Ljava/io/OutputStream;->write([BII)V
    goto :copy_loop

    :copy_done
    invoke-virtual {v5}, Ljava/io/InputStream;->close()V
    invoke-virtual {v6}, Ljava/io/OutputStream;->close()V
    invoke-virtual {v2}, Ljava/util/zip/ZipFile;->close()V

    :try_extract_end
    .catch Ljava/io/IOException; {:try_extract .. :try_extract_end} :catch_extract
    goto :do_hook
    :catch_extract
    move-exception v0
    new-instance v2, Ljava/lang/RuntimeException;
    invoke-direct {v2, v0}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/Throwable;)V
    throw v2

    :do_hook
    # Hook: hookApkPath(apkFile.getAbsolutePath(), repFile.getAbsolutePath())
    invoke-virtual {v1}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;
    move-result-object v0
    invoke-virtual {v4}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;
    move-result-object v2

    invoke-static {v0, v2}, Lbin/mt/signature/KillerApplication;->hookApkPath(Ljava/lang/String;Ljava/lang/String;)V

    const-string v0, "HSPatch"
    new-instance v2, Ljava/lang/StringBuilder;
    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V
    const-string v3, "SignatureKiller: hooked APK reads -> "
    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v4}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;
    move-result-object v3
    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v2
    invoke-static {v0, v2}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    return-void
.end method


# ===== findField: reflection helper =====

.method private static findField(Ljava/lang/Class;Ljava/lang/String;)Ljava/lang/reflect/Field;
    .locals 2
    .param p0, "clazz"
    .param p1, "fieldName"

    :try_direct
    invoke-virtual {p0, p1}, Ljava/lang/Class;->getDeclaredField(Ljava/lang/String;)Ljava/lang/reflect/Field;
    move-result-object v0
    const/4 v1, 0x1
    invoke-virtual {v0, v1}, Ljava/lang/reflect/Field;->setAccessible(Z)V
    return-object v0
    :try_direct_end
    .catch Ljava/lang/NoSuchFieldException; {:try_direct .. :try_direct_end} :walk_super

    :walk_super
    move-exception v0

    # Walk superclass chain
    :super_loop
    invoke-virtual {p0}, Ljava/lang/Class;->getSuperclass()Ljava/lang/Class;
    move-result-object p0
    if-eqz p0, :not_found

    const-class v1, Ljava/lang/Object;
    invoke-virtual {p0, v1}, Ljava/lang/Object;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-nez v1, :not_found

    :try_super
    invoke-virtual {p0, p1}, Ljava/lang/Class;->getDeclaredField(Ljava/lang/String;)Ljava/lang/reflect/Field;
    move-result-object v0
    const/4 v1, 0x1
    invoke-virtual {v0, v1}, Ljava/lang/reflect/Field;->setAccessible(Z)V
    return-object v0
    :try_super_end
    .catch Ljava/lang/NoSuchFieldException; {:try_super .. :try_super_end} :next_super

    :next_super
    move-exception v0
    goto :super_loop

    :not_found
    # Re-throw original exception
    new-instance v1, Ljava/lang/NoSuchFieldException;
    invoke-direct {v1, p1}, Ljava/lang/NoSuchFieldException;-><init>(Ljava/lang/String;)V
    throw v1
.end method


# ===== getDataFile: returns app data directory =====

.method private static getDataFile(Ljava/lang/String;)Ljava/io/File;
    .locals 3
    .param p0, "packageName"

    :try_user
    invoke-static {}, Landroid/os/Environment;->getExternalStorageDirectory()Ljava/io/File;
    move-result-object v0
    invoke-virtual {v0}, Ljava/io/File;->getName()Ljava/lang/String;
    move-result-object v0
    # v0 = username (storage dir name)

    const-string v1, "\\d+"
    invoke-virtual {v0, v1}, Ljava/lang/String;->matches(Ljava/lang/String;)Z
    move-result v1
    if-eqz v1, :use_default

    # path = /data/user/{username}/{packageName}
    new-instance v1, Ljava/lang/StringBuilder;
    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V
    const-string v2, "/data/user/"
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v2, "/"
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0

    new-instance v1, Ljava/io/File;
    invoke-direct {v1, v0}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    invoke-virtual {v1}, Ljava/io/File;->canWrite()Z
    move-result v0
    if-eqz v0, :use_default

    return-object v1
    :try_user_end
    .catch Ljava/lang/Throwable; {:try_user .. :try_user_end} :use_default

    :use_default
    # Fallback: /data/data/{packageName}
    new-instance v0, Ljava/lang/StringBuilder;
    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V
    const-string v1, "/data/data/"
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0

    new-instance v1, Ljava/io/File;
    invoke-direct {v1, v0}, Ljava/io/File;-><init>(Ljava/lang/String;)V
    return-object v1
.end method


# ===== getApkPath: reads /proc/self/maps to find APK path =====

.method private static getApkPath(Ljava/lang/String;)Ljava/lang/String;
    .locals 5
    .param p0, "packageName"

    :try_read
    new-instance v0, Ljava/io/BufferedReader;
    new-instance v1, Ljava/io/FileReader;
    const-string v2, "/proc/self/maps"
    invoke-direct {v1, v2}, Ljava/io/FileReader;-><init>(Ljava/lang/String;)V
    invoke-direct {v0, v1}, Ljava/io/BufferedReader;-><init>(Ljava/io/Reader;)V
    # v0 = reader

    :read_loop
    invoke-virtual {v0}, Ljava/io/BufferedReader;->readLine()Ljava/lang/String;
    move-result-object v1
    # v1 = line
    if-eqz v1, :read_done

    # Split line by whitespace, get last element (path)
    const-string v2, "\\s+"
    invoke-virtual {v1, v2}, Ljava/lang/String;->split(Ljava/lang/String;)[Ljava/lang/String;
    move-result-object v2
    # v2 = parts[]
    array-length v3, v2
    add-int/lit8 v3, v3, -1
    aget-object v3, v2, v3
    # v3 = path (last element)

    invoke-static {p0, v3}, Lbin/mt/signature/KillerApplication;->isApkPath(Ljava/lang/String;Ljava/lang/String;)Z
    move-result v4
    if-eqz v4, :read_loop

    # Found! Close reader and return path
    invoke-virtual {v0}, Ljava/io/BufferedReader;->close()V
    return-object v3

    :read_done
    invoke-virtual {v0}, Ljava/io/BufferedReader;->close()V
    const/4 v0, 0x0
    return-object v0

    :try_read_end
    .catch Ljava/lang/Exception; {:try_read .. :try_read_end} :catch_read
    :catch_read
    move-exception v0
    new-instance v1, Ljava/lang/RuntimeException;
    invoke-direct {v1, v0}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/Throwable;)V
    throw v1
.end method


# ===== isApkPath: validates if path matches APK location for package =====

.method private static isApkPath(Ljava/lang/String;Ljava/lang/String;)Z
    .locals 6
    .param p0, "packageName"
    .param p1, "path"

    # Must start with "/" and end with ".apk"
    const-string v0, "/"
    invoke-virtual {p1, v0}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z
    move-result v0
    if-eqz v0, :ret_false

    const-string v0, ".apk"
    invoke-virtual {p1, v0}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z
    move-result v0
    if-eqz v0, :ret_false

    # Remove leading "/" and split by "/" (max 6 parts)
    const/4 v0, 0x1
    invoke-virtual {p1, v0}, Ljava/lang/String;->substring(I)Ljava/lang/String;
    move-result-object v0
    const-string v1, "/"
    const/4 v2, 0x6
    invoke-virtual {v0, v1, v2}, Ljava/lang/String;->split(Ljava/lang/String;I)[Ljava/lang/String;
    move-result-object v0
    # v0 = splitStr[]

    array-length v1, v0
    # v1 = splitCount

    # Check: /data/app/<pkg>*/base.apk (4 or 5 parts)
    const/4 v2, 0x4
    if-eq v1, v2, :check_data_app
    const/4 v2, 0x5
    if-eq v1, v2, :check_data_app
    goto :check_three

    :check_data_app
    const/4 v2, 0x0
    aget-object v3, v0, v2
    const-string v4, "data"
    invoke-virtual {v3, v4}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v3
    if-eqz v3, :check_mnt_asec

    const/4 v2, 0x1
    aget-object v3, v0, v2
    const-string v4, "app"
    invoke-virtual {v3, v4}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v3
    if-eqz v3, :check_mnt_asec

    # Last element must be "base.apk"
    add-int/lit8 v2, v1, -1
    aget-object v3, v0, v2
    const-string v4, "base.apk"
    invoke-virtual {v3, v4}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v3
    if-eqz v3, :check_mnt_asec

    # Second-to-last must startWith packageName
    add-int/lit8 v2, v1, -2
    aget-object v3, v0, v2
    invoke-virtual {v3, p0}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z
    move-result v3
    if-eqz v3, :check_mnt_asec
    const/4 v0, 0x1
    return v0

    :check_mnt_asec
    # Check: /mnt/asec/<pkg>*/pkg.apk (4 or 5 parts)
    const/4 v2, 0x0
    aget-object v3, v0, v2
    const-string v4, "mnt"
    invoke-virtual {v3, v4}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v3
    if-eqz v3, :check_three

    const/4 v2, 0x1
    aget-object v3, v0, v2
    const-string v4, "asec"
    invoke-virtual {v3, v4}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v3
    if-eqz v3, :check_three

    add-int/lit8 v2, v1, -1
    aget-object v3, v0, v2
    const-string v4, "pkg.apk"
    invoke-virtual {v3, v4}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v3
    if-eqz v3, :check_three

    add-int/lit8 v2, v1, -2
    aget-object v3, v0, v2
    invoke-virtual {v3, p0}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z
    move-result v3
    if-eqz v3, :check_three
    const/4 v0, 0x1
    return v0

    :check_three
    # Check: /data/app/<pkg>*.apk (3 parts)
    const/4 v2, 0x3
    if-ne v1, v2, :check_expand

    const/4 v2, 0x0
    aget-object v3, v0, v2
    const-string v4, "data"
    invoke-virtual {v3, v4}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v3
    if-eqz v3, :ret_false

    const/4 v2, 0x1
    aget-object v3, v0, v2
    const-string v4, "app"
    invoke-virtual {v3, v4}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v3
    if-eqz v3, :ret_false

    const/4 v2, 0x2
    aget-object v3, v0, v2
    invoke-virtual {v3, p0}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z
    move-result v3
    if-eqz v3, :ret_false
    const/4 v0, 0x1
    return v0

    :check_expand
    # Check: /mnt/expand/*/app/<pkg>*/base.apk (6 parts)
    const/4 v2, 0x6
    if-ne v1, v2, :ret_false

    const/4 v2, 0x0
    aget-object v3, v0, v2
    const-string v4, "mnt"
    invoke-virtual {v3, v4}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v3
    if-eqz v3, :ret_false

    const/4 v2, 0x1
    aget-object v3, v0, v2
    const-string v4, "expand"
    invoke-virtual {v3, v4}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v3
    if-eqz v3, :ret_false

    const/4 v2, 0x3
    aget-object v3, v0, v2
    const-string v4, "app"
    invoke-virtual {v3, v4}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v3
    if-eqz v3, :ret_false

    const/4 v2, 0x5
    aget-object v3, v0, v2
    const-string v4, "base.apk"
    invoke-virtual {v3, v4}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v3
    if-eqz v3, :ret_false

    const/4 v2, 0x4
    aget-object v3, v0, v2
    invoke-virtual {v3, p0}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z
    move-result v3
    if-eqz v3, :ret_false
    const/4 v0, 0x1
    return v0

    :ret_false
    const/4 v0, 0x0
    return v0
.end method


# ===== Native methods (in libSignatureKiller.so) =====

.method private static native hookApkPath(Ljava/lang/String;Ljava/lang/String;)V
.end method

.method public static native refreshHooks()V
.end method
