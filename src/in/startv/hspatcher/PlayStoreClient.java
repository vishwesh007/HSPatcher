package in.startv.hspatcher;

import android.content.Context;
import android.os.Environment;
import android.util.Log;

import java.io.*;
import java.net.*;
import java.nio.charset.StandardCharsets;
import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Google Play Store anonymous downloader — Java port of gplaydl's core API.
 * Uses Aurora Store's token dispenser for anonymous auth (no Google account needed).
 * Downloads base APK + split APKs + OBB files.
 */
public class PlayStoreClient {

    private static final String TAG = "HSPatcher";
    private static final String DISPENSER_URL = "https://auroraoss.com/api/auth";
    private static final String FDFE_URL = "https://android.clients.google.com/fdfe";
    private static final String DETAILS_URL = FDFE_URL + "/details";
    private static final String PURCHASE_URL = FDFE_URL + "/purchase";
    private static final String DELIVERY_URL = FDFE_URL + "/delivery";
    private static final String SEARCH_URL = FDFE_URL + "/search";
    private static final String WEB_SEARCH_URL = "https://play.google.com/store/search";
    private static final int TIMEOUT_MS = 30000;
    private static final Pattern PACKAGE_NAME_PATTERN =
        Pattern.compile("^[a-zA-Z][a-zA-Z0-9_]*(\\.[a-zA-Z0-9_]+)+$");
    private static final Pattern WEB_DETAILS_ID_PATTERN =
        Pattern.compile("/store/apps/details\\?id=([a-zA-Z0-9_$.]+(?:\\.[a-zA-Z0-9_$.]+)+)");

    // Device profile for auth — Pixel 7a arm64
    private static final Map<String, String> DEVICE_PROFILE = new LinkedHashMap<>();
    static {
        DEVICE_PROFILE.put("Build.HARDWARE", "lynx");
        DEVICE_PROFILE.put("Build.RADIO", "unknown");
        DEVICE_PROFILE.put("Build.BOOTLOADER", "lynx-1.0-10625894");
        DEVICE_PROFILE.put("Build.FINGERPRINT", "google/lynx/lynx:14/UQ1A.231205.015/11084887:user/release-keys");
        DEVICE_PROFILE.put("Build.BRAND", "google");
        DEVICE_PROFILE.put("Build.DEVICE", "lynx");
        DEVICE_PROFILE.put("Build.VERSION.SDK_INT", "34");
        DEVICE_PROFILE.put("Build.MODEL", "Pixel 7a");
        DEVICE_PROFILE.put("Build.MANUFACTURER", "Google");
        DEVICE_PROFILE.put("Build.PRODUCT", "lynx");
        DEVICE_PROFILE.put("Build.ID", "UQ1A.231205.015");
        DEVICE_PROFILE.put("Build.VERSION.RELEASE", "14");
        DEVICE_PROFILE.put("Platforms", "arm64-v8a,armeabi-v7a,armeabi");
        DEVICE_PROFILE.put("SharedLibraries", "android.test.runner,com.google.android.maps,org.apache.http.legacy");
        DEVICE_PROFILE.put("Features", "android.hardware.sensor.accelerometer,android.hardware.sensor.compass,android.hardware.wifi");
        DEVICE_PROFILE.put("Locales", "en_US");
        DEVICE_PROFILE.put("Screen.Density", "420");
        DEVICE_PROFILE.put("Screen.Width", "1080");
        DEVICE_PROFILE.put("Screen.Height", "2400");
        DEVICE_PROFILE.put("GSF.version", "233657032");
        DEVICE_PROFILE.put("Vending.version", "84122900");
        DEVICE_PROFILE.put("Vending.versionString", "41.2.29-23 [0] [PR] 639844241");
        DEVICE_PROFILE.put("CellOperator", "310260");
        DEVICE_PROFILE.put("SimOperator", "310260");
        DEVICE_PROFILE.put("Roaming", "mobile-notroaming");
        DEVICE_PROFILE.put("TimeZone", "America/New_York");
        DEVICE_PROFILE.put("GL.Version", "196610");
        DEVICE_PROFILE.put("GL.Extensions", "GL_OES_EGL_image,GL_OES_EGL_image_external");
        DEVICE_PROFILE.put("UserReadableName", "Pixel 7a");
    }

    /** App details from Play Store. */
    public static class AppDetails {
        public String packageName = "";
        public String title = "";
        public String developer = "";
        public String versionString = "";
        public int versionCode = 0;
        public String rating = "";
        public String downloads = "";
    }

    /** A downloadable split APK. */
    public static class SplitInfo {
        public String name = "";
        public String url = "";
        public long size = 0;
    }

    /** An additional file (OBB or asset pack). */
    public static class AdditionalFile {
        public int fileType = 0; // 0=main OBB, 1=patch OBB, 2=asset pack
        public int versionCode = 0;
        public long size = 0;
        public String url = "";
        public boolean gzipped = false;

