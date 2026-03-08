#!/usr/bin/env python3
"""Patch agent.js on disk to add v3.46/v3.47 features that were missing."""
import os

AGENT_PATH = os.path.join(os.path.dirname(__file__), 'frida_agent', 'agent.js')

with open(AGENT_PATH, 'r', encoding='utf-8') as f:
    content = f.read()

original_size = len(content)
original_lines = content.count('\n')

# ============================================================
# PATCH 1: Insert Frida hiding + Anti-kill + PairIP bypass
# After: "console.log('[*] Piracy/License/Root bypass hooks installed');"
# Before: the blank lines + "// 3b. CRYPTO EXCEPTION RESILIENCE"
# ============================================================

FRIDA_ANCHOR = "console.log('[*] Piracy/License/Root bypass hooks installed');"
CRYPTO_ANCHOR = "        // =====================================================\n        // 3b. CRYPTO EXCEPTION RESILIENCE"

FRIDA_PAIRIP_BLOCK = r"""
        // =====================================================
        // 3a-ext. FRIDA DETECTION HIDING & PairIP BYPASS
        //   - Hide frida-related files, ports, and /proc artifacts
        //   - Block Runtime.exec commands that probe for frida
        //   - Prevent app self-kill via Process.killProcess / System.exit
        //   - Neutralize PairIP integrity check library if present
        // =====================================================

        // --- Frida file path hiding ---
        try {
            var File = Java.use('java.io.File');
            var _origFridaExists = File.exists;
            var _fridaPathSet = {};
            ['/data/local/tmp/frida-server', '/data/local/tmp/re.frida.server',
             '/data/local/tmp/frida-agent', '/data/local/tmp/frida-gadget',
             '/data/local/tmp/frida-helper', '/data/local/tmp/frida',
             '/sdcard/frida-server', '/system/lib/libfrida-gadget.so',
             '/system/lib64/libfrida-gadget.so',
             '/data/local/tmp/libfrida-gadget.so',
             '/data/local/tmp/libfrida-gadget-arm.so',
             '/data/local/tmp/libfrida-gadget-arm64.so'].forEach(function(p) { _fridaPathSet[p] = true; });
            // Extend existing File.exists hook (already hooked for root paths above)
            var _prevExistsImpl = File.exists.implementation;
            if (_prevExistsImpl) {
                File.exists.implementation = function() {
                    var path = this.getAbsolutePath();
                    if (_fridaPathSet[path]) {
                        console.log('[+] FRIDA-HIDE: Hiding frida path: ' + path);
                        return false;
                    }
                    return _prevExistsImpl.call(this);
                };
            }
        } catch (err) {
            console.log('[!] Frida path hiding hook error: ' + err);
        }

        // --- Frida port detection hiding (default port 27042) ---
        try {
            var InetAddress = Java.use('java.net.InetAddress');
            var Socket = Java.use('java.net.Socket');
            var origSocketInit = Socket.$init.overload('java.net.InetAddress', 'int');
            origSocketInit.implementation = function(addr, port) {
                if (port === 27042 || port === 27043) {
                    console.log('[+] FRIDA-HIDE: Blocking frida port probe: ' + port);
                    throw Java.use('java.net.ConnectException').$new('Connection refused');
                }
                return origSocketInit.call(this, addr, port);
            };
        } catch (err) { }

        // --- Block frida detection via Runtime.exec (extend existing hook) ---
        try {
            var Runtime2 = Java.use('java.lang.Runtime');
            var origExec2 = Runtime2.exec.overload('[Ljava.lang.String;');
            origExec2.implementation = function(cmdArr) {
                if (cmdArr !== null && cmdArr.length > 0) {
                    var joined = '';
                    for (var i = 0; i < cmdArr.length; i++) {
                        joined += cmdArr[i] + ' ';
                    }
                    var lower = joined.toLowerCase();
                    if (lower.indexOf('frida') !== -1 || lower.indexOf('gadget') !== -1 ||
                        lower.indexOf('27042') !== -1 || lower.indexOf('xposed') !== -1) {
                        console.log('[+] FRIDA-HIDE: Blocking detection exec: ' + joined.trim());
                        throw Java.use('java.io.IOException').$new('Permission denied');
                    }
                }
                return origExec2.call(this, cmdArr);
            };
        } catch (err) { }

        // --- Hide frida from /proc/self/maps reading ---
        try {
            var BufferedReader = Java.use('java.io.BufferedReader');
            var origReadLine = BufferedReader.readLine;
            origReadLine.implementation = function() {
                var line = origReadLine.call(this);
                if (line !== null) {
                    var s = '' + line;
                    if (s.indexOf('frida') !== -1 || s.indexOf('gadget') !== -1 ||
                        s.indexOf('LIBFRIDA') !== -1 || s.indexOf('linjector') !== -1) {
                        // Return empty string to hide frida from maps
                        return Java.use('java.lang.String').$new('');
                    }
                }
                return line;
            };
        } catch (err) { }

        // --- Prevent app self-kill ---
        try {
            var Process = Java.use('android.os.Process');
            var myPid = Process.myPid();
            Process.killProcess.implementation = function(pid) {
                if (pid === myPid) {
                    console.log('[+] ANTI-KILL: Blocked Process.killProcess(myPid) \u2014 app stays alive');
                    return;
                }
                Process.killProcess.call(this, pid);
            };
        } catch (err) { }

        try {
            var SystemClass = Java.use('java.lang.System');
            SystemClass.exit.implementation = function(code) {
                console.log('[+] ANTI-KILL: Blocked System.exit(' + code + ') \u2014 app stays alive');
                // Don't actually exit
            };
        } catch (err) { }

        // --- PairIP integrity check bypass ---
        // PairIP (libpairipcore.so) is an anti-tamper library used by some apps.
        // It validates APK signature/integrity and kills the app if modified.
        // Strategy: Hook its native init + Java entry points to neutralize it.
        try {
            var pairipLoaded = false;
            try {
                var pairipLib = Module.findBaseAddress('libpairipcore.so');
                if (pairipLib !== null) pairipLoaded = true;
            } catch(e) {}

            if (pairipLoaded) {
                console.log('[*] PAIRIP: libpairipcore.so detected \u2014 applying bypass');
                // Hook common PairIP entry functions
                var pairFuncs = ['pairip_start', 'pairip_init', 'Java_com_pairip_VMRunner_start',
                                 'Java_com_pairip_VMRunner_execute'];
                pairFuncs.forEach(function(fname) {
                    try {
                        var addr = Module.findExportByName('libpairipcore.so', fname);
                        if (addr) {
                            Interceptor.replace(addr, new NativeCallback(function() {
                                console.log('[+] PAIRIP: Neutralized ' + fname + '()');
                                return 0;
                            }, 'int', []));
                        }
                    } catch(e) {}
                });
            }

            // Also hook PairIP Java side if class exists
            try {
                var VMRunner = Java.use('com.pairip.VMRunner');
                VMRunner.start.implementation = function() {
                    console.log('[+] PAIRIP: Blocked VMRunner.start()');
                };
            } catch(e) { /* Class not present \u2014 OK */ }
            try {
                var VMRunner2 = Java.use('com.pairip.VMRunner');
                VMRunner2.execute.implementation = function() {
                    console.log('[+] PAIRIP: Blocked VMRunner.execute()');
                };
            } catch(e) { /* Class not present \u2014 OK */ }

        } catch (err) {
            console.log('[!] PairIP bypass error: ' + err);
        }

        console.log('[*] Frida hiding + Anti-kill + PairIP bypass installed');

"""

