.class public Lin/startv/hotstar/NetworkInterceptor$LoggingProxySelector;
.super Ljava/net/ProxySelector;
.source "NetworkInterceptor.java"

# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lin/startv/hotstar/NetworkInterceptor;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "LoggingProxySelector"
.end annotation

# This wraps the system ProxySelector to intercept ALL socket connections.
# ProxySelector.select(URI) is called before ANY socket is opened, including
# HTTP, HTTPS, WebSocket, raw TCP, etc. This gives us the most universal
# view of network activity.

# instance fields
.field private original:Ljava/net/ProxySelector;
.field private seen:Ljava/util/Set;

# direct methods
.method public constructor <init>(Ljava/net/ProxySelector;)V
    .locals 2
    .param p1, "original"

    invoke-direct {p0}, Ljava/net/ProxySelector;-><init>()V
    iput-object p1, p0, Lin/startv/hotstar/NetworkInterceptor$LoggingProxySelector;->original:Ljava/net/ProxySelector;

    # Use ConcurrentHashMap-backed set for thread safety
    new-instance v0, Ljava/util/concurrent/ConcurrentHashMap;
    invoke-direct {v0}, Ljava/util/concurrent/ConcurrentHashMap;-><init>()V
    invoke-static {v0}, Ljava/util/Collections;->newSetFromMap(Ljava/util/Map;)Ljava/util/Set;
    move-result-object v0
    iput-object v0, p0, Lin/startv/hotstar/NetworkInterceptor$LoggingProxySelector;->seen:Ljava/util/Set;
    return-void
.end method

# ========================================================================
# select() — called before every socket connection
# ========================================================================
.method public select(Ljava/net/URI;)Ljava/util/List;
    .locals 7
    .param p1, "uri"

    :try_log
    if-eqz p1, :skip_log

    invoke-virtual {p1}, Ljava/net/URI;->toString()Ljava/lang/String;
    move-result-object v0

    # Deduplicate: only log first occurrence of each host
    invoke-virtual {p1}, Ljava/net/URI;->getHost()Ljava/lang/String;
    move-result-object v1
    if-eqz v1, :log_it

    # Build a dedup key: scheme + host
    new-instance v2, Ljava/lang/StringBuilder;
    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V
    invoke-virtual {p1}, Ljava/net/URI;->getScheme()Ljava/lang/String;
    move-result-object v3
    if-eqz v3, :no_scheme
    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v3, "://"
    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    :no_scheme
    invoke-virtual {v2, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v2

    # Apply UrlHook rules to socket host key before dedup/logging
    const-string v6, "UTF-8"
    invoke-static {v2, v6}, Lin/startv/hotstar/UrlHook;->decodeAndPatch(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v2

    # Check if we've seen this host before (log anyway for first time)
    iget-object v3, p0, Lin/startv/hotstar/NetworkInterceptor$LoggingProxySelector;->seen:Ljava/util/Set;
    invoke-interface {v3, v2}, Ljava/util/Set;->contains(Ljava/lang/Object;)Z
    move-result v4
    if-nez v4, :skip_dedup_log

    # New host — add to seen set and log
    invoke-interface {v3, v2}, Ljava/util/Set;->add(Ljava/lang/Object;)Z

    new-instance v3, Ljava/lang/StringBuilder;
    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V
    const-string v4, "[Socket] NEW HOST: "
    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v3, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v3
    const-string v4, "HSPatch-Net"
    invoke-static {v4, v3}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    invoke-static {v3}, Lin/startv/hotstar/NetworkLogger;->log(Ljava/lang/String;)V

    :skip_dedup_log
    :log_it
    # Always log full URI to verbose logcat (not file, to avoid flooding)
    const-string v3, "HSPatch-Net"
    new-instance v4, Ljava/lang/StringBuilder;
    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V
    const-string v5, "[Socket] → "
    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v4, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v4
    invoke-static {v3, v4}, Landroid/util/Log;->v(Ljava/lang/String;Ljava/lang/String;)I

    :skip_log
    :try_log_end
    .catch Ljava/lang/Throwable; {:try_log .. :try_log_end} :catch_log
    goto :after_log
    :catch_log
    move-exception v0
    :after_log

    # Delegate to original ProxySelector
    iget-object v0, p0, Lin/startv/hotstar/NetworkInterceptor$LoggingProxySelector;->original:Ljava/net/ProxySelector;
    if-eqz v0, :no_orig
    invoke-virtual {v0, p1}, Ljava/net/ProxySelector;->select(Ljava/net/URI;)Ljava/util/List;
    move-result-object v0
    return-object v0

    :no_orig
    # Return a list with DIRECT proxy (no proxy)
    sget-object v0, Ljava/net/Proxy;->NO_PROXY:Ljava/net/Proxy;
    invoke-static {v0}, Ljava/util/Collections;->singletonList(Ljava/lang/Object;)Ljava/util/List;
    move-result-object v0
    return-object v0
.end method

# ========================================================================
# connectFailed() — mandatory override
# ========================================================================
.method public connectFailed(Ljava/net/URI;Ljava/net/SocketAddress;Ljava/io/IOException;)V
    .locals 4
    .param p1, "uri"
    .param p2, "sa"
    .param p3, "ioe"

    :try_log
    new-instance v0, Ljava/lang/StringBuilder;
    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V
    const-string v1, "[Socket] FAIL: "
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {p1}, Ljava/net/URI;->toString()Ljava/lang/String;
    move-result-object v1
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v1, " → "
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {p3}, Ljava/io/IOException;->getMessage()Ljava/lang/String;
    move-result-object v1
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    const-string v1, "HSPatch-Net"
    invoke-static {v1, v0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I
    invoke-static {v0}, Lin/startv/hotstar/NetworkLogger;->log(Ljava/lang/String;)V
    :try_log_end
    .catch Ljava/lang/Throwable; {:try_log .. :try_log_end} :catch_log
    goto :after_log
    :catch_log
    move-exception v0
    :after_log

    # Delegate
    iget-object v0, p0, Lin/startv/hotstar/NetworkInterceptor$LoggingProxySelector;->original:Ljava/net/ProxySelector;
    if-eqz v0, :no_orig
    invoke-virtual {v0, p1, p2, p3}, Ljava/net/ProxySelector;->connectFailed(Ljava/net/URI;Ljava/net/SocketAddress;Ljava/io/IOException;)V
    :no_orig
    return-void
.end method