        public String getExtension() { return fileType == 2 ? ".apk" : ".obb"; }
        public String getTypeLabel() {
            switch (fileType) {
                case 1: return "patch";
                case 2: return "asset";
                default: return "main";
            }
        }
    }

    /** Delivery result with download URLs. */
    public static class DeliveryResult {
        public String downloadUrl = "";
        public long downloadSize = 0;
        public List<SplitInfo> splits = new ArrayList<>();
        public List<AdditionalFile> additionalFiles = new ArrayList<>();
        public Map<String, String> cookies = new LinkedHashMap<>();
    }

    /** Search result entry. */
    public static class SearchResult {
        public String packageName = "";
        public String title = "";
        public String developer = "";
    }

    private static final class RankedSearchResult {
        final SearchResult result = new SearchResult();
        int score;
    }

    /** Callback for progress updates. */
    public interface ProgressCallback {
        void onProgress(String message);
        void onError(String error);
        void onComplete(File downloadedFile);
    }

    // ======================== AUTH ========================

    private String authToken = "";
    private String gsfId = "";
    private String dfeCookie = "";
    private String deviceConfigToken = "";
    private String deviceCheckInToken = "";

    /** Authenticate anonymously via Aurora Store's token dispenser. */
    public boolean authenticate() {
        try {
            String json = buildProfileJson();
            byte[] body = json.getBytes(StandardCharsets.UTF_8);

            HttpURLConnection conn = (HttpURLConnection) new URL(DISPENSER_URL).openConnection();
            conn.setRequestMethod("POST");
            conn.setConnectTimeout(TIMEOUT_MS);
            conn.setReadTimeout(TIMEOUT_MS);
            conn.setRequestProperty("User-Agent", "com.aurora.store-4.6.1-70");
            conn.setRequestProperty("Content-Type", "application/json");
            conn.setDoOutput(true);
            conn.getOutputStream().write(body);

            int code = conn.getResponseCode();
            if (code != 200) {
                Log.e(TAG, "Auth failed: HTTP " + code);
                return false;
            }

            String response = readStream(conn.getInputStream());
            authToken = extractJsonString(response, "authToken");
            gsfId = extractJsonString(response, "gsfId");
            dfeCookie = extractJsonString(response, "dfeCookie");
            deviceConfigToken = extractJsonString(response, "deviceConfigToken");
            deviceCheckInToken = extractJsonString(response, "deviceCheckInConsistencyToken");

            if (authToken.isEmpty()) {
                Log.e(TAG, "No authToken in response");
                return false;
            }

            Log.i(TAG, "PlayStore auth OK, gsfId=" + gsfId);
            return true;
        } catch (Exception e) {
            Log.e(TAG, "Auth error: " + e.getMessage());
            return false;
        }
    }

    public boolean isAuthenticated() {
        return !authToken.isEmpty();
    }

    // ======================== DETAILS ========================

    /** Fetch app details from Play Store. */
    public AppDetails getDetails(String packageName) throws IOException {
        HttpURLConnection conn = openProtobuf(DETAILS_URL + "?doc=" + packageName);
        int code = conn.getResponseCode();
        if (code == 404) throw new IOException("App not found: " + packageName);
        if (code == 401) throw new IOException("Auth expired");
        if (code != 200) throw new IOException("Details failed: HTTP " + code);

        byte[] raw = readBytes(conn.getInputStream());

        // Parse: ResponseWrapper(1) → Payload(2) → DetailsResponse(4) → DocV2
        List<ProtobufDecoder.Field> docFields = ProtobufDecoder.navigate(raw, 1, 2, 4);
        if (docFields.isEmpty()) throw new IOException("Cannot parse app details");

        AppDetails details = new AppDetails();
        details.packageName = ProtobufDecoder.firstString(docFields, 1);
        details.title = ProtobufDecoder.firstString(docFields, 5);
        details.developer = ProtobufDecoder.firstString(docFields, 6);

        // DocDetails(13) → AppDetails(1)
        byte[] docDetailsBytes = ProtobufDecoder.firstBytes(docFields, 13);
        if (docDetailsBytes != null) {
            List<ProtobufDecoder.Field> dd = new ProtobufDecoder(docDetailsBytes).readAll();
            byte[] appDetailsBytes = ProtobufDecoder.firstBytes(dd, 1);
            if (appDetailsBytes != null) {
                List<ProtobufDecoder.Field> ad = new ProtobufDecoder(appDetailsBytes).readAll();
                long vc = ProtobufDecoder.firstInt(ad, 3);
                if (vc > 0) details.versionCode = (int) vc;
                details.versionString = ProtobufDecoder.firstString(ad, 4);
                String dl = ProtobufDecoder.firstString(ad, 61);
                if (!dl.isEmpty()) details.downloads = dl;
            }
        }

        if (details.packageName.isEmpty()) details.packageName = packageName;
        return details;
    }

    // ======================== PURCHASE ========================

