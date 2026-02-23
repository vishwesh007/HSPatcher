.class public Lin/startv/hotstar/HttpDumper;
.super Ljava/lang/Object;
.source "HttpDumper.java"

# ================================================================
# HttpDumper - Comprehensive HTTP request/response dumper
# Writes full headers, status codes, and metadata to http_dump.txt
# Captures ALL traffic intercepted by ResponseCache wrapper
# ================================================================

# static fields
.field private static dumpFile:Ljava/lang/String;
.field private static initialized:Z
.field private static requestId:I


# direct methods
.method public constructor <init>()V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    return-void
.end method


# ================================================================
# init(Context) - Initialize the dump file
# ================================================================
.method public static init(Landroid/content/Context;)V
    .locals 4
    .param p0, "ctx"

    sget-boolean v0, Lin/startv/hotstar/HttpDumper;->initialized:Z
    if-nez v0, :done

    :try_init
    # Get external files dir for dump file
    const/4 v0, 0x0
    invoke-virtual {p0, v0}, Landroid/content/Context;->getExternalFilesDir(Ljava/lang/String;)Ljava/io/File;
    move-result-object v0

    if-eqz v0, :use_fallback
    invoke-virtual {v0}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;
    move-result-object v0
    new-instance v1, Ljava/lang/StringBuilder;
    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v2, "/http_dump.txt"
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    goto :set_path

    :use_fallback
    const-string v0, "/storage/emulated/0/Download/hspatch_http_dump.txt"

    :set_path
    sput-object v0, Lin/startv/hotstar/HttpDumper;->dumpFile:Ljava/lang/String;

    # Ensure parent directory exists
    new-instance v1, Ljava/io/File;
    invoke-direct {v1, v0}, Ljava/io/File;-><init>(Ljava/lang/String;)V
    invoke-virtual {v1}, Ljava/io/File;->getParentFile()Ljava/io/File;
    move-result-object v1
    if-eqz v1, :dir_ok
    invoke-virtual {v1}, Ljava/io/File;->mkdirs()Z
    :dir_ok

    const/4 v1, 0x0
    sput v1, Lin/startv/hotstar/HttpDumper;->requestId:I

    # Write header
    new-instance v1, Ljava/lang/StringBuilder;
    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V
    const-string v2, "\u2550\u2550\u2550\u2550\u2550\u2550\u2550 HSPatch HTTP Dump \u2550\u2550\u2550\u2550\u2550\u2550\u2550\nStarted: "
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    new-instance v2, Ljava/util/Date;
    invoke-direct {v2}, Ljava/util/Date;-><init>()V
    invoke-virtual {v2}, Ljava/util/Date;->toString()Ljava/lang/String;
    move-result-object v2
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v2, "\nDump file: "
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v2, "\n\n"
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v1
    invoke-static {v1}, Lin/startv/hotstar/HttpDumper;->writeLine(Ljava/lang/String;)V

    const/4 v0, 0x1
    sput-boolean v0, Lin/startv/hotstar/HttpDumper;->initialized:Z

    const-string v0, "HSPatch-Net"
    new-instance v1, Ljava/lang/StringBuilder;
    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V
    const-string v2, "HttpDumper initialized: "
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    sget-object v2, Lin/startv/hotstar/HttpDumper;->dumpFile:Ljava/lang/String;
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v1
    invoke-static {v0, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    :try_init_end
    .catchall {:try_init .. :try_init_end} :catch_init
    goto :done
    :catch_init
    move-exception v0
    const-string v1, "HSPatch-Net"
    const-string v2, "HttpDumper init failed"
    invoke-static {v1, v2}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    :done
    return-void
.end method


# ================================================================
# writeLine(String) - append a line to the dump file
# ================================================================
.method private static writeLine(Ljava/lang/String;)V
    .locals 3
    .param p0, "line"

    :try_write
    sget-object v0, Lin/startv/hotstar/HttpDumper;->dumpFile:Ljava/lang/String;
    if-eqz v0, :skip

    new-instance v1, Ljava/io/FileWriter;
    const/4 v2, 0x1
    invoke-direct {v1, v0, v2}, Ljava/io/FileWriter;-><init>(Ljava/lang/String;Z)V

    invoke-virtual {v1, p0}, Ljava/io/Writer;->write(Ljava/lang/String;)V
    invoke-virtual {v1}, Ljava/io/Writer;->flush()V
    invoke-virtual {v1}, Ljava/io/Writer;->close()V

    :skip
    :try_write_end
    .catchall {:try_write .. :try_write_end} :catch_write
    goto :done
    :catch_write
    move-exception v0
    :done
    return-void
.end method


# ================================================================
# dumpRequest(String method, String url, Map<String, List<String>> headers)
# Writes full request details with all headers to dump file
# ================================================================
.method public static dumpRequest(Ljava/lang/String;Ljava/lang/String;Ljava/util/Map;)V
    .locals 5
    .param p0, "method"
    .param p1, "url"
    .param p2, "headers"

    :try_dump
    sget-boolean v0, Lin/startv/hotstar/HttpDumper;->initialized:Z
    if-eqz v0, :skip

    # Increment request ID
    sget v0, Lin/startv/hotstar/HttpDumper;->requestId:I
    add-int/lit8 v0, v0, 0x1
    sput v0, Lin/startv/hotstar/HttpDumper;->requestId:I

    # Timestamp
    new-instance v1, Ljava/text/SimpleDateFormat;
    const-string v2, "HH:mm:ss.SSS"
    invoke-direct {v1, v2}, Ljava/text/SimpleDateFormat;-><init>(Ljava/lang/String;)V
    new-instance v2, Ljava/util/Date;
    invoke-direct {v2}, Ljava/util/Date;-><init>()V
    invoke-virtual {v1, v2}, Ljava/text/SimpleDateFormat;->format(Ljava/util/Date;)Ljava/lang/String;
    move-result-object v1
    # v1 = timestamp

    # Build dump entry
    new-instance v2, Ljava/lang/StringBuilder;
    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "\n\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\n"
    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v3, ">>> REQUEST #"
    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v2, v0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    const-string v3, " ["
    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v2, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v3, "]\n"
    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v3, "\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\n"
    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v2, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v3, " "
    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v2, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v3, "\n"
    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    # Dump request headers
    if-eqz p2, :no_req_headers
    invoke-interface {p2}, Ljava/util/Map;->isEmpty()Z
    move-result v3
    if-nez v3, :no_req_headers

    const-string v3, "\nRequest Headers:\n"
    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-static {v2, p2}, Lin/startv/hotstar/HttpDumper;->dumpHeaders(Ljava/lang/StringBuilder;Ljava/util/Map;)V

    :no_req_headers
    # Write the request dump
    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v2
    invoke-static {v2}, Lin/startv/hotstar/HttpDumper;->writeLine(Ljava/lang/String;)V

    :skip
    :try_dump_end
    .catchall {:try_dump .. :try_dump_end} :catch_dump
    goto :done
    :catch_dump
    move-exception v0
    :done
    return-void
.end method


# ================================================================
# dumpResponse(String url, URLConnection conn)
# Gets status code and ALL headers from the URLConnection
# ================================================================
.method public static dumpResponse(Ljava/lang/String;Ljava/net/URLConnection;)V
    .locals 6
    .param p0, "url"
    .param p1, "conn"

    :try_dump
    sget-boolean v0, Lin/startv/hotstar/HttpDumper;->initialized:Z
    if-eqz v0, :skip

    # Build dump entry
    new-instance v0, Ljava/lang/StringBuilder;
    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    # Timestamp
    new-instance v1, Ljava/text/SimpleDateFormat;
    const-string v2, "HH:mm:ss.SSS"
    invoke-direct {v1, v2}, Ljava/text/SimpleDateFormat;-><init>(Ljava/lang/String;)V
    new-instance v2, Ljava/util/Date;
    invoke-direct {v2}, Ljava/util/Date;-><init>()V
    invoke-virtual {v1, v2}, Ljava/text/SimpleDateFormat;->format(Ljava/util/Date;)Ljava/lang/String;
    move-result-object v1
    # v1 = timestamp

    const-string v2, "\n<<< RESPONSE ["
    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v2, "] "
    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v2, "\n"
    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    # Try to get status code (only if HttpURLConnection)
    instance-of v1, p1, Ljava/net/HttpURLConnection;
    if-eqz v1, :no_status

    move-object v1, p1
    check-cast v1, Ljava/net/HttpURLConnection;

    invoke-virtual {v1}, Ljava/net/HttpURLConnection;->getResponseCode()I
    move-result v2

    const-string v3, "  Status: "
    invoke-virtual {v0, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/net/HttpURLConnection;->getResponseMessage()Ljava/lang/String;
    move-result-object v3
    if-eqz v3, :no_resp_msg
    const-string v4, " "
    invoke-virtual {v0, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    :no_resp_msg
    const-string v3, "\n"
    invoke-virtual {v0, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    # Get content type
    invoke-virtual {v1}, Ljava/net/HttpURLConnection;->getContentType()Ljava/lang/String;
    move-result-object v3
    if-eqz v3, :no_ctype_dump
    const-string v4, "  Content-Type: "
    invoke-virtual {v0, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v4, "\n"
    invoke-virtual {v0, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    :no_ctype_dump

    # Get content length
    invoke-virtual {v1}, Ljava/net/HttpURLConnection;->getContentLength()I
    move-result v3
    const/4 v4, -0x1
    if-eq v3, v4, :no_clen_dump
    const-string v4, "  Content-Length: "
    invoke-virtual {v0, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    const-string v4, "\n"
    invoke-virtual {v0, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    :no_clen_dump

    :no_status

    # Get ALL response headers from URLConnection
    invoke-virtual {p1}, Ljava/net/URLConnection;->getHeaderFields()Ljava/util/Map;
    move-result-object v1

    if-eqz v1, :no_headers_dump
    invoke-interface {v1}, Ljava/util/Map;->isEmpty()Z
    move-result v2
    if-nez v2, :no_headers_dump

    const-string v2, "\n  Response Headers:\n"
    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-static {v0, v1}, Lin/startv/hotstar/HttpDumper;->dumpHeaders(Ljava/lang/StringBuilder;Ljava/util/Map;)V
    :no_headers_dump

    const-string v1, "\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\n"
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    # Write the response dump
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    invoke-static {v0}, Lin/startv/hotstar/HttpDumper;->writeLine(Ljava/lang/String;)V

    :skip
    :try_dump_end
    .catchall {:try_dump .. :try_dump_end} :catch_dump
    goto :done
    :catch_dump
    move-exception v0
    :done
    return-void
.end method


# ================================================================
# dumpHeaders(StringBuilder sb, Map<String, List<String>> headers)
# Iterates through all header entries and appends them to StringBuilder
# ================================================================
.method private static dumpHeaders(Ljava/lang/StringBuilder;Ljava/util/Map;)V
    .locals 6
    .param p0, "sb"
    .param p1, "headers"

    if-eqz p1, :done
    invoke-interface {p1}, Ljava/util/Map;->isEmpty()Z
    move-result v0
    if-nez v0, :done

    # Get entrySet -> iterator
    invoke-interface {p1}, Ljava/util/Map;->entrySet()Ljava/util/Set;
    move-result-object v0
    invoke-interface {v0}, Ljava/util/Set;->iterator()Ljava/util/Iterator;
    move-result-object v0

    :loop
    invoke-interface {v0}, Ljava/util/Iterator;->hasNext()Z
    move-result v1
    if-eqz v1, :done

    invoke-interface {v0}, Ljava/util/Iterator;->next()Ljava/lang/Object;
    move-result-object v1
    check-cast v1, Ljava/util/Map$Entry;

    # Get key (may be null for HTTP status line)
    invoke-interface {v1}, Ljava/util/Map$Entry;->getKey()Ljava/lang/Object;
    move-result-object v2

    if-nez v2, :has_key
    const-string v2, "(status-line)"
    goto :key_ready
    :has_key
    check-cast v2, Ljava/lang/String;
    :key_ready

    # Get value (List<String>) -> toString
    invoke-interface {v1}, Ljava/util/Map$Entry;->getValue()Ljava/lang/Object;
    move-result-object v3
    if-eqz v3, :skip_entry
    invoke-virtual {v3}, Ljava/lang/Object;->toString()Ljava/lang/String;
    move-result-object v3

    # Append "    key: value\n"
    const-string v4, "    "
    invoke-virtual {p0, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {p0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v4, ": "
    invoke-virtual {p0, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {p0, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v4, "\n"
    invoke-virtual {p0, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    :skip_entry
    goto :loop

    :done
    return-void
.end method
