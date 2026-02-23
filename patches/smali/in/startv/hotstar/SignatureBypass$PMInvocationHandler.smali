.class public Lin/startv/hotstar/SignatureBypass$PMInvocationHandler;
.super Ljava/lang/Object;
.source "SignatureBypass.java"

.implements Ljava/lang/reflect/InvocationHandler;

# instance fields
.field public realPM:Ljava/lang/Object;

.method public constructor <init>(Ljava/lang/Object;)V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lin/startv/hotstar/SignatureBypass$PMInvocationHandler;->realPM:Ljava/lang/Object;
    return-void
.end method

# InvocationHandler.invoke(Object proxy, Method method, Object[] args)
.method public invoke(Ljava/lang/Object;Ljava/lang/reflect/Method;[Ljava/lang/Object;)Ljava/lang/Object;
    .locals 5

    :try_start_invoke
    # Forward the call to real PM
    iget-object v0, p0, Lin/startv/hotstar/SignatureBypass$PMInvocationHandler;->realPM:Ljava/lang/Object;
    invoke-virtual {p2, v0, p3}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;
    move-result-object v1

    # Check if this is getPackageInfo
    invoke-virtual {p2}, Ljava/lang/reflect/Method;->getName()Ljava/lang/String;
    move-result-object v2
    const-string v3, "getPackageInfo"
    invoke-virtual {v2, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v3
    if-eqz v3, :return_result

    # It's getPackageInfo - patch the result
    instance-of v3, v1, Landroid/content/pm/PackageInfo;
    if-eqz v3, :return_result

    check-cast v1, Landroid/content/pm/PackageInfo;
    invoke-static {v1}, Lin/startv/hotstar/SignatureBypass;->patchPackageInfo(Landroid/content/pm/PackageInfo;)V

    :return_result
    return-object v1

    :try_end_invoke
    .catch Ljava/lang/reflect/InvocationTargetException; {:try_start_invoke .. :try_end_invoke} :catch_ite
    .catch Ljava/lang/Exception; {:try_start_invoke .. :try_end_invoke} :catch_ex

    :catch_ite
    move-exception v0
    # Re-throw the actual target exception
    invoke-virtual {v0}, Ljava/lang/reflect/InvocationTargetException;->getTargetException()Ljava/lang/Throwable;
    move-result-object v1
    throw v1

    :catch_ex
    move-exception v0
    # Forward other calls normally
    iget-object v1, p0, Lin/startv/hotstar/SignatureBypass$PMInvocationHandler;->realPM:Ljava/lang/Object;
    invoke-virtual {p2, v1, p3}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;
    move-result-object v2
    return-object v2
.end method