    /** "Purchase" a free app (required before delivery). */
    public void purchase(String packageName, int versionCode) {
        try {
            HttpURLConnection conn = (HttpURLConnection) new URL(PURCHASE_URL).openConnection();
            conn.setRequestMethod("POST");
            conn.setConnectTimeout(TIMEOUT_MS);
            conn.setReadTimeout(TIMEOUT_MS);
            setAuthHeaders(conn);
            conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
            conn.setDoOutput(true);
            String body = "doc=" + packageName + "&ot=1&vc=" + versionCode;
            conn.getOutputStream().write(body.getBytes(StandardCharsets.UTF_8));
            conn.getResponseCode(); // fire and forget, non-fatal
        } catch (Exception e) {
            Log.w(TAG, "Purchase request (non-fatal): " + e.getMessage());
        }
    }

    // ======================== DELIVERY ========================

    /** Get download URLs for APK, splits, and OBB files. */
    public DeliveryResult getDelivery(String packageName, int versionCode) throws IOException {
        HttpURLConnection conn = openProtobuf(DELIVERY_URL + "?doc=" + packageName + "&ot=1&vc=" + versionCode);
        int code = conn.getResponseCode();
        if (code == 401) throw new IOException("Auth expired");
        if (code != 200) throw new IOException("Delivery failed: HTTP " + code);

        byte[] raw = readBytes(conn.getInputStream());
        return parseDelivery(raw);
    }

    private DeliveryResult parseDelivery(byte[] raw) {
        // Try multiple payload field numbers (21 is primary, fallback to 5, 4, 6)
        for (int payloadFn : new int[]{21, 5, 4, 6}) {
            List<ProtobufDecoder.Field> addFields = ProtobufDecoder.navigate(raw, 1, payloadFn, 2);
            String dlUrl = ProtobufDecoder.firstString(addFields, 3);
            if (!dlUrl.isEmpty()) {
                return extractDelivery(addFields);
            }
        }

        // Fallback: scan for CDN URLs
        DeliveryResult result = new DeliveryResult();
        for (String s : ProtobufDecoder.extractStrings(raw)) {
            if (s.startsWith("https://") && s.contains("android.clients.google.com")) {
                result.downloadUrl = s;
                break;
            }
        }
        return result;
    }

    private DeliveryResult extractDelivery(List<ProtobufDecoder.Field> fields) {
        DeliveryResult result = new DeliveryResult();
        result.downloadUrl = ProtobufDecoder.firstString(fields, 3);
        long size = ProtobufDecoder.firstInt(fields, 1);
        if (size > 0) result.downloadSize = size;

        // Field 4: cookies and OBB entries
        for (byte[] f4b : ProtobufDecoder.allBytes(fields, 4)) {
            List<ProtobufDecoder.Field> cf = new ProtobufDecoder(f4b).readAll();
            // Check if field 1 is string (cookie) or varint (OBB)
            int f1wt = -1;
            for (ProtobufDecoder.Field f : cf) {
                if (f.fieldNumber == 1) { f1wt = f.wireType; break; }
            }
            if (f1wt == 2) {
                // Cookie
                String name = ProtobufDecoder.firstString(cf, 1);
                String value = ProtobufDecoder.firstString(cf, 2);
                if (!name.isEmpty()) result.cookies.put(name, value);
            } else if (f1wt == 0) {
                // OBB / additional file
                String url = ProtobufDecoder.firstString(cf, 4);
                if (!url.isEmpty() && url.startsWith("https://")) {
                    AdditionalFile af = new AdditionalFile();
                    long ft = ProtobufDecoder.firstInt(cf, 1);
                    if (ft >= 0) af.fileType = (int) ft;
                    long vc = ProtobufDecoder.firstInt(cf, 2);
                    if (vc > 0) af.versionCode = (int) vc;
                    long sz = ProtobufDecoder.firstInt(cf, 3);
                    if (sz > 0) af.size = sz;
                    af.url = url;
                    result.additionalFiles.add(af);
                }
            }
        }

        // Field 15: split APKs (repeated: 1=name, 2=size, 5=downloadUrl)
        for (byte[] splitB : ProtobufDecoder.allBytes(fields, 15)) {
            List<ProtobufDecoder.Field> sf = new ProtobufDecoder(splitB).readAll();
            String url = ProtobufDecoder.firstString(sf, 5);
            if (!url.isEmpty()) {
                SplitInfo si = new SplitInfo();
                si.name = ProtobufDecoder.firstString(sf, 1);
                if (si.name.isEmpty()) si.name = "split" + result.splits.size();
                si.url = url;
                long sz = ProtobufDecoder.firstInt(sf, 2);
                if (sz > 0) si.size = sz;
                result.splits.add(si);
            }
        }

        // Field 18: asset pack APKs
        for (byte[] afB : ProtobufDecoder.allBytes(fields, 18)) {
            List<ProtobufDecoder.Field> af = new ProtobufDecoder(afB).readAll();
            String url = ProtobufDecoder.firstString(af, 3);
            if (!url.isEmpty() && url.startsWith("https://")) {
                AdditionalFile a = new AdditionalFile();
                long ft = ProtobufDecoder.firstInt(af, 1);
                if (ft >= 0) a.fileType = (int) ft;
                long sz = ProtobufDecoder.firstInt(af, 2);
                if (sz > 0) a.size = sz;
                a.url = url;
                a.gzipped = (a.fileType == 2);
                result.additionalFiles.add(a);
            }
        }

        return result;
    }