# Check if already patched
if 'FRIDA DETECTION HIDING' not in content:
    # Find anchor and insert
    idx = content.find(FRIDA_ANCHOR)
    if idx == -1:
        print("ERROR: Could not find Frida anchor in agent.js")
        exit(1)
    # Find end of the anchor line
    anchor_end = content.index('\n', idx) + 1
    # Find the crypto section start
    crypto_idx = content.find(CRYPTO_ANCHOR)
    if crypto_idx == -1:
        print("ERROR: Could not find CRYPTO anchor in agent.js")
        exit(1)
    # Replace the gap between anchor and crypto section with our new block
    content = content[:anchor_end] + FRIDA_PAIRIP_BLOCK + "\n" + content[crypto_idx:]
    print("PATCH 1: Inserted Frida hiding + Anti-kill + PairIP bypass section")
else:
    print("PATCH 1: Already applied (Frida hiding section exists)")

# ============================================================
# PATCH 2: Replace updateBlockingNotification with nm.cancel version
# ============================================================

OLD_UPDATE_FN = """        function updateBlockingNotification() {
            try {
                var ctx = Java.use('android.app.ActivityThread').currentApplication();
                if (ctx === null) return;
                var context = Java.cast(ctx, Java.use('android.content.Context'));

                var Intent = Java.use('android.content.Intent');"""

