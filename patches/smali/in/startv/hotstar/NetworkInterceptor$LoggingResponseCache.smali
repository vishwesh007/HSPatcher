.class public Lin/startv/hotstar/NetworkInterceptor$LoggingResponseCache;
.super Ljava/net/ResponseCache;
.source "NetworkInterceptor.java"

# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lin/startv/hotstar/NetworkInterceptor;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "LoggingResponseCache"
.end annotation

# This ResponseCache wrapper intercepts EVERY HttpURLConnection request.
# java.net.ResponseCache.get() is called before any HTTP connection is made,
# giving us visibility into ALL URLs accessed via HttpURLConnection, OkHttp
# (which uses HttpURLConnection internally in some versions), Volley, Cronet,
# and any custom HTTP client that uses java.net.URL.openConnection().

# instance fields
.field private original:Ljava/net/ResponseCache;
.field private reqCount:I

# direct methods
.method public constructor <init>(Ljava/net/ResponseCache;)V
    .locals 1
    .param p1, "original"

    invoke-direct {p0}, Ljava/net/ResponseCache;-><init>()V
    iput-object p1, p0, Lin/startv/hotstar/NetworkInterceptor$LoggingResponseCache;->original:Ljava/net/ResponseCache;
    const/4 v0, 0x0
    iput v0, p0, Lin/startv/hotstar/NetworkInterceptor$LoggingResponseCache;->reqCount:I
    return-void
.end method

# ========================================================================
# get() — called by HttpURLConnection before making a request.
# We log the URI and request method, then delegate to original cache.
# ========================================================================
.method public get(Ljava/net/URI;Ljava/lang/String;Ljava/util/Map;)Ljava/net/CacheResponse;
    .locals 5
    .param p1, "uri"
    .param p2, "requestMethod"
    .param p3, "requestHeaders"

    # Increment request counter
    iget v0, p0, Lin/startv/hotstar/NetworkInterceptor$LoggingResponseCache;->reqCount:I
    add-int/lit8 v0, v0, 0x1
    iput v0, p0, Lin/startv/hotstar/NetworkInterceptor$LoggingResponseCache;->reqCount:I

    # Log this request
    :try_log
    invoke-virtual {p1}, Ljava/net/URI;->toString()Ljava/lang/String;
    move-result-object v1

    # Extract just the method — p2 is the request method string (GET, POST, etc.)
    if-nez p2, :has_method
    const-string p2, "GET"
    :has_method

    # Log via NetworkInterceptor.logEvent
    const-string v2, "URLConn"
    invoke-static {p2, v1, v2}, Lin/startv/hotstar/NetworkInterceptor;->logEvent(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V

    # Dump full request with headers to http_dump.txt
    :try_dump_req
    invoke-static {p2, v1, p3}, Lin/startv/hotstar/HttpDumper;->dumpRequest(Ljava/lang/String;Ljava/lang/String;Ljava/util/Map;)V
    :try_dump_req_end
    .catch Ljava/lang/Throwable; {:try_dump_req .. :try_dump_req_end} :catch_dump_req
    goto :after_dump_req
    :catch_dump_req
    move-exception v2
    :after_dump_req

    # Also extract and log request headers if present
    if-eqz p3, :skip_headers
    invoke-interface {p3}, Ljava/util/Map;->size()I
    move-result v2
    if-lez v2, :skip_headers

    # Log header count
    new-instance v3, Ljava/lang/StringBuilder;
    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V
    const-string v4, "    Headers: "
    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v3, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    const-string v4, " entries"
    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v3
    const-string v4, "HSPatch-Net"
    invoke-static {v4, v3}, Landroid/util/Log;->v(Ljava/lang/String;Ljava/lang/String;)I
    :skip_headers

    :try_log_end
    .catch Ljava/lang/Throwable; {:try_log .. :try_log_end} :catch_log
    goto :after_log
    :catch_log
    move-exception v0
    :after_log

    # Delegate to original cache (or return null if no original)
    iget-object v0, p0, Lin/startv/hotstar/NetworkInterceptor$LoggingResponseCache;->original:Ljava/net/ResponseCache;
    if-eqz v0, :no_original
    invoke-virtual {v0, p1, p2, p3}, Ljava/net/ResponseCache;->get(Ljava/net/URI;Ljava/lang/String;Ljava/util/Map;)Ljava/net/CacheResponse;
    move-result-object v0
    return-object v0

    :no_original
    const/4 v0, 0x0
    return-object v0
.end method

# ========================================================================
# put() — called after receiving a response. Log the response too.
# ========================================================================
.method public put(Ljava/net/URI;Ljava/net/URLConnection;)Ljava/net/CacheRequest;
    .locals 5
    .param p1, "uri"
    .param p2, "conn"

    :try_log
    # Log the response
    invoke-virtual {p1}, Ljava/net/URI;->toString()Ljava/lang/String;
    move-result-object v0

    # Dump full response with headers to http_dump.txt
    :try_dump_resp
    invoke-static {v0, p2}, Lin/startv/hotstar/HttpDumper;->dumpResponse(Ljava/lang/String;Ljava/net/URLConnection;)V
    :try_dump_resp_end
    .catch Ljava/lang/Throwable; {:try_dump_resp .. :try_dump_resp_end} :catch_dump_resp
    goto :after_dump_resp
    :catch_dump_resp
    move-exception v1
    :after_dump_resp

    # Try to get the response code
    instance-of v1, p2, Ljava/net/HttpURLConnection;
    if-eqz v1, :no_code
    check-cast p2, Ljava/net/HttpURLConnection;
    invoke-virtual {p2}, Ljava/net/HttpURLConnection;->getResponseCode()I
    move-result v1

    new-instance v2, Ljava/lang/StringBuilder;
    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V
    const-string v3, "[URLConn] Response "
    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v2, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    const-string v3, " <- "
    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v2, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v2

    # Try to get content type
    invoke-virtual {p2}, Ljava/net/HttpURLConnection;->getContentType()Ljava/lang/String;
    move-result-object v3
    if-eqz v3, :no_ctype
    new-instance v4, Ljava/lang/StringBuilder;
    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V
    invoke-virtual {v4, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v2, " ("
    invoke-virtual {v4, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v4, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v2, ")"
    invoke-virtual {v4, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v2
    :no_ctype

    const-string v3, "HSPatch-Net"
    invoke-static {v3, v2}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    invoke-static {v2}, Lin/startv/hotstar/NetworkLogger;->log(Ljava/lang/String;)V

    :no_code
    :try_log_end
    .catch Ljava/lang/Throwable; {:try_log .. :try_log_end} :catch_log
    goto :after_log
    :catch_log
    move-exception v0
    :after_log

    # Delegate to original
    iget-object v0, p0, Lin/startv/hotstar/NetworkInterceptor$LoggingResponseCache;->original:Ljava/net/ResponseCache;
    if-eqz v0, :no_orig
    invoke-virtual {v0, p1, p2}, Ljava/net/ResponseCache;->put(Ljava/net/URI;Ljava/net/URLConnection;)Ljava/net/CacheRequest;
    move-result-object v0
    return-object v0

    :no_orig
    const/4 v0, 0x0
    return-object v0
.end method
