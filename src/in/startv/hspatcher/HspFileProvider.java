package in.startv.hspatcher;

import android.content.ContentProvider;
import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.MatrixCursor;
import android.net.Uri;
import android.os.ParcelFileDescriptor;
import android.provider.OpenableColumns;
import android.util.Log;

import java.io.File;
import java.io.FileNotFoundException;

/**
 * FileProvider to serve APK files via content:// URIs for package installation.
 * Required on Android 7+ where file:// URIs are blocked by StrictMode.
 * 
 * CRITICAL: The query() method MUST return proper OpenableColumns metadata
 * (DISPLAY_NAME and SIZE) or the system package installer will silently refuse
 * to process the APK on many OEMs (especially Xiaomi/Samsung/OPPO).
 */
public class HspFileProvider extends ContentProvider {

    private static final String TAG = "HspFileProvider";
    private static final String AUTHORITY = "in.startv.hspatcher.provider";

    /**
     * Build a content:// URI for the given file.
     */
    public static Uri getUriForFile(Context context, File file) {
        return new Uri.Builder()
            .scheme("content")
            .authority(AUTHORITY)
            .path(file.getAbsolutePath())
            .build();
    }

    @Override
    public boolean onCreate() {
        return true;
    }

    @Override
    public ParcelFileDescriptor openFile(Uri uri, String mode) throws FileNotFoundException {
        File file = resolveFile(uri);
        Log.d(TAG, "openFile: " + file.getAbsolutePath() + " (" + file.length() + " bytes)");
        return ParcelFileDescriptor.open(file, ParcelFileDescriptor.MODE_READ_ONLY);
    }

    @Override
    public String getType(Uri uri) {
        return "application/vnd.android.package-archive";
    }

    /**
     * Returns file metadata required by the system package installer.
     * Without proper DISPLAY_NAME and SIZE, installation silently fails on many devices.
     */
    @Override
    public Cursor query(Uri uri, String[] projection, String selection,
                        String[] selectionArgs, String sortOrder) {
        File file;
        try {
            file = resolveFile(uri);
        } catch (FileNotFoundException e) {
            Log.e(TAG, "query: file not found for URI: " + uri);
            return null;
        }

        // Default projection if none specified
        if (projection == null) {
            projection = new String[] {
                OpenableColumns.DISPLAY_NAME,
                OpenableColumns.SIZE
            };
        }

        MatrixCursor cursor = new MatrixCursor(projection, 1);
        Object[] row = new Object[projection.length];
        for (int i = 0; i < projection.length; i++) {
            if (OpenableColumns.DISPLAY_NAME.equals(projection[i])) {
                row[i] = file.getName();
            } else if (OpenableColumns.SIZE.equals(projection[i])) {
                row[i] = file.length();
            } else {
                row[i] = null;
            }
        }
        cursor.addRow(row);
        Log.d(TAG, "query: " + file.getName() + " (" + file.length() + " bytes)");
        return cursor;
    }

    @Override
    public Uri insert(Uri uri, ContentValues values) {
        return null;
    }

    @Override
    public int delete(Uri uri, String selection, String[] selectionArgs) {
        return 0;
    }

    @Override
    public int update(Uri uri, ContentValues values, String selection,
                      String[] selectionArgs) {
        return 0;
    }

    /**
     * Resolve the file from the content URI path.
     * Security: only serves .apk files.
     */
    private File resolveFile(Uri uri) throws FileNotFoundException {
        String path = uri.getPath();
        if (path == null) {
            throw new FileNotFoundException("No path in URI: " + uri);
        }
        File file = new File(path);
        if (!file.getName().toLowerCase().endsWith(".apk")) {
            throw new FileNotFoundException("Only APK files can be served: " + path);
        }
        if (!file.exists()) {
            throw new FileNotFoundException("File not found: " + path);
        }
        return file;
    }
}
