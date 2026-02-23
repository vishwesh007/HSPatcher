package in.startv.hspatcher;

import android.util.Log;
import java.io.*;
import java.util.*;

/**
 * Binary AXML (Android Binary XML) manifest patcher.
 * Adds &lt;activity&gt; declarations for HSPatch activities to an APK's AndroidManifest.xml.
 *
 * The binary manifest format (AXML) consists of:
 * 1. File header (type=0x0003, size)
 * 2. String pool (all strings used in the XML)
 * 3. Resource ID map (maps attribute strings to android R.attr values)
 * 4. XML tree (namespace, element start/end chunks)
 *
 * We add activities by:
 * - Appending new class name strings to the string pool
 * - Inserting StartElement + EndElement chunks before &lt;/application&gt;
 */
public class ManifestPatcher {

    private static final String TAG = "HSPatcher";

    // AXML chunk types
    private static final int TYPE_XML          = 0x0003;
    private static final int TYPE_STRING_POOL  = 0x0001;
    private static final int TYPE_RESOURCE_MAP = 0x0180;
    private static final int TYPE_ELEM_START   = 0x0102;
    private static final int TYPE_ELEM_END     = 0x0103;

    // Android resource attribute IDs
    private static final int RES_ATTR_NAME     = 0x01010003;
    private static final int RES_ATTR_EXPORTED = 0x01010010;

    // Typed value types
    private static final int VAL_STRING  = 0x03;
    private static final int VAL_BOOLEAN = 0x12;

    /** HSPatch activities to register in patched manifests. */
    public static final String[] ACTIVITIES = {
        "in.startv.hotstar.DebugPanelActivity",
        "in.startv.hotstar.FileExplorerActivity",
        "in.startv.hotstar.FileViewerActivity",
        "in.startv.hotstar.LogViewerActivity",
        "in.startv.hotstar.NetworkMonitorActivity"
    };

    /**
     * Patch a binary AndroidManifest.xml to add HSPatch activity declarations.
     * Returns the patched manifest, or the original if patching fails.
     */
    public static byte[] patch(byte[] manifest) {
        try {
            return doPatch(manifest, ACTIVITIES);
        } catch (Exception e) {
            Log.e(TAG, "Manifest patch failed: " + e.getMessage());
            return manifest;
        }
    }

