.class public Lbin/mt/signature/SignatureCreator;
.super Ljava/lang/Object;
.implements Landroid/os/Parcelable$Creator;

# Custom Parcelable.Creator<PackageInfo> that replaces signatures
# with the original (pre-patching) signature data.
# Part of ApkSignatureKillerEx integration.

.annotation system Ldalvik/annotation/Signature;
    value = {
        "Ljava/lang/Object;",
        "Landroid/os/Parcelable$Creator<",
        "Landroid/content/pm/PackageInfo;",
        ">;"
    }
.end annotation


# ===== Fields =====

.field private final originalCreator:Landroid/os/Parcelable$Creator;

.field private final packageName:Ljava/lang/String;

.field private final fakeSignature:Landroid/content/pm/Signature;


# ===== Constructor =====

.method public constructor <init>(Landroid/os/Parcelable$Creator;Ljava/lang/String;Landroid/content/pm/Signature;)V
    .locals 0
    .param p1, "originalCreator"
    .param p2, "packageName"
    .param p3, "fakeSignature"

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lbin/mt/signature/SignatureCreator;->originalCreator:Landroid/os/Parcelable$Creator;
    iput-object p2, p0, Lbin/mt/signature/SignatureCreator;->packageName:Ljava/lang/String;
    iput-object p3, p0, Lbin/mt/signature/SignatureCreator;->fakeSignature:Landroid/content/pm/Signature;
    return-void
.end method


# ===== createFromParcel (actual impl) =====

.method public createFromParcel(Landroid/os/Parcel;)Landroid/content/pm/PackageInfo;
    .locals 5
    .param p1, "source"

    # Call original creator
    iget-object v0, p0, Lbin/mt/signature/SignatureCreator;->originalCreator:Landroid/os/Parcelable$Creator;
    invoke-interface {v0, p1}, Landroid/os/Parcelable$Creator;->createFromParcel(Landroid/os/Parcel;)Ljava/lang/Object;
    move-result-object v0
    check-cast v0, Landroid/content/pm/PackageInfo;
    # v0 = PackageInfo

    # Check if this is our target package
    iget-object v1, v0, Landroid/content/pm/PackageInfo;->packageName:Ljava/lang/String;
    iget-object v2, p0, Lbin/mt/signature/SignatureCreator;->packageName:Ljava/lang/String;
    invoke-virtual {v2, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-eqz v1, :skip_replace

    # Replace signatures[0]
    iget-object v1, v0, Landroid/content/pm/PackageInfo;->signatures:[Landroid/content/pm/Signature;
    if-eqz v1, :check_signing_info
    array-length v2, v1
    if-lez v2, :check_signing_info
    iget-object v2, p0, Lbin/mt/signature/SignatureCreator;->fakeSignature:Landroid/content/pm/Signature;
    const/4 v3, 0x0
    aput-object v2, v1, v3

    :check_signing_info
    # Replace signingInfo signatures (Android P+, API 28)
    const/16 v1, 0x1c
    invoke-static {}, Landroid/os/Build$VERSION;->SDK_INT:I
    # Can't call SDK_INT as method; use sget instead
    sget v2, Landroid/os/Build$VERSION;->SDK_INT:I
    if-lt v2, v1, :skip_replace

    iget-object v1, v0, Landroid/content/pm/PackageInfo;->signingInfo:Landroid/content/pm/SigningInfo;
    if-eqz v1, :skip_replace

    :try_signing_info
    invoke-virtual {v1}, Landroid/content/pm/SigningInfo;->getApkContentsSigners()[Landroid/content/pm/Signature;
    move-result-object v2
    if-eqz v2, :skip_replace
    array-length v3, v2
    if-lez v3, :skip_replace
    iget-object v3, p0, Lbin/mt/signature/SignatureCreator;->fakeSignature:Landroid/content/pm/Signature;
    const/4 v4, 0x0
    aput-object v3, v2, v4
    :try_signing_info_end
    .catch Ljava/lang/Throwable; {:try_signing_info .. :try_signing_info_end} :catch_signing_info
    goto :skip_replace
    :catch_signing_info
    move-exception v2

    :skip_replace
    return-object v0
.end method


# ===== createFromParcel bridge (generic erasure) =====

.method public bridge synthetic createFromParcel(Landroid/os/Parcel;)Ljava/lang/Object;
    .locals 1
    .param p1, "source"

    invoke-virtual {p0, p1}, Lbin/mt/signature/SignatureCreator;->createFromParcel(Landroid/os/Parcel;)Landroid/content/pm/PackageInfo;
    move-result-object v0
    return-object v0
.end method


# ===== newArray (actual impl) =====

.method public newArray(I)[Landroid/content/pm/PackageInfo;
    .locals 1
    .param p1, "size"

    iget-object v0, p0, Lbin/mt/signature/SignatureCreator;->originalCreator:Landroid/os/Parcelable$Creator;
    invoke-interface {v0, p1}, Landroid/os/Parcelable$Creator;->newArray(I)[Ljava/lang/Object;
    move-result-object v0
    check-cast v0, [Landroid/content/pm/PackageInfo;
    return-object v0
.end method


# ===== newArray bridge (generic erasure) =====

.method public bridge synthetic newArray(I)[Ljava/lang/Object;
    .locals 1
    .param p1, "size"

    invoke-virtual {p0, p1}, Lbin/mt/signature/SignatureCreator;->newArray(I)[Landroid/content/pm/PackageInfo;
    move-result-object v0
    return-object v0
.end method