NEW_UPDATE_FN = """        function updateBlockingNotification() {
            try {
                var ctx = Java.use('android.app.ActivityThread').currentApplication();
                if (ctx === null) return;
                var context = Java.cast(ctx, Java.use('android.content.Context'));

                var nm = Java.cast(context.getSystemService(Java.use('java.lang.String').$new('notification')),
                                   Java.use('android.app.NotificationManager'));

                // Only show notification when blocking is enabled
                if (!trafficMonitorEnabled) {
                    nm.cancel(NOTIF_ID);
                    return;
                }

                var Intent = Java.use('android.content.Intent');"""

if OLD_UPDATE_FN in content:
    content = content.replace(OLD_UPDATE_FN, NEW_UPDATE_FN, 1)
    print("PATCH 2a: Added nm.cancel(NOTIF_ID) when blocking OFF")
else:
    print("PATCH 2a: Already applied or anchor not found")

# Also fix the title/text to be ON-only and the action label 
OLD_TITLE_BLOCK = """                var title = trafficMonitorEnabled
                    ? '\\uD83D\\uDEE1 Blocking: ON'
                    : '\\uD83D\\uDEE1 Blocking: OFF';
                var modeStr = networkFilterMode === 0 ? 'Blacklist' : 'Whitelist';
                var hostCount = Object.keys(discoveredHosts).length;
                var text = trafficMonitorEnabled
                    ? 'Mode: ' + modeStr + ' \\u2022 ' + hostCount + ' hosts \\u2022 Tap to disable'
                    : 'Blocking disabled \\u2022 Tap to enable';"""

NEW_TITLE_BLOCK = """                var title = '\\uD83D\\uDEE1 Blocking: ON';
                var modeStr = networkFilterMode === 0 ? 'Blacklist' : 'Whitelist';
                var hostCount = Object.keys(discoveredHosts).length;
                var text = 'Mode: ' + modeStr + ' \\u2022 ' + hostCount + ' hosts \\u2022 Tap to disable';"""

if OLD_TITLE_BLOCK in content:
    content = content.replace(OLD_TITLE_BLOCK, NEW_TITLE_BLOCK, 1)
    print("PATCH 2b: Simplified notification title/text (ON-only)")
else:
    print("PATCH 2b: Title block already patched or different format")

# Fix action label to be non-conditional
OLD_ACTION = "                var actionLabel = trafficMonitorEnabled ? '\\u274C Turn OFF' : '\\u2705 Turn ON';"
NEW_ACTION = "                var actionLabel = '\\u274C Turn OFF';"

if OLD_ACTION in content:
    content = content.replace(OLD_ACTION, NEW_ACTION, 1)
    print("PATCH 2c: Simplified action label (Turn OFF only)")
else:
    print("PATCH 2c: Action label already patched or different format")

# Move nm.notify before the catch - replace the old nm creation + notify block
OLD_NM_NOTIFY = """                var nm = Java.cast(context.getSystemService(Java.use('java.lang.String').$new('notification')),
                                   Java.use('android.app.NotificationManager'));
                nm.notify(NOTIF_ID, builder.build());"""
NEW_NM_NOTIFY = """                nm.notify(NOTIF_ID, builder.build());"""

if OLD_NM_NOTIFY in content:
    content = content.replace(OLD_NM_NOTIFY, NEW_NM_NOTIFY, 1)
    print("PATCH 2d: Removed duplicate nm creation (now uses early-created nm)")
else:
    print("PATCH 2d: nm.notify already patched or different format")


# ============================================================
# PATCH 3: Insert DEBUG_NOTIF_ID + showDebugPanelNotification function
# Before: "function isDomainRule(pattern) {"
# ============================================================

DOMAIN_RULE_ANCHOR = "        // Separate domain-only rules from path rules for smarter matching\n        // Domain rules: no '/' "

