package in.startv.hspatcher;

import java.io.*;
import java.math.BigInteger;
import java.security.*;
import java.util.Date;
import javax.security.auth.x500.X500Principal;

/**
 * Minimal X.509 v3 self-signed certificate builder using raw DER encoding.
 * No BouncyCastle or sun.security dependencies — works on Android.
 */
public class CertBuilder {

    public static byte[] buildSelfSigned(PublicKey pub, PrivateKey priv,
                                          X500Principal subject,
                                          Date notBefore, Date notAfter) throws Exception {

        // TBSCertificate
        ByteArrayOutputStream tbs = new ByteArrayOutputStream();

        // version [0] EXPLICIT INTEGER v3 (2)
        tbs.write(explicit(0, derInteger(2)));

        // serialNumber INTEGER
        tbs.write(derInteger(new BigInteger("1")));

        // signature AlgorithmIdentifier: SHA256withRSA
        tbs.write(sha256WithRsaAlgId());

        // issuer = subject (self-signed)
        tbs.write(subject.getEncoded());

        // validity SEQUENCE { notBefore, notAfter }
        ByteArrayOutputStream validity = new ByteArrayOutputStream();
        validity.write(derUTCTime(notBefore));
        validity.write(derUTCTime(notAfter));
        tbs.write(derSequence(validity.toByteArray()));

        // subject
        tbs.write(subject.getEncoded());

        // subjectPublicKeyInfo (from the key itself)
        tbs.write(pub.getEncoded());

        byte[] tbsBytes = derSequence(tbs.toByteArray());

        // Sign TBSCertificate
        Signature sig = Signature.getInstance("SHA256withRSA");
        sig.initSign(priv);
        sig.update(tbsBytes);
        byte[] sigValue = sig.sign();

        // Certificate SEQUENCE { tbsCertificate, signatureAlgorithm, signatureValue }
        ByteArrayOutputStream cert = new ByteArrayOutputStream();
        cert.write(tbsBytes);
        cert.write(sha256WithRsaAlgId());
        cert.write(derBitString(sigValue));

        return derSequence(cert.toByteArray());
    }

    private static byte[] sha256WithRsaAlgId() {
        // SEQUENCE { OID 1.2.840.113549.1.1.11, NULL }
        byte[] oid = new byte[]{0x06, 0x09, 0x2A, (byte)0x86, 0x48, (byte)0x86, (byte)0xF7,
                                0x0D, 0x01, 0x01, 0x0B};
        byte[] nul = new byte[]{0x05, 0x00};
        return derSequence(concat(oid, nul));
    }

    private static byte[] derSequence(byte[] content) {
        return concat(new byte[]{0x30}, derLength(content.length), content);
    }

    private static byte[] derInteger(int val) {
        if (val < 0x80) return new byte[]{0x02, 0x01, (byte) val};
        byte[] b = BigInteger.valueOf(val).toByteArray();
        return concat(new byte[]{0x02}, derLength(b.length), b);
    }

    private static byte[] derInteger(BigInteger val) {
        byte[] b = val.toByteArray();
        return concat(new byte[]{0x02}, derLength(b.length), b);
    }

    private static byte[] derBitString(byte[] content) {
        // BIT STRING: tag 0x03, length, 0x00 (no unused bits), content
        byte[] inner = concat(new byte[]{0x00}, content);
        return concat(new byte[]{0x03}, derLength(inner.length), inner);
    }

    private static byte[] derUTCTime(Date date) {
        java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyMMddHHmmss'Z'");
        sdf.setTimeZone(java.util.TimeZone.getTimeZone("UTC"));
        byte[] timeBytes = sdf.format(date).getBytes();
        return concat(new byte[]{0x17}, derLength(timeBytes.length), timeBytes);
    }

    private static byte[] explicit(int tag, byte[] content) {
        byte tagByte = (byte)(0xA0 | tag);
        return concat(new byte[]{tagByte}, derLength(content.length), content);
    }

    private static byte[] derLength(int len) {
        if (len < 0x80) return new byte[]{(byte) len};
        if (len < 0x100) return new byte[]{(byte) 0x81, (byte) len};
        if (len < 0x10000) return new byte[]{(byte) 0x82, (byte)(len >> 8), (byte) len};
        return new byte[]{(byte) 0x83, (byte)(len >> 16), (byte)(len >> 8), (byte) len};
    }

    private static byte[] concat(byte[]... arrays) {
        int total = 0;
        for (byte[] a : arrays) total += a.length;
        byte[] result = new byte[total];
        int pos = 0;
        for (byte[] a : arrays) {
            System.arraycopy(a, 0, result, pos, a.length);
            pos += a.length;
        }
        return result;
    }
}