    // ======================== SEARCH ========================

    /** Search Play Store for apps. Returns up to `limit` results. */
    public List<SearchResult> search(String query, int limit) throws IOException {
        String encodedQuery = URLEncoder.encode(query, "UTF-8");
        HttpURLConnection conn = openProtobuf(SEARCH_URL + "?q=" + encodedQuery + "&c=3");
        int code = conn.getResponseCode();
        if (code == 401) throw new IOException("Auth expired");
        if (code == 429) {
            Log.w(TAG, "Search rate-limited (HTTP 429), falling back to web search for query: " + query);
            return fallbackSearch(query, limit);
        }
        if (code != 200) throw new IOException("Search failed: HTTP " + code);

        byte[] raw = readBytes(conn.getInputStream());
        List<SearchResult> results = parseSearch(raw, query, limit);
        if (!results.isEmpty()) return results;

        Log.w(TAG, "Protobuf search returned no results, falling back to web search for query: " + query);
        return fallbackSearch(query, limit);
    }

    private List<SearchResult> fallbackSearch(String query, int limit) throws IOException {
        String encodedQuery = URLEncoder.encode(query, "UTF-8");
        String url = WEB_SEARCH_URL + "?q=" + encodedQuery + "&c=apps&hl=en&gl=US";

        HttpURLConnection conn = (HttpURLConnection) new URL(url).openConnection();
        conn.setRequestMethod("GET");
        conn.setConnectTimeout(TIMEOUT_MS);
        conn.setReadTimeout(TIMEOUT_MS);
        conn.setRequestProperty("User-Agent",
            "Mozilla/5.0 (Linux; Android 14; Pixel 7a) AppleWebKit/537.36 " +
            "(KHTML, like Gecko) Chrome/124.0.0.0 Mobile Safari/537.36");
        conn.setRequestProperty("Accept-Language", "en-US,en;q=0.9");

        int code = conn.getResponseCode();
        if (code != 200) throw new IOException("Web search failed: HTTP " + code);

        String html = readStream(conn.getInputStream());
        Map<String, RankedSearchResult> rankedResults = new LinkedHashMap<>();
        String normalizedQuery = normalizeSearchText(query);

        Matcher matcher = WEB_DETAILS_ID_PATTERN.matcher(html);
        int ordinal = 0;
        while (matcher.find() && rankedResults.size() < Math.max(limit * 3, 12)) {
            String packageName = matcher.group(1);
            if (!isPackageName(packageName)) continue;
            int score = 80 - (ordinal * 3) + scoreText(packageName, normalizedQuery);
            addRankedResult(rankedResults, packageName, "", "", score);
            ordinal++;
        }

        if (rankedResults.isEmpty()) {
            throw new IOException("No results found for: " + query);
        }

        List<RankedSearchResult> ordered = new ArrayList<>(rankedResults.values());
        Collections.sort(ordered, (a, b) -> Integer.compare(b.score, a.score));
        enrichSearchResults(ordered, limit);

        List<SearchResult> results = new ArrayList<>();
        for (RankedSearchResult ranked : ordered) {
            if (ranked.result.packageName.isEmpty()) continue;
            if (ranked.result.title == null || ranked.result.title.trim().isEmpty()) {
                ranked.result.title = ranked.result.packageName;
            }
            results.add(ranked.result);
            if (results.size() >= limit) break;
        }
        return results;
    }

    private List<SearchResult> parseSearch(byte[] raw, String query, int limit) {
        Map<String, RankedSearchResult> rankedResults = new LinkedHashMap<>();
        String normalizedQuery = normalizeSearchText(query);

        findDocV2(raw, rankedResults, normalizedQuery, 0);
        if (rankedResults.isEmpty()) {
            addFallbackPackages(raw, rankedResults);
        }

        List<RankedSearchResult> ordered = new ArrayList<>(rankedResults.values());
        Collections.sort(ordered, (a, b) -> Integer.compare(b.score, a.score));

        enrichSearchResults(ordered, limit);

        List<SearchResult> results = new ArrayList<>();
        for (RankedSearchResult ranked : ordered) {
            if (ranked.result.packageName.isEmpty()) continue;
            if (ranked.result.title == null || ranked.result.title.trim().isEmpty()) {
                ranked.result.title = ranked.result.packageName;
            }
            results.add(ranked.result);
            if (results.size() >= limit) break;
        }
        return results;
    }