    private static byte[] doPatch(byte[] data, String[] activities) throws Exception {
        if (data.length < 16) throw new Exception("Manifest too small: " + data.length);

        // ---- Parse file header ----
        int fileType = rShort(data, 0);
        if (fileType != TYPE_XML)
            throw new Exception("Not AXML: 0x" + Integer.toHexString(fileType));

        // ---- Parse string pool ----
        int spOff = 8;
        if (rShort(data, spOff) != TYPE_STRING_POOL)
            throw new Exception("Expected string pool at offset 8");

        int spHdrSize   = rShort(data, spOff + 2);   // typically 28
        int spChunkSize = rInt(data, spOff + 4);
        int strCount    = rInt(data, spOff + 8);
        int styleCount  = rInt(data, spOff + 12);
        int spFlags     = rInt(data, spOff + 16);
        boolean utf8    = (spFlags & 0x100) != 0;
        int strStart    = rInt(data, spOff + 20);     // relative to spOff
        int stylStart   = rInt(data, spOff + 24);     // relative to spOff, 0 if no styles

        // Read all existing strings
        int offsBase = spOff + spHdrSize;
        String[] strings = new String[strCount];
        int[] strOffs = new int[strCount];
        for (int i = 0; i < strCount; i++) {
            strOffs[i] = rInt(data, offsBase + i * 4);
        }
        int strDataBase = spOff + strStart; // absolute position of string data
        for (int i = 0; i < strCount; i++) {
            strings[i] = decodeString(data, strDataBase + strOffs[i], utf8);
        }

        // ---- Parse resource map (after string pool) ----
        int rmOff = spOff + spChunkSize;
        int rmChunkSize = 0;
        int[] resIds = null;
        if (rmOff + 8 <= data.length && rShort(data, rmOff) == TYPE_RESOURCE_MAP) {
            rmChunkSize = rInt(data, rmOff + 4);
            int rmCount = (rmChunkSize - 8) / 4;
            resIds = new int[rmCount];
            for (int i = 0; i < rmCount; i++) {
                resIds[i] = rInt(data, rmOff + 8 + i * 4);
            }
        }

        // ---- Find required string indices ----
        int androidNsIdx   = findStr(strings, "http://schemas.android.com/apk/res/android");
        int applicationIdx = findStr(strings, "application");
        int activityIdx    = findStr(strings, "activity");
        int nameAttrIdx    = -1;
        int exportedAttrIdx = -1;

        // Find attribute indices via resource ID map (most reliable)
        if (resIds != null) {
            for (int i = 0; i < resIds.length; i++) {
                if (resIds[i] == RES_ATTR_NAME) nameAttrIdx = i;
                if (resIds[i] == RES_ATTR_EXPORTED) exportedAttrIdx = i;
            }
        }
        // Fallback: find by string name
        if (nameAttrIdx < 0) nameAttrIdx = findStr(strings, "name");

        if (androidNsIdx < 0) throw new Exception("Android namespace URI not found");
        if (applicationIdx < 0) throw new Exception("'application' string not found");
        if (nameAttrIdx < 0) throw new Exception("'name' attribute string not found");

        // ---- Determine new strings to add ----
        List<String> newStrings = new ArrayList<>();
        boolean addActivityStr = (activityIdx < 0);
        if (addActivityStr) {
            newStrings.add("activity");
            activityIdx = strCount + newStrings.size() - 1;
        }

        // Only register activities not already in the manifest
        List<String> toRegister = new ArrayList<>();
        List<Integer> classNameIndices = new ArrayList<>();
        for (String act : activities) {
            if (findStr(strings, act) >= 0) continue; // already present
            toRegister.add(act);
            newStrings.add(act);
            classNameIndices.add(strCount + newStrings.size() - 1);
        }

        if (toRegister.isEmpty()) {
            Log.d(TAG, "  All activities already registered in manifest");
            return data;
        }

        int N = newStrings.size();

        // ---- Find </application> end element position ----
        int xmlTreeStart = spOff + spChunkSize + rmChunkSize;
        int appEndOff = -1;
        int pos = xmlTreeStart;
        while (pos + 8 <= data.length) {
            int chunkType = rShort(data, pos);
            int chunkSize = rInt(data, pos + 4);
            if (chunkSize < 8 || pos + chunkSize > data.length) break;

            if (chunkType == TYPE_ELEM_END && pos + 24 <= data.length) {
                int nameIdx = rInt(data, pos + 20);
                if (nameIdx == applicationIdx) {
                    appEndOff = pos;
                    break;
                }
            }
            pos += chunkSize;
        }
        if (appEndOff < 0) throw new Exception("</application> end element not found");

        // ---- Compute string data sizes ----
        // Existing string data length (from strStart to stylesStart or chunkEnd)
        int strDataLen;
        if (stylStart > 0) {
            strDataLen = stylStart - strStart;
        } else {
            strDataLen = spChunkSize - strStart;
        }

        // Encode new strings and compute their offsets
        byte[][] encodedNew = new byte[N][];
        int[] newStrOffs = new int[N];
        int cumOff = strDataLen; // new strings start after existing data
        for (int i = 0; i < N; i++) {
            encodedNew[i] = encodeString(newStrings.get(i), utf8);
            newStrOffs[i] = cumOff;
            cumOff += encodedNew[i].length;
        }

        // ---- Build activity XML element chunks ----
        ByteArrayOutputStream actXml = new ByteArrayOutputStream();
        for (int i = 0; i < toRegister.size(); i++) {
            int classIdx = classNameIndices.get(i);
            boolean addExported = (exportedAttrIdx >= 0);
            int attrCount = addExported ? 2 : 1;
            int elemSize = 36 + attrCount * 20;

            // StartElement
            wShort(actXml, TYPE_ELEM_START);
            wShort(actXml, 0x0010);         // headerSize = 16
            wInt(actXml, elemSize);
            wInt(actXml, 0);                // lineNumber
            wInt(actXml, 0xFFFFFFFF);       // comment = -1
            wInt(actXml, 0xFFFFFFFF);       // ns (none for <activity>)
            wInt(actXml, activityIdx);      // name = "activity"
            wShort(actXml, 0x0014);         // attributeStart = 20
            wShort(actXml, 0x0014);         // attributeSize = 20
            wShort(actXml, attrCount);
            wShort(actXml, 0);              // idIndex
            wShort(actXml, 0);              // classIndex
            wShort(actXml, 0);              // styleIndex

            // Attribute 1: android:name = "class.name"
            wInt(actXml, androidNsIdx);
            wInt(actXml, nameAttrIdx);
            wInt(actXml, classIdx);         // rawValue string index
            wShort(actXml, 0x0008);         // typedValue.size
            actXml.write(0x00);             // typedValue.res0
            actXml.write(VAL_STRING);       // typedValue.dataType
            wInt(actXml, classIdx);         // typedValue.data

            // Attribute 2 (optional): android:exported = false
            if (addExported) {
                wInt(actXml, androidNsIdx);
                wInt(actXml, exportedAttrIdx);
                wInt(actXml, 0xFFFFFFFF);   // rawValue = none
                wShort(actXml, 0x0008);
                actXml.write(0x00);
                actXml.write(VAL_BOOLEAN);
                wInt(actXml, 0);            // false
            }

            // EndElement
            wShort(actXml, TYPE_ELEM_END);
            wShort(actXml, 0x0010);
            wInt(actXml, 24);
            wInt(actXml, 0);
            wInt(actXml, 0xFFFFFFFF);
            wInt(actXml, 0xFFFFFFFF);       // ns
            wInt(actXml, activityIdx);      // name = "activity"
        }
        byte[] actChunks = actXml.toByteArray();

        // ---- Assemble new manifest ----
        // Build new string pool in a buffer (compute sizes dynamically)
        ByteArrayOutputStream spBuf = new ByteArrayOutputStream();

        // String pool header (will patch sizes after)
        wShort(spBuf, TYPE_STRING_POOL);
        wShort(spBuf, spHdrSize);
        wInt(spBuf, 0);                 // placeholder: chunkSize
        wInt(spBuf, strCount + N);      // updated stringCount
        wInt(spBuf, styleCount);
        wInt(spBuf, spFlags);
        wInt(spBuf, 0);                 // placeholder: stringsStart
        wInt(spBuf, 0);                 // placeholder: stylesStart

        // Original string offsets
        for (int i = 0; i < strCount; i++) wInt(spBuf, strOffs[i]);
        // New string offsets
        for (int i = 0; i < N; i++) wInt(spBuf, newStrOffs[i]);
        // Style offsets (if any)
        int styleOffsBase = offsBase + strCount * 4;
        for (int i = 0; i < styleCount; i++) {
            wInt(spBuf, rInt(data, styleOffsBase + i * 4));
        }

        // Record stringsStart position
        int newStringsStart = spBuf.size(); // relative to start of chunk

        // Original string data
        spBuf.write(data, strDataBase, strDataLen);
        // New string data
        for (int i = 0; i < N; i++) spBuf.write(encodedNew[i]);
        // Pad to 4-byte boundary
        while (spBuf.size() % 4 != 0) spBuf.write(0);

        // Style data (if any)
        int newStylesStart = 0;
        if (stylStart > 0 && styleCount > 0) {
            newStylesStart = spBuf.size();
            int styleDataLen = spChunkSize - stylStart;
            spBuf.write(data, spOff + stylStart, styleDataLen);
        }
        // Pad chunk to 4-byte boundary
        while (spBuf.size() % 4 != 0) spBuf.write(0);

        int newSpChunkSize = spBuf.size();

        // Patch the placeholder values
        byte[] spBytes = spBuf.toByteArray();
        writeIntAt(spBytes, 4, newSpChunkSize);
        writeIntAt(spBytes, 20, newStringsStart);
        writeIntAt(spBytes, 24, newStylesStart);

        // Assemble final manifest
        int xmlBeforeApp = appEndOff - xmlTreeStart;
        int xmlFromApp = data.length - appEndOff;
        int newFileSize = 8 + newSpChunkSize + rmChunkSize + xmlBeforeApp
                         + actChunks.length + xmlFromApp;

        ByteArrayOutputStream out = new ByteArrayOutputStream(newFileSize + 16);

        // File header
        wShort(out, TYPE_XML);
        wShort(out, 8);
        wInt(out, newFileSize);

        // String pool (rebuilt)
        out.write(spBytes);

        // Resource map (unchanged)
        if (rmChunkSize > 0) {
            out.write(data, rmOff, rmChunkSize);
        }

        // XML tree before </application>
        out.write(data, xmlTreeStart, xmlBeforeApp);

        // New activity elements
        out.write(actChunks);

        // XML tree from </application> to end
        out.write(data, appEndOff, xmlFromApp);

        byte[] result = out.toByteArray();
        Log.d(TAG, "  Manifest patched: " + data.length + " -> " + result.length +
              " bytes (" + toRegister.size() + " activities added)");
        return result;
    }

