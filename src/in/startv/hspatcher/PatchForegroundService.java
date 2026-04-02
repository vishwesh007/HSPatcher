package in.startv.hspatcher;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ServiceInfo;
import android.os.Build;
import android.os.IBinder;
import android.os.PowerManager;

public class PatchForegroundService extends Service {

    private static final String CHANNEL_ID = "hspatcher_patch";
    private static final int NOTIFICATION_ID = 3601;
    private static final String ACTION_START = "in.startv.hspatcher.action.PATCH_START";
    private static final String ACTION_UPDATE = "in.startv.hspatcher.action.PATCH_UPDATE";
    private static final String ACTION_STOP = "in.startv.hspatcher.action.PATCH_STOP";
    private static final String EXTRA_TARGET = "target";
    private static final String EXTRA_PROGRESS = "progress";
    private static final String EXTRA_STEP = "step";

    private NotificationManager notificationManager;
    private PowerManager.WakeLock wakeLock;
    private String targetLabel = "Selected APK";
    private String patchStep = "Starting";
    private int patchProgress = 0;

    public static void start(Context context, String target, int progress, String step) {
        Intent intent = new Intent(context, PatchForegroundService.class);
        intent.setAction(ACTION_START);
        intent.putExtra(EXTRA_TARGET, target);
        intent.putExtra(EXTRA_PROGRESS, progress);
        intent.putExtra(EXTRA_STEP, step);
        if (Build.VERSION.SDK_INT >= 26) {
            context.startForegroundService(intent);
        } else {
            context.startService(intent);
        }
    }

    public static void update(Context context, String target, int progress, String step) {
        Intent intent = new Intent(context, PatchForegroundService.class);
        intent.setAction(ACTION_UPDATE);
        intent.putExtra(EXTRA_TARGET, target);
        intent.putExtra(EXTRA_PROGRESS, progress);
        intent.putExtra(EXTRA_STEP, step);
        context.startService(intent);
    }

    public static void stop(Context context) {
        Intent intent = new Intent(context, PatchForegroundService.class);
        intent.setAction(ACTION_STOP);
        context.startService(intent);
    }

    @Override
    public void onCreate() {
        super.onCreate();
        notificationManager = (NotificationManager) getSystemService(NOTIFICATION_SERVICE);
        createChannel();
        acquireWakeLock();
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        String action = intent != null ? intent.getAction() : ACTION_UPDATE;
        if (intent != null) {
            String nextTarget = intent.getStringExtra(EXTRA_TARGET);
            String nextStep = intent.getStringExtra(EXTRA_STEP);
            if (nextTarget != null && !nextTarget.trim().isEmpty()) {
                targetLabel = nextTarget.trim();
            }
            if (nextStep != null && !nextStep.trim().isEmpty()) {
                patchStep = nextStep.trim();
            }
            patchProgress = Math.max(0, Math.min(100, intent.getIntExtra(EXTRA_PROGRESS, patchProgress)));
        }

        if (ACTION_STOP.equals(action)) {
            stopForeground(true);
            stopSelf();
            return START_NOT_STICKY;
        }

        Notification notification = buildNotification();
        if (ACTION_START.equals(action)) {
            if (Build.VERSION.SDK_INT >= 29) {
                startForeground(NOTIFICATION_ID, notification,
                    ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC);
            } else {
                startForeground(NOTIFICATION_ID, notification);
            }
        } else if (notificationManager != null) {
            notificationManager.notify(NOTIFICATION_ID, notification);
        }
        return START_NOT_STICKY;
    }

    @Override
    public void onDestroy() {
        releaseWakeLock();
        super.onDestroy();
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    private void createChannel() {
        if (notificationManager == null || Build.VERSION.SDK_INT < 26) return;
        NotificationChannel channel = new NotificationChannel(
            CHANNEL_ID,
            "Patch progress",
            NotificationManager.IMPORTANCE_LOW);
        channel.setDescription("Keeps HSPatcher alive while patching runs.");
        channel.setShowBadge(false);
        notificationManager.createNotificationChannel(channel);
    }

    private void acquireWakeLock() {
        try {
            PowerManager powerManager = (PowerManager) getSystemService(POWER_SERVICE);
            if (powerManager == null) return;
            wakeLock = powerManager.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK,
                "HSPatcher:PatchWakeLock");
            wakeLock.setReferenceCounted(false);
            wakeLock.acquire();
        } catch (Throwable ignored) {
        }
    }

    private void releaseWakeLock() {
        try {
            if (wakeLock != null && wakeLock.isHeld()) {
                wakeLock.release();
            }
        } catch (Throwable ignored) {
        }
        wakeLock = null;
    }

    private Notification buildNotification() {
        Intent activityIntent = new Intent(this, MainActivity.class);
        activityIntent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_SINGLE_TOP);
        PendingIntent contentIntent = PendingIntent.getActivity(
            this,
            0,
            activityIntent,
            Build.VERSION.SDK_INT >= 23
                ? PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
                : PendingIntent.FLAG_UPDATE_CURRENT);

        String title = "Patching " + targetLabel;
        String text = patchStep + " (" + patchProgress + "%)";

        Notification.Builder builder = Build.VERSION.SDK_INT >= 26
            ? new Notification.Builder(this, CHANNEL_ID)
            : new Notification.Builder(this);

        builder.setContentTitle(title)
            .setContentText(text)
            .setSmallIcon(android.R.drawable.stat_sys_download)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setContentIntent(contentIntent)
            .setCategory(Notification.CATEGORY_PROGRESS)
            .setProgress(100, patchProgress, false);

        if (Build.VERSION.SDK_INT >= 21) {
            builder.setColor(0xFF00E676).setVisibility(Notification.VISIBILITY_PUBLIC);
        }

        return builder.build();
    }
}