package in.startv.hspatcher;

import android.content.ContentProvider;
import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.net.Uri;
import android.os.ParcelFileDescriptor;

import java.io.File;
import java.io.FileNotFoundException;

/**
 * Minimal FileProvider to serve APK files via content:// URIs.
 * Required on Android 7+ where file:// URIs are blocked by StrictMode.
 * Only serves .apk files for security.
 */
public class HspFileProvider extends ContentProvider {

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
        String path = uri.getPath();
        if (path == null) {
            throw new FileNotFoundException("No path in URI");
        }
        File file = new File(path);
        // Security: only serve APK files
        if (!file.getName().toLowerCase().endsWith(".apk")) {
            throw new FileNotFoundException("Only APK files can be served: " + path);
        }
        if (!file.exists()) {
            throw new FileNotFoundException("File not found: " + path);
        }
        return ParcelFileDescriptor.open(file, ParcelFileDescriptor.MODE_READ_ONLY);
    }

    @Override
    public String getType(Uri uri) {
        return "application/vnd.android.package-archive";
    }

    @Override
    public Cursor query(Uri uri, String[] projection, String selection,
                        String[] selectionArgs, String sortOrder) {
        return null;
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
}