    // ======================== STRING ENCODING ========================

    private static String decodeString(byte[] data, int pos, boolean utf8) {
        try {
            if (utf8) {
                // charLen: 1 or 2 bytes (7-bit variable length)
                int charLen = data[pos] & 0xFF;
                if ((charLen & 0x80) != 0) {
                    charLen = ((charLen & 0x7F) << 8) | (data[pos + 1] & 0xFF);
                    pos++;
                }
                pos++;
                // byteLen: 1 or 2 bytes
                int byteLen = data[pos] & 0xFF;
                if ((byteLen & 0x80) != 0) {
                    byteLen = ((byteLen & 0x7F) << 8) | (data[pos + 1] & 0xFF);
                    pos++;
                }
                pos++;
                if (pos + byteLen > data.length) return "";
                return new String(data, pos, byteLen, "UTF-8");
            } else {
                int charLen = rShort(data, pos);
                pos += 2;
                if ((charLen & 0x8000) != 0) {
                    charLen = ((charLen & 0x7FFF) << 16) | rShort(data, pos);
                    pos += 2;
                }
                if (pos + charLen * 2 > data.length) return "";
                return new String(data, pos, charLen * 2, "UTF-16LE");
            }
        } catch (Exception e) {
            return "";
        }
    }

    private static byte[] encodeString(String s, boolean utf8) {
        try {
            ByteArrayOutputStream out = new ByteArrayOutputStream();
            if (utf8) {
                byte[] bytes = s.getBytes("UTF-8");
                int charLen = s.length();
                int byteLen = bytes.length;
                // Variable-length charLen
                if (charLen >= 0x80) {
                    out.write((charLen >> 8) | 0x80);
                    out.write(charLen & 0xFF);
                } else {
                    out.write(charLen);
                }
                // Variable-length byteLen
                if (byteLen >= 0x80) {
                    out.write((byteLen >> 8) | 0x80);
                    out.write(byteLen & 0xFF);
                } else {
                    out.write(byteLen);
                }
                out.write(bytes);
                out.write(0); // null terminator
            } else {
                byte[] bytes = s.getBytes("UTF-16LE");
                int charLen = s.length();
                if (charLen >= 0x8000) {
                    wShort(out, (charLen >> 16) | 0x8000);
                    wShort(out, charLen & 0xFFFF);
                } else {
                    wShort(out, charLen);
                }
                out.write(bytes);
                out.write(0); out.write(0); // null terminator (UTF-16)
            }
            return out.toByteArray();
        } catch (Exception e) {
            return new byte[0];
        }
    }

