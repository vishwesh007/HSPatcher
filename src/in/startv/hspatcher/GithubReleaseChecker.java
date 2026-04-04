package in.startv.hspatcher;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Intent;
import android.content.SharedPreferences;
import android.net.Uri;
import android.widget.Toast;

import org.json.JSONArray;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

final class GithubReleaseChecker {

    private static final String PREFS_NAME = "github_release_checker";
    private static final String KEY_LAST_CHECK_MS = "last_check_ms";
    private static final long AUTO_CHECK_INTERVAL_MS = 12L * 60L * 60L * 1000L;
    private static final Pattern DIGIT_GROUP = Pattern.compile("\\d+");

    private GithubReleaseChecker() {
    }

    static void checkForUpdates(Activity activity, boolean manual, String repoSlug) {
        if (activity == null || activity.isFinishing()) {
            return;
        }

        SharedPreferences prefs = activity.getSharedPreferences(PREFS_NAME, Activity.MODE_PRIVATE);
        long now = System.currentTimeMillis();
        if (!manual) {
            long lastCheck = prefs.getLong(KEY_LAST_CHECK_MS, 0L);
            if (now - lastCheck < AUTO_CHECK_INTERVAL_MS) {
                return;
            }
        }
        prefs.edit().putLong(KEY_LAST_CHECK_MS, now).apply();

        new Thread(() -> {
            try {
                ReleaseInfo releaseInfo = fetchLatestRelease(repoSlug);
                String currentVersion = activity.getPackageManager()
                    .getPackageInfo(activity.getPackageName(), 0).versionName;
                boolean newer = compareVersions(releaseInfo.versionName, currentVersion) > 0;

                activity.runOnUiThread(() -> {
                    if (activity.isFinishing()) {
                        return;
                    }
                    if (newer) {
                        showUpdateDialog(activity, releaseInfo, currentVersion);
                    } else if (manual) {
                        Toast.makeText(activity,
                            "Already on the latest release (" + formatVersion(currentVersion) + ")",
                            Toast.LENGTH_LONG).show();
                    }
                });
            } catch (Exception e) {
                if (!manual) {
                    return;
                }
                activity.runOnUiThread(() -> {
                    if (activity.isFinishing()) {
                        return;
                    }
                    new AlertDialog.Builder(activity)
                        .setTitle(activity.getString(R.string.check_github_updates_title))
                        .setMessage("Could not reach GitHub right now.\n\n" + e.getMessage())
                        .setPositiveButton("OK", null)
                        .show();
                });
            }
        }).start();
    }

    private static ReleaseInfo fetchLatestRelease(String repoSlug) throws Exception {
        URL url = new URL("https://api.github.com/repos/" + repoSlug + "/releases/latest");
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        connection.setRequestMethod("GET");
        connection.setConnectTimeout(10000);
        connection.setReadTimeout(10000);
        connection.setRequestProperty("Accept", "application/vnd.github+json");
        connection.setRequestProperty("User-Agent", "FridaPacker-Android");

        int statusCode = connection.getResponseCode();
        InputStream inputStream = statusCode >= 200 && statusCode < 300
            ? connection.getInputStream()
            : connection.getErrorStream();
        String response = readAll(inputStream);
        if (statusCode < 200 || statusCode >= 300) {
            throw new IllegalStateException("GitHub API error " + statusCode + ": " + response);
        }

        JSONObject json = new JSONObject(response);
        String tagName = json.optString("tag_name", "");
        String versionName = normalizeVersionName(tagName.isEmpty() ? json.optString("name", "") : tagName);
        if (versionName.isEmpty()) {
            throw new IllegalStateException("Latest release did not include a usable version tag");
        }

        String releaseUrl = json.optString("html_url", "https://github.com/" + repoSlug + "/releases/latest");
        JSONArray assets = json.optJSONArray("assets");
        if (assets != null) {
            for (int index = 0; index < assets.length(); index++) {
                JSONObject asset = assets.optJSONObject(index);
                if (asset == null) {
                    continue;
                }
                String assetUrl = asset.optString("browser_download_url", "");
                String assetName = asset.optString("name", "").toLowerCase(Locale.US);
                if (assetUrl.endsWith(".apk") || assetName.endsWith(".apk")) {
                    releaseUrl = assetUrl;
                    break;
                }
            }
        }

        return new ReleaseInfo(
            versionName,
            json.optString("name", "Latest release"),
            json.optString("body", ""),
            releaseUrl
        );
    }