SHOW_DEBUG_NOTIF_BLOCK = """        var DEBUG_NOTIF_ID = 19731;
        var DEBUG_NOTIF_CHANNEL = 'hspatch_debug';

        function showDebugPanelNotification(context, nm) {
            try {
                // Create debug panel notification channel
                var NotificationChannel = Java.use('android.app.NotificationChannel');
                var ch = NotificationChannel.$new(
                    Java.use('java.lang.String').$new(DEBUG_NOTIF_CHANNEL),
                    Java.cast(Java.use('java.lang.String').$new('HSPatch Debug Panel'), Java.use('java.lang.CharSequence')),
                    2); // IMPORTANCE_LOW \u2014 no sound
                ch.setDescription(Java.use('java.lang.String').$new('Quick access to HSPatch Debug Panel'));
                nm.createNotificationChannel(ch);

                // Create intent to open DebugPanelActivity using actual package name
                var Intent = Java.use('android.content.Intent');
                var PendingIntent = Java.use('android.app.PendingIntent');
                var ComponentName = Java.use('android.content.ComponentName');

                var pkgName = context.getPackageName();
                var launchIntent = Intent.$new();
                launchIntent.setComponent(ComponentName.$new(
                    pkgName,
                    Java.use('java.lang.String').$new('in.startv.hotstar.DebugPanelActivity')));
                launchIntent.setFlags(0x10000000); // FLAG_ACTIVITY_NEW_TASK

                var piFlags = 0x08000000 | 0x04000000; // FLAG_UPDATE_CURRENT | FLAG_IMMUTABLE
                var pi = PendingIntent.getActivity(context, 1, launchIntent, piFlags);

                var Builder = Java.use('android.app.Notification$Builder');
                var builder = Builder.$new(context, Java.use('java.lang.String').$new(DEBUG_NOTIF_CHANNEL));

                var iconId = 17301624;
                try { iconId = context.getApplicationInfo().icon.value; } catch(e) {}
                if (iconId === 0) iconId = 17301624; // fallback to system icon

                builder.setSmallIcon(iconId);
                builder.setContentTitle(Java.use('java.lang.String').$new('\\uD83D\\uDEE0 HSPatch Debug Panel'));
                builder.setContentText(Java.use('java.lang.String').$new('Tap to open debug panel \\u2022 File explorer \\u2022 Logs'));
                builder.setOngoing(true);
                builder.setContentIntent(pi);

                nm.notify(DEBUG_NOTIF_ID, builder.build());
                Log.i(netLogTag, '[DEBUG] Debug panel persistent notification shown (pkg=' + pkgName + ')');
            } catch(e) {
                Log.e(netLogTag, '[DEBUG] Debug panel notification error: ' + e);
            }
        }

"""

if 'DEBUG_NOTIF_ID' not in content:
    idx = content.find(DOMAIN_RULE_ANCHOR)
    if idx == -1:
        # Try alternate anchor
        idx = content.find("function isDomainRule(pattern)")
        if idx == -1:
            print("ERROR: Could not find isDomainRule anchor")
            exit(1)
        # Back up to find the comment before it
        idx = content.rfind('\n', 0, idx) + 1  # Start of isDomainRule line
        # Go back one more line for the comment
        idx2 = content.rfind('\n', 0, idx - 1)
        if idx2 != -1:
            prev_line = content[idx2+1:idx].strip()
            if prev_line.startswith('//'):
                idx = idx2 + 1  # Include the comment
    content = content[:idx] + SHOW_DEBUG_NOTIF_BLOCK + content[idx:]
    print("PATCH 3: Inserted DEBUG_NOTIF_ID + showDebugPanelNotification function")
else:
    print("PATCH 3: Already applied (DEBUG_NOTIF_ID exists)")


# Write back
with open(AGENT_PATH, 'w', encoding='utf-8', newline='\n') as f:
    f.write(content)

new_size = len(content)
new_lines = content.count('\n')
print(f"\nDone! {original_size} -> {new_size} bytes, {original_lines} -> {new_lines} lines")

# Verify
for pattern in ['DEBUG_NOTIF_ID', 'pairip', 'ANTI-KILL', 'showDebugPanelNotification', 'nm.cancel', 'killProcess', 'ComponentName']:
    found = pattern in content
    print(f"  {pattern}: {'OK' if found else 'MISSING!'}")