    private static int findStr(String[] strings, String target) {
        for (int i = 0; i < strings.length; i++) {
            if (target.equals(strings[i])) return i;
        }
        return -1;
    }

    // ======================== BINARY HELPERS ========================

    private static int rShort(byte[] d, int o) {
        return (d[o] & 0xFF) | ((d[o + 1] & 0xFF) << 8);
    }

    private static int rInt(byte[] d, int o) {
        return (d[o] & 0xFF) | ((d[o + 1] & 0xFF) << 8)
             | ((d[o + 2] & 0xFF) << 16) | ((d[o + 3] & 0xFF) << 24);
    }

    private static void wShort(OutputStream os, int v) throws IOException {
        os.write(v & 0xFF);
        os.write((v >> 8) & 0xFF);
    }

    private static void wInt(OutputStream os, int v) throws IOException {
        os.write(v & 0xFF);
        os.write((v >> 8) & 0xFF);
        os.write((v >> 16) & 0xFF);
        os.write((v >> 24) & 0xFF);
    }

    private static void writeIntAt(byte[] data, int off, int v) {
        data[off]     = (byte) (v & 0xFF);
        data[off + 1] = (byte) ((v >> 8) & 0xFF);
        data[off + 2] = (byte) ((v >> 16) & 0xFF);
        data[off + 3] = (byte) ((v >> 24) & 0xFF);
    }
}