    private void findDocV2(byte[] data, Map<String, RankedSearchResult> rankedResults,
                           String normalizedQuery, int depth) {
        if (depth > 12 || rankedResults.size() >= 40 || data == null || data.length == 0) return;
        try {
            List<ProtobufDecoder.Field> fields = new ProtobufDecoder(data).readAll();

            List<String> directStrings = extractDirectStrings(fields);
            List<String> directPackages = extractPackageNames(directStrings);
            if (!directPackages.isEmpty()) {
                String title = chooseBestTitle(directStrings, directPackages, normalizedQuery);
                String developer = chooseDeveloper(directStrings, directPackages, title);
                int score = 30 + scoreText(title, normalizedQuery) - (depth * 2);
                for (String pkg : directPackages) {
                    addRankedResult(rankedResults, pkg, title, developer, score);
                }
            }

            if (data.length <= 16384) {
                List<String> subtreeStrings = ProtobufDecoder.extractStrings(data);
                List<String> subtreePackages = extractPackageNames(subtreeStrings);
                if (!subtreePackages.isEmpty()) {
                    String title = chooseBestTitle(subtreeStrings, subtreePackages, normalizedQuery);
                    String developer = chooseDeveloper(subtreeStrings, subtreePackages, title);
                    int score = 14 + scoreText(title, normalizedQuery) - depth;
                    for (String pkg : subtreePackages) {
                        addRankedResult(rankedResults, pkg, title, developer, score);
                    }
                }
            }

            for (ProtobufDecoder.Field f : fields) {
                if (f.wireType == 2 && f.value instanceof byte[] && ((byte[]) f.value).length > 20) {
                    findDocV2((byte[]) f.value, rankedResults, normalizedQuery, depth + 1);
                    if (rankedResults.size() >= 40) return;
                }
            }
        } catch (Exception ignored) {}
    }

    private void addFallbackPackages(byte[] raw, Map<String, RankedSearchResult> rankedResults) {
        for (String value : ProtobufDecoder.extractStrings(raw)) {
            if (!isPackageName(value)) continue;
            addRankedResult(rankedResults, value, "", "", 1);
            if (rankedResults.size() >= 12) return;
        }
    }

    private void enrichSearchResults(List<RankedSearchResult> ordered, int limit) {
        int maxToEnrich = Math.min(Math.max(limit, 5), ordered.size());
        for (int i = 0; i < maxToEnrich; i++) {
            RankedSearchResult ranked = ordered.get(i);
            if (!needsDetails(ranked.result)) continue;
            try {
                AppDetails details = getDetails(ranked.result.packageName);
                if (details != null) {
                    if (ranked.result.title == null || ranked.result.title.trim().isEmpty()) {
                        ranked.result.title = details.title;
                    }
                    if (ranked.result.developer == null || ranked.result.developer.trim().isEmpty()) {
                        ranked.result.developer = details.developer;
                    }
                    ranked.score += 5;
                }
            } catch (Exception ignored) {
            }
        }
        Collections.sort(ordered, (a, b) -> Integer.compare(b.score, a.score));
    }

    private boolean needsDetails(SearchResult result) {
        return result.title == null || result.title.trim().isEmpty()
            || result.developer == null || result.developer.trim().isEmpty()
            || result.title.equals(result.packageName);
    }

    private void addRankedResult(Map<String, RankedSearchResult> rankedResults, String packageName,
                                 String title, String developer, int score) {
        if (!isPackageName(packageName)) return;

        RankedSearchResult existing = rankedResults.get(packageName);
        if (existing == null) {
            existing = new RankedSearchResult();
            existing.result.packageName = packageName;
            rankedResults.put(packageName, existing);
        }

        boolean shouldReplace = score > existing.score
            || (isBlank(existing.result.title) && !isBlank(title))
            || (isBlank(existing.result.developer) && !isBlank(developer));
        if (!shouldReplace) return;

        existing.score = Math.max(existing.score, score);
        if (!isBlank(title)) existing.result.title = title.trim();
        if (!isBlank(developer)) existing.result.developer = developer.trim();
    }

    private List<String> extractDirectStrings(List<ProtobufDecoder.Field> fields) {
        List<String> strings = new ArrayList<>();
        for (ProtobufDecoder.Field field : fields) {
            if (field.wireType != 2 || !(field.value instanceof byte[])) continue;
            byte[] value = (byte[]) field.value;
            if (value.length == 0 || value.length > 160) continue;
            try {
                String text = new String(value, "UTF-8").trim();
                if (text.length() < 2 || !isPrintable(text)) continue;
                strings.add(text);
            } catch (Exception ignored) {
            }
        }
        return strings;
    }

    private List<String> extractPackageNames(List<String> strings) {
        LinkedHashSet<String> packages = new LinkedHashSet<>();
        for (String value : strings) {
            if (isPackageName(value)) packages.add(value.trim());
        }
        return new ArrayList<>(packages);
    }

