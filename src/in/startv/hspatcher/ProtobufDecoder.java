package in.startv.hspatcher;

import java.io.*;
import java.util.*;

/**
 * Minimal protobuf wire-format decoder (no .proto files or codegen needed).
 * Ported from gplaydl's pure-Python protobuf.py.
 * Supports varint (wire type 0), 64-bit (1), length-delimited (2), and 32-bit (5).
 */
public class ProtobufDecoder {

    private final byte[] data;
    private int pos;

    public ProtobufDecoder(byte[] data) {
        this.data = data;
        this.pos = 0;
    }

    /** A single decoded protobuf field: (fieldNumber, wireType, value). */
    public static class Field {
        public final int fieldNumber;
        public final int wireType;
        public final Object value; // Long for varint/fixed, byte[] for length-delimited

        public Field(int fieldNumber, int wireType, Object value) {
            this.fieldNumber = fieldNumber;
            this.wireType = wireType;
            this.value = value;
        }
    }

    /** Read all fields from the buffer. */
    public List<Field> readAll() {
        List<Field> fields = new ArrayList<>();
        while (pos < data.length) {
            try {
                long tag = readVarint();
                int wireType = (int) (tag & 0x07);
                int fieldNum = (int) (tag >>> 3);
                if (fieldNum == 0) break;

                Object value;
                switch (wireType) {
                    case 0: // varint
                        value = readVarint();
                        break;
                    case 1: // 64-bit fixed
                        value = readFixed64();
                        break;
                    case 2: // length-delimited
                        int len = (int) readVarint();
                        if (len < 0 || pos + len > data.length) return fields;
                        value = Arrays.copyOfRange(data, pos, pos + len);
                        pos += len;
                        break;
                    case 5: // 32-bit fixed
                        value = readFixed32();
                        break;
                    default:
                        return fields; // unknown wire type, stop
                }
                fields.add(new Field(fieldNum, wireType, value));
            } catch (Exception e) {
                break;
            }
        }
        return fields;
    }

    private long readVarint() {
        long result = 0;
        int shift = 0;
        while (pos < data.length) {
            int b = data[pos++] & 0xFF;
            result |= (long) (b & 0x7F) << shift;
            if ((b & 0x80) == 0) return result;
            shift += 7;
            if (shift >= 64) break;
        }
        return result;
    }

    private long readFixed64() {
        long val = 0;
        for (int i = 0; i < 8 && pos < data.length; i++) {
            val |= (long) (data[pos++] & 0xFF) << (i * 8);
        }
        return val;
    }

    private long readFixed32() {
        long val = 0;
        for (int i = 0; i < 4 && pos < data.length; i++) {
            val |= (long) (data[pos++] & 0xFF) << (i * 8);
        }
        return val;
    }

    // ======================== HELPERS ========================

    /** Get first string value for a given field number. */
    public static String firstString(List<Field> fields, int num) {
        for (Field f : fields) {
            if (f.fieldNumber == num && f.wireType == 2 && f.value instanceof byte[]) {
                try {
                    return new String((byte[]) f.value, "UTF-8");
                } catch (Exception e) {
                    return "";
                }
            }
        }
        return "";
    }

    /** Get first varint value for a given field number. Returns -1 if not found. */
    public static long firstInt(List<Field> fields, int num) {
        for (Field f : fields) {
            if (f.fieldNumber == num && f.wireType == 0 && f.value instanceof Long) {
                return (Long) f.value;
            }
        }
        return -1;
    }

    /** Get first bytes value for a given field number. */
    public static byte[] firstBytes(List<Field> fields, int num) {
        for (Field f : fields) {
            if (f.fieldNumber == num && f.wireType == 2 && f.value instanceof byte[]) {
                return (byte[]) f.value;
            }
        }
        return null;
    }

    /** Get all bytes values for a given field number. */
    public static List<byte[]> allBytes(List<Field> fields, int num) {
        List<byte[]> result = new ArrayList<>();
        for (Field f : fields) {
            if (f.fieldNumber == num && f.wireType == 2 && f.value instanceof byte[]) {
                result.add((byte[]) f.value);
            }
        }
        return result;
    }

    /** Navigate a nested protobuf path: e.g., navigate(raw, 1, 2, 4) → decoded fields at that path. */
    public static List<Field> navigate(byte[] raw, int... path) {
        byte[] current = raw;
        for (int fieldNum : path) {
            List<Field> fields = new ProtobufDecoder(current).readAll();
            byte[] sub = firstBytes(fields, fieldNum);
            if (sub == null) return Collections.emptyList();
            current = sub;
        }
        return new ProtobufDecoder(current).readAll();
    }

    /** Extract all UTF-8 strings from a protobuf blob (for fallback URL scanning). */
    public static List<String> extractStrings(byte[] raw) {
        List<String> strings = new ArrayList<>();
        extractStringsRecursive(raw, strings, 0);
        return strings;
    }

    private static void extractStringsRecursive(byte[] raw, List<String> out, int depth) {
        if (depth > 15) return;
        try {
            List<Field> fields = new ProtobufDecoder(raw).readAll();
            for (Field f : fields) {
                if (f.wireType == 2 && f.value instanceof byte[]) {
                    byte[] val = (byte[]) f.value;
                    try {
                        String s = new String(val, "UTF-8");
                        if (s.length() > 3 && isPrintable(s)) {
                            out.add(s);
                        }
                    } catch (Exception ignored) {}
                    if (val.length > 10) {
                        extractStringsRecursive(val, out, depth + 1);
                    }
                }
            }
        } catch (Exception ignored) {}
    }

    private static boolean isPrintable(String s) {
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            if (c < 0x20 && c != '\n' && c != '\r' && c != '\t') return false;
        }
        return true;
    }
}
