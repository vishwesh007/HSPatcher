.class public Lin/startv/hotstar/SSLBypass$AllHostnames;
.super Ljava/lang/Object;
.source "SSLBypass.java"

# interfaces
.implements Ljavax/net/ssl/HostnameVerifier;

# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lin/startv/hotstar/SSLBypass;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "AllHostnames"
.end annotation


# direct methods
.method public constructor <init>()V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    return-void
.end method


# virtual methods
.method public verify(Ljava/lang/String;Ljavax/net/ssl/SSLSession;)Z
    .locals 1
    # Always return true - accept all hostnames
    const/4 v0, 0x1
    return v0
.end method