    private String chooseBestTitle(List<String> strings, List<String> packages, String normalizedQuery) {
        String best = "";
        int bestScore = Integer.MIN_VALUE;
        for (String candidate : strings) {
            if (!looksLikeHumanLabel(candidate)) continue;
            if (packages.contains(candidate)) continue;
            int score = scoreText(candidate, normalizedQuery);
            if (candidate.indexOf(' ') >= 0) score += 6;
            if (Character.isUpperCase(candidate.charAt(0))) score += 4;
            if (candidate.length() <= 32) score += 3;
            if (candidate.contains(".")) score -= 10;
            if (candidate.startsWith("http")) score -= 30;
            if (score > bestScore) {
                bestScore = score;
                best = candidate;
            }
        }
        return best;
    }

    private String chooseDeveloper(List<String> strings, List<String> packages, String title) {
        for (String candidate : strings) {
            if (!looksLikeHumanLabel(candidate)) continue;
            if (packages.contains(candidate)) continue;
            if (!title.isEmpty() && candidate.equals(title)) continue;
            if (candidate.startsWith("http")) continue;
            if (candidate.contains(".")) continue;
            return candidate;
        }
        return "";
    }

    private int scoreText(String candidate, String normalizedQuery) {
        if (candidate == null || candidate.trim().isEmpty()) return 0;
        String normalizedCandidate = normalizeSearchText(candidate);
        if (normalizedQuery.isEmpty()) return normalizedCandidate.length() <= 40 ? 4 : 0;
        if (normalizedCandidate.equals(normalizedQuery)) return 120;
        if (normalizedCandidate.contains(normalizedQuery)) return 90;
        if (normalizedQuery.contains(normalizedCandidate) && normalizedCandidate.length() > 2) return 70;

        int overlap = 0;
        for (String token : normalizedQuery.split(" ")) {
            if (token.isEmpty()) continue;
            if (normalizedCandidate.contains(token)) overlap += 18;
        }
        return overlap;
    }

    private String normalizeSearchText(String value) {
        if (value == null) return "";
        String normalized = value.toLowerCase(Locale.US)
            .replaceAll("[^a-z0-9]+", " ")
            .trim()
            .replaceAll("\\s+", " ");
        return normalized;
    }

    private boolean looksLikeHumanLabel(String value) {
        if (value == null) return false;
        String trimmed = value.trim();
        if (trimmed.length() < 2 || trimmed.length() > 80) return false;
        if (!isPrintable(trimmed)) return false;
        if (isPackageName(trimmed)) return false;
        if (trimmed.startsWith("http://") || trimmed.startsWith("https://")) return false;
        return true;
    }

    private boolean isPackageName(String value) {
        if (value == null) return false;
        String trimmed = value.trim();
        return trimmed.length() >= 6 && PACKAGE_NAME_PATTERN.matcher(trimmed).matches();
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }

    private boolean isPrintable(String value) {
        for (int i = 0; i < value.length(); i++) {
            char c = value.charAt(i);
            if (c < 0x20 && c != '\n' && c != '\r' && c != '\t') return false;
        }
        return true;
    }

    // ======================== DOWNLOAD ========================

    /** Download an app and all its splits to the given directory. Returns the base APK file. */
    public File downloadApp(String packageName, File outputDir, boolean includeSplits,
                            ProgressCallback callback) {
        try {
            if (!isAuthenticated()) {
                callback.onProgress("Authenticating with Play Store...");
                if (!authenticate()) {
                    callback.onError("Authentication failed. Try again later.");
                    return null;
                }
                callback.onProgress("✅ Authenticated");
            }

            // Get details
            callback.onProgress("Fetching app details...");
            AppDetails details = getDetails(packageName);
            callback.onProgress("📱 " + details.title + " v" + details.versionString
                + " (vc=" + details.versionCode + ")");

            // Purchase
            callback.onProgress("Acquiring download permission...");
            purchase(packageName, details.versionCode);

            // Get delivery URLs
            callback.onProgress("Getting download URLs...");
            DeliveryResult delivery = getDelivery(packageName, details.versionCode);
            if (delivery.downloadUrl.isEmpty()) {
                callback.onError("No download URL available. App may require purchase.");
                return null;
            }

            outputDir.mkdirs();

            // Clean previous download files to avoid stale data
            File[] oldFiles = outputDir.listFiles();
            if (oldFiles != null) {
                for (File f : oldFiles) f.delete();
            }

            // Download base APK
            String baseFileName = packageName + "-" + details.versionCode + ".apk";
            File baseFile = new File(outputDir, baseFileName);
            callback.onProgress("Downloading base APK (" + formatSize(delivery.downloadSize) + ")...");
            downloadFile(delivery.downloadUrl, baseFile, delivery.cookies);
            callback.onProgress("✅ Base APK downloaded: " + baseFileName);

            // Download splits
            if (includeSplits && !delivery.splits.isEmpty()) {
                callback.onProgress("Downloading " + delivery.splits.size() + " split APK(s)...");
                for (SplitInfo split : delivery.splits) {
                    String splitFileName = packageName + "-" + details.versionCode + "-" + split.name + ".apk";
                    File splitFile = new File(outputDir, splitFileName);
                    downloadFile(split.url, splitFile, delivery.cookies);
                    callback.onProgress("  ✅ " + split.name + " (" + formatSize(split.size) + ")");
                }
            }

            // Download OBB / asset packs (stored separately, NOT as .apk to avoid merger conflicts)
            if (!delivery.additionalFiles.isEmpty()) {
                for (AdditionalFile af : delivery.additionalFiles) {
                    // Use .obb or .asset extension — never .apk — to prevent ApkBundle from loading these
                    String afName = af.getTypeLabel() + "." + af.versionCode + "." + packageName + af.getExtension();
                    if (af.fileType == 2) {
                        afName = packageName + "-" + af.versionCode + "-asset.bin";
                    }
                    File afFile = new File(outputDir, afName);
                    callback.onProgress("Downloading " + af.getTypeLabel() + " (" + formatSize(af.size) + ")...");
                    downloadFile(af.url, afFile, delivery.cookies);
                    callback.onProgress("  ✅ " + afName);
                }
            }

            // If there are splits, create a combined .apks bundle
            File resultFile = baseFile;
            if (includeSplits && !delivery.splits.isEmpty()) {
                callback.onProgress("Creating split bundle...");
                File bundleFile = new File(outputDir, packageName + ".apks");
                createApksBundle(outputDir, bundleFile);
                resultFile = bundleFile;
                callback.onProgress("✅ Bundle created: " + bundleFile.getName());
            }

            callback.onComplete(resultFile);
            return resultFile;

        } catch (Exception e) {
            Log.e(TAG, "Download error", e);
            callback.onError("Download failed: " + e.getMessage());
            return null;
        }
    }

