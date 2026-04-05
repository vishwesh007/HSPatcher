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
import android.webkit.MimeTypeMap;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.Locale;

/**
 * FileProvider to serve APKs and in-app workspace files via content:// URIs.
 * Required on Android 7+ where file:// URIs are blocked by StrictMode.
 */
public class HspFileProvider extends ContentProvider {

    private static final String TAG = "HspFileProvider";

    /**
     * Build a content:// URI for the given file.
     */
    public static Uri getUriForFile(Context context, File file) {
        return new Uri.Builder()
            .scheme("content")
            .authority(getAuthority(context))
            .path(file.getAbsolutePath())
            .build();
    }

    public static String getTypeForFile(File file) {
        if (file == null) {
            return "application/octet-stream";
        }

        String name = file.getName().toLowerCase(Locale.US);
        if (name.endsWith(".apk")) {
            return "application/vnd.android.package-archive";
        }

        String extension = MimeTypeMap.getFileExtensionFromUrl(file.getName());
        if (extension != null && !extension.isEmpty()) {
            String mime = MimeTypeMap.getSingleton().getMimeTypeFromExtension(extension.toLowerCase(Locale.US));
            if (mime != null && !mime.isEmpty()) {
                return mime;
            }
        }

        if (name.endsWith(".smali") || name.endsWith(".xml") || name.endsWith(".json")
                || name.endsWith(".txt") || name.endsWith(".md") || name.endsWith(".cfg")
                || name.endsWith(".conf") || name.endsWith(".ini") || name.endsWith(".gradle")
                || name.endsWith(".java") || name.endsWith(".kt") || name.endsWith(".js")
                || name.endsWith(".css") || name.endsWith(".html") || name.endsWith(".properties")
                || name.endsWith(".yml") || name.endsWith(".yaml") || name.endsWith(".csv")
                || name.endsWith(".log")) {
            return "text/plain";
        }

        return "application/octet-stream";
    }

    private static String getAuthority(Context context) {
        return context.getPackageName() + ".provider";
    }

    @Override
    public boolean onCreate() {
        return true;
    }

    @Override
    public ParcelFileDescriptor openFile(Uri uri, String mode) throws FileNotFoundException {
        File file = resolveFile(uri);
        String resolvedMode = mode == null || mode.trim().isEmpty() ? "r" : mode;
        Log.d(TAG, "openFile: " + file.getAbsolutePath() + " mode=" + resolvedMode + " (" + file.length() + " bytes)");
        return ParcelFileDescriptor.open(file, ParcelFileDescriptor.parseMode(resolvedMode));
    }

    @Override
    public String getType(Uri uri) {
        try {
            return getTypeForFile(resolveFile(uri));
        } catch (FileNotFoundException e) {
            Log.e(TAG, "getType: file not found for URI: " + uri, e);
            return "application/octet-stream";
        }
    }

    /**
     * Returns file metadata required by package installer and external editors.
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

    private File resolveFile(Uri uri) throws FileNotFoundException {
        String path = uri.getPath();
        if (path == null) {
            throw new FileNotFoundException("No path in URI: " + uri);
        }
        File file = new File(path);
        if (!file.exists()) {
            throw new FileNotFoundException("File not found: " + path);
        }
        if (!isAllowedFile(file)) {
            throw new FileNotFoundException("File is outside the allowed HSPatcher sandbox: " + path);
        }
        return file;
    }

    private boolean isAllowedFile(File file) throws FileNotFoundException {
        Context context = getContext();
        if (context == null) {
            throw new FileNotFoundException("Provider context is unavailable");
        }

        try {
            String targetPath = file.getCanonicalPath();
            return isUnderRoot(targetPath, context.getFilesDir())
                || isUnderRoot(targetPath, context.getCacheDir())
                || isUnderRoot(targetPath, context.getExternalFilesDir(null))
                || isUnderRoot(targetPath, context.getExternalCacheDir());
        } catch (IOException e) {
            throw new FileNotFoundException("Could not resolve file path: " + e.getMessage());
        }
    }

    private boolean isUnderRoot(String targetPath, File root) throws IOException {
        if (root == null) {
            return false;
        }
        String rootPath = root.getCanonicalPath();
        return targetPath.equals(rootPath) || targetPath.startsWith(rootPath + File.separator);
    }
}
