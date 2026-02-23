.class public Lin/startv/hotstar/SignatureBypass;
.super Ljava/lang/Object;
.source "SignatureBypass.java"

# ================================================================
# SignatureBypass - Hooks PackageManager to return original signatures
# Captures the original signature at init time (from real PM), then
# proxies PackageManager calls to return that cached signature.
# This defeats signature verification checks in the app.
# ================================================================

# static fields
.field public static originalSignatures:[Landroid/content/pm/Signature;
.field public static originalPackageName:Ljava/lang/String;
.field public static initialized:Z

.method public constructor <init>()V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    return-void
.end method

# ================================================================
# init(Context) - Capture original signature info, install proxy
# ================================================================
.method public static init(Landroid/content/Context;)V
    .locals 6

    sget-boolean v0, Lin/startv/hotstar/SignatureBypass;->initialized:Z
    if-nez v0, :already_init

    :try_start
    # Get package name
    invoke-virtual {p0}, Landroid/content/Context;->getPackageName()Ljava/lang/String;
    move-result-object v0
    sput-object v0, Lin/startv/hotstar/SignatureBypass;->originalPackageName:Ljava/lang/String;

    # Get current signatures via GET_SIGNATURES (0x40)
    invoke-virtual {p0}, Landroid/content/Context;->getPackageManager()Landroid/content/pm/PackageManager;
    move-result-object v1
    const/16 v2, 0x40
    invoke-virtual {v1, v0, v2}, Landroid/content/pm/PackageManager;->getPackageInfo(Ljava/lang/String;I)Landroid/content/pm/PackageInfo;
    move-result-object v3

    # Cache signatures
    iget-object v4, v3, Landroid/content/pm/PackageInfo;->signatures:[Landroid/content/pm/Signature;
    sput-object v4, Lin/startv/hotstar/SignatureBypass;->originalSignatures:[Landroid/content/pm/Signature;

    # Also try GET_SIGNING_CERTIFICATES (0x8000000) for API 28+
    :try_start_28
    const v2, 0x8000000
    invoke-virtual {v1, v0, v2}, Landroid/content/pm/PackageManager;->getPackageInfo(Ljava/lang/String;I)Landroid/content/pm/PackageInfo;
    move-result-object v3

    # Check signingInfo
    iget-object v4, v3, Landroid/content/pm/PackageInfo;->signingInfo:Landroid/content/pm/SigningInfo;
    if-eqz v4, :skip_signing_info

    invoke-virtual {v4}, Landroid/content/pm/SigningInfo;->getApkContentsSigners()[Landroid/content/pm/Signature;
    move-result-object v5
    if-eqz v5, :skip_signing_info
    array-length v4, v5
    if-lez v4, :skip_signing_info

    # Use these as the canonical original signatures
    sput-object v5, Lin/startv/hotstar/SignatureBypass;->originalSignatures:[Landroid/content/pm/Signature;

    :skip_signing_info
    :try_end_28
    .catch Ljava/lang/Exception; {:try_start_28 .. :try_end_28} :catch_28
    :catch_28

    # Install ApplicationPackageManager proxy
    invoke-static {p0}, Lin/startv/hotstar/SignatureBypass;->installProxy(Landroid/content/Context;)V

    const/4 v0, 0x1
    sput-boolean v0, Lin/startv/hotstar/SignatureBypass;->initialized:Z

    const-string v0, "HSPatch"
    const-string v1, "SignatureBypass: Initialized, original signatures cached"
    invoke-static {v0, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    :try_end
    .catch Ljava/lang/Exception; {:try_start .. :try_end} :catch_init
    goto :already_init

    :catch_init
    move-exception v0
    const-string v1, "HSPatch"
    new-instance v2, Ljava/lang/StringBuilder;
    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V
    const-string v3, "SignatureBypass init failed: "
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
# installProxy(Context) - Replace the IPackageManager in the
# PackageManager via reflection to intercept getPackageInfo calls
# Uses InvocationHandler proxy on IPackageManager
# ================================================================
.method public static installProxy(Landroid/content/Context;)V
    .locals 8

    :try_start_proxy
    # Get the real PackageManager
    invoke-virtual {p0}, Landroid/content/Context;->getPackageManager()Landroid/content/pm/PackageManager;
    move-result-object v0

    # Get the mPM field from ApplicationPackageManager
    invoke-virtual {v0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;
    move-result-object v1
    const-string v2, "mPM"
    invoke-virtual {v1, v2}, Ljava/lang/Class;->getDeclaredField(Ljava/lang/String;)Ljava/lang/reflect/Field;
    move-result-object v3
    const/4 v4, 0x1
    invoke-virtual {v3, v4}, Ljava/lang/reflect/Field;->setAccessible(Z)V

    # Get the real IPackageManager instance
    invoke-virtual {v3, v0}, Ljava/lang/reflect/Field;->get(Ljava/lang/Object;)Ljava/lang/Object;
    move-result-object v4

    # Create InvocationHandler
    new-instance v5, Lin/startv/hotstar/SignatureBypass$PMInvocationHandler;
    invoke-direct {v5, v4}, Lin/startv/hotstar/SignatureBypass$PMInvocationHandler;-><init>(Ljava/lang/Object;)V

    # Get IPackageManager interface class
    const-string v6, "android.content.pm.IPackageManager"
    invoke-static {v6}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;
    move-result-object v6

    # Create dynamic proxy
    invoke-virtual {v6}, Ljava/lang/Class;->getClassLoader()Ljava/lang/ClassLoader;
    move-result-object v7
    const/4 v2, 0x1
    new-array v2, v2, [Ljava/lang/Class;
    const/4 v1, 0x0
    aput-object v6, v2, v1
    invoke-static {v7, v2, v5}, Ljava/lang/reflect/Proxy;->newProxyInstance(Ljava/lang/ClassLoader;[Ljava/lang/Class;Ljava/lang/reflect/InvocationHandler;)Ljava/lang/Object;
    move-result-object v7

    # Replace mPM field
    invoke-virtual {v3, v0, v7}, Ljava/lang/reflect/Field;->set(Ljava/lang/Object;Ljava/lang/Object;)V

    # Also replace the sPackageManager in ActivityThread
    :try_start_at
    const-string v1, "android.app.ActivityThread"
    invoke-static {v1}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;
    move-result-object v1
    const-string v2, "sPackageManager"
    invoke-virtual {v1, v2}, Ljava/lang/Class;->getDeclaredField(Ljava/lang/String;)Ljava/lang/reflect/Field;
    move-result-object v2
    const/4 v3, 0x1
    invoke-virtual {v2, v3}, Ljava/lang/reflect/Field;->setAccessible(Z)V
    const/4 v3, 0x0
    invoke-virtual {v2, v3, v7}, Ljava/lang/reflect/Field;->set(Ljava/lang/Object;Ljava/lang/Object;)V
    :try_end_at
    .catch Ljava/lang/Exception; {:try_start_at .. :try_end_at} :catch_at
    :catch_at
    # Silently ignore if ActivityThread field not accessible

    const-string v0, "HSPatch"
    const-string v1, "SignatureBypass: IPackageManager proxy installed"
    invoke-static {v0, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    :try_end_proxy
    .catch Ljava/lang/Exception; {:try_start_proxy .. :try_end_proxy} :catch_proxy
    goto :done_proxy

    :catch_proxy
    move-exception v0
    const-string v1, "HSPatch"
    new-instance v2, Ljava/lang/StringBuilder;
    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V
    const-string v3, "SignatureBypass proxy install failed: "
    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;
    move-result-object v3
    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v2
    invoke-static {v1, v2}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    :done_proxy
    return-void
.end method


# ================================================================
# patchPackageInfo(PackageInfo) - Inject cached signatures into PI
# Called by the proxy handler after every getPackageInfo call
# ================================================================
.method public static patchPackageInfo(Landroid/content/pm/PackageInfo;)V
    .locals 3

    if-eqz p0, :done_patch

    # Check if this is our package
    iget-object v0, p0, Landroid/content/pm/PackageInfo;->packageName:Ljava/lang/String;
    sget-object v1, Lin/startv/hotstar/SignatureBypass;->originalPackageName:Ljava/lang/String;
    if-eqz v1, :done_patch
    if-eqz v0, :done_patch

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v2
    if-eqz v2, :done_patch

    # Patch signatures field
    sget-object v0, Lin/startv/hotstar/SignatureBypass;->originalSignatures:[Landroid/content/pm/Signature;
    if-eqz v0, :done_patch
    iput-object v0, p0, Landroid/content/pm/PackageInfo;->signatures:[Landroid/content/pm/Signature;

    # Also patch signingInfo if available (API 28+)
    :try_start_si
    iget-object v1, p0, Landroid/content/pm/PackageInfo;->signingInfo:Landroid/content/pm/SigningInfo;
    # signingInfo patching is handled by the Frida script at runtime
    :try_end_si
    .catch Ljava/lang/Exception; {:try_start_si .. :try_end_si} :catch_si
    :catch_si

    :done_patch
    return-void
.end method