    private static void showUpdateDialog(Activity activity, ReleaseInfo releaseInfo, String currentVersion) {
        String body = releaseInfo.releaseNotes == null ? "" : releaseInfo.releaseNotes.trim();
        if (body.length() > 700) {
            body = body.substring(0, 700).trim() + "\n\n…";
        }

        StringBuilder message = new StringBuilder();
        message.append("Installed: ").append(formatVersion(currentVersion)).append("\n");
        message.append("Latest: ").append(formatVersion(releaseInfo.versionName));
        if (releaseInfo.releaseName != null && !releaseInfo.releaseName.trim().isEmpty()) {
            message.append("\n\n").append(releaseInfo.releaseName.trim());
        }
        if (!body.isEmpty()) {
            message.append("\n\n").append(body);
        }

        new AlertDialog.Builder(activity)
            .setTitle("Update available")
            .setMessage(message.toString())
            .setPositiveButton("Open GitHub", (dialog, which) -> {
                Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(releaseInfo.releaseUrl));
                activity.startActivity(intent);
            })
            .setNegativeButton("Later", null)
            .show();
    }

    private static String readAll(InputStream inputStream) throws Exception {
        if (inputStream == null) {
            return "";
        }
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(inputStream))) {
            StringBuilder builder = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) {
                builder.append(line).append('\n');
            }
            return builder.toString().trim();
        }
    }

    private static String normalizeVersionName(String rawValue) {
        if (rawValue == null) {
            return "";
        }
        String trimmed = rawValue.trim();
        if (trimmed.startsWith("v") || trimmed.startsWith("V")) {
            trimmed = trimmed.substring(1);
        }
        return trimmed.trim();
    }

    private static String formatVersion(String version) {
        String normalized = normalizeVersionName(version);
        if (normalized.isEmpty()) {
            return "v?";
        }
        return "v" + normalized;
    }

    private static int compareVersions(String left, String right) {
        List<Integer> leftParts = extractNumberGroups(left);
        List<Integer> rightParts = extractNumberGroups(right);
        int max = Math.max(leftParts.size(), rightParts.size());
        for (int index = 0; index < max; index++) {
            int leftValue = index < leftParts.size() ? leftParts.get(index) : 0;
            int rightValue = index < rightParts.size() ? rightParts.get(index) : 0;
            if (leftValue != rightValue) {
                return leftValue > rightValue ? 1 : -1;
            }
        }
        return normalizeVersionName(left).compareToIgnoreCase(normalizeVersionName(right));
    }

    private static List<Integer> extractNumberGroups(String version) {
        List<Integer> parts = new ArrayList<>();
        Matcher matcher = DIGIT_GROUP.matcher(normalizeVersionName(version));
        while (matcher.find()) {
            try {
                parts.add(Integer.parseInt(matcher.group()));
            } catch (NumberFormatException ignored) {
                parts.add(0);
            }
        }
        return parts;
    }

    private static final class ReleaseInfo {
        final String versionName;
        final String releaseName;
        final String releaseNotes;
        final String releaseUrl;

        ReleaseInfo(String versionName, String releaseName, String releaseNotes, String releaseUrl) {
            this.versionName = versionName;
            this.releaseName = releaseName;
            this.releaseNotes = releaseNotes;
            this.releaseUrl = releaseUrl;
        }
    }
}