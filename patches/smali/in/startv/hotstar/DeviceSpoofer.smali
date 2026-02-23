.class public Lin/startv/hotstar/DeviceSpoofer;
.super Ljava/lang/Object;
.source "DeviceSpoofer.java"

# Static fields for cached spoofed values
.field public static spoofedAndroidId:Ljava/lang/String;
.field public static spoofedSerial:Ljava/lang/String;
.field public static spoofedFingerprint:Ljava/lang/String;
.field public static spoofedModel:Ljava/lang/String;
.field public static spoofedManufacturer:Ljava/lang/String;
.field public static spoofedBrand:Ljava/lang/String;
.field public static spoofedDevice:Ljava/lang/String;
.field public static spoofedProduct:Ljava/lang/String;
.field public static spoofedBoard:Ljava/lang/String;
.field public static spoofedHardware:Ljava/lang/String;
.field public static spoofedImei:Ljava/lang/String;
.field public static initialized:Z

.method public constructor <init>()V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    return-void
.end method

# Generate random hex string of given length
.method public static randomHex(I)Ljava/lang/String;
    .locals 5
    new-instance v0, Ljava/lang/StringBuilder;
    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V
    const-string v1, "0123456789abcdef"
    new-instance v2, Ljava/util/Random;
    invoke-direct {v2}, Ljava/util/Random;-><init>()V
    const/4 v3, 0x0
    :loop_rh
    if-ge v3, p0, :done_rh
    const/16 v4, 0x10
    invoke-virtual {v2, v4}, Ljava/util/Random;->nextInt(I)I
    move-result v4
    invoke-virtual {v1, v4}, Ljava/lang/String;->charAt(I)C
    move-result v4
    invoke-virtual {v0, v4}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;
    add-int/lit8 v3, v3, 0x1
    goto :loop_rh
    :done_rh
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    return-object v0
.end method

# Generate a random IMEI-like number (15 digits)
.method public static randomImei()Ljava/lang/String;
    .locals 5
    new-instance v0, Ljava/lang/StringBuilder;
    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V
    new-instance v1, Ljava/util/Random;
    invoke-direct {v1}, Ljava/util/Random;-><init>()V
    const/4 v2, 0x0
    :loop_ri
    const/16 v3, 0xf
    if-ge v2, v3, :done_ri
    const/16 v3, 0xa
    invoke-virtual {v1, v3}, Ljava/util/Random;->nextInt(I)I
    move-result v3
    invoke-virtual {v0, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    add-int/lit8 v2, v2, 0x1
    goto :loop_ri
    :done_ri
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    return-object v0
.end method

# Generate random Android ID (16 hex chars)
.method public static randomAndroidId()Ljava/lang/String;
    .locals 1
    const/16 v0, 0x10
    invoke-static {v0}, Lin/startv/hotstar/DeviceSpoofer;->randomHex(I)Ljava/lang/String;
    move-result-object v0
    return-object v0
.end method

# Generate random serial (8 chars alphanumeric uppercase)
.method public static randomSerial()Ljava/lang/String;
    .locals 5
    new-instance v0, Ljava/lang/StringBuilder;
    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V
    const-string v1, "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    new-instance v2, Ljava/util/Random;
    invoke-direct {v2}, Ljava/util/Random;-><init>()V
    const/4 v3, 0x0
    :loop_rs
    const/16 v4, 0x8
    if-ge v3, v4, :done_rs
    invoke-virtual {v1}, Ljava/lang/String;->length()I
    move-result v4
    invoke-virtual {v2, v4}, Ljava/util/Random;->nextInt(I)I
    move-result v4
    invoke-virtual {v1, v4}, Ljava/lang/String;->charAt(I)C
    move-result v4
    invoke-virtual {v0, v4}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;
    add-int/lit8 v3, v3, 0x1
    goto :loop_rs
    :done_rs
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    return-object v0
.end method

# Generate random model name
.method public static randomModel()Ljava/lang/String;
    .locals 4
    const/4 v0, 0x5
    new-array v0, v0, [Ljava/lang/String;
    const/4 v1, 0x0
    const-string v2, "SM-G998B"
    aput-object v2, v0, v1
    const/4 v1, 0x1
    const-string v2, "Pixel 7 Pro"
    aput-object v2, v0, v1
    const/4 v1, 0x2
    const-string v2, "SM-S908B"
    aput-object v2, v0, v1
    const/4 v1, 0x3
    const-string v2, "22021211RG"
    aput-object v2, v0, v1
    const/4 v1, 0x4
    const-string v2, "LE2127"
    aput-object v2, v0, v1
    new-instance v1, Ljava/util/Random;
    invoke-direct {v1}, Ljava/util/Random;-><init>()V
    array-length v2, v0
    invoke-virtual {v1, v2}, Ljava/util/Random;->nextInt(I)I
    move-result v2
    aget-object v3, v0, v2
    return-object v3
.end method

# Save all spoofed values to SharedPreferences
.method public static saveToPrefs(Landroid/content/Context;)V
    .locals 3
    const-string v0, "device_spoof"
    const/4 v1, 0x0
    invoke-virtual {p0, v0, v1}, Landroid/content/Context;->getSharedPreferences(Ljava/lang/String;I)Landroid/content/SharedPreferences;
    move-result-object v0
    invoke-interface {v0}, Landroid/content/SharedPreferences;->edit()Landroid/content/SharedPreferences$Editor;
    move-result-object v1

    const-string v2, "android_id"
    sget-object v0, Lin/startv/hotstar/DeviceSpoofer;->spoofedAndroidId:Ljava/lang/String;
    invoke-interface {v1, v2, v0}, Landroid/content/SharedPreferences$Editor;->putString(Ljava/lang/String;Ljava/lang/String;)Landroid/content/SharedPreferences$Editor;

    const-string v2, "serial"
    sget-object v0, Lin/startv/hotstar/DeviceSpoofer;->spoofedSerial:Ljava/lang/String;
    invoke-interface {v1, v2, v0}, Landroid/content/SharedPreferences$Editor;->putString(Ljava/lang/String;Ljava/lang/String;)Landroid/content/SharedPreferences$Editor;

    const-string v2, "fingerprint"
    sget-object v0, Lin/startv/hotstar/DeviceSpoofer;->spoofedFingerprint:Ljava/lang/String;
    invoke-interface {v1, v2, v0}, Landroid/content/SharedPreferences$Editor;->putString(Ljava/lang/String;Ljava/lang/String;)Landroid/content/SharedPreferences$Editor;

    const-string v2, "model"
    sget-object v0, Lin/startv/hotstar/DeviceSpoofer;->spoofedModel:Ljava/lang/String;
    invoke-interface {v1, v2, v0}, Landroid/content/SharedPreferences$Editor;->putString(Ljava/lang/String;Ljava/lang/String;)Landroid/content/SharedPreferences$Editor;

    const-string v2, "manufacturer"
    sget-object v0, Lin/startv/hotstar/DeviceSpoofer;->spoofedManufacturer:Ljava/lang/String;
    invoke-interface {v1, v2, v0}, Landroid/content/SharedPreferences$Editor;->putString(Ljava/lang/String;Ljava/lang/String;)Landroid/content/SharedPreferences$Editor;

    const-string v2, "brand"
    sget-object v0, Lin/startv/hotstar/DeviceSpoofer;->spoofedBrand:Ljava/lang/String;
    invoke-interface {v1, v2, v0}, Landroid/content/SharedPreferences$Editor;->putString(Ljava/lang/String;Ljava/lang/String;)Landroid/content/SharedPreferences$Editor;

    const-string v2, "device"
    sget-object v0, Lin/startv/hotstar/DeviceSpoofer;->spoofedDevice:Ljava/lang/String;
    invoke-interface {v1, v2, v0}, Landroid/content/SharedPreferences$Editor;->putString(Ljava/lang/String;Ljava/lang/String;)Landroid/content/SharedPreferences$Editor;

    const-string v2, "product"
    sget-object v0, Lin/startv/hotstar/DeviceSpoofer;->spoofedProduct:Ljava/lang/String;
    invoke-interface {v1, v2, v0}, Landroid/content/SharedPreferences$Editor;->putString(Ljava/lang/String;Ljava/lang/String;)Landroid/content/SharedPreferences$Editor;

    const-string v2, "board"
    sget-object v0, Lin/startv/hotstar/DeviceSpoofer;->spoofedBoard:Ljava/lang/String;
    invoke-interface {v1, v2, v0}, Landroid/content/SharedPreferences$Editor;->putString(Ljava/lang/String;Ljava/lang/String;)Landroid/content/SharedPreferences$Editor;

    const-string v2, "hardware"
    sget-object v0, Lin/startv/hotstar/DeviceSpoofer;->spoofedHardware:Ljava/lang/String;
    invoke-interface {v1, v2, v0}, Landroid/content/SharedPreferences$Editor;->putString(Ljava/lang/String;Ljava/lang/String;)Landroid/content/SharedPreferences$Editor;

    const-string v2, "imei"
    sget-object v0, Lin/startv/hotstar/DeviceSpoofer;->spoofedImei:Ljava/lang/String;
    invoke-interface {v1, v2, v0}, Landroid/content/SharedPreferences$Editor;->putString(Ljava/lang/String;Ljava/lang/String;)Landroid/content/SharedPreferences$Editor;

    invoke-interface {v1}, Landroid/content/SharedPreferences$Editor;->apply()V
    return-void
.end method

# Generate all new random values and save
.method public static resetFingerprint(Landroid/content/Context;)V
    .locals 2

    invoke-static {}, Lin/startv/hotstar/DeviceSpoofer;->randomAndroidId()Ljava/lang/String;
    move-result-object v0
    sput-object v0, Lin/startv/hotstar/DeviceSpoofer;->spoofedAndroidId:Ljava/lang/String;

    invoke-static {}, Lin/startv/hotstar/DeviceSpoofer;->randomSerial()Ljava/lang/String;
    move-result-object v0
    sput-object v0, Lin/startv/hotstar/DeviceSpoofer;->spoofedSerial:Ljava/lang/String;

    invoke-static {}, Lin/startv/hotstar/DeviceSpoofer;->randomImei()Ljava/lang/String;
    move-result-object v0
    sput-object v0, Lin/startv/hotstar/DeviceSpoofer;->spoofedImei:Ljava/lang/String;

    invoke-static {}, Lin/startv/hotstar/DeviceSpoofer;->randomModel()Ljava/lang/String;
    move-result-object v0
    sput-object v0, Lin/startv/hotstar/DeviceSpoofer;->spoofedModel:Ljava/lang/String;

    # Generate fingerprint from brand/model
    new-instance v0, Ljava/lang/StringBuilder;
    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V
    const-string v1, "google/raven/raven:13/TP1A."
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const/4 v1, 0x6
    invoke-static {v1}, Lin/startv/hotstar/DeviceSpoofer;->randomHex(I)Ljava/lang/String;
    move-result-object v1
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v1, "/release-keys"
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    sput-object v0, Lin/startv/hotstar/DeviceSpoofer;->spoofedFingerprint:Ljava/lang/String;

    const-string v0, "Google"
    sput-object v0, Lin/startv/hotstar/DeviceSpoofer;->spoofedManufacturer:Ljava/lang/String;
    const-string v0, "google"
    sput-object v0, Lin/startv/hotstar/DeviceSpoofer;->spoofedBrand:Ljava/lang/String;
    const-string v0, "raven"
    sput-object v0, Lin/startv/hotstar/DeviceSpoofer;->spoofedDevice:Ljava/lang/String;
    const-string v0, "raven"
    sput-object v0, Lin/startv/hotstar/DeviceSpoofer;->spoofedProduct:Ljava/lang/String;
    const-string v0, "raven"
    sput-object v0, Lin/startv/hotstar/DeviceSpoofer;->spoofedBoard:Ljava/lang/String;
    const-string v0, "raven"
    sput-object v0, Lin/startv/hotstar/DeviceSpoofer;->spoofedHardware:Ljava/lang/String;

    invoke-static {p0}, Lin/startv/hotstar/DeviceSpoofer;->saveToPrefs(Landroid/content/Context;)V

    const/4 v0, 0x1
    sput-boolean v0, Lin/startv/hotstar/DeviceSpoofer;->initialized:Z

    return-void
.end method

# Initialize: load from prefs or generate new
.method public static init(Landroid/content/Context;)V
    .locals 4

    sget-boolean v0, Lin/startv/hotstar/DeviceSpoofer;->initialized:Z
    if-eqz v0, :not_init
    return-void
    :not_init

    const-string v0, "device_spoof"
    const/4 v1, 0x0
    invoke-virtual {p0, v0, v1}, Landroid/content/Context;->getSharedPreferences(Ljava/lang/String;I)Landroid/content/SharedPreferences;
    move-result-object v0

    const-string v1, "android_id"
    const/4 v2, 0x0
    invoke-interface {v0, v1, v2}, Landroid/content/SharedPreferences;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v1

    if-nez v1, :load_existing

    # First time - check if auto-reset is enabled
    sget-boolean v1, Lin/startv/hotstar/HSPatchConfig;->autoResetFingerprint:Z
    if-eqz v1, :skip_first_reset

    # Auto-reset enabled: generate new fingerprint
    invoke-static {p0}, Lin/startv/hotstar/DeviceSpoofer;->resetFingerprint(Landroid/content/Context;)V

    const-string v1, "HSPatch"
    const-string v2, "DeviceSpoofer: First run, auto-reset fingerprint generated"
    invoke-static {v1, v2}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    return-void

    :skip_first_reset
    # Auto-reset disabled: skip fingerprint generation, mark initialized
    const/4 v0, 0x1
    sput-boolean v0, Lin/startv/hotstar/DeviceSpoofer;->initialized:Z

    const-string v1, "HSPatch"
    const-string v2, "DeviceSpoofer: First run, auto-reset DISABLED - skipping fingerprint generation"
    invoke-static {v1, v2}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    return-void

    :load_existing
    # Load all from prefs
    sput-object v1, Lin/startv/hotstar/DeviceSpoofer;->spoofedAndroidId:Ljava/lang/String;

    const-string v1, "serial"
    invoke-interface {v0, v1, v2}, Landroid/content/SharedPreferences;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v1
    sput-object v1, Lin/startv/hotstar/DeviceSpoofer;->spoofedSerial:Ljava/lang/String;

    const-string v1, "fingerprint"
    invoke-interface {v0, v1, v2}, Landroid/content/SharedPreferences;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v1
    sput-object v1, Lin/startv/hotstar/DeviceSpoofer;->spoofedFingerprint:Ljava/lang/String;

    const-string v1, "model"
    invoke-interface {v0, v1, v2}, Landroid/content/SharedPreferences;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v1
    sput-object v1, Lin/startv/hotstar/DeviceSpoofer;->spoofedModel:Ljava/lang/String;

    const-string v1, "manufacturer"
    invoke-interface {v0, v1, v2}, Landroid/content/SharedPreferences;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v1
    sput-object v1, Lin/startv/hotstar/DeviceSpoofer;->spoofedManufacturer:Ljava/lang/String;

    const-string v1, "brand"
    invoke-interface {v0, v1, v2}, Landroid/content/SharedPreferences;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v1
    sput-object v1, Lin/startv/hotstar/DeviceSpoofer;->spoofedBrand:Ljava/lang/String;

    const-string v1, "device"
    invoke-interface {v0, v1, v2}, Landroid/content/SharedPreferences;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v1
    sput-object v1, Lin/startv/hotstar/DeviceSpoofer;->spoofedDevice:Ljava/lang/String;

    const-string v1, "product"
    invoke-interface {v0, v1, v2}, Landroid/content/SharedPreferences;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v1
    sput-object v1, Lin/startv/hotstar/DeviceSpoofer;->spoofedProduct:Ljava/lang/String;

    const-string v1, "board"
    invoke-interface {v0, v1, v2}, Landroid/content/SharedPreferences;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v1
    sput-object v1, Lin/startv/hotstar/DeviceSpoofer;->spoofedBoard:Ljava/lang/String;

    const-string v1, "hardware"
    invoke-interface {v0, v1, v2}, Landroid/content/SharedPreferences;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v1
    sput-object v1, Lin/startv/hotstar/DeviceSpoofer;->spoofedHardware:Ljava/lang/String;

    const-string v1, "imei"
    invoke-interface {v0, v1, v2}, Landroid/content/SharedPreferences;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v1
    sput-object v1, Lin/startv/hotstar/DeviceSpoofer;->spoofedImei:Ljava/lang/String;

    # Apply Build field overrides
    invoke-static {}, Lin/startv/hotstar/DeviceSpoofer;->applyBuildOverrides()V

    const/4 v0, 0x1
    sput-boolean v0, Lin/startv/hotstar/DeviceSpoofer;->initialized:Z

    return-void
.end method

# Override Build.* static fields via reflection
.method public static applyBuildOverrides()V
    .locals 4

    :try_start_abo
    const-class v0, Landroid/os/Build;

    # SERIAL
    const-string v1, "SERIAL"
    invoke-virtual {v0, v1}, Ljava/lang/Class;->getDeclaredField(Ljava/lang/String;)Ljava/lang/reflect/Field;
    move-result-object v1
    const/4 v2, 0x1
    invoke-virtual {v1, v2}, Ljava/lang/reflect/Field;->setAccessible(Z)V
    sget-object v3, Lin/startv/hotstar/DeviceSpoofer;->spoofedSerial:Ljava/lang/String;
    const/4 v2, 0x0
    invoke-virtual {v1, v2, v3}, Ljava/lang/reflect/Field;->set(Ljava/lang/Object;Ljava/lang/Object;)V

    # FINGERPRINT
    const-string v1, "FINGERPRINT"
    invoke-virtual {v0, v1}, Ljava/lang/Class;->getDeclaredField(Ljava/lang/String;)Ljava/lang/reflect/Field;
    move-result-object v1
    const/4 v2, 0x1
    invoke-virtual {v1, v2}, Ljava/lang/reflect/Field;->setAccessible(Z)V
    sget-object v3, Lin/startv/hotstar/DeviceSpoofer;->spoofedFingerprint:Ljava/lang/String;
    const/4 v2, 0x0
    invoke-virtual {v1, v2, v3}, Ljava/lang/reflect/Field;->set(Ljava/lang/Object;Ljava/lang/Object;)V

    # MODEL
    const-string v1, "MODEL"
    invoke-virtual {v0, v1}, Ljava/lang/Class;->getDeclaredField(Ljava/lang/String;)Ljava/lang/reflect/Field;
    move-result-object v1
    const/4 v2, 0x1
    invoke-virtual {v1, v2}, Ljava/lang/reflect/Field;->setAccessible(Z)V
    sget-object v3, Lin/startv/hotstar/DeviceSpoofer;->spoofedModel:Ljava/lang/String;
    const/4 v2, 0x0
    invoke-virtual {v1, v2, v3}, Ljava/lang/reflect/Field;->set(Ljava/lang/Object;Ljava/lang/Object;)V

    # MANUFACTURER
    const-string v1, "MANUFACTURER"
    invoke-virtual {v0, v1}, Ljava/lang/Class;->getDeclaredField(Ljava/lang/String;)Ljava/lang/reflect/Field;
    move-result-object v1
    const/4 v2, 0x1
    invoke-virtual {v1, v2}, Ljava/lang/reflect/Field;->setAccessible(Z)V
    sget-object v3, Lin/startv/hotstar/DeviceSpoofer;->spoofedManufacturer:Ljava/lang/String;
    const/4 v2, 0x0
    invoke-virtual {v1, v2, v3}, Ljava/lang/reflect/Field;->set(Ljava/lang/Object;Ljava/lang/Object;)V

    # BRAND
    const-string v1, "BRAND"
    invoke-virtual {v0, v1}, Ljava/lang/Class;->getDeclaredField(Ljava/lang/String;)Ljava/lang/reflect/Field;
    move-result-object v1
    const/4 v2, 0x1
    invoke-virtual {v1, v2}, Ljava/lang/reflect/Field;->setAccessible(Z)V
    sget-object v3, Lin/startv/hotstar/DeviceSpoofer;->spoofedBrand:Ljava/lang/String;
    const/4 v2, 0x0
    invoke-virtual {v1, v2, v3}, Ljava/lang/reflect/Field;->set(Ljava/lang/Object;Ljava/lang/Object;)V

    # DEVICE
    const-string v1, "DEVICE"
    invoke-virtual {v0, v1}, Ljava/lang/Class;->getDeclaredField(Ljava/lang/String;)Ljava/lang/reflect/Field;
    move-result-object v1
    const/4 v2, 0x1
    invoke-virtual {v1, v2}, Ljava/lang/reflect/Field;->setAccessible(Z)V
    sget-object v3, Lin/startv/hotstar/DeviceSpoofer;->spoofedDevice:Ljava/lang/String;
    const/4 v2, 0x0
    invoke-virtual {v1, v2, v3}, Ljava/lang/reflect/Field;->set(Ljava/lang/Object;Ljava/lang/Object;)V

    # PRODUCT
    const-string v1, "PRODUCT"
    invoke-virtual {v0, v1}, Ljava/lang/Class;->getDeclaredField(Ljava/lang/String;)Ljava/lang/reflect/Field;
    move-result-object v1
    const/4 v2, 0x1
    invoke-virtual {v1, v2}, Ljava/lang/reflect/Field;->setAccessible(Z)V
    sget-object v3, Lin/startv/hotstar/DeviceSpoofer;->spoofedProduct:Ljava/lang/String;
    const/4 v2, 0x0
    invoke-virtual {v1, v2, v3}, Ljava/lang/reflect/Field;->set(Ljava/lang/Object;Ljava/lang/Object;)V

    # BOARD
    const-string v1, "BOARD"
    invoke-virtual {v0, v1}, Ljava/lang/Class;->getDeclaredField(Ljava/lang/String;)Ljava/lang/reflect/Field;
    move-result-object v1
    const/4 v2, 0x1
    invoke-virtual {v1, v2}, Ljava/lang/reflect/Field;->setAccessible(Z)V
    sget-object v3, Lin/startv/hotstar/DeviceSpoofer;->spoofedBoard:Ljava/lang/String;
    const/4 v2, 0x0
    invoke-virtual {v1, v2, v3}, Ljava/lang/reflect/Field;->set(Ljava/lang/Object;Ljava/lang/Object;)V

    # HARDWARE
    const-string v1, "HARDWARE"
    invoke-virtual {v0, v1}, Ljava/lang/Class;->getDeclaredField(Ljava/lang/String;)Ljava/lang/reflect/Field;
    move-result-object v1
    const/4 v2, 0x1
    invoke-virtual {v1, v2}, Ljava/lang/reflect/Field;->setAccessible(Z)V
    sget-object v3, Lin/startv/hotstar/DeviceSpoofer;->spoofedHardware:Ljava/lang/String;
    const/4 v2, 0x0
    invoke-virtual {v1, v2, v3}, Ljava/lang/reflect/Field;->set(Ljava/lang/Object;Ljava/lang/Object;)V

    :try_end_abo
    .catch Ljava/lang/Exception; {:try_start_abo .. :try_end_abo} :catch_abo
    :catch_abo
    # Silently ignore reflection failures on newer Android
    return-void
.end method

# Hook for Settings.Secure.getString to return spoofed android_id
# Call this from wherever the app reads ANDROID_ID
.method public static getSecureString(Landroid/content/ContentResolver;Ljava/lang/String;)Ljava/lang/String;
    .locals 1
    const-string v0, "android_id"
    invoke-virtual {p1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v0
    if-eqz v0, :original_ss
    sget-object v0, Lin/startv/hotstar/DeviceSpoofer;->spoofedAndroidId:Ljava/lang/String;
    if-eqz v0, :original_ss
    return-object v0
    :original_ss
    invoke-static {p0, p1}, Landroid/provider/Settings$Secure;->getString(Landroid/content/ContentResolver;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v0
    return-object v0
.end method

# Hook for TelephonyManager.getDeviceId() — returns spoofed IMEI
.method public static getSpoofedDeviceId()Ljava/lang/String;
    .locals 1
    sget-object v0, Lin/startv/hotstar/DeviceSpoofer;->spoofedImei:Ljava/lang/String;
    if-nez v0, :ret_ds
    const-string v0, "000000000000000"
    :ret_ds
    return-object v0
.end method

# Get the android_id for direct usage
.method public static getAndroidId()Ljava/lang/String;
    .locals 1
    sget-object v0, Lin/startv/hotstar/DeviceSpoofer;->spoofedAndroidId:Ljava/lang/String;
    if-nez v0, :ret_ai
    const-string v0, "0000000000000000"
    :ret_ai
    return-object v0
.end method
