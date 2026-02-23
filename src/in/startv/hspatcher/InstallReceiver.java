package in.startv.hspatcher;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageInstaller;
import android.util.Log;
import android.widget.Toast;

/**
 * BroadcastReceiver for PackageInstaller session API callbacks.
 * Required on Android 14+ where PendingIntent.getActivity() no longer works
 * reliably for install session commits.
 */
public class InstallReceiver extends BroadcastReceiver {

    private static final String TAG = "HSPatcher-Install";

    @Override
    public void onReceive(Context context, Intent intent) {
        if (intent == null) return;

        int status = intent.getIntExtra(PackageInstaller.EXTRA_STATUS,
            PackageInstaller.STATUS_FAILURE);
        String message = intent.getStringExtra(PackageInstaller.EXTRA_STATUS_MESSAGE);

        Log.d(TAG, "Install status: " + status + " msg: " + message);

        switch (status) {
            case PackageInstaller.STATUS_PENDING_USER_ACTION:
                // System needs user confirmation — launch the install prompt
                Intent confirmIntent = intent.getParcelableExtra(Intent.EXTRA_INTENT);
                if (confirmIntent != null) {
                    confirmIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                    try {
                        context.startActivity(confirmIntent);
                        Log.d(TAG, "Install confirmation dialog launched");
                    } catch (Exception e) {
                        Log.e(TAG, "Failed to launch install confirmation: " + e.getMessage());
                        Toast.makeText(context,
                            "Failed to show install prompt: " + e.getMessage(),
                            Toast.LENGTH_LONG).show();
                    }
                }
                break;

            case PackageInstaller.STATUS_SUCCESS:
                Log.d(TAG, "Installation successful!");
                Toast.makeText(context, "✅ Installation successful!",
                    Toast.LENGTH_SHORT).show();
                break;

            case PackageInstaller.STATUS_FAILURE:
            case PackageInstaller.STATUS_FAILURE_ABORTED:
            case PackageInstaller.STATUS_FAILURE_BLOCKED:
            case PackageInstaller.STATUS_FAILURE_CONFLICT:
            case PackageInstaller.STATUS_FAILURE_INCOMPATIBLE:
            case PackageInstaller.STATUS_FAILURE_INVALID:
            case PackageInstaller.STATUS_FAILURE_STORAGE:
                String errorMsg = message != null ? message : "Unknown error (status " + status + ")";
                Log.e(TAG, "Installation failed: " + errorMsg);
                Toast.makeText(context, "❌ Install failed: " + errorMsg,
                    Toast.LENGTH_LONG).show();
                break;
        }
    }
}
