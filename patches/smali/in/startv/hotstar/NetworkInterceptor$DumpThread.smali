.class public Lin/startv/hotstar/NetworkInterceptor$DumpThread;
.super Ljava/lang/Object;
.source "NetworkInterceptor.java"

# interfaces
.implements Ljava/lang/Runnable;

# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lin/startv/hotstar/NetworkInterceptor;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "DumpThread"
.end annotation

# Periodically logs a summary of network activity + checks for common
# HTTP libraries loaded in the app's classloader.

# direct methods
.method public constructor <init>()V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    return-void
.end method

.method public run()V
    .locals 8

    # Wait 8 seconds for app to settle
    const-wide/16 v0, 0x1f40
    :try_sleep1
    invoke-static {v0, v1}, Ljava/lang/Thread;->sleep(J)V
    :try_sleep1_end
    .catch Ljava/lang/InterruptedException; {:try_sleep1 .. :try_sleep1_end} :catch_sleep1
    goto :after_sleep1
    :catch_sleep1
    move-exception v0
    :after_sleep1

    const-string v0, "HSPatch-Net"
    const-string v1, "=== Network Library Detection ==="
    invoke-static {v0, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    # Detect loaded HTTP libraries
    const/4 v7, 0x0

    # Check OkHttp3
    :try_ok3
    const-string v0, "okhttp3.OkHttpClient"
    invoke-static {v0}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;
    const-string v0, "HSPatch-Net"
    const-string v1, "  \u2705 OkHttp3 detected"
    invoke-static {v0, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    invoke-static {v1}, Lin/startv/hotstar/NetworkLogger;->log(Ljava/lang/String;)V
    add-int/lit8 v7, v7, 0x1
    :try_ok3_end
    .catch Ljava/lang/Throwable; {:try_ok3 .. :try_ok3_end} :catch_ok3
    goto :after_ok3
    :catch_ok3
    move-exception v0
    const-string v0, "HSPatch-Net"
    const-string v1, "  \u274c OkHttp3 not found"
    invoke-static {v0, v1}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I
    :after_ok3

    # Check OkHttp2
    :try_ok2
    const-string v0, "com.squareup.okhttp.OkHttpClient"
    invoke-static {v0}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;
    const-string v0, "HSPatch-Net"
    const-string v1, "  \u2705 OkHttp2 (legacy) detected"
    invoke-static {v0, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    invoke-static {v1}, Lin/startv/hotstar/NetworkLogger;->log(Ljava/lang/String;)V
    add-int/lit8 v7, v7, 0x1
    :try_ok2_end
    .catch Ljava/lang/Throwable; {:try_ok2 .. :try_ok2_end} :catch_ok2
    goto :after_ok2
    :catch_ok2
    move-exception v0
    :after_ok2

    # Check Retrofit2
    :try_retro2
    const-string v0, "retrofit2.Retrofit"
    invoke-static {v0}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;
    const-string v0, "HSPatch-Net"
    const-string v1, "  \u2705 Retrofit2 detected"
    invoke-static {v0, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    invoke-static {v1}, Lin/startv/hotstar/NetworkLogger;->log(Ljava/lang/String;)V
    add-int/lit8 v7, v7, 0x1
    :try_retro2_end
    .catch Ljava/lang/Throwable; {:try_retro2 .. :try_retro2_end} :catch_retro2
    goto :after_retro2
    :catch_retro2
    move-exception v0
    :after_retro2

    # Check Retrofit1
    :try_retro1
    const-string v0, "retrofit.RestAdapter"
    invoke-static {v0}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;
    const-string v0, "HSPatch-Net"
    const-string v1, "  \u2705 Retrofit1 (legacy) detected"
    invoke-static {v0, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    invoke-static {v1}, Lin/startv/hotstar/NetworkLogger;->log(Ljava/lang/String;)V
    add-int/lit8 v7, v7, 0x1
    :try_retro1_end
    .catch Ljava/lang/Throwable; {:try_retro1 .. :try_retro1_end} :catch_retro1
    goto :after_retro1
    :catch_retro1
    move-exception v0
    :after_retro1

    # Check Volley
    :try_volley
    const-string v0, "com.android.volley.RequestQueue"
    invoke-static {v0}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;
    const-string v0, "HSPatch-Net"
    const-string v1, "  \u2705 Volley detected"
    invoke-static {v0, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    invoke-static {v1}, Lin/startv/hotstar/NetworkLogger;->log(Ljava/lang/String;)V
    add-int/lit8 v7, v7, 0x1
    :try_volley_end
    .catch Ljava/lang/Throwable; {:try_volley .. :try_volley_end} :catch_volley
    goto :after_volley
    :catch_volley
    move-exception v0
    :after_volley

    # Check Ktor
    :try_ktor
    const-string v0, "io.ktor.client.HttpClient"
    invoke-static {v0}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;
    const-string v0, "HSPatch-Net"
    const-string v1, "  \u2705 Ktor detected"
    invoke-static {v0, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    invoke-static {v1}, Lin/startv/hotstar/NetworkLogger;->log(Ljava/lang/String;)V
    add-int/lit8 v7, v7, 0x1
    :try_ktor_end
    .catch Ljava/lang/Throwable; {:try_ktor .. :try_ktor_end} :catch_ktor
    goto :after_ktor
    :catch_ktor
    move-exception v0
    :after_ktor

    # Check Apache HttpClient (legacy)
    :try_apache
    const-string v0, "org.apache.http.impl.client.DefaultHttpClient"
    invoke-static {v0}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;
    const-string v0, "HSPatch-Net"
    const-string v1, "  \u2705 Apache HttpClient detected"
    invoke-static {v0, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    invoke-static {v1}, Lin/startv/hotstar/NetworkLogger;->log(Ljava/lang/String;)V
    add-int/lit8 v7, v7, 0x1
    :try_apache_end
    .catch Ljava/lang/Throwable; {:try_apache .. :try_apache_end} :catch_apache
    goto :after_apache
    :catch_apache
    move-exception v0
    :after_apache

    # Check Cronet
    :try_cronet
    const-string v0, "org.chromium.net.CronetEngine"
    invoke-static {v0}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;
    const-string v0, "HSPatch-Net"
    const-string v1, "  \u2705 Cronet detected"
    invoke-static {v0, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    invoke-static {v1}, Lin/startv/hotstar/NetworkLogger;->log(Ljava/lang/String;)V
    add-int/lit8 v7, v7, 0x1
    :try_cronet_end
    .catch Ljava/lang/Throwable; {:try_cronet .. :try_cronet_end} :catch_cronet
    goto :after_cronet
    :catch_cronet
    move-exception v0
    :after_cronet

    # Check Fuel (Kotlin HTTP)
    :try_fuel
    const-string v0, "com.github.kittinunf.fuel.Fuel"
    invoke-static {v0}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;
    const-string v0, "HSPatch-Net"
    const-string v1, "  \u2705 Fuel detected"
    invoke-static {v0, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    invoke-static {v1}, Lin/startv/hotstar/NetworkLogger;->log(Ljava/lang/String;)V
    add-int/lit8 v7, v7, 0x1
    :try_fuel_end
    .catch Ljava/lang/Throwable; {:try_fuel .. :try_fuel_end} :catch_fuel
    goto :after_fuel
    :catch_fuel
    move-exception v0
    :after_fuel

    # Summary
    new-instance v0, Ljava/lang/StringBuilder;
    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V
    const-string v1, "=== Detected "
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0, v7}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    const-string v1, " HTTP lib(s). ResponseCache+ProxySelector intercept ALL. ==="
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    const-string v1, "HSPatch-Net"
    invoke-static {v1, v0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    invoke-static {v0}, Lin/startv/hotstar/NetworkLogger;->log(Ljava/lang/String;)V

    return-void
.end method