    /** Download a single file from URL to dest. */
    private void downloadFile(String urlStr, File dest, Map<String, String> cookies) throws IOException {
        HttpURLConnection conn = (HttpURLConnection) new URL(urlStr).openConnection();
        conn.setConnectTimeout(TIMEOUT_MS);
        conn.setReadTimeout(300000); // 5 min for large files
        conn.setRequestProperty("User-Agent", "AndroidDownloadManager/14 (Linux; U; Android 14; Pixel 7a)");
        if (cookies != null && !cookies.isEmpty()) {
            StringBuilder sb = new StringBuilder();
            for (Map.Entry<String, String> e : cookies.entrySet()) {
                if (sb.length() > 0) sb.append("; ");
                sb.append(e.getKey()).append("=").append(e.getValue());
            }
            conn.setRequestProperty("Cookie", sb.toString());
        }
        conn.setInstanceFollowRedirects(true);

        try (InputStream in = conn.getInputStream();
             FileOutputStream out = new FileOutputStream(dest)) {
            byte[] buf = new byte[65536];
            int n;
            while ((n = in.read(buf)) > 0) {
                out.write(buf, 0, n);
            }
        }
    }

    /** Create a .apks ZIP bundle from valid APKs in the directory. Validates ZIP magic before including. */
    private void createApksBundle(File dir, File output) throws IOException {
        File[] apks = dir.listFiles((d, name) -> name.endsWith(".apk"));
        if (apks == null || apks.length == 0) return;

        try (java.util.zip.ZipOutputStream zos = new java.util.zip.ZipOutputStream(new FileOutputStream(output))) {
            byte[] buf = new byte[65536];
            for (File apk : apks) {
                // Validate: must be a valid ZIP/APK (starts with PK magic bytes)
                if (!isValidZip(apk)) {
                    Log.w(TAG, "Skipping non-APK file: " + apk.getName());
                    continue;
                }
                zos.putNextEntry(new java.util.zip.ZipEntry(apk.getName()));
                try (FileInputStream fis = new FileInputStream(apk)) {
                    int n;
                    while ((n = fis.read(buf)) > 0) {
                        zos.write(buf, 0, n);
                    }
                }
                zos.closeEntry();
            }
        }
    }

    /** Check if file starts with ZIP/PK magic bytes (0x504B0304). */
    private boolean isValidZip(File f) {
        if (f.length() < 4) return false;
        try (FileInputStream fis = new FileInputStream(f)) {
            byte[] magic = new byte[4];
            if (fis.read(magic) < 4) return false;
            return magic[0] == 0x50 && magic[1] == 0x4B && magic[2] == 0x03 && magic[3] == 0x04;
        } catch (IOException e) {
            return false;
        }
    }

    // ======================== HTTP HELPERS ========================

    private HttpURLConnection openProtobuf(String urlStr) throws IOException {
        HttpURLConnection conn = (HttpURLConnection) new URL(urlStr).openConnection();
        conn.setConnectTimeout(TIMEOUT_MS);
        conn.setReadTimeout(TIMEOUT_MS);
        setAuthHeaders(conn);
        conn.setRequestProperty("Content-Type", "application/x-protobuf");
        conn.setRequestProperty("Accept", "application/x-protobuf");
        return conn;
    }

