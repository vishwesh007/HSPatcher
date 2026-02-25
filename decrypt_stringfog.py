#!/usr/bin/env python3
"""
Comprehensive StringFog decryptor for HttpCanary Premium v3.3.6.

Decrypts ALL encrypted strings in smali files and replaces them inline,
removing the StringFog invocation and move-result-object instructions.

Algorithm (reverse-engineered from smali):
  sorted_ext_key recovered via known-plaintext attack (45 bytes)
  Even-length data: data[i] ^= key[kl-1-(i%kl)]
  Odd-length data:  data[n-1-j] ^= key[j%kl]
"""
import base64
import os
import re
import sys

# === RECOVERED KEY (158 bytes, from runtime extraction + extension) ===
# Sorted key: 154 bytes extracted via Log.d() hook on Arrays.sort() result
# Extension: [0x11, 0x22, 0x33, 0x44] (even-length sorted key → ﱱ appended)
SORTED_EXT_KEY = [
    129, 138, 140, 144, 144, 145, 145, 147, 147, 148,
    148, 148, 148, 150, 151, 151, 151, 151, 154, 154,
    155, 156, 156, 156, 156, 157, 157, 159, 159, 162,
    164, 165, 166, 166, 167, 167, 172, 174, 174, 175,
    177, 178, 179, 180, 181, 183, 183, 185, 189, 189,
    191, 191, 198, 198, 199, 199, 200, 200, 201, 201,
    202, 202, 203, 204, 204, 204, 204, 205, 205, 205,
    206, 206, 207, 207, 208, 209, 209, 209, 209, 211,
    212, 224, 224, 225, 225, 227, 228, 229, 229, 234,
    234, 238, 239, 239, 240, 241, 241, 242, 242, 243,
    243, 251, 251, 251, 253, 254, 254, 255, 255, 255,
    2, 6, 6, 11, 11, 11, 11, 11, 14, 22,
    25, 28, 33, 38, 39, 44, 53, 53, 53, 71,
    73, 78, 81, 82, 83, 86, 87, 89, 94, 94,
    94, 94, 96, 100, 108, 111, 111, 111, 117, 120,
    122, 124, 126, 127, 17, 34, 51, 68
]
KL = len(SORTED_EXT_KEY)  # 158

# StringFog class and method signature in smali
STRINGFOG_INVOKE = 'Lcom/guoshi/httpcanary/\ufc72;->\ufc70(Ljava/lang/String;)Ljava/lang/String;'


def decrypt_string(encoded):
    """Decrypt a StringFog-encrypted base64 string."""
    try:
        decoded = bytearray(base64.b64decode(encoded))
    except Exception:
        return None
    
    n = len(decoded)
    if n == 0:
        return ""
    
    if n % 2 == 0:
        # Even: data[i] ^= key[kl-1-(i%kl)]
        for i in range(n):
            ki = i % KL
            decoded[i] ^= SORTED_EXT_KEY[KL - 1 - ki]
    else:
        # Odd: data[n-1-j] ^= key[j%kl]
        for j in range(n):
            ki = j % KL
            decoded[n - 1 - j] ^= SORTED_EXT_KEY[ki]
    
    try:
        return decoded.decode('utf-8')
    except UnicodeDecodeError:
        return None


def escape_smali_string(s):
    """Escape a string for use in smali const-string."""
    result = []
    for ch in s:
        if ch == '"':
            result.append('\\"')
        elif ch == '\\':
            result.append('\\\\')
        elif ch == '\n':
            result.append('\\n')
        elif ch == '\r':
            result.append('\\r')
        elif ch == '\t':
            result.append('\\t')
        elif ch == '\0':
            result.append('\\0')
        elif ord(ch) < 0x20 or ord(ch) > 0x7e:
            # Use unicode escape for non-printable/non-ASCII
            code = ord(ch)
            if code <= 0xFFFF:
                result.append(f'\\u{code:04x}')
            else:
                # Surrogate pair for supplementary chars
                code -= 0x10000
                high = 0xD800 + (code >> 10)
                low = 0xDC00 + (code & 0x3FF)
                result.append(f'\\u{high:04x}\\u{low:04x}')
        else:
            result.append(ch)
    return ''.join(result)


