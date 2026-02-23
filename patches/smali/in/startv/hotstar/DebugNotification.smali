.class public Lin/startv/hotstar/DebugNotification;
.super Ljava/lang/Object;
.source "DebugNotification.java"


# static fields
.field private static final CHANNEL_ID:Ljava/lang/String; = "hspatch_debug"
.field private static final NOTIFICATION_ID:I = 0x4853


# direct methods
.method public constructor <init>()V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    return-void
.end method

# Show a DISMISSABLE notification with app name that opens DebugPanelActivity
.method public static show(Landroid/content/Context;)V
    .locals 8

    :try_start
    # ====== Get app label for notification title ======
    invoke-virtual {p0}, Landroid/content/Context;->getApplicationInfo()Landroid/content/pm/ApplicationInfo;
    move-result-object v6

    invoke-virtual {p0}, Landroid/content/Context;->getPackageManager()Landroid/content/pm/PackageManager;
    move-result-object v7

    invoke-virtual {v6, v7}, Landroid/content/pm/ApplicationInfo;->loadLabel(Landroid/content/pm/PackageManager;)Ljava/lang/CharSequence;
    move-result-object v6
    invoke-interface {v6}, Ljava/lang/CharSequence;->toString()Ljava/lang/String;
    move-result-object v6

    # Build title: "🔧 <AppName> Debug Panel"
    new-instance v7, Ljava/lang/StringBuilder;
    invoke-direct {v7}, Ljava/lang/StringBuilder;-><init>()V
    const-string v0, "\ud83d\udd27 "
    invoke-virtual {v7, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v7, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v0, " Debug Panel"
    invoke-virtual {v7, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v7}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v6

    # ====== Step 1: Create NotificationChannel (Android O+) ======
    sget v0, Landroid/os/Build$VERSION;->SDK_INT:I
    const/16 v1, 0x1a    # 26 = Android O

    if-lt v0, v1, :skip_channel

    # Create channel
    new-instance v2, Landroid/app/NotificationChannel;
    const-string v3, "hspatch_debug"
    const-string v4, "HSPatch Debug"
    const/4 v5, 0x2    # IMPORTANCE_LOW (no sound)
    invoke-direct {v2, v3, v4, v5}, Landroid/app/NotificationChannel;-><init>(Ljava/lang/String;Ljava/lang/CharSequence;I)V

    # Set description
    const-string v3, "Debug panel notification for HSPatch modules"
    invoke-virtual {v2, v3}, Landroid/app/NotificationChannel;->setDescription(Ljava/lang/String;)V

    # Register channel with NotificationManager
    const-string v3, "notification"
    invoke-virtual {p0, v3}, Landroid/content/Context;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;
    move-result-object v3
    check-cast v3, Landroid/app/NotificationManager;
    invoke-virtual {v3, v2}, Landroid/app/NotificationManager;->createNotificationChannel(Landroid/app/NotificationChannel;)V

    :skip_channel

    # ====== Step 2: Create PendingIntent for DebugPanelActivity ======
    new-instance v2, Landroid/content/Intent;
    const-class v3, Lin/startv/hotstar/DebugPanelActivity;
    invoke-direct {v2, p0, v3}, Landroid/content/Intent;-><init>(Landroid/content/Context;Ljava/lang/Class;)V

    # Set flags
    const/high16 v3, 0x10000000    # FLAG_ACTIVITY_NEW_TASK
    invoke-virtual {v2, v3}, Landroid/content/Intent;->setFlags(I)Landroid/content/Intent;

    # Create PendingIntent
    const/4 v3, 0x0    # requestCode
    const/high16 v4, 0x4000000    # FLAG_IMMUTABLE
    # Add FLAG_UPDATE_CURRENT
    const v5, 0x8000000    # FLAG_UPDATE_CURRENT
    or-int/2addr v4, v5
    invoke-static {p0, v3, v2, v4}, Landroid/app/PendingIntent;->getActivity(Landroid/content/Context;ILandroid/content/Intent;I)Landroid/app/PendingIntent;
    move-result-object v2

    # ====== Step 3: Build the Notification (DISMISSABLE) ======
    new-instance v3, Landroid/app/Notification$Builder;

    # Check if we need channel (Android O+)
    if-lt v0, v1, :no_channel_builder

    const-string v4, "hspatch_debug"
    invoke-direct {v3, p0, v4}, Landroid/app/Notification$Builder;-><init>(Landroid/content/Context;Ljava/lang/String;)V
    goto :builder_done

    :no_channel_builder
    invoke-direct {v3, p0}, Landroid/app/Notification$Builder;-><init>(Landroid/content/Context;)V

    :builder_done

    # Set small icon
    const v4, 0x01080034
    invoke-virtual {v3, v4}, Landroid/app/Notification$Builder;->setSmallIcon(I)Landroid/app/Notification$Builder;

    # Set title — dynamic "<AppName> Debug Panel"
    invoke-virtual {v3, v6}, Landroid/app/Notification$Builder;->setContentTitle(Ljava/lang/CharSequence;)Landroid/app/Notification$Builder;

    # Set text
    const-string v4, "Tap to open \u2022 Logs \u2022 Rules \u2022 Network"
    invoke-virtual {v3, v4}, Landroid/app/Notification$Builder;->setContentText(Ljava/lang/CharSequence;)Landroid/app/Notification$Builder;

    # NOT ongoing — DISMISSABLE
    const/4 v4, 0x0
    invoke-virtual {v3, v4}, Landroid/app/Notification$Builder;->setOngoing(Z)Landroid/app/Notification$Builder;

    # Auto-cancel: dismiss on tap
    const/4 v4, 0x1
    invoke-virtual {v3, v4}, Landroid/app/Notification$Builder;->setAutoCancel(Z)Landroid/app/Notification$Builder;

    # Set content intent
    invoke-virtual {v3, v2}, Landroid/app/Notification$Builder;->setContentIntent(Landroid/app/PendingIntent;)Landroid/app/Notification$Builder;

    # Set priority LOW
    const/4 v4, -0x1    # PRIORITY_LOW
    invoke-virtual {v3, v4}, Landroid/app/Notification$Builder;->setPriority(I)Landroid/app/Notification$Builder;

    # Build notification
    invoke-virtual {v3}, Landroid/app/Notification$Builder;->build()Landroid/app/Notification;
    move-result-object v3

    # ====== Step 4: Show the Notification ======
    const-string v4, "notification"
    invoke-virtual {p0, v4}, Landroid/content/Context;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;
    move-result-object v4
    check-cast v4, Landroid/app/NotificationManager;

    const/16 v5, 0x4853    # NOTIFICATION_ID = 18515 ("HS")
    invoke-virtual {v4, v5, v3}, Landroid/app/NotificationManager;->notify(ILandroid/app/Notification;)V

    # Log
    const-string v4, "HSPatch"
    const-string v5, "Debug notification shown (dismissable) - tap to open Debug Panel"
    invoke-static {v4, v5}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    :try_end
    .catchall {:try_start .. :try_end} :catch_block

    goto :after

    :catch_block
    move-exception v0

    # Log error
    const-string v1, "HSPatch"
    const-string v2, "Failed to show debug notification"
    invoke-static {v1, v2}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    :after
    return-void
.end method