    private void setAuthHeaders(HttpURLConnection conn) {
        conn.setRequestProperty("Authorization", "Bearer " + authToken);
        conn.setRequestProperty("User-Agent",
            "Android-Finsky/41.2.29-23 [0] [PR] 639844241 "
            + "(api=3,versionCode=84122900,sdk=34,device=lynx,"
            + "hardware=lynx,product=lynx,platformVersionRelease=14,"
            + "model=Pixel%207a,buildId=UQ1A.231205.015,"
            + "isWideScreen=0,supportedAbis=arm64-v8a;armeabi-v7a;armeabi)");
        conn.setRequestProperty("X-DFE-Device-Id", gsfId);
        conn.setRequestProperty("Accept-Language", "en-US");
        conn.setRequestProperty("X-DFE-Encoded-Targets",
            "CAESN/qigQYC2AMBFfUbyA7SM5Ij/CvfBoIDgxXrBPsDlQUdMfOLAfoFrwEHgAcBrQYhoA0cGt4MKK0Y2gI");
        conn.setRequestProperty("X-DFE-Client-Id", "am-android-google");
        conn.setRequestProperty("X-DFE-Network-Type", "4");
        conn.setRequestProperty("X-DFE-Content-Filters", "");
        conn.setRequestProperty("X-Limit-Ad-Tracking-Enabled", "false");
        conn.setRequestProperty("X-Ad-Id", "");
        conn.setRequestProperty("X-DFE-UserLanguages", "en_US");
        conn.setRequestProperty("X-DFE-Request-Params", "timeoutMs=4000");
        conn.setRequestProperty("X-DFE-No-Prefetch", "true");
        if (!dfeCookie.isEmpty()) conn.setRequestProperty("X-DFE-Cookie", dfeCookie);
        if (!deviceCheckInToken.isEmpty())
            conn.setRequestProperty("X-DFE-Device-Checkin-Consistency-Token", deviceCheckInToken);
        if (!deviceConfigToken.isEmpty())
            conn.setRequestProperty("X-DFE-Device-Config-Token", deviceConfigToken);
    }

    // ======================== STRING/JSON HELPERS ========================

    private String buildProfileJson() {
        StringBuilder sb = new StringBuilder("{");
        boolean first = true;
        for (Map.Entry<String, String> e : DEVICE_PROFILE.entrySet()) {
            if (!first) sb.append(",");
            first = false;
            sb.append("\"").append(escapeJson(e.getKey())).append("\":\"")
              .append(escapeJson(e.getValue())).append("\"");
        }
        sb.append("}");
        return sb.toString();
    }

    private static String escapeJson(String s) {
        return s.replace("\\", "\\\\").replace("\"", "\\\"")
                .replace("\n", "\\n").replace("\r", "\\r");
    }

    static String extractJsonString(String json, String key) {
        String search = "\"" + key + "\"";
        int idx = json.indexOf(search);
        if (idx < 0) return "";
        idx = json.indexOf(":", idx + search.length());
        if (idx < 0) return "";
        idx++;
        while (idx < json.length() && json.charAt(idx) == ' ') idx++;
        if (idx >= json.length()) return "";

        if (json.charAt(idx) == '"') {
            idx++;
            StringBuilder sb = new StringBuilder();
            while (idx < json.length() && json.charAt(idx) != '"') {
                if (json.charAt(idx) == '\\' && idx + 1 < json.length()) {
                    idx++;
                    char c = json.charAt(idx);
                    if (c == 'n') sb.append('\n');
                    else if (c == 'r') sb.append('\r');
                    else if (c == 't') sb.append('\t');
                    else sb.append(c);
                } else {
                    sb.append(json.charAt(idx));
                }
                idx++;
            }
            return sb.toString();
        }

        // Number or other literal
        int start = idx;
        while (idx < json.length() && json.charAt(idx) != ',' && json.charAt(idx) != '}') idx++;
        return json.substring(start, idx).trim();
    }

    private static String readStream(InputStream is) throws IOException {
        ByteArrayOutputStream bos = new ByteArrayOutputStream();
        byte[] buf = new byte[4096];
        int n;
        while ((n = is.read(buf)) > 0) bos.write(buf, 0, n);
        return bos.toString("UTF-8");
    }

    private static byte[] readBytes(InputStream is) throws IOException {
        ByteArrayOutputStream bos = new ByteArrayOutputStream();
        byte[] buf = new byte[4096];
        int n;
        while ((n = is.read(buf)) > 0) bos.write(buf, 0, n);
        return bos.toByteArray();
    }

    private static String formatSize(long bytes) {
        if (bytes <= 0) return "unknown size";
        if (bytes > 1024 * 1024) return (bytes / (1024 * 1024)) + " MB";
        return (bytes / 1024) + " KB";
    }
}