def process_smali_file(filepath, dry_run=False):
    """Process a single smali file, decrypting all StringFog strings.
    
    Returns (replacements_count, failures_count).
    """
    with open(filepath, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    replacements = 0
    failures = 0
    modified = False
    
    # State machine to find the pattern:
    # 1. const-string vN, "encoded"
    # 2. invoke-static {vN}, StringFog decrypt
    # 3. move-result-object vM
    
    # We'll do multiple passes or use index-based scanning
    i = 0
    while i < len(lines):
        line = lines[i].strip()
        
        # Look for const-string followed (within a few lines) by StringFog invoke
        const_match = re.match(r'const-string(?:/jumbo)?\s+(v\d+|p\d+),\s*"(.*)"', line)
        if const_match:
            src_reg = const_match.group(1)
            encoded = const_match.group(2)
            const_line_idx = i
            
            # Look ahead for invoke-static within next 5 lines
            for j in range(i + 1, min(i + 6, len(lines))):
                invoke_line = lines[j].strip()
                
                # Check for StringFog invoke with matching register
                invoke_pattern = f'invoke-static {{{src_reg}}}, {re.escape(STRINGFOG_INVOKE)}'
                if invoke_line == f'invoke-static {{{src_reg}}}, {STRINGFOG_INVOKE}':
                    invoke_line_idx = j
                    
                    # Look for move-result-object within next 3 lines
                    for k in range(j + 1, min(j + 4, len(lines))):
                        move_line = lines[k].strip()
                        move_match = re.match(r'move-result-object\s+(v\d+|p\d+)', move_line)
                        if move_match:
                            target_reg = move_match.group(1)
                            move_line_idx = k
                            
                            # Try to decrypt
                            decrypted = decrypt_string(encoded)
                            if decrypted is not None:
                                escaped = escape_smali_string(decrypted)
                                
                                # Get original indentation
                                indent = lines[const_line_idx][:len(lines[const_line_idx]) - len(lines[const_line_idx].lstrip())]
                                
                                # Replace const-string with decrypted value, targeting the move-result register
                                if target_reg == src_reg:
                                    lines[const_line_idx] = f'{indent}const-string {target_reg}, "{escaped}"\n'
                                else:
                                    # Different target register - use target_reg
                                    lines[const_line_idx] = f'{indent}const-string {target_reg}, "{escaped}"\n'
                                
                                # NOP the invoke-static
                                invoke_indent = lines[invoke_line_idx][:len(lines[invoke_line_idx]) - len(lines[invoke_line_idx].lstrip())]
                                lines[invoke_line_idx] = f'{invoke_indent}nop\n'
                                
                                # NOP the move-result-object
                                move_indent = lines[move_line_idx][:len(lines[move_line_idx]) - len(lines[move_line_idx].lstrip())]
                                lines[move_line_idx] = f'{move_indent}nop\n'
                                
                                replacements += 1
                                modified = True
                            else:
                                failures += 1
                                rel = os.path.relpath(filepath)
                                print(f'  FAIL: {rel} L{const_line_idx+1}: "{encoded}"', file=sys.stderr)
                            
                            break
                    break
        i += 1
    
    if modified and not dry_run:
        with open(filepath, 'w', encoding='utf-8', newline='\n') as f:
            f.writelines(lines)
    
    return replacements, failures


def main():
    import argparse
    parser = argparse.ArgumentParser(description='Decrypt StringFog strings in HttpCanary smali files')
    parser.add_argument('--smali-dir', default='build_patched/smali',
                        help='Path to smali directory')
    parser.add_argument('--dry-run', action='store_true',
                        help='Only show what would be changed, do not modify files')
    parser.add_argument('--test', action='store_true',
                        help='Run verification tests only')
    parser.add_argument('--dump', action='store_true',
                        help='Dump all encrypted strings and their decryptions')
    args = parser.parse_args()
    
    if args.test:
        run_tests()
        return
    
    if args.dump:
        dump_all_strings(args.smali_dir)
        return
    
    print(f'StringFog Decryptor - Key length: {KL} bytes')
    print(f'Scanning: {args.smali_dir}')
    if args.dry_run:
        print('DRY RUN - no files will be modified')
    print()
    
    total_replacements = 0
    total_failures = 0
    total_files = 0
    modified_files = 0
    
    for root, dirs, files in os.walk(args.smali_dir):
        for fname in files:
            if not fname.endswith('.smali'):
                continue
            filepath = os.path.join(root, fname)
            total_files += 1
            
            replacements, failures = process_smali_file(filepath, args.dry_run)
            total_replacements += replacements
            total_failures += failures
            if replacements > 0:
                modified_files += 1
    
    print(f'\n=== Summary ===')
    print(f'Files scanned:    {total_files}')
    print(f'Files modified:   {modified_files}')
    print(f'Strings decrypted: {total_replacements}')
    print(f'Failures:          {total_failures}')


def run_tests():
    """Verify decryption against known pairs."""
    known = [
        ("9/7i3u3n5A==", "forName"),
        ("8PLj0vH3+PXh9vXc9eTk5eU=", "getDeclaredMethod"),
        ("+P337PP8ueTu5eDx+brF3sPk/uTl5+Q=", "dalvik.system.VMRuntime"),
        ("I1ZWQwoQCBMVEA==", "getRuntime"),
        ("N1ZWWRYaGB8WNB8GKhQBDS4qNzE3JA==", "setHiddenApiExemptions"),
        ("rg==", "/"),
        ("5OH34u3u5A==", "upgrade"),
        ("5vT88+Pn5A==", "welcome"),
    ]
    
    print("=== Verification Tests ===")
    all_ok = True
    for encoded, expected in known:
        result = decrypt_string(encoded)
        ok = result == expected
        status = "OK" if ok else "FAIL"
        print(f'  [{status}] "{encoded}" => "{result}" (expected: "{expected}")')
        if not ok:
            all_ok = False
    
    print(f'\nAll tests passed: {all_ok}')


def dump_all_strings(smali_dir):
    """Dump all encrypted strings found in smali files and their decryptions."""
    # Collect all unique encrypted strings
    all_encoded = set()
    
    for root, dirs, files in os.walk(smali_dir):
        for fname in files:
            if not fname.endswith('.smali'):
                continue
            filepath = os.path.join(root, fname)
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Find all const-string values that are followed by StringFog invoke
            lines = content.split('\n')
            for i, line in enumerate(lines):
                stripped = line.strip()
                const_match = re.match(r'const-string(?:/jumbo)?\s+(?:v\d+|p\d+),\s*"(.*)"', stripped)
                if const_match:
                    encoded = const_match.group(1)
                    # Check if followed by StringFog invoke
                    for j in range(i + 1, min(i + 6, len(lines))):
                        if STRINGFOG_INVOKE in lines[j]:
                            all_encoded.add(encoded)
                            break
    
    print(f'Unique encrypted strings: {len(all_encoded)}')
    print()
    
    ok_count = 0
    fail_count = 0
    
    for encoded in sorted(all_encoded):
        result = decrypt_string(encoded)
        if result is not None:
            # Check if result looks reasonable (mostly printable)
            printable_ratio = sum(1 for c in result if c.isprintable() or c in '\n\r\t') / max(len(result), 1)
            status = "OK" if printable_ratio > 0.8 else "??"
            if status == "OK":
                ok_count += 1
            else:
                fail_count += 1
            print(f'  [{status}] "{encoded}" => "{result}"')
        else:
            fail_count += 1
            print(f'  [FAIL] "{encoded}" => DECODE ERROR')
    
    print(f'\nOK: {ok_count}, Suspicious/Failed: {fail_count}')


if __name__ == '__main__':
    main()
