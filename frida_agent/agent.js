import Java from "frida-java-bridge";

/*
 * HSPatch Universal Frida Script v3.53
 * - SSL Certificate Pinning Bypass (Java + Native BoringSSL + Cronet)
 * - Security Error Dialog Suppression (JSON config + runtime fallback)
 * - Signature Verification Bypass (runtime layer)
 * - Piracy / License / Integrity Checks Removal
 * - Screenshot / Recording FLAG_SECURE Bypass
 * - Crypto Exception Resilience (Cipher.doFinal BadPaddingException safety net)
 * - Network Traffic Monitoring, Blocking & Modification
 * - URL Preparation-Time Content Blocker (URL.$init, URI.create, Uri.parse,
 *   HttpUrl.parse/get, Retrofit.baseUrl, OkHttp3, Cronet, WebView, DNS)
 * - WebSocket Kill Switch (toggle via Debug Panel)
 * - Frida Stealth (anti-detection: /proc/maps, threads, ports, files)
 *
 * NOTE: Uses performNow() on Android 16+ (ART already attached to thread),
 * falls back to Java.perform() on older versions (Android 10+) where ART
 * may not yet be attached. Java bridge imported for Frida 17+ support.
 */

function _hspatchMain() {
    var TAG = "HSPatch-Frida";

    // Diagnostic: log Frida script engine status
    try {
        var AndroidLog = Java.use('android.util.Log');
        AndroidLog.i(TAG, 'HSPatch callback FIRED - SDK=' + Java.use('android.os.Build$VERSION').SDK_INT.value);
    } catch(e) {}

        console.log('');
        console.log('======================================================');
        console.log('[#] HSPatch Universal Bypass Suite v3.52              [#]');
        console.log('======================================================');

        // =====================================================
        // CACHED CLASS REFERENCES (performance optimization)
        // Java.use() does ART class resolution on every call.
        // Caching eliminates microseconds of overhead per lookup
        // in hot-path functions called 100s of times/sec.
        // =====================================================
        var _classCache = {};
        function _cls(name) {
            if (!_classCache[name]) _classCache[name] = Java.use(name);
            return _classCache[name];
        }

        // Cached app context (lazy-init, survives app lifetime)
        var _appCtx = null;
        function _getCtx() {
            if (_appCtx === null) {
                try { _appCtx = _cls('android.app.ActivityThread').currentApplication(); } catch(e) {}
            }
            return _appCtx;
        }

        // Pre-cached Java strings for SharedPreferences keys (avoid allocation per read)
        var _jStr = {};
        function _jstr(s) {
            if (!_jStr[s]) _jStr[s] = Java.use('java.lang.String').$new(s);
            return _jStr[s];
        }


        // =====================================================
        // 0. CA CERTIFICATE DUMP (from embedded assets)
        //    Dumps assets/user_ca.crt to /data/local/tmp/
        // =====================================================
        try {
            var context = Java.use('android.app.ActivityThread').currentApplication().getApplicationContext();
            var assetMgr = context.getAssets();
            try {
                var is = assetMgr.open('user_ca.crt');
                var File = Java.use('java.io.File');
                var FileOutputStream = Java.use('java.io.FileOutputStream');
                var outPath = '/data/local/tmp/user_ca.crt';
                var fos = FileOutputStream.$new(outPath);
                var buf = Java.array('byte', new Array(4096).fill(0));
                var n;
                while ((n = is.read(buf)) !== -1) {
                    fos.write(buf, 0, n);
                }
                fos.close();
                is.close();
                console.log('[+] CA cert dumped to ' + outPath);
            } catch (assetErr) {
                console.log('[*] No embedded CA cert (assets/user_ca.crt not found)');
            }
        } catch (ctxErr) {
            console.log('[!] Could not dump CA cert: ' + ctxErr);
        }

        // =====================================================
        // 1. SSL CERTIFICATE PINNING BYPASS (Universal)
        //    PERMANENT — always enabled, no file toggle
        //    Ref: httptoolkit/frida-interception-and-unpinning
        // =====================================================

        var Log = Java.use('android.util.Log');

        // SSL bypass is PERMANENT — always enabled, no file toggle
        {
            // Trust-all X509TrustManager (created once, reused everywhere)
            var _TrustAll = Java.registerClass({
                name: 'com.hspatch.ssl.TrustAll',
                implements: [Java.use('javax.net.ssl.X509TrustManager')],
                methods: {
                    checkClientTrusted: function(chain, authType) {},
                    checkServerTrusted: function(chain, authType) {},
                    getAcceptedIssuers: function() { return []; }
                }
            });
            var _ta = _TrustAll.$new();

            // Accept-all HostnameVerifier (created once)
            var _HVAll = Java.registerClass({
                name: 'com.hspatch.ssl.HVAll',
                implements: [Java.use('javax.net.ssl.HostnameVerifier')],
                methods: { verify: function() { return true; } }
            });
            var _hv = _HVAll.$new();

            // (a) SSLContext.init — THE most critical hook. Every HTTPS library
            //     ultimately calls this to configure TLS trust.
            var _sslCtxHooked = false;
            try {
                var _SSLCtx = Java.use('javax.net.ssl.SSLContext');
                _SSLCtx.init.overload('[Ljavax.net.ssl.KeyManager;', '[Ljavax.net.ssl.TrustManager;', 'java.security.SecureRandom')
                    .implementation = function(km, tm, sr) { this.init(km, [_ta], sr); };
                _sslCtxHooked = true;
                Log.d(TAG, '[+] SSLContext.init hooked');
            } catch(e) { Log.w(TAG, '[-] SSLContext.init: ' + e); }

            // (a2) SSLContext.getDefault + SSLSocketFactory.getDefault — catch pre-initialized contexts
            try {
                var _trustAllCtx = Java.use('javax.net.ssl.SSLContext').getInstance('TLS');
                _trustAllCtx.init(null, [_ta], null);
                var _trustAllFactory = _trustAllCtx.getSocketFactory();
                try {
                    Java.use('javax.net.ssl.SSLSocketFactory').getDefault.implementation = function() {
                        return _trustAllFactory;
                    };
                    Log.d(TAG, '[+] SSLSocketFactory.getDefault hooked');
                } catch(e) {}
                try {
                    Java.use('javax.net.ssl.SSLContext').getDefault.implementation = function() {
                        return _trustAllCtx;
                    };
                    Log.d(TAG, '[+] SSLContext.getDefault hooked');
                } catch(e) {}
            } catch(e) { Log.d(TAG, '[-] default context hook: ' + e); }

            // (b) TrustManagerFactory.getTrustManagers — return trust-all
            try {
                Java.use('javax.net.ssl.TrustManagerFactory').getTrustManagers
                    .implementation = function() { return [_ta]; };
                Log.d(TAG, '[+] TrustManagerFactory.getTrustManagers hooked');
            } catch(e) {}

            // (c) TrustManagerImpl (Conscrypt) — Android's built-in TLS verifier
            var _tmiHooks = 0;
            try {
                var TMI = Java.use('com.android.org.conscrypt.TrustManagerImpl');
                // verifyChain — primary path on Android 7+ (returns List<X509Certificate>)
                try { TMI.verifyChain.implementation = function() {
                    var chain = arguments[0];
                    var al = Java.use('java.util.ArrayList').$new();
                    if (chain) { for (var ci = 0; ci < chain.length; ci++) al.add(chain[ci]); }
                    return al;
                }; _tmiHooks++; } catch(e) {}
                // checkTrustedRecursive — older path
                try { TMI.checkTrustedRecursive.implementation = function() {
                    return Java.use('java.util.ArrayList').$new();
                }; _tmiHooks++; } catch(e) {}
                // checkServerTrusted — multiple overloads
                try { TMI.checkServerTrusted.overload('[Ljava.security.cert.X509Certificate;', 'java.lang.String')
                    .implementation = function(certs, authType) { return Java.use('java.util.Arrays').asList(certs); }; _tmiHooks++; } catch(e) {}
                try { TMI.checkServerTrusted.overload('[Ljava.security.cert.X509Certificate;', 'java.lang.String', 'java.lang.String')
                    .implementation = function(certs, authType, host) { return Java.use('java.util.Arrays').asList(certs); }; _tmiHooks++; } catch(e) {}
                try { TMI.checkServerTrusted.overload('[Ljava.security.cert.X509Certificate;', 'java.lang.String', 'javax.net.ssl.SSLSession')
                    .implementation = function(certs, authType, session) { return Java.use('java.util.Arrays').asList(certs); }; _tmiHooks++; } catch(e) {}
                Log.d(TAG, '[+] TrustManagerImpl: ' + _tmiHooks + ' hooks installed');
            } catch(e) { Log.w(TAG, '[-] TrustManagerImpl: ' + e); }

            // (d) Conscrypt socket-level cert chain verification (covers all socket impls)
            var _conscryptSockets = [
                'com.android.org.conscrypt.OpenSSLSocketImpl',
                'com.android.org.conscrypt.ConscryptFileDescriptorSocket',
                'com.android.org.conscrypt.ConscryptEngineSocket'
            ];
            var _csHooked = 0;
            for (var _csi = 0; _csi < _conscryptSockets.length; _csi++) {
                try { Java.use(_conscryptSockets[_csi]).verifyCertificateChain.implementation = function() {}; _csHooked++; } catch(e) {}
            }
            Log.d(TAG, '[+] Conscrypt sockets: ' + _csHooked + '/3 hooked');

            // Additional Conscrypt hooks: AbstractConscryptSocket, ConscryptEngine, Platform
            var _extraConscryptClasses = [
                'com.android.org.conscrypt.AbstractConscryptSocket',
                'com.android.org.conscrypt.ConscryptEngine',
                'com.android.org.conscrypt.Platform',
                'com.android.org.conscrypt.NativeSsl'
            ];
            for (var eci = 0; eci < _extraConscryptClasses.length; eci++) {
                try {
                    var EC = Java.use(_extraConscryptClasses[eci]);
                    try { EC.verifyCertificateChain.overloads.forEach(function(ov) {
                        ov.implementation = function() {};
                    }); Log.d(TAG, '[+] ' + _extraConscryptClasses[eci] + '.verifyCertificateChain hooked'); } catch(e) {}
                    try { EC.checkServerTrusted.overloads.forEach(function(ov) {
                        ov.implementation = function() { return Java.use('java.util.Collections').emptyList(); };
                    }); Log.d(TAG, '[+] ' + _extraConscryptClasses[eci] + '.checkServerTrusted hooked'); } catch(e) {}
                } catch(e) {}
            }

            // (e) Conscrypt CertPinManager + CertificateTransparency
            try { var CPM = Java.use('com.android.org.conscrypt.CertPinManager');
                try { CPM.isChainValid.implementation = function() { return true; }; } catch(e) {}
                try { CPM.checkChainPinning.implementation = function() {}; } catch(e) {}
            } catch(e) {}
            try { Java.use('com.android.org.conscrypt.ct.CertificateTransparency').checkCT.implementation = function() {}; } catch(e) {}

            // (f) HttpsURLConnection — hostname + socket factory overrides
            try { var HC = Java.use('javax.net.ssl.HttpsURLConnection');
                try { HC.setDefaultHostnameVerifier.implementation = function(v) { this.setDefaultHostnameVerifier(_hv); }; } catch(e) {}
                try { HC.setHostnameVerifier.implementation = function(v) { this.setHostnameVerifier(_hv); }; } catch(e) {}
                try { HC.setSSLSocketFactory.implementation = function() {}; } catch(e) {}
            } catch(e) {}

            // (g) OkHttp3 CertificatePinner — all check overloads
            try { var CP = Java.use('okhttp3.CertificatePinner');
                try { CP.check.overload('java.lang.String', 'java.util.List').implementation = function() {}; } catch(e) {}
                try { CP.check.overload('java.lang.String', 'java.security.cert.Certificate').implementation = function() {}; } catch(e) {}
                try { CP.check.overload('java.lang.String', '[Ljava.security.cert.Certificate;').implementation = function() {}; } catch(e) {}
                try { CP['check$okhttp'].implementation = function() {}; } catch(e) {}
            } catch(e) {}

            // (g2) Cronet CronetEngine.Builder — bypass QUIC + PKP
            try {
                var CronetBuilder = Java.use('org.chromium.net.CronetEngine$Builder');
                CronetBuilder.build.implementation = function() {
                    try { this.enablePublicKeyPinningBypassForLocalTrustAnchors(true); } catch(e) {}
                    try { this.enableQuic(false); } catch(e) {}
                    return this.build();
                };
                Log.d(TAG, '[+] CronetEngine.Builder.build hooked (PKP bypass + QUIC off)');
            } catch(e) {}
            try {
                var ExpBuilder = Java.use('org.chromium.net.ExperimentalCronetEngine$Builder');
                ExpBuilder.build.implementation = function() {
                    try { this.enablePublicKeyPinningBypassForLocalTrustAnchors(true); } catch(e) {}
                    try { this.enableQuic(false); } catch(e) {}
                    return this.build();
                };
                Log.d(TAG, '[+] ExperimentalCronetEngine.Builder.build hooked');
            } catch(e) {}

            // (h) Android vendored OkHttp v2 — hostname verifier
            try { Java.use('com.android.okhttp.internal.tls.OkHostnameVerifier')
                .verify.overload('java.lang.String', 'javax.net.ssl.SSLSession')
                .implementation = function() { return true; }; } catch(e) {}

            // (i) NetworkSecurityConfig — remove certificate pin sets
            try {
                var _EP = Java.use('android.security.net.config.PinSet').EMPTY_PINSET.value;
                Java.use('android.security.net.config.NetworkSecurityConfig').$init.overloads
                    .forEach(function(ov) {
                        ov.implementation = function() {
                            try { arguments[2] = _EP; } catch(e2) {}
                            ov.call(this, arguments[0], arguments[1], arguments[2],
                                arguments[3], arguments[4], arguments[5], arguments[6]);
                        };
                    });
            } catch(e) {}

            Log.i(TAG, '[*] SSL bypass PERMANENT: SSLContext + TrustManager + Conscrypt + OkHttp + NetSecCfg');

            // =====================================================
            // 1a-2. SECURITY ERROR DIALOG SUPPRESSION
            //       The "Security error" dialog is now neutralized at APK level
            //       by PatchEngine (JSON config patching), so this is a BEST-EFFORT
            //       runtime fallback. Uses delayed Java.enumerateLoadedClasses to
            //       find the obfuscated class dynamically (name changes per release).
            // =====================================================

            // v3.42: REMOVED attemptErrorMapperHook() — it called
            // Java.enumerateMethods('*!a/s') which scans ALL methods in ALL classes,
            // taking seconds and causing startup lag/ANR. The NET_201/security error
            // is fully handled by PatchEngine's JSON config patching at APK level.

            // Suppress SSLHandshakeException at Java level
            try {
                var SSLHandshakeException = Java.use('javax.net.ssl.SSLHandshakeException');
                SSLHandshakeException.$init.overload('java.lang.String').implementation = function(msg) {
                    Log.i(TAG, '[!] SSLHandshakeException SUPPRESSED: ' + msg);
                    this.$init(msg);
                };
            } catch(eSSL) {}

            // v3.42: REMOVED hookCronetCallbacks() with enumerateLoadedClasses —
            // iterating ALL loaded classes is extremely expensive (~5000+ classes).
            // SSL errors are already suppressed at TrustManager/BoringSSL level.
            // Any remaining Cronet SSL errors are non-fatal after SSL bypass.

            // Enhanced SSLPeerUnverifiedException + dynamic CertificatePinner discovery
            try {
                var SSLPeerUnverified = Java.use('javax.net.ssl.SSLPeerUnverifiedException');
                var _pinnerPatched = false;
                SSLPeerUnverified.$init.overload('java.lang.String').implementation = function(msg) {
                    var truncMsg = msg ? (msg.length > 100 ? msg.substring(0, 100) + '...' : msg) : '';
                    Log.i(TAG, '[!] SSLPeerUnverifiedException SUPPRESSED: ' + truncMsg);

                    // Dynamic CertificatePinner discovery: on first pinning failure,
                    // walk the stack to find the obfuscated pinner class & hook it.
                    if (!_pinnerPatched && msg && msg.indexOf('pinning') !== -1) {
                        try {
                            var stack = Java.use('java.lang.Thread').currentThread().getStackTrace();
                            for (var si = 0; si < stack.length && si < 25; si++) {
                                var cls = stack[si].getClassName();
                                var method = stack[si].getMethodName();
                                if (cls.startsWith('java.') || cls.startsWith('javax.') ||
                                    cls.startsWith('dalvik.') || cls.indexOf('hspatch') !== -1) continue;

                                // The direct caller of new SSLPeerUnverifiedException is the pinner
                                try {
                                    var PinnerCls = Java.use(cls);
                                    var targetMethod = PinnerCls[method];
                                    if (targetMethod && targetMethod.overloads) {
                                        var hooked = false;
                                        targetMethod.overloads.forEach(function(ov) {
                                            if (ov.returnType.className === 'void') {
                                                ov.implementation = function() {};
                                                hooked = true;
                                            }
                                        });
                                        if (hooked) {
                                            _pinnerPatched = true;
                                            Log.i(TAG, '[PIN] PATCHED obfuscated CertificatePinner: ' + cls + '.' + method + '()');
                                            break;
                                        }
                                    }
                                } catch(hookE) {}
                            }
                        } catch(stackE) {
                            Log.w(TAG, '[PIN] Stack analysis error: ' + stackE);
                        }
                    }
                    this.$init(msg);
                };
            } catch(ePeer) {}


            // ── NET_201 Runtime Suppression ──────────────────────
            // v3.42: REMOVED JSONObject.getString/optString hooks — they ran on
            // EVERY JSON string read in the entire app (thousands per API response),
            // causing severe performance overhead. NET_201 is handled at APK level
            // by PatchEngine JSON file patching, which is permanent and zero-cost.

            // Hook AlertDialog.Builder to suppress security error dialogs
            try {
                var AlertDialogBuilder = Java.use('android.app.AlertDialog$Builder');
                var _setTitle = AlertDialogBuilder.setTitle.overload('java.lang.CharSequence');
                _setTitle.implementation = function(title) {
                    var t = title ? title.toString() : '';
                    if (t === 'Security error' || t.indexOf('security error') !== -1 ||
                        t.indexOf('Security Error') !== -1) {
                        Log.i(TAG, '[!] Security error dialog SUPPRESSED (title: ' + t + ')');
                        return _setTitle.call(this, 'Connection issue');
                    }
                    return _setTitle.call(this, title);
                };

                var _setMessage = AlertDialogBuilder.setMessage.overload('java.lang.CharSequence');
                _setMessage.implementation = function(msg) {
                    var m = msg ? msg.toString() : '';
                    if (m.indexOf('interfering with your secure connection') !== -1 ||
                        m.indexOf('security') !== -1 && m.indexOf('connection') !== -1) {
                        Log.i(TAG, '[!] Security error message SUPPRESSED');
                        return _setMessage.call(this, 'Please check your network and retry.');
                    }
                    return _setMessage.call(this, msg);
                };
                Log.i(TAG, '[+] AlertDialog security error suppression active');
            } catch(eDialog) {
                Log.d(TAG, '[-] AlertDialog hook: ' + eDialog);
            }
        }

        // =====================================================
        // 1b. NATIVE BoringSSL CERTIFICATE BYPASS (Cronet/libssl)
        //     Hooks SSL_CTX_set_custom_verify & SSL_set_custom_verify
        //     to always return SSL_VERIFY_OK (0).
        //     For libwebviewchromium.so, uses enumerateSymbols() to find
        //     non-exported BoringSSL symbols (statically linked).
        //     Ref: httptoolkit/frida-interception-and-unpinning/native-tls-hook.js
        // =====================================================

        var SSL_VERIFY_OK = 0;
        var SSL_VERIFY_NONE = 0;
        var _nativeSslHooked = 0;

        // Helper: find a function address by exported name only.
        // NOTE: enumerateSymbols() removed — it causes SIGSEGV (null FILE*
        // in __fseeko64) on certain modules (libwebviewchromium.so, etc.)
        // when Frida reads ELF symbol tables from /proc/self/maps.
        function findSSLFunction(mod, fnName) {
            try {
                return mod.findExportByName(fnName);
            } catch(e) {
                return null;
            }
        }

        function patchNativeSSLVerify(libName) {
            var mod = null;
            try { mod = Process.getModuleByName(libName); } catch (e) { return 0; }
            if (!mod) return 0;

            var patched = 0;

            // --- Part A: BoringSSL custom verify hooks ---
            // Hooks SSL_CTX_set_custom_verify & SSL_set_custom_verify
            // to replace the app's callback with one that always returns OK
            var verifyFnNames = ['SSL_CTX_set_custom_verify', 'SSL_set_custom_verify'];

            // Create a single always-OK callback (reused for all hooks)
            var alwaysOkCallback = new NativeCallback(function(ssl, out_alert) {
                return SSL_VERIFY_OK;
            }, 'int', ['pointer', 'pointer']);

            for (var vi = 0; vi < verifyFnNames.length; vi++) {
                try {
                    var fnAddr = findSSLFunction(mod, verifyFnNames[vi]);
                    if (fnAddr) {
                        var origFn = new NativeFunction(fnAddr, 'void', ['pointer', 'int', 'pointer']);
                        (function(fn, name, addr) {
                            Interceptor.replace(addr, new NativeCallback(function(ctx_or_ssl, mode, callback) {
                                fn(ctx_or_ssl, mode, alwaysOkCallback);
                            }, 'void', ['pointer', 'int', 'pointer']));
                        })(origFn, verifyFnNames[vi], fnAddr);
                        patched++;
                        console.log('[+] Native SSL: ' + verifyFnNames[vi] + ' hooked in ' + libName);
                    }
                } catch (e) {
                    console.log('[-] Native SSL: ' + verifyFnNames[vi] + ' in ' + libName + ': ' + e);
                }
            }

            // --- Part B: Standard OpenSSL verify mode hooks ---
            // Forces SSL_VERIFY_NONE (0) to completely disable certificate
            // verification at native level. This catches the default Conscrypt/
            // BoringSSL path where SSL_CTX_set_custom_verify is never called.
            // Signature: void SSL_CTX_set_verify(SSL_CTX *ctx, int mode, verify_callback cb)
            //            void SSL_set_verify(SSL *ssl, int mode, verify_callback cb)
            var stdVerifyFns = ['SSL_CTX_set_verify', 'SSL_set_verify'];
            for (var svi = 0; svi < stdVerifyFns.length; svi++) {
                try {
                    var svAddr = findSSLFunction(mod, stdVerifyFns[svi]);
                    if (svAddr) {
                        (function(addr, name) {
                            var origSvFn = new NativeFunction(addr, 'void', ['pointer', 'int', 'pointer']);
                            Interceptor.replace(addr, new NativeCallback(function(ctx_or_ssl, mode, callback) {
                                // Force mode to SSL_VERIFY_NONE regardless of what was requested
                                origSvFn(ctx_or_ssl, SSL_VERIFY_NONE, ptr(0));
                            }, 'void', ['pointer', 'int', 'pointer']));
                        })(svAddr, stdVerifyFns[svi]);
                        patched++;
                        console.log('[+] Native SSL: ' + stdVerifyFns[svi] + ' -> VERIFY_NONE in ' + libName);
                    }
                } catch (e) {
                    console.log('[-] Native SSL: ' + stdVerifyFns[svi] + ' in ' + libName + ': ' + e);
                }
            }

            // Hook SSL_get_psk_identity — some verification paths check this is non-null
            try {
                var pskAddr = findSSLFunction(mod, 'SSL_get_psk_identity');
                if (pskAddr) {
                    var pskStr = Memory.allocUtf8String('PSK_PLACEHOLDER');
                    Interceptor.replace(pskAddr, new NativeCallback(function(ssl) {
                        return pskStr;
                    }, 'pointer', ['pointer']));
                    console.log('[+] Native SSL: SSL_get_psk_identity hooked in ' + libName);
                }
            } catch (e) {}

            // Hook SSL_new and SSL_CTX_new to force SSL_VERIFY_NONE on all new SSL objects
            // This catches SSL contexts created after Frida loads, preventing SSLHandshakeExceptions
            var sslNewFns = ['SSL_new', 'SSL_CTX_new'];
            for (var sni = 0; sni < sslNewFns.length; sni++) {
                try {
                    var snAddr = findSSLFunction(mod, sslNewFns[sni]);
                    if (snAddr) {
                        (function(addr, name) {
                            Interceptor.attach(addr, {
                                onLeave: function(retval) {
                                    if (!retval.isNull()) {
                                        var setVerifyName = name === 'SSL_new' ? 'SSL_set_verify' : 'SSL_CTX_set_verify';
                                        var svAddr2 = findSSLFunction(mod, setVerifyName);
                                        if (svAddr2) {
                                            var setVerifyFn = new NativeFunction(svAddr2, 'void', ['pointer', 'int', 'pointer']);
                                            setVerifyFn(retval, SSL_VERIFY_NONE, ptr(0));
                                            console.log('[+] Native SSL: ' + name + ' -> forced VERIFY_NONE in ' + libName);
                                        }
                                    }
                                }
                            });
                        })(snAddr, sslNewFns[sni]);
                        patched++;
                        console.log('[+] Native SSL: ' + sslNewFns[sni] + ' hooked in ' + libName);
                    }
                } catch (e) {
                    console.log('[-] Native SSL: ' + sslNewFns[sni] + ' in ' + libName + ': ' + e);
                }
            }

            // Note: SSL_do_handshake/SSL_connect hooks REMOVED in v3.19
            // Pretending handshake success corrupts TLS state machine and
            // CAUSES failures on valid connections. The verify hooks above
            // are sufficient - they allow the handshake to complete naturally
            // with certificate verification disabled.

            // Hook SSL_get_verify_result to always return X509_V_OK (0)
            try {
                var vrAddr = findSSLFunction(mod, 'SSL_get_verify_result');
                if (vrAddr) {
                    Interceptor.replace(vrAddr, new NativeCallback(function(ssl) {
                        return 0; // X509_V_OK
                    }, 'long', ['pointer']));
                    patched++;
                    console.log('[+] Native SSL: SSL_get_verify_result hooked in ' + libName);
                }
            } catch (e) {
                console.log('[-] Native SSL: SSL_get_verify_result in ' + libName + ': ' + e);
            }

            return patched;
        }

        // Try immediate hook on known BoringSSL/Cronet library names
        // libwebviewchromium.so is the system WebView (Chromium) with statically-linked BoringSSL
        // NOTE: libwebviewchromium.so removed — BoringSSL is statically linked
        // (not exported) and scanning its massive symbol table causes SIGSEGV.
        var _nativeSslLibs = ['libssl.so', 'libsscronet.so', 'libcronet.so', 'libcronet.102.0.5005.125.so'];
        for (var nsi = 0; nsi < _nativeSslLibs.length; nsi++) {
            _nativeSslHooked += patchNativeSSLVerify(_nativeSslLibs[nsi]);
        }

        // NOTE: broad "scan ALL modules" loop REMOVED in v3.41.
        // Calling findExportByName/enumerateSymbols on every loaded module
        // caused SIGSEGV in Frida's ELF reader (__fseeko64 null FILE*).
        // The named libs above cover all real-world SSL scenarios.

        // Watch for late-loaded SSL libs by name only (safe — no broad scan)
        try {
            var _patchedModules = {};
            Process.attachModuleObserver({
                onAdded: function(mod) {
                    var name = mod.name;
                    if (_patchedModules[name]) return;
                    // Only check libs whose name suggests SSL/Cronet
                    if (name.indexOf('ssl') === -1 && name.indexOf('cronet') === -1 &&
                        name.indexOf('boringssl') === -1) return;
                    if (name.indexOf('frida') !== -1 || name.indexOf('gadget') !== -1) return;
                    try {
                        _patchedModules[name] = true;
                        var p = patchNativeSSLVerify(name);
                        if (p > 0) {
                            _nativeSslHooked += p;
                            console.log('[+] Late-loaded SSL lib patched: ' + name + ' (' + p + ' hooks)');
                        }
                    } catch(lateE) {}
                }
            });
        } catch (e) {
            // Fallback: retry named libs after 3s for older Frida without attachModuleObserver
            setTimeout(function() {
                for (var nsi2 = 0; nsi2 < _nativeSslLibs.length; nsi2++) {
                    _nativeSslHooked += patchNativeSSLVerify(_nativeSslLibs[nsi2]);
                }
                if (_nativeSslHooked > 0) console.log('[+] Delayed native SSL hooks: ' + _nativeSslHooked);
            }, 3000);
        }

        Log.i(TAG, '[*] Native BoringSSL bypass: ' + _nativeSslHooked + ' hooks installed');


        // =====================================================
        // 2. SIGNATURE VERIFICATION BYPASS (Runtime Layer)
        // =====================================================

        // Hook PackageManager.getPackageInfo to fix signatures
        try {
            var PM = Java.use('android.app.ApplicationPackageManager');

            PM.getPackageInfo.overload('java.lang.String', 'int').implementation = function(name, flags) {
                var pi = this.getPackageInfo(name, flags);

                // Only patch our own package
                var ctx = Java.use('android.app.ActivityThread').currentApplication();
                if (ctx !== null && name === ctx.getPackageName()) {
                    if ((flags & 0x40) !== 0 || (flags & 0x8000000) !== 0) {
                        try {
                            var storedSigs = Java.use('in.startv.hotstar.SignatureBypass').originalSignatures.value;
                            if (storedSigs !== null) {
                                pi.signatures.value = storedSigs;
                                console.log('[+] SIG: Patched getPackageInfo signatures for ' + name);
                            }
                        } catch(e) {}
                    }
                }
                return pi;
            };
            console.log('[*] Signature bypass hooks installed');
        } catch (err) {
            console.log('[-] PackageManager signature hook: ' + err);
        }


        // =====================================================
        // 3. PIRACY / LICENSE / INTEGRITY CHECK REMOVAL
        // =====================================================

        // Google Play Licensing (LVL)
        try {
            var LicenseChecker = Java.use('com.google.android.vending.licensing.LicenseChecker');
            LicenseChecker.checkAccess.implementation = function(callback) {
                console.log('[+] PIRACY: Bypassing LicenseChecker.checkAccess');
                try { callback.allow(0x100); } catch(e) { callback.allow(); }
            };
        } catch (err) { }

        // Installer package check bypass
        try {
            var APM = Java.use('android.app.ApplicationPackageManager');
            APM.getInstallerPackageName.implementation = function(pkg) {
                console.log('[+] PIRACY: Spoofing installer to Play Store for: ' + pkg);
                return "com.android.vending";
            };
        } catch (err) { }

        // Debug detection bypass
        try {
            var Debug = Java.use('android.os.Debug');
            Debug.isDebuggerConnected.implementation = function() { return false; };
        } catch (err) { }

        // Root detection - block common su checks
        try {
            var Runtime = Java.use('java.lang.Runtime');
            var origExec = Runtime.exec.overload('java.lang.String');
            origExec.implementation = function(cmd) {
                if (cmd.indexOf('su') === 0 || cmd === 'which su' ||
                    cmd.indexOf('/system/xbin/su') !== -1 ||
                    cmd.indexOf('/system/bin/su') !== -1 ||
                    cmd.indexOf('busybox') !== -1) {
                    console.log('[+] ROOT: Blocking root detection exec: ' + cmd);
                    throw Java.use('java.io.IOException').$new('Permission denied');
                }
                return origExec.call(this, cmd);
            };
        } catch (err) { }

        // Root detection - hide known root paths (v3.42: O(1) Set lookup)
        try {
            var File = Java.use('java.io.File');
            var origExists = File.exists;
            var _rootPathSet = {};
            ['/system/app/Superuser.apk', '/system/xbin/su', '/system/bin/su',
             '/sbin/su', '/data/local/xbin/su', '/data/local/bin/su',
             '/su/bin/su', '/data/adb/magisk'].forEach(function(p) { _rootPathSet[p] = true; });
            File.exists.implementation = function() {
                var path = this.getAbsolutePath();
                if (_rootPathSet[path]) {
                    return false;
                }
                return origExists.call(this);
            };
        } catch (err) { }

        // Build.TAGS - release-keys
        try {
            var Build = Java.use('android.os.Build');
            var tags = Build.TAGS.value;
            if (tags && tags.indexOf('test-keys') !== -1) {
                Build.TAGS.value = 'release-keys';
                console.log('[+] ROOT: Changed Build.TAGS to release-keys');
            }
        } catch (err) { }

        console.log('[*] Piracy/License/Root bypass hooks installed');


        // =====================================================
        // 3a. FRIDA STEALTH — Anti-Detection Bypass
        //     Hides Frida gadget from apps that scan for it.
        //     Detection vectors covered:
        //       1. /proc/self/maps — strips lines containing frida/gadget
        //       2. /proc/self/status — hides TracerPid
        //       3. Thread enumeration — hides frida thread names
        //       4. File existence checks — hides frida-related files
        //       5. Port 27042 — hides frida-server default port
        //       6. Native openat/open — intercepts /proc/self/maps reads
        //     Ref: github.com/AeonLucid/frida-anti-detection patterns
        // =====================================================
        var _stealthTag = 'HSPatch-Stealth';
        var _stealthCount = 0;

        // --- Native hooks: hide frida from /proc/self/maps and /proc/self/status ---
        try {
            // Patterns that indicate frida presence in maps lines
            var _fridaPatterns = ['frida', 'gadget', 'gum-js', 'gmain', 'linjector'];

            var _isFridaLine = function(line) {
                var lower = line.toLowerCase();
                for (var i = 0; i < _fridaPatterns.length; i++) {
                    if (lower.indexOf(_fridaPatterns[i]) !== -1) return true;
                }
                return false;
            };

            var _safeReadPath = function(p) {
                try { return p.readUtf8String(); } catch(e2) { return null; }
            };

            // Use Process.getModuleByName for Frida gadget compatibility
            var _libc = Process.getModuleByName('libc.so');

            // Hook libc open/openat to track FDs for /proc/self/maps and /proc/self/status
            var _mapsTrackedFds = {};

            var _openPtr = _libc.findExportByName('open');
            var _openatPtr = _libc.findExportByName('openat');
            var _readPtr = _libc.findExportByName('read');
            var _closePtr = _libc.findExportByName('close');

            if (_openPtr) {
                try {
                    Interceptor.attach(_openPtr, {
                        onEnter: function(args) {
                            this._path = _safeReadPath(args[0]);
                        },
                        onLeave: function(retval) {
                            var fd = retval.toInt32();
                            if (fd > 0 && this._path) {
                                if (this._path.indexOf('/proc/self/maps') !== -1 ||
                                    this._path.indexOf('/proc/' + Process.id + '/maps') !== -1) {
                                    _mapsTrackedFds[fd] = 'maps';
                                } else if (this._path.indexOf('/proc/self/status') !== -1 ||
                                           this._path.indexOf('/proc/' + Process.id + '/status') !== -1) {
                                    _mapsTrackedFds[fd] = 'status';
                                }
                            }
                        }
                    });
                    _stealthCount++;
                } catch (eOpen) {
                    Log.w(_stealthTag, '[-] open() hook: ' + eOpen);
                }
            }

            if (_openatPtr) {
                try {
                    Interceptor.attach(_openatPtr, {
                        onEnter: function(args) {
                            this._path = _safeReadPath(args[1]);
                        },
                        onLeave: function(retval) {
                            var fd = retval.toInt32();
                            if (fd > 0 && this._path) {
                                if (this._path.indexOf('/proc/self/maps') !== -1 ||
                                    this._path.indexOf('/proc/' + Process.id + '/maps') !== -1) {
                                    _mapsTrackedFds[fd] = 'maps';
                                } else if (this._path.indexOf('/proc/self/status') !== -1 ||
                                           this._path.indexOf('/proc/' + Process.id + '/status') !== -1) {
                                    _mapsTrackedFds[fd] = 'status';
                                }
                            }
                        }
                    });
                    _stealthCount++;
                } catch (eOpenat) {
                    Log.w(_stealthTag, '[-] openat() hook: ' + eOpenat);
                }
            }

            // Hook read() to filter out frida-related lines from /proc/self/maps
            // and spoof TracerPid in /proc/self/status
            if (_readPtr) {
                try {
                    Interceptor.attach(_readPtr, {
                        onEnter: function(args) {
                            this._fd = args[0].toInt32();
                            this._buf = args[1];
                            this._size = args[2].toInt32();
                        },
                        onLeave: function(retval) {
                            var fd = this._fd;
                            var bytesRead = retval.toInt32();
                            if (bytesRead <= 0 || !_mapsTrackedFds[fd]) return;

                            try {
                                var content = this._buf.readUtf8String(bytesRead);
                                if (!content) return;

                                if (_mapsTrackedFds[fd] === 'maps') {
                                    var lines = content.split('\n');
                                    var filtered = [];
                                    var removed = 0;
                                    for (var i = 0; i < lines.length; i++) {
                                        if (!_isFridaLine(lines[i])) {
                                            filtered.push(lines[i]);
                                        } else {
                                            removed++;
                                        }
                                    }
                                    if (removed > 0) {
                                        var clean = filtered.join('\n');
                                        this._buf.writeUtf8String(clean);
                                        retval.replace(clean.length);
                                    }
                                } else if (_mapsTrackedFds[fd] === 'status') {
                                    var patched = content.replace(/TracerPid:\s*\d+/g, 'TracerPid:\t0');
                                    if (patched !== content) {
                                        this._buf.writeUtf8String(patched);
                                        retval.replace(patched.length);
                                    }
                                }
                            } catch (e) {
                                // Ignore read errors (binary data, etc.)
                            }
                        }
                    });
                    _stealthCount++;
                } catch (eRead) {
                    Log.w(_stealthTag, '[-] read() hook: ' + eRead);
                }
            }

            // Track close() for cleanup
            if (_closePtr) {
                try {
                    Interceptor.attach(_closePtr, {
                        onEnter: function(args) {
                            var fd = args[0].toInt32();
                            if (_mapsTrackedFds[fd]) {
                                delete _mapsTrackedFds[fd];
                            }
                        }
                    });
                } catch (eClose) {
                    Log.w(_stealthTag, '[-] close() hook: ' + eClose);
                }
            }


        } catch (eNativeStealth) {
            Log.w(_stealthTag, '[-] Native stealth hooks failed: ' + eNativeStealth);
        }

        // --- Java-level: hide frida artifacts from File.exists(), file list, thread enum ---
        try {
            // Additional paths that indicate frida (beyond root paths already hooked)
            var _fridaFileSet = {};
            ['/data/local/tmp/frida-server', '/data/local/tmp/re.frida.server',
             '/data/local/tmp/frida-server-arm64', '/data/local/tmp/frida-server-arm',
             '/data/local/tmp/frida-agent', '/data/local/tmp/frida-gadget',
             '/data/local/tmp/frida-helper'].forEach(function(p) { _fridaFileSet[p] = true; });

            // Extend the existing File.exists() hook to also catch frida paths
            // (the root path set is already hooked above in section 3)
            // We hook File.exists() again — Frida merges hooks, so both fire
            var FileS = Java.use('java.io.File');
            var _origExistsS = FileS.exists;
            FileS.exists.implementation = function() {
                var path = this.getAbsolutePath();
                if (_fridaFileSet[path]) {
                    Log.d(_stealthTag, '[+] Hiding frida file: ' + path);
                    return false;
                }
                // Also catch any path containing 'frida' in /data/local/tmp/
                if (path.indexOf('/data/local/tmp/') === 0 && path.toLowerCase().indexOf('frida') !== -1) {
                    return false;
                }
                return _origExistsS.call(this);
            };
            _stealthCount++;
        } catch (eFileS) {
            Log.w(_stealthTag, '[-] File.exists stealth hook: ' + eFileS);
        }

        // --- Hide frida thread names ---
        try {
            var Thread = Java.use('java.lang.Thread');
            var _origGetName = Thread.getName;
            var _fridaThreadNames = { 'gum-js-loop': true, 'gmain': true, 'gdbus': true,
                                       'linjector': true, 'frida': true };
            Thread.getName.implementation = function() {
                var name = _origGetName.call(this);
                if (name) {
                    var lower = name.toLowerCase();
                    for (var key in _fridaThreadNames) {
                        if (lower.indexOf(key) !== -1) {
                            return 'Thread-' + this.getId();
                        }
                    }
                }
                return name;
            };
            _stealthCount++;
        } catch (eThread) {
            Log.w(_stealthTag, '[-] Thread stealth hook: ' + eThread);
        }

        // --- Hide frida's default port (27042) from socket scans ---
        try {
            var InetSockAddr = Java.use('java.net.InetSocketAddress');
            var _origISA = InetSockAddr.$init.overload('int');
            _origISA.implementation = function(port) {
                // Just let it through — we catch at connect level
                return _origISA.call(this, port);
            };

            // ServerSocket / Socket.connect — block connections TO port 27042
            var Socket = Java.use('java.net.Socket');
            var _origConnect4 = Socket.connect.overload('java.net.SocketAddress', 'int');
            _origConnect4.implementation = function(addr, timeout) {
                try {
                    var sa = Java.cast(addr, InetSockAddr);
                    if (sa.getPort() === 27042) {
                        Log.d(_stealthTag, '[+] Blocked connection to port 27042 (frida-server)');
                        throw Java.use('java.net.ConnectException').$new('Connection refused');
                    }
                } catch (e) {
                    if (('' + e).indexOf('Connection refused') !== -1) throw e;
                }
                return _origConnect4.call(this, addr, timeout);
            };
            _stealthCount++;
        } catch (ePort) {
            Log.w(_stealthTag, '[-] Port stealth hook: ' + ePort);
        }

        // --- Hide Frida from native stat/access checks ---
        try {
            if (!_libc) _libc = Process.getModuleByName('libc.so');
            var _statPtr = _libc.findExportByName('stat');
            var _accessPtr = _libc.findExportByName('access');

            var _isFridaNativePath = function(path) {
                if (!path) return false;
                var lower = path.toLowerCase();
                return (lower.indexOf('frida') !== -1 || lower.indexOf('gadget') !== -1) &&
                       (lower.indexOf('/data/local/tmp/') !== -1 || lower.indexOf('/data/local/') !== -1);
            }

            if (_statPtr) {
                try {
                    Interceptor.attach(_statPtr, {
                        onEnter: function(args) {
                            try { var path = args[0].readUtf8String(); if (_isFridaNativePath(path)) this._hide = true; } catch(e) {}
                        },
                        onLeave: function(retval) {
                            if (this._hide) retval.replace(-1);
                        }
                    });
                    _stealthCount++;
                } catch (eStat) {
                    Log.w(_stealthTag, '[-] stat() hook: ' + eStat);
                }
            }

            if (_accessPtr) {
                try {
                    Interceptor.attach(_accessPtr, {
                        onEnter: function(args) {
                            try { var path = args[0].readUtf8String(); if (_isFridaNativePath(path)) this._hide = true; } catch(e) {}
                        },
                        onLeave: function(retval) {
                            if (this._hide) retval.replace(-1);
                        }
                    });
                    _stealthCount++;
                } catch (eAccess) {
                    Log.w(_stealthTag, '[-] access() hook: ' + eAccess);
                }
            }

        } catch (eStatStealth) {
            Log.w(_stealthTag, '[-] Native stat/access stealth: ' + eStatStealth);
        }

        Log.i(_stealthTag, '[*] Frida stealth: ' + _stealthCount + ' hooks installed');
        console.log('[*] Frida stealth: ' + _stealthCount + ' anti-detection hooks installed');

        // Self-test: verify /proc/self/maps filtering works from within the process
        try {
            var BufferedReader = Java.use('java.io.BufferedReader');
            var FileReader = Java.use('java.io.FileReader');
            var br = BufferedReader.$new(FileReader.$new('/proc/self/maps'));
            var line, fridaFound = false, totalLines = 0;
            while ((line = br.readLine()) !== null) {
                totalLines++;
                var lower = line.toLowerCase();
                if (lower.indexOf('frida') !== -1 || lower.indexOf('gadget') !== -1) {
                    fridaFound = true;
                    Log.w(_stealthTag, '[!] SELF-TEST FAIL: maps still shows: ' + line);
                }
            }
            br.close();
            if (!fridaFound) {
                Log.i(_stealthTag, '[+] SELF-TEST PASS: /proc/self/maps clean (' + totalLines + ' lines, no frida references)');
            }
        } catch (eSelfTest) {
            Log.w(_stealthTag, '[-] Self-test error: ' + eSelfTest);
        }


        // =====================================================
        // 3b. CRYPTO EXCEPTION RESILIENCE (Re-signing Safety Net)
        //     When APK is re-signed, encrypted tokens/keys derived
        //     from the original signing cert fail to decrypt.
        //     Native JNI code calling Cipher.doFinal() may not handle
        //     the exception, causing ART to abort ("No pending exception
        //     expected"). Uses TWO layers:
        //       Layer 1: Conscrypt OpenSSLCipher.engineDoFinal — catches
        //                at the crypto provider BEFORE Cipher.doFinal
        //       Layer 2: javax.crypto.Cipher.doFinal (all overloads)
        //     Ref: Coursera Keys.kochavaProdToken() crash, common in
        //     analytics SDKs (Kochava, Adjust, AppsFlyer).
        // =====================================================

        var _cryptoFixCount = 0;

        // Broad exception matcher — uses toString for maximum compatibility
        function _isCryptoException(e) {
            var s = '' + e;
            return s.indexOf('BadPadding') !== -1 ||
                   s.indexOf('IllegalBlockSize') !== -1 ||
                   s.indexOf('AEADBadTag') !== -1 ||
                   s.indexOf('BAD_DECRYPT') !== -1 ||
                   s.indexOf('OPENSSL_internal') !== -1;
        }

        // --- Layer 1: Conscrypt provider (catches exception at source) ---
        try {
            var OpenSSLCipher = Java.use('com.android.org.conscrypt.OpenSSLCipher');
            var _origEngineDoFinal = OpenSSLCipher.engineDoFinal.overload('[B', 'int', 'int');
            _origEngineDoFinal.implementation = function(input, off, len) {
                try {
                    return _origEngineDoFinal.call(this, input, off, len);
                } catch(e) {
                    if (_isCryptoException(e)) {
                        Log.w(TAG, '[!] CRYPTO-L1: Caught ' + e + ' in OpenSSLCipher.engineDoFinal — returning empty (re-sign safe)');
                        return Java.array('byte', []);
                    }
                    throw e;
                }
            };
            _cryptoFixCount++;
            Log.d(TAG, '[+] CRYPTO: OpenSSLCipher.engineDoFinal hooked (Layer 1)');
        } catch(e) {
            Log.d(TAG, '[-] CRYPTO: OpenSSLCipher.engineDoFinal hook failed: ' + e);
        }

        // --- Layer 2: javax.crypto.Cipher.doFinal (all overloads) ---
        try {
            var Cipher = Java.use('javax.crypto.Cipher');

            // doFinal() — no-arg
            try {
                var _origDoFinal0 = Cipher.doFinal.overload();
                _origDoFinal0.implementation = function() {
                    try {
                        return _origDoFinal0.call(this);
                    } catch(e) {
                        if (_isCryptoException(e)) {
                            Log.w(TAG, '[!] CRYPTO-L2: Caught ' + e + ' in Cipher.doFinal() — returning empty');
                            return Java.array('byte', []);
                        }
                        throw e;
                    }
                };
                _cryptoFixCount++;
                Log.d(TAG, '[+] CRYPTO: Cipher.doFinal() hooked (Layer 2)');
            } catch(e) { Log.d(TAG, '[-] CRYPTO: Cipher.doFinal() hook failed: ' + e); }

            // doFinal(byte[]) — most common form
            try {
                var _origDoFinal1 = Cipher.doFinal.overload('[B');
                _origDoFinal1.implementation = function(input) {
                    try {
                        return _origDoFinal1.call(this, input);
                    } catch(e) {
                        if (_isCryptoException(e)) {
                            Log.w(TAG, '[!] CRYPTO-L2: Caught ' + e + ' in Cipher.doFinal(byte[]) — returning empty');
                            return Java.array('byte', []);
                        }
                        throw e;
                    }
                };
                _cryptoFixCount++;
                Log.d(TAG, '[+] CRYPTO: Cipher.doFinal(byte[]) hooked (Layer 2)');
            } catch(e) { Log.d(TAG, '[-] CRYPTO: Cipher.doFinal(byte[]) hook failed: ' + e); }

            // doFinal(byte[], int, int) — offset+length variant
            try {
                var _origDoFinal3 = Cipher.doFinal.overload('[B', 'int', 'int');
                _origDoFinal3.implementation = function(input, off, len) {
                    try {
                        return _origDoFinal3.call(this, input, off, len);
                    } catch(e) {
                        if (_isCryptoException(e)) {
                            Log.w(TAG, '[!] CRYPTO-L2: Caught ' + e + ' in Cipher.doFinal(byte[],int,int) — returning empty');
                            return Java.array('byte', []);
                        }
                        throw e;
                    }
                };
                _cryptoFixCount++;
                Log.d(TAG, '[+] CRYPTO: Cipher.doFinal(byte[],int,int) hooked (Layer 2)');
            } catch(e) { Log.d(TAG, '[-] CRYPTO: Cipher.doFinal(byte[],int,int) hook failed: ' + e); }

            // doFinal(byte[], int) — output buffer variant
            try {
                var _origDoFinal2 = Cipher.doFinal.overload('[B', 'int');
                _origDoFinal2.implementation = function(output, outOff) {
                    try {
                        return _origDoFinal2.call(this, output, outOff);
                    } catch(e) {
                        if (_isCryptoException(e)) {
                            Log.w(TAG, '[!] CRYPTO-L2: Caught ' + e + ' in Cipher.doFinal(byte[],int) — returning 0');
                            return 0;
                        }
                        throw e;
                    }
                };
                _cryptoFixCount++;
                Log.d(TAG, '[+] CRYPTO: Cipher.doFinal(byte[],int) hooked (Layer 2)');
            } catch(e) { Log.d(TAG, '[-] CRYPTO: Cipher.doFinal(byte[],int) hook failed: ' + e); }

            Log.i(TAG, '[*] Crypto resilience: ' + _cryptoFixCount + ' hooks installed (L1 provider + L2 Cipher)');
        } catch(e) {
            Log.e(TAG, '[-] Crypto resilience hook failed: ' + e);
        }


        // =====================================================
        // 4. SCREENSHOT & RECORDING ENABLEMENT
        // =====================================================

        try {
            var Window = Java.use('android.view.Window');
            Window.setFlags.implementation = function(flags, mask) {
                var cleanFlags = flags & ~0x2000;
                var cleanMask = mask & ~0x2000;
                if (flags !== cleanFlags) {
                    console.log('[+] SCREEN: Stripped FLAG_SECURE from setFlags');
                }
                this.setFlags(cleanFlags, cleanMask);
            };

            Window.addFlags.implementation = function(flags) {
                var cleanFlags = flags & ~0x2000;
                if (flags !== cleanFlags) {
                    console.log('[+] SCREEN: Stripped FLAG_SECURE from addFlags');
                }
                this.addFlags(cleanFlags);
            };
        } catch (err) {
            console.log('[-] Window FLAG_SECURE hook: ' + err);
        }

        // SurfaceView.setSecure
        try {
            var SurfaceView = Java.use('android.view.SurfaceView');
            SurfaceView.setSecure.implementation = function(isSecure) {
                console.log('[+] SCREEN: Bypassing SurfaceView.setSecure(' + isSecure + ')');
                this.setSecure(false);
            };
        } catch (err) { }

        console.log('[*] Screenshot/Recording bypass hooks installed');


        // =====================================================
        // 5. NETWORK TRAFFIC: NATIVE + JAVA INTERCEPTION v4.0
        // =====================================================
        // ARCHITECTURE:
        //   Layer 1 — Native libc hooks (connect, send, sendto, getaddrinfo)
        //             Catches ALL traffic from ANY library (Java, native, JNI)
        //   Layer 2 — Native TLS hooks (SSL_write, SSL_read)
        //             Sees decrypted HTTPS payload (HTTP headers, bodies)
        //   Layer 3 — Java hooks (OkHttp, URL, WebView)
        //             For block/rewrite rule enforcement at application level
        //   Layer 4 — Advanced hooks (OkHttp interceptor injection, ExoPlayer,
        //             Volley, Glide, TLS SNI) — deep execution-level blocking
        // =====================================================

        var netLogTag = "HSPatch-Net";
        var Log = Java.use('android.util.Log');

        // --- Native logcat helper (works from ANY thread, no JNI needed) ---
        var ANDROID_LOG_INFO = 4;
        var _logTagPtr = Memory.allocUtf8String(netLogTag);
        var _androidLogPrint = new NativeFunction(
            Process.getModuleByName('liblog.so').getExportByName('__android_log_print'),
            'int', ['int', 'pointer', 'pointer']
        );
        function nativeLog(msg) {
            var msgPtr = Memory.allocUtf8String(msg);
            _androidLogPrint(ANDROID_LOG_INFO, _logTagPtr, msgPtr);
        }

        // --- Rules engine ---
        // Built-in blocks: tracking/identity endpoints from video SDK libraries
        // These domains are from the Tiled Media SDK and make external identity
        // verification calls. Block at DNS + rewrite to unreachable dummy.
        var blockPatterns = [
            'v2.identity.tiled.media',
            'v2.identity.shenwavideo.cn'
        ];
        // Built-in rewrites: neutralize SDK identity calls by redirecting to localhost
        var _builtinRewrites = [
            { from: 'v2.identity.tiled.media', to: '127.0.0.1' },
            { from: 'v2.identity.shenwavideo.cn', to: '127.0.0.1' }
        ];
        var rewriteRules = _builtinRewrites.slice();
        var apiDumpEnabled = false;
        var trafficMonitorEnabled = true; // Toggled via in-app notification, persisted via flag file
        var blockingNotificationEnabled = false; // Toggled via HostFilterActivity switch, persisted via prefs
        var toggleReceiverRegistered = false;
        var refreshNotifReceiverRegistered = false;
        var NOTIF_ID = 19730;
        var NOTIF_CHANNEL = 'hspatch_block';
        var apiDumpMaxBytes = 10 * 1024 * 1024;

        // --- Host discovery & filter mode ---
        var networkFilterMode = 0; // 0 = Only Block (blacklist), 1 = Only Allow (whitelist)
        var discoveredHosts = {};  // hostname -> 'ALLOW' or 'DENY'
        var hostRulesLoaded = false;
        var hostRulesDirty = false;
        var hostRulesWriteTimer = null;

        function getInternalFilePath(fileName) {
            try {
                return _cls('in.startv.hotstar.HSPatchConfig').getFilePath(fileName);
            } catch (e) { }
            try {
                var ctx2 = _getCtx();
                if (ctx2 !== null) return ctx2.getFilesDir().getAbsolutePath() + '/' + fileName;
            } catch (e2) { }
            return null;
        }

        // Cached SimpleDateFormat for apiDumpWrite (avoid creating per-event)
        var _apiDumpSdf = null;
        function apiDumpWrite(line) {
            if (!apiDumpEnabled) return;
            try {
                var path = getInternalFilePath('api_dump.txt');
                if (path === null) return;
                var f2 = _cls('java.io.File').$new(path);
                if (f2.exists() && f2.length() > apiDumpMaxBytes) return;
                if (_apiDumpSdf === null) _apiDumpSdf = _cls('java.text.SimpleDateFormat').$new('HH:mm:ss.SSS');
                var ts2 = _apiDumpSdf.format(_cls('java.util.Date').$new());
                var fw2 = _cls('java.io.FileWriter').$new(path, true);
                fw2.write(ts2 + ' ' + line + '\n');
                fw2.flush();
                fw2.close();
            } catch (e3) { }
        }

        // --- Host discovery & filter mode functions ---
        function loadHostRules() {
            try {
                var path = getInternalFilePath('host_rules.txt');
                if (path === null) return;
                var f = _cls('java.io.File').$new(path);
                if (!f.exists()) { hostRulesLoaded = true; return; }
                var reader = _cls('java.io.BufferedReader').$new(_cls('java.io.FileReader').$new(path));
                var line;
                var count = 0;
                while ((line = reader.readLine()) !== null) {
                    var ls = line.toString().trim();
                    if (ls.length === 0 || ls.charAt(0) === '#') continue;
                    var spaceIdx = ls.indexOf(' ');
                    if (spaceIdx > 0) {
                        var host = ls.substring(0, spaceIdx).trim().toLowerCase();
                        var status = ls.substring(spaceIdx + 1).trim().toUpperCase();
                        if (status === 'DENY' || status === 'BLOCK') {
                            discoveredHosts[host] = 'DENY';
                        } else {
                            discoveredHosts[host] = 'ALLOW';
                        }
                    } else {
                        discoveredHosts[ls.toLowerCase()] = 'ALLOW';
                    }
                    count++;
                }
                reader.close();
                hostRulesLoaded = true;
                Log.i(netLogTag, '[HOSTS] Loaded ' + count + ' host rules');
            } catch (e) {
                Log.w(netLogTag, '[HOSTS] Load error: ' + e);
            }
        }

        function saveHostRules() {
            try {
                var path = getInternalFilePath('host_rules.txt');
                if (path === null) {
                    Log.w(netLogTag, '[HOSTS] Save skipped: path is null');
                    return;
                }
                Log.i(netLogTag, '[HOSTS] Saving ' + Object.keys(discoveredHosts).length + ' hosts to ' + path);
                var sb = _cls('java.lang.StringBuilder').$new();
                sb.append('# Host rules - format: hostname ALLOW/DENY\n');
                sb.append('# Auto-generated by HSPatch host discovery\n');
                var hosts = Object.keys(discoveredHosts).sort();
                for (var i = 0; i < hosts.length; i++) {
                    sb.append(hosts[i] + ' ' + discoveredHosts[hosts[i]] + '\n');
                }
                var fw = _cls('java.io.PrintWriter').$new(
                    _cls('java.io.File').$new(path)
                );
                fw.print(sb.toString());
                fw.flush();
                fw.close();
                hostRulesDirty = false;
                Log.i(netLogTag, '[HOSTS] Saved successfully');
            } catch (e) {
                Log.w(netLogTag, '[HOSTS] Save error: ' + e);
            }
        }

        function scheduleHostRulesSave() {
            if (hostRulesWriteTimer !== null) return; // already scheduled
            Log.d(netLogTag, '[HOSTS] Scheduling save in 5s');
            hostRulesWriteTimer = setTimeout(function() {
                hostRulesWriteTimer = null;
                if (hostRulesDirty) {
                    Java.perform(function() { saveHostRules(); });
                }
            }, 5000); // batch writes every 5s
        }

        function discoverHost(hostname) {
            if (!hostname || hostname.length === 0) return;
            var host = hostname.toLowerCase();
            // Skip loopback
            if (host === 'localhost' || host === '127.0.0.1' || host === '::1') return;
            // Skip IPs that are just numbers (not real hostnames) - still discover them
            if (discoveredHosts[host] !== undefined) return; // already known
            // v3.44: In Only Allow (whitelist) mode, new unknown hosts default to DENY
            //        so they are blocked until explicitly marked ALLOW by the user.
            //        In Only Block (blacklist) mode they default to ALLOW as before.
            var defaultStatus = (networkFilterMode === 1) ? 'DENY' : 'ALLOW';
            discoveredHosts[host] = defaultStatus;
            hostRulesDirty = true;
            Log.i(netLogTag, '[HOSTS] Discovered new host: ' + host + ' (default: ' + defaultStatus + ')');
            scheduleHostRulesSave();
        }

        function shouldBlockByHostRules(hostname) {
            if (!trafficMonitorEnabled) return null;
            if (!hostname || hostname.length === 0) return null; // v3.44: null guard
            var host = hostname.toLowerCase();

            // Never block loopback — our own blocked-URL redirect uses 127.0.0.1
            if (host === 'localhost' || host === '127.0.0.1' || host === '::1' || host === '0.0.0.0') return null;

            // Discover the host
            discoverHost(host);

            var status = discoveredHosts[host];

            if (networkFilterMode === 0) {
                // Only Block mode (blacklist): block hosts marked DENY
                if (status === 'DENY') return 'HOST_DENY:' + host;
                return null; // allow everything else
            } else {
                // Only Allow mode (whitelist): only allow hosts marked ALLOW
                if (status === 'ALLOW') return null; // allowed
                return 'HOST_NOT_ALLOWED:' + host; // block everything else
            }
        }

        function loadFilterMode() {
            try {
                var ctx = _getCtx();
                if (ctx === null) return;
                var prefs = ctx.getSharedPreferences(_jstr('hspatch_config'), 0);
                if (prefs.contains(_jstr('network_filter_mode'))) {
                    networkFilterMode = prefs.getInt(_jstr('network_filter_mode'), 0);
                    Log.i(netLogTag, '[FILTER] Mode loaded: ' + (networkFilterMode === 0 ? 'Only Block' : 'Only Allow'));
                }
            } catch(e) {
                Log.w(netLogTag, '[FILTER] Could not load mode: ' + e);
            }
        }

        function apiDumpEvent(source, method, urlOrMsg) {
            try { apiDumpWrite('[' + source + '] ' + method + ' ' + urlOrMsg); } catch (e4) { }
        }

        function loadBlockingRules() {
            try {
                var ctx = _getCtx();
                if (ctx === null) return;
                var pkgName = ctx.getPackageName();
                var fileNames = ['blocking_' + pkgName + '.txt', 'blocking_rules.txt', 'blocking_hotstar.txt'];
                var dirs = [];
                try { var fd = ctx.getFilesDir(); if (fd !== null) dirs.push(fd.getAbsolutePath()); } catch(e) {}
                try { dirs.push(ctx.getApplicationInfo().dataDir.value + '/files'); } catch(e) {}
                // App-specific external dir (no permission needed on Android 10+)
                try { var efd = ctx.getExternalFilesDir(null); if (efd !== null) dirs.push(efd.getAbsolutePath()); } catch(e) {}
                // Fallback: /sdcard/Download and /sdcard for non-root testing via adb push
                try {
                    var Environment = Java.use('android.os.Environment');
                    var sdcard = Environment.getExternalStorageDirectory().getAbsolutePath();
                    dirs.push(sdcard + '/Download');
                    dirs.push(sdcard);
                } catch(e) {}

                apiDumpEnabled = false;
                // trafficMonitorEnabled is now managed by SharedPreferences (set after loadBlockingRules)
                // Flag file is only a fallback for first-run or manual override
                var flagFileDisabled = false;
                try {
                    var File0 = _cls('java.io.File');
                    for (var dti = 0; dti < dirs.length; dti++) {
                        if (File0.$new(dirs[dti] + '/api_dump_enabled.txt').exists()) { apiDumpEnabled = true; break; }
                    }
                    // Check for traffic monitoring & blocking toggle (flag file fallback)
                    for (var dti2 = 0; dti2 < dirs.length; dti2++) {
                        if (File0.$new(dirs[dti2] + '/traffic_monitor_disabled.txt').exists()) {
                            flagFileDisabled = true;
                            break;
                        }
                    }
                } catch (eDump) { }

                var File = _cls('java.io.File');
                var BufferedReader = _cls('java.io.BufferedReader');
                var FileReader = _cls('java.io.FileReader');
                var found = false;
                for (var fi = 0; fi < fileNames.length && !found; fi++) {
                    for (var di = 0; di < dirs.length && !found; di++) {
                        var fullPath = dirs[di] + '/' + fileNames[fi];
                        try {
                            var f = File.$new(fullPath);
                            if (f.exists() && f.canRead()) {
                                Log.i(netLogTag, '[RULES] Loading from: ' + fullPath);
                                var reader = BufferedReader.$new(FileReader.$new(fullPath));
                                var line;
                                while ((line = reader.readLine()) !== null) {
                                    var ls = line.toString().trim();
                                    if (ls.length === 0 || ls.charAt(0) === '#') continue;
                                    var arrowIdx = ls.indexOf('=>');
                                    if (arrowIdx > 0) {
                                        var pat = ls.substring(0, arrowIdx).trim();
                                        var rep = ls.substring(arrowIdx + 2).trim();
                                        if (rep.length === 0 || rep === 'BLOCK') { blockPatterns.push(pat); }
                                        else { rewriteRules.push({ from: pat, to: rep }); }
                                    } else {
                                        if (ls.indexOf('://') !== -1 && ls.indexOf(':') !== -1) continue;
                                        var sepIdx = ls.indexOf(':');
                                        if (sepIdx > 0) {
                                            var pat2 = ls.substring(0, sepIdx).trim();
                                            var rep2 = ls.substring(sepIdx + 1).trim();
                                            if (rep2.length === 0 || rep2 === 'BLOCK') { blockPatterns.push(pat2); }
                                            else { rewriteRules.push({ from: pat2, to: rep2 }); }
                                        } else { blockPatterns.push(ls); }
                                    }
                                }
                                reader.close();
                                Log.i(netLogTag, '[RULES] ' + blockPatterns.length + ' block + ' + rewriteRules.length + ' rewrite');
                                found = true;
                            }
                        } catch (eFile) {
                            Log.d(netLogTag, '[RULES] Skip ' + fullPath + ': ' + eFile);
                        }
                    }
                }
                if (!found) { Log.w(netLogTag, '[RULES] No blocking rules file found in any search dir'); }
            } catch (err) { Log.w(netLogTag, '[RULES] Failed: ' + err); }
        }

        // Built-in blocks that persist across rule reloads
        var _builtinBlocks = [
            'v2.identity.tiled.media',
            'v2.identity.shenwavideo.cn'
        ];

        function scheduleRuleReload() {
            setTimeout(function() {
                Java.perform(function() {
                    var ob = blockPatterns.length, or2 = rewriteRules.length, od = apiDumpEnabled;
                    blockPatterns = _builtinBlocks.slice(); rewriteRules = _builtinRewrites.slice();
                    loadBlockingRules();
                    _buildBlockIndex();
                    if (blockPatterns.length !== ob || rewriteRules.length !== or2 || apiDumpEnabled !== od) {
                        Log.i(netLogTag, '[RULES] Reloaded: ' + blockPatterns.length + ' block, ' + rewriteRules.length + ' rewrite, dump=' + (apiDumpEnabled?'ON':'OFF'));
                    }
                    // Reload host rules and filter mode
                    var oldMode = networkFilterMode;
                    loadFilterMode();
                    var oldHostCount = Object.keys(discoveredHosts).length;
                    discoveredHosts = {};
                    loadHostRules();
                    var newHostCount = Object.keys(discoveredHosts).length;
                    if (oldMode !== networkFilterMode || oldHostCount !== newHostCount) {
                        Log.i(netLogTag, '[HOSTS] Reloaded: ' + newHostCount + ' hosts, mode=' + (networkFilterMode === 0 ? 'Block' : 'Allow'));
                    }
                });
                scheduleRuleReload();
            }, 120000); // v3.42: 120s instead of 5s to reduce GC pressure
        }
        loadBlockingRules();
        _buildBlockIndex();
        loadHostRules();
        loadFilterMode();
        scheduleRuleReload();

        // Restore toggle state from SharedPreferences (primary), flag file (fallback)
        try {
            var ctx0 = _getCtx();
            if (ctx0 !== null) {
                var prefs = ctx0.getSharedPreferences(_jstr('hspatch_config'), 0);
                if (prefs.contains(_jstr('blocking_enabled'))) {
                    trafficMonitorEnabled = prefs.getBoolean(_jstr('blocking_enabled'), true);
                    Log.i(netLogTag, '[TOGGLE] State restored from preferences: ' + (trafficMonitorEnabled ? 'ON' : 'OFF'));
                } else {
                    Log.i(netLogTag, '[TOGGLE] No saved preference, using default (ON)');
                }
            }
        } catch(ep) {
            Log.w(netLogTag, '[TOGGLE] Could not read preferences: ' + ep);
        }

        // Restore blocking notification visibility preference (default OFF)
        function loadBlockingNotificationPref() {
            try {
                var ctxN = _getCtx();
                if (ctxN === null) return;
                var prefsN = ctxN.getSharedPreferences(_jstr('hspatch_config'), 0);
                blockingNotificationEnabled = prefsN.getBoolean(_jstr('blocking_notification'), false);
            } catch (eN) {
                // Keep default false on errors
            }
        }
        loadBlockingNotificationPref();

        // =================== IN-APP BLOCKING TOGGLE (Notification) ===================
        function saveBlockingState(enabled) {
            try {
                var ctx = _getCtx();
                if (ctx === null) return;
                var prefs = ctx.getSharedPreferences(_jstr('hspatch_config'), 0);
                prefs.edit()
                    .putBoolean(_jstr('blocking_enabled'), enabled)
                    .apply();
                Log.i(netLogTag, '[TOGGLE] State saved to preferences: ' + (enabled ? 'ON' : 'OFF'));
            } catch(e) {
                Log.e(netLogTag, '[TOGGLE] Save error: ' + e);
            }
        }

        function updateBlockingNotification() {
            try {
                var ctx = _getCtx();
                if (ctx === null) return;
                var context = Java.cast(ctx, _cls('android.content.Context'));

                // Reload preference (allows live toggling from HostFilterActivity)
                try { loadBlockingNotificationPref(); } catch(ePref) {}

                var nm = Java.cast(context.getSystemService(_jstr('notification')),
                                   _cls('android.app.NotificationManager'));

                // If disabled, cancel existing notif and exit.
                if (!blockingNotificationEnabled) {
                    try { nm.cancel(NOTIF_ID); } catch(eCancel) {}
                    return;
                }

                var Intent = _cls('android.content.Intent');
                var PendingIntent = _cls('android.app.PendingIntent');
                var toggleIntent = Intent.$new(_jstr('hspatch.TOGGLE_BLOCK'));
                // FLAG_UPDATE_CURRENT | FLAG_IMMUTABLE
                var piFlags = 0x08000000 | 0x04000000;
                var togglePi = PendingIntent.getBroadcast(context, 0, toggleIntent, piFlags);

                var Builder = _cls('android.app.Notification$Builder');
                var builder = Builder.$new(context, _jstr(NOTIF_CHANNEL));

                var title = trafficMonitorEnabled
                    ? '\uD83D\uDEE1 Blocking: ON'
                    : '\uD83D\uDEE1 Blocking: OFF';
                var modeStr = networkFilterMode === 0 ? 'Blacklist' : 'Whitelist';
                var hostCount = Object.keys(discoveredHosts).length;
                var text = trafficMonitorEnabled
                    ? 'Mode: ' + modeStr + ' \u2022 ' + hostCount + ' hosts \u2022 Tap to disable'
                    : 'Blocking disabled \u2022 Tap to enable';

                var iconId = 17301624; // android.R.drawable.ic_lock_idle_lock
                try { iconId = ctx.getApplicationInfo().icon.value; } catch(e) {}

                builder.setSmallIcon(iconId);
                builder.setContentTitle(_jstr(title));
                builder.setContentText(_jstr(text));
                builder.setOngoing(true);
                builder.setContentIntent(togglePi);
                // Add explicit action button
                var actionLabel = trafficMonitorEnabled ? '\u274C Turn OFF' : '\u2705 Turn ON';
                builder.addAction(iconId,
                    Java.cast(_jstr(actionLabel), _cls('java.lang.CharSequence')),
                    togglePi);
                nm.notify(NOTIF_ID, builder.build());
            } catch(e) {
                Log.e(netLogTag, '[TOGGLE] Notification error: ' + e);
            }
        }

        function setupBlockingToggleUI() {
            try {
                var ctx = _getCtx();
                if (ctx === null) {
                    Log.w(netLogTag, '[TOGGLE] No context yet, retrying in 3s...');
                    setTimeout(function() { Java.perform(function() { setupBlockingToggleUI(); }); }, 3000);
                    return;
                }
                var context = Java.cast(ctx, _cls('android.content.Context'));

                // Create notification channel (Android O+)
                var NotificationChannel = _cls('android.app.NotificationChannel');
                var nm = Java.cast(context.getSystemService(_jstr('notification')),
                                   _cls('android.app.NotificationManager'));
                var ch = NotificationChannel.$new(
                    _jstr(NOTIF_CHANNEL),
                    Java.cast(_jstr('HSPatch Blocking Control'), _cls('java.lang.CharSequence')),
                    2); // IMPORTANCE_LOW — no sound
                ch.setDescription(_jstr('Toggle ad/tracker blocking on or off'));
                nm.createNotificationChannel(ch);

                // Register BroadcastReceiver for toggle action
                if (!toggleReceiverRegistered) {
                    var BroadcastReceiver = Java.use('android.content.BroadcastReceiver');
                    var ReceiverClass = Java.registerClass({
                        name: 'hspatch.BlockToggleReceiver',
                        superClass: BroadcastReceiver,
                        methods: {
                            onReceive: [{
                                returnType: 'void',
                                argumentTypes: ['android.content.Context', 'android.content.Intent'],
                                implementation: function(c, i) {
                                    try {
                                        trafficMonitorEnabled = !trafficMonitorEnabled;
                                        Log.i(netLogTag, '[TOGGLE] Blocking ' + (trafficMonitorEnabled ? 'ENABLED' : 'DISABLED') + ' via notification/debug panel');
                                        saveBlockingState(trafficMonitorEnabled);
                                        // Also reload filter mode in case it changed from debug panel
                                        loadFilterMode();
                                        updateBlockingNotification();
                                        // Show toast
                                        try {
                                            var ctx2 = _getCtx();
                                            var Toast = _cls('android.widget.Toast');
                                            var msg = trafficMonitorEnabled ? 'Blocking ON' : 'Blocking OFF';
                                            Toast.makeText(ctx2, Java.cast(_jstr(msg), _cls('java.lang.CharSequence')), 0).show();
                                        } catch(et) {}
                                    } catch(e) {
                                        Log.e(netLogTag, '[TOGGLE] onReceive error: ' + e);
                                    }
                                }
                            }]
                        }
                    });

                    var filter = _cls('android.content.IntentFilter').$new(
                        _jstr('hspatch.TOGGLE_BLOCK'));
                    var receiver = ReceiverClass.$new();

                    // API 33+ requires RECEIVER_NOT_EXPORTED flag
                    try {
                        context.registerReceiver(receiver, filter, 4); // 4 = RECEIVER_NOT_EXPORTED
                    } catch(e) {
                        try {
                            context.registerReceiver(receiver, filter);
                        } catch(e2) {
                            Log.e(netLogTag, '[TOGGLE] Cannot register receiver: ' + e2);
                        }
                    }
                    toggleReceiverRegistered = true;
                }

                // Receiver to refresh/cancel notification when preference changes
                if (!refreshNotifReceiverRegistered) {
                    try {
                        var BroadcastReceiver2 = Java.use('android.content.BroadcastReceiver');
                        var RefreshClass = Java.registerClass({
                            name: 'hspatch.BlockNotifRefreshReceiver',
                            superClass: BroadcastReceiver2,
                            methods: {
                                onReceive: [{
                                    returnType: 'void',
                                    argumentTypes: ['android.content.Context', 'android.content.Intent'],
                                    implementation: function(c, i) {
                                        try {
                                            updateBlockingNotification();
                                        } catch (eR) {
                                            Log.e(netLogTag, '[TOGGLE] Refresh receiver error: ' + eR);
                                        }
                                    }
                                }]
                            }
                        });

                        var filter2 = _cls('android.content.IntentFilter').$new(
                            _jstr('hspatch.REFRESH_BLOCK_NOTIF'));
                        var receiver2 = RefreshClass.$new();

                        try {
                            context.registerReceiver(receiver2, filter2, 4); // RECEIVER_NOT_EXPORTED
                        } catch(eR0) {
                            try { context.registerReceiver(receiver2, filter2); } catch(eR1) {}
                        }

                        refreshNotifReceiverRegistered = true;
                    } catch(eRR) {
                        Log.e(netLogTag, '[TOGGLE] Cannot register refresh receiver: ' + eRR);
                    }
                }

                // Show initial notification
                updateBlockingNotification();
                Log.i(netLogTag, '[TOGGLE] In-app blocking toggle ready (notification)');
            } catch(e) {
                Log.e(netLogTag, '[TOGGLE] Setup error: ' + e);
            }
        }

        // =====================================================
        // 5b. WEBSOCKET KILL SWITCH
        //     Completely blocks all WebSocket connections when enabled.
        //     Toggled via Debug Panel switch, persisted via prefs.
        // =====================================================
        var websocketKillEnabled = false;
        var wsKillTag = 'HSPatch-WSKill';

        function loadWebsocketKillPref() {
            try {
                var ctxWS = _getCtx();
                if (ctxWS === null) return;
                var prefsWS = ctxWS.getSharedPreferences(_jstr('hspatch_config'), 0);
                websocketKillEnabled = prefsWS.getBoolean(_jstr('websocket_kill'), false);
                Log.i(wsKillTag, '[WS-KILL] Pref loaded: ' + (websocketKillEnabled ? 'ON' : 'OFF'));
            } catch (eWS) {
                // Keep default false on errors
            }
        }
        loadWebsocketKillPref();

        // Hook OkHttp3 newWebSocket — the primary WebSocket creation API
        try {
            var OkHttpClient_WS = Java.use('okhttp3.OkHttpClient');
            var _okNewWS = OkHttpClient_WS.newWebSocket.overload('okhttp3.Request', 'okhttp3.WebSocketListener');
            _okNewWS.implementation = function(request, listener) {
                loadWebsocketKillPref();
                if (websocketKillEnabled) {
                    var url = request.url().toString();
                    Log.i(wsKillTag, '[WS-KILL] BLOCKED OkHttp3 WebSocket: ' + url);
                    // Call listener.onFailure with an IOException to cleanly notify the caller
                    try {
                        var IOException = _cls('java.io.IOException');
                        var failEx = IOException.$new('HSPatch: WebSocket killed by user toggle');
                        var Response_WS = _cls('okhttp3.Response');
                        listener.onFailure(Java.cast(_cls('java.lang.Object').$new(), _cls('okhttp3.WebSocket')), failEx, null);
                    } catch(eFail) {
                        // If onFailure fails, just log it
                        Log.d(wsKillTag, '[WS-KILL] onFailure callback error (non-critical): ' + eFail);
                    }
                    return null;
                }
                return _okNewWS.call(this, request, listener);
            };
            Log.i(wsKillTag, '[+] OkHttp3 newWebSocket hooked');
        } catch (e) {
            Log.d(wsKillTag, '[-] OkHttp3 newWebSocket hook: ' + e);
        }

        // Hook RealWebSocket.connect — catches internal WebSocket initiation
        try {
            var RealWebSocket = Java.use('okhttp3.internal.ws.RealWebSocket');
            var _rwsConnect = RealWebSocket.connect.overload('okhttp3.OkHttpClient');
            _rwsConnect.implementation = function(client) {
                loadWebsocketKillPref();
                if (websocketKillEnabled) {
                    Log.i(wsKillTag, '[WS-KILL] BLOCKED RealWebSocket.connect');
                    return; // Simply don't connect
                }
                return _rwsConnect.call(this, client);
            };
            Log.i(wsKillTag, '[+] RealWebSocket.connect hooked');
        } catch (e) {
            Log.d(wsKillTag, '[-] RealWebSocket.connect hook: ' + e);
        }

        // Hook java.net WebSocket (JSR 356 / Tyrus)
        try {
            var WebSocketContainer = Java.use('javax.websocket.ContainerProvider');
            var _getContainer = WebSocketContainer.getWebSocketContainer;
            _getContainer.implementation = function() {
                loadWebsocketKillPref();
                if (websocketKillEnabled) {
                    Log.i(wsKillTag, '[WS-KILL] BLOCKED WebSocketContainer creation');
                    throw _cls('java.lang.RuntimeException').$new('HSPatch: WebSocket killed by user toggle');
                }
                return _getContainer.call(this);
            };
            Log.i(wsKillTag, '[+] javax.websocket hooked');
        } catch (e) {
            // javax.websocket may not be present — that's fine
            Log.d(wsKillTag, '[-] javax.websocket hook: ' + e);
        }

        Log.i(wsKillTag, '[*] WebSocket kill switch installed (state: ' + (websocketKillEnabled ? 'ON' : 'OFF') + ')');

        // =====================================================
        // 5c. APP BAR HIDE (Bottom Navigation)
        //     Hides the bottom navigation bar in JioHotstar
        //     for a more immersive content viewing experience.
        //     Toggled via Debug Panel switch, persisted via prefs.
        // =====================================================
        var appBarHideEnabled = false;
        var appBarTag = 'HSPatch-AppBar';
        var _appBarHideTimer = null;

        function loadAppBarHidePref() {
            try {
                var ctxAB = _getCtx();
                if (ctxAB === null) return;
                var prefsAB = ctxAB.getSharedPreferences(_jstr('hspatch_config'), 0);
                appBarHideEnabled = prefsAB.getBoolean(_jstr('appbar_hide'), false);
            } catch (eAB) {
                // Keep default false on errors
            }
        }
        loadAppBarHidePref();

        // Traverse view tree and hide/show views matching the target resource-id
        function _setAppBarVisibility(rootView, visible) {
            var GONE = 8, VISIBLE = 0;
            var target = visible ? VISIBLE : GONE;
            var found = false;

            function traverse(view) {
                try {
                    // Check AccessibilityNodeInfo resource name (works for React Native testID)
                    var nodeInfo = view.createAccessibilityNodeInfo();
                    if (nodeInfo !== null) {
                        var resName = nodeInfo.getViewIdResourceName();
                        if (resName !== null) {
                            var rn = resName.toString();
                            if (rn === 'tag_bottom_menu') {
                                view.setVisibility(target);
                                found = true;
                                Log.i(appBarTag, '[APP-BAR] ' + (visible ? 'SHOWN' : 'HIDDEN') + ' bottom nav (tag_bottom_menu)');
                                nodeInfo.recycle();
                                return;
                            }
                        }
                        nodeInfo.recycle();
                    }
                } catch (eN) {}

                // Recurse into ViewGroup children
                try {
                    var ViewGroup = Java.use('android.view.ViewGroup');
                    var vg = Java.cast(view, ViewGroup);
                    var count = vg.getChildCount();
                    for (var i = 0; i < count; i++) {
                        traverse(vg.getChildAt(i));
                        if (found) return;
                    }
                } catch (eV) {}
            }

            traverse(rootView);
            return found;
        }

        // Apply app bar hide to the current Activity
        function applyAppBarHide() {
            loadAppBarHidePref();
            if (!appBarHideEnabled) return;
            try {
                var ActivityThread = Java.use('android.app.ActivityThread');
                var at = ActivityThread.currentActivityThread();
                var app = at.getApplication();
                if (app === null) return;

                // Get current resumed Activity
                var activities = at.mActivities.value;
                var keys = activities.keySet().toArray();
                for (var k = 0; k < keys.length; k++) {
                    var record = activities.get(keys[k]);
                    if (record === null) continue;
                    var paused = record.paused.value;
                    if (paused) continue;
                    var act = record.activity.value;
                    if (act === null) continue;

                    var decor = act.getWindow().getDecorView();
                    if (_setAppBarVisibility(decor, false)) {
                        Log.i(appBarTag, '[APP-BAR] Hide applied to ' + act.getClass().getName());
                    }
                }
            } catch (eA) {
                Log.d(appBarTag, '[APP-BAR] applyAppBarHide error: ' + eA);
            }
        }

        // Schedule periodic re-application (React Native may recreate views)
        function scheduleAppBarHide() {
            if (_appBarHideTimer !== null) {
                clearInterval(_appBarHideTimer);
                _appBarHideTimer = null;
            }
            loadAppBarHidePref();
            if (appBarHideEnabled) {
                // Initial apply after a short delay for view tree to settle
                setTimeout(function() { Java.perform(function() { applyAppBarHide(); }); }, 2000);
                // Re-apply every 5 seconds (handles navigation/recreation)
                _appBarHideTimer = setInterval(function() {
                    Java.perform(function() { applyAppBarHide(); });
                }, 5000);
                Log.i(appBarTag, '[APP-BAR] Auto-hide scheduled');
            } else {
                // Restore visibility when disabled
                try {
                    var ActivityThread2 = Java.use('android.app.ActivityThread');
                    var at2 = ActivityThread2.currentActivityThread();
                    var activities2 = at2.mActivities.value;
                    var keys2 = activities2.keySet().toArray();
                    for (var k2 = 0; k2 < keys2.length; k2++) {
                        var record2 = activities2.get(keys2[k2]);
                        if (record2 === null) continue;
                        var act2 = record2.activity.value;
                        if (act2 === null) continue;
                        var decor2 = act2.getWindow().getDecorView();
                        _setAppBarVisibility(decor2, true);
                    }
                } catch (eR) {}
                Log.i(appBarTag, '[APP-BAR] Auto-hide disabled, bars restored');
            }
        }

        // Register broadcast receiver for toggle from DebugPanel
        function setupAppBarHideToggle() {
            try {
                var ctx = _getCtx();
                if (ctx === null) {
                    setTimeout(function() { Java.perform(function() { setupAppBarHideToggle(); }); }, 3000);
                    return;
                }
                var context = Java.cast(ctx, _cls('android.content.Context'));

                var BroadcastReceiver = Java.use('android.content.BroadcastReceiver');
                var ABReceiver = Java.registerClass({
                    name: 'hspatch.AppBarHideReceiver',
                    superClass: BroadcastReceiver,
                    methods: {
                        onReceive: [{
                            returnType: 'void',
                            argumentTypes: ['android.content.Context', 'android.content.Intent'],
                            implementation: function(c, i) {
                                try {
                                    loadAppBarHidePref();
                                    scheduleAppBarHide();
                                    Log.i(appBarTag, '[APP-BAR] Toggle received: ' + (appBarHideEnabled ? 'HIDE' : 'SHOW'));
                                } catch (eT) {
                                    Log.e(appBarTag, '[APP-BAR] Toggle error: ' + eT);
                                }
                            }
                        }]
                    }
                });

                var filter = _cls('android.content.IntentFilter').$new(_jstr('hspatch.TOGGLE_APPBAR_HIDE'));
                var receiver = ABReceiver.$new();
                try {
                    context.registerReceiver(receiver, filter, 4); // RECEIVER_NOT_EXPORTED
                } catch (e1) {
                    try { context.registerReceiver(receiver, filter); } catch (e2) {}
                }

                // Apply initial state
                scheduleAppBarHide();
                Log.i(appBarTag, '[APP-BAR] Hide toggle ready (state: ' + (appBarHideEnabled ? 'ON' : 'OFF') + ')');
            } catch (eS) {
                Log.e(appBarTag, '[APP-BAR] Setup error: ' + eS);
            }
        }

        // =====================================================
        // OPTIMIZED BLOCKING ENGINE
        // Domain-only patterns stored in hash for O(1) lookup.
        // Path patterns kept in array for substring matching.
        // =====================================================
        var _domainBlockSet = {};    // exact domain patterns → O(1)
        var _pathBlockPatterns = []; // patterns with '/' → substring scan

        function _buildBlockIndex() {
            _domainBlockSet = {};
            _pathBlockPatterns = [];
            for (var i = 0; i < blockPatterns.length; i++) {
                var p = blockPatterns[i];
                if (p.indexOf('/') === -1) {
                    // Domain-only pattern: store lowercase for O(1) lookup
                    _domainBlockSet[p.toLowerCase()] = p;
                } else {
                    _pathBlockPatterns.push(p);
                }
            }
        }

        // Extract host from URL (fast, no regex)
        function _extractHost(url) {
            var protoEnd = url.indexOf('://');
            if (protoEnd === -1) return null;
            var hostStart = protoEnd + 3;
            var hostEnd = url.indexOf('/', hostStart);
            if (hostEnd === -1) hostEnd = url.indexOf('?', hostStart);
            if (hostEnd === -1) hostEnd = url.length;
            var host = url.substring(hostStart, hostEnd);
            var colonIdx = host.indexOf(':');
            if (colonIdx !== -1) host = host.substring(0, colonIdx);
            return host;
        }

        function shouldBlock(url) {
            if (!trafficMonitorEnabled) return null;

            // Fast path: check domain hash O(1)
            var host = _extractHost(url);
            if (host) {
                var hostLower = host.toLowerCase();
                // Check exact domain match in hash
                if (_domainBlockSet[hostLower]) return _domainBlockSet[hostLower];
                // Check domain substring match (e.g. pattern "ads.example" matches "cdn.ads.example.com")
                var domainKeys = Object.keys(_domainBlockSet);
                for (var d = 0; d < domainKeys.length; d++) {
                    if (hostLower.indexOf(domainKeys[d]) !== -1) return _domainBlockSet[domainKeys[d]];
                }
            }

            // Check path-containing patterns (substring match on full URL)
            for (var i = 0; i < _pathBlockPatterns.length; i++) {
                if (url.indexOf(_pathBlockPatterns[i]) !== -1) return _pathBlockPatterns[i];
            }

            // Check host-based rules (discoveredHosts ALLOW/DENY)
            if (host) {
                var hostResult = shouldBlockByHostRules(host);
                if (hostResult) return hostResult;
            }
            return null;
        }

        // DNS-safe version: only checks domain-level rules (no path patterns)
        function shouldBlockDNS(hostname) {
            if (!trafficMonitorEnabled) return null;
            var hostLower = hostname.toLowerCase();

            // Fast path: exact domain hash match
            if (_domainBlockSet[hostLower]) return _domainBlockSet[hostLower];

            // Substring match on domain patterns only
            var domainKeys = Object.keys(_domainBlockSet);
            for (var d = 0; d < domainKeys.length; d++) {
                if (hostLower.indexOf(domainKeys[d]) !== -1) return _domainBlockSet[domainKeys[d]];
            }

            // Check host-based rules
            var hostResult = shouldBlockByHostRules(hostname);
            if (hostResult) return hostResult;
            return null;
        }

        function applyRewrites(url) {
            var modified = url, changed = false;
            for (var i = 0; i < rewriteRules.length; i++) {
                if (modified.indexOf(rewriteRules[i].from) !== -1) {
                    modified = modified.split(rewriteRules[i].from).join(rewriteRules[i].to);
                    changed = true;
                }
            }
            return { url: modified, changed: changed };
        }

        function ensureNetworkLoggerInitialized() {
            try {
                var ctx = _getCtx();
                if (ctx === null) return;
                _cls('in.startv.hotstar.NetworkLogger').init(ctx);
            } catch (e) { }
        }
        function safeNetworkLoggerLog(line) {
            try { ensureNetworkLoggerInitialized(); _cls('in.startv.hotstar.NetworkLogger').log(line); } catch (e) { }
        }
        function logRewritten(source, method, before, after) {
            Log.i(netLogTag, '[REWRITE] [' + source + '] ' + method + ' ' + before + ' -> ' + after);
            safeNetworkLoggerLog('[REWRITE] [' + source + '] ' + method + ' ' + before + ' -> ' + after);
            apiDumpEvent(source, method, before + ' -> ' + after);
        }
        // Batched blocked URL file writer (reduces sync I/O from per-event to periodic flush)
        var _blockedUrlBuffer = [];
        var _blockedUrlFlushTimer = null;

        function _flushBlockedUrls() {
            _blockedUrlFlushTimer = null;
            if (_blockedUrlBuffer.length === 0) return;
            var batch = _blockedUrlBuffer.splice(0);
            Java.perform(function() {
                try {
                    var bp = getInternalFilePath('blocked_urls.txt');
                    if (bp) {
                        var fw = _cls('java.io.FileWriter').$new(bp, true);
                        for (var i = 0; i < batch.length; i++) {
                            fw.write(batch[i] + '\n');
                        }
                        fw.flush();
                        fw.close();
                    }
                } catch(e2) {}
            });
        }

        function logBlocked(source, method, url, pattern) {
            Log.i(netLogTag, '[BLOCKED] [' + source + '] ' + method + ' ' + url + ' (matched: ' + pattern + ')');
            safeNetworkLoggerLog('[BLOCKED] [' + source + '] ' + method + ' ' + url + ' (matched: ' + pattern + ')');
            _blockedUrlBuffer.push(url);
            if (_blockedUrlFlushTimer === null) {
                _blockedUrlFlushTimer = setTimeout(_flushBlockedUrls, 3000);
            }
            apiDumpEvent(source, method, 'BLOCK ' + url + ' (matched: ' + pattern + ')');
        }

        // =========================================================
        //  LAYER 1: NATIVE libc HOOKS  — GROUND TRUTH
        //  Every TCP/UDP/DNS call on Android goes through these.
        //  No Java library, native SDK, or JNI code can bypass them.
        // =========================================================

        // v3.42: _fdMap, _fdLoggedSend, _fdLoggedRecv REMOVED — no longer
        // needed after removing send/recv/write/read/close hooks

        // Parse struct sockaddr → { family, ip, port }
        function parseSockaddr(addrPtr, addrLen) {
            try {
                if (addrPtr.isNull()) return null;
                var family = addrPtr.readU16();

                if (family === 2 && addrLen >= 8) { // AF_INET
                    var port = (addrPtr.add(2).readU8() << 8) | addrPtr.add(3).readU8();
                    var ip = addrPtr.add(4).readU8() + '.' + addrPtr.add(5).readU8() + '.' +
                             addrPtr.add(6).readU8() + '.' + addrPtr.add(7).readU8();
                    return { family: 'IPv4', ip: ip, port: port };
                }

                if (family === 10 && addrLen >= 28) { // AF_INET6
                    var port6 = (addrPtr.add(2).readU8() << 8) | addrPtr.add(3).readU8();
                    // Check for IPv4-mapped (::ffff:x.x.x.x)
                    var b10 = addrPtr.add(8 + 10).readU8(), b11 = addrPtr.add(8 + 11).readU8();
                    if (b10 === 0xff && b11 === 0xff) {
                        var ip4 = addrPtr.add(8+12).readU8() + '.' + addrPtr.add(8+13).readU8() + '.' +
                                  addrPtr.add(8+14).readU8() + '.' + addrPtr.add(8+15).readU8();
                        return { family: 'IPv4', ip: ip4, port: port6 };
                    }
                    var parts = [];
                    for (var j = 0; j < 16; j += 2) {
                        parts.push(((addrPtr.add(8+j).readU8() << 8) | addrPtr.add(8+j+1).readU8()).toString(16));
                    }
                    return { family: 'IPv6', ip: parts.join(':'), port: port6 };
                }

                return null; // AF_UNIX, etc. — skip
            } catch (e) { return null; }
        }

        // Util: first N printable chars from a buffer (for peeking at HTTP headers)
        function peekBuf(ptr, len, maxChars) {
            try {
                var n = Math.min(len, maxChars || 256);
                var bytes = ptr.readByteArray(n);
                if (bytes === null) return '';
                var arr = new Uint8Array(bytes);
                var s = '';
                for (var i = 0; i < arr.length; i++) {
                    var c = arr[i];
                    if (c === 0) break;
                    if (c >= 0x20 && c < 0x7f) s += String.fromCharCode(c);
                    else if (c === 0x0a) s += '\\n';
                    else if (c === 0x0d) s += '\\r';
                    else s += '.';
                }
                return s;
            } catch (e) { return ''; }
        }

        // === connect(fd, addr, addrlen) — EVERY outbound TCP/UDP connection ===
        // v3.42: onEnter-only (no onLeave) saves ~5μs per call per Frida docs
        try {
            var _connectPtr = Process.getModuleByName('libc.so').getExportByName('connect');
            Interceptor.attach(_connectPtr, {
                onEnter: function(args) {
                    var sa = parseSockaddr(args[1], args[2].toInt32());
                    if (sa === null) return;
                    if (sa.ip === '127.0.0.1' || sa.ip === '0:0:0:0:0:0:0:1') return;
                    var fd = args[0].toInt32();
                    var dest = sa.ip + ':' + sa.port;
                    console.log('[NET] CONNECT fd=' + fd + ' -> ' + dest);
                    nativeLog('[NET] CONNECT fd=' + fd + ' -> ' + dest);
                    apiDumpEvent('NATIVE', 'CONNECT', 'fd=' + fd + ' ' + sa.family + ' ' + dest);
                }
            });
            nativeLog('[+] Native connect() hooked');
        } catch (e) { nativeLog('[-] connect hook: ' + e); }

        // === getaddrinfo(hostname, service, hints, res) — ALL DNS lookups ===
        try {
            var _gaiPtr = Process.getModuleByName('libc.so').getExportByName('getaddrinfo');
            Interceptor.attach(_gaiPtr, {
                onEnter: function(args) {
                    this.host = args[0].isNull() ? null : args[0].readCString();
                    this.svc = args[1].isNull() ? null : args[1].readCString();
                },
                onLeave: function(retval) {
                    if (this.host === null) return;
                    var entry = this.host + (this.svc ? ':' + this.svc : '');
                    nativeLog('[NET] DNS ' + entry);
                    apiDumpEvent('DNS', 'RESOLVE', entry);

                    // Block check on hostname — DNS-safe (domain rules only, no path patterns)
                    var bm = shouldBlockDNS(this.host);
                    if (bm !== null) {
                        nativeLog('[NET] DNS BLOCKED: ' + this.host + ' (rule: ' + bm + ')');
                        apiDumpEvent('DNS', 'BLOCKED', this.host + ' rule=' + bm);
                        // Return EAI_NONAME (8) to fail the lookup
                        retval.replace(8);
                    }
                }
            });
            nativeLog('[+] Native getaddrinfo() hooked');
        } catch (e) { nativeLog('[-] getaddrinfo hook: ' + e); }

        // v3.42: REMOVED send()/sendto()/recvfrom() hooks — monitoring-only,
        // not blocking. They intercepted every socket data transfer causing lag.
        // Blocking is handled by getaddrinfo() (DNS) + Java URL hooks + TLS SNI.

        // v3.42: REMOVED write()/read()/close() hooks — they intercepted EVERY
        // I/O syscall (file, pipe, binder, UI rendering, etc.) causing severe lag
        // and ANR. Network monitoring is handled by SSL_write + connect + getaddrinfo.

        console.log('[*] Native libc network hooks installed (Layer 1)');


        // =========================================================
        //  LAYER 2: NATIVE TLS HOOKS — SEE DECRYPTED HTTPS DATA
        //  Hooks SSL_write from BoringSSL (libssl.so)
        //  v3.42: SSL_read removed (hot during streaming, monitoring-only)
        //  SSL_write lets us see outgoing HTTP request headers.
        // =========================================================

        function tryAttachSSL(libName) {
            var sslMod = null;
            try { sslMod = Process.getModuleByName(libName); } catch (e) { return false; }
            if (sslMod === null) return false;

            // SSL_write(SSL*, buf, num) → see outgoing HTTPS plaintext
            try {
                var sslWritePtr = sslMod.getExportByName('SSL_write');
                if (sslWritePtr) {
                    Interceptor.attach(sslWritePtr, {
                        onEnter: function(args) {
                            this.ssl = args[0];
                            this.buf = args[1];
                            this.num = args[2].toInt32();
                        },
                        onLeave: function(retval) {
                            var written = retval.toInt32();
                            if (written <= 0) return;
                            var peek = peekBuf(this.buf, written, 384);
                            if (peek.length === 0) return;

                            // HTTP method detection: GET, POST, PUT, DELETE, PATCH, HEAD, OPTIONS
                            var isHttp = /^(GET|POST|PUT|DELETE|PATCH|HEAD|OPTIONS|CONNECT) /.test(peek);
                            if (isHttp) {
                                // Extract first line (request line)
                                var firstLine = peek.split('\\r\\n')[0] || peek.split('\\n')[0] || peek.substring(0, 120);
                                console.log('[NET] >> TLS-OUT: ' + firstLine);
                                apiDumpEvent('TLS', 'REQUEST', firstLine);
                                // Try extracting Host header
                                var hostMatch = peek.match(/Host: ([^\r\n\\]+)/i);
                                if (hostMatch) {
                                    apiDumpEvent('TLS', 'HOST', hostMatch[1]);
                                }
                            }
                            if (apiDumpEnabled) {
                                apiDumpWrite('  TLS>> ' + peek.substring(0, 512));
                            }
                        }
                    });
                    console.log('[+] SSL_write hooked from ' + libName);
                }
            } catch (e) { }

            // v3.42: REMOVED SSL_read hook — monitoring-only (response viewing).
            // During video streaming, SSL_read is called thousands of times/sec
            // for downloading video chunks. ~11μs overhead per call = severe lag.
            // SSL_write (kept above) provides sufficient request visibility.

            return true;
        }

        // Try hooking SSL from various possible library names
        // BoringSSL on Android is typically libssl.so
        // Some apps bundle their own (Chromium-based, Flutter, etc.)
        var sslLibNames = ['libssl.so', 'libssl.so.3', 'libssl.so.1.1'];
        var sslHooked = false;
        for (var si = 0; si < sslLibNames.length; si++) {
            if (tryAttachSSL(sslLibNames[si])) { sslHooked = true; break; }
        }

        // Also try hooking on module load for lazy-loaded SSL
        if (!sslHooked) {
            try {
                var _sslObserver = Process.attachModuleObserver({
                    onAdded: function(mod) {
                        if (mod.name === 'libssl.so' || mod.name.indexOf('libssl') !== -1) {
                            console.log('[+] Late-loaded SSL: ' + mod.name);
                            tryAttachSSL(mod.name);
                        }
                    }
                });
            } catch (e) {
                // attachModuleObserver not available on older Frida; fall back to delayed retry
                setTimeout(function() {
                    for (var si2 = 0; si2 < sslLibNames.length; si2++) {
                        if (tryAttachSSL(sslLibNames[si2])) break;
                    }
                }, 3000);
            }
        }

        console.log('[*] Native TLS hooks installed (Layer 2)');


        // =========================================================
        //  LAYER 3: JAVA HOOKS — URL PREPARATION-TIME ENFORCEMENT
        //  Block/rewrite at URL construction (preparation) time,
        //  BEFORE any connection is attempted. This is the earliest
        //  and most effective interception point.
        //  Monitoring is handled by Layer 1+2 above.
        // =========================================================

        // --- URL constructors — PRIMARY interception point ---
        // Hooking URL.$init catches URLs at preparation time, before
        // any connection or request object is created.
        try {
            var URL = Java.use('java.net.URL');

            // URL(String spec) — most common constructor
            try {
                var _urlInit1 = URL.$init.overload('java.lang.String');
                _urlInit1.implementation = function(spec) {
                    var s = spec ? spec.toString() : '';
                    // Only intercept HTTP/HTTPS URLs — skip content://, file://, jar:// etc.
                    if (s.length > 0 && (s.indexOf('http://') === 0 || s.indexOf('https://') === 0)) {
                        try {
                            var bm = shouldBlock(s);
                            if (bm !== null) { logBlocked('URL', '$init(String)', s, bm); return _urlInit1.call(this, 'http://127.0.0.1:1/blocked'); }
                            var rw = applyRewrites(s);
                            if (rw.changed) { logRewritten('URL', '$init(String)', s, rw.url); return _urlInit1.call(this, rw.url); }
                        } catch (hookErr) { Log.w(netLogTag, '[!] URL.$init hook err: ' + hookErr); }
                    }
                    return _urlInit1.call(this, spec);
                };
                Log.d(netLogTag, '[+] URL.$init(String) hooked');
            } catch (e) { Log.d(netLogTag, '[-] URL.$init(String): ' + e); }

            // URL(URL context, String spec) — relative URL resolution
            try {
                var _urlInit2 = URL.$init.overload('java.net.URL', 'java.lang.String');
                _urlInit2.implementation = function(context, spec) {
                    // Resolve the full URL by calling original, then check
                    _urlInit2.call(this, context, spec);
                    var full = this.toString();
                    if (full.indexOf('http://') !== 0 && full.indexOf('https://') !== 0) return; // skip non-HTTP
                    try {
                        var bm = shouldBlock(full);
                        if (bm !== null) { logBlocked('URL', '$init(URL,String)', full, bm); _urlInit1.call(this, 'http://127.0.0.1:1/blocked'); return; }
                        var rw = applyRewrites(full);
                        if (rw.changed) { logRewritten('URL', '$init(URL,String)', full, rw.url); _urlInit1.call(this, rw.url); return; }
                    } catch (hookErr) { Log.w(netLogTag, '[!] URL.$init(URL,String) hook err: ' + hookErr); }
                };
                Log.d(netLogTag, '[+] URL.$init(URL,String) hooked');
            } catch (e) { Log.d(netLogTag, '[-] URL.$init(URL,String): ' + e); }

            // URL(String protocol, String host, String file) — component constructor
            try {
                var _urlInit3 = URL.$init.overload('java.lang.String', 'java.lang.String', 'java.lang.String');
                _urlInit3.implementation = function(protocol, host, file) {
                    _urlInit3.call(this, protocol, host, file);
                    var proto = protocol ? protocol.toString().toLowerCase() : '';
                    if (proto !== 'http' && proto !== 'https') return; // skip non-HTTP
                    var full = this.toString();
                    try {
                        var bm = shouldBlock(full);
                        if (bm !== null) { logBlocked('URL', '$init(proto,host,file)', full, bm); _urlInit1.call(this, 'http://127.0.0.1:1/blocked'); return; }
                        var rw = applyRewrites(full);
                        if (rw.changed) { logRewritten('URL', '$init(proto,host,file)', full, rw.url); _urlInit1.call(this, rw.url); return; }
                    } catch (hookErr) { Log.w(netLogTag, '[!] URL.$init(proto,host,file) hook err: ' + hookErr); }
                };
                Log.d(netLogTag, '[+] URL.$init(proto,host,file) hooked');
            } catch (e) { Log.d(netLogTag, '[-] URL.$init(proto,host,file): ' + e); }

            // URL(String protocol, String host, int port, String file) — full constructor
            try {
                var _urlInit4 = URL.$init.overload('java.lang.String', 'java.lang.String', 'int', 'java.lang.String');
                _urlInit4.implementation = function(protocol, host, port, file) {
                    _urlInit4.call(this, protocol, host, port, file);
                    var proto = protocol ? protocol.toString().toLowerCase() : '';
                    if (proto !== 'http' && proto !== 'https') return; // skip non-HTTP
                    var full = this.toString();
                    try {
                        var bm = shouldBlock(full);
                        if (bm !== null) { logBlocked('URL', '$init(proto,host,port,file)', full, bm); _urlInit1.call(this, 'http://127.0.0.1:1/blocked'); return; }
                        var rw = applyRewrites(full);
                        if (rw.changed) { logRewritten('URL', '$init(proto,host,port,file)', full, rw.url); _urlInit1.call(this, rw.url); return; }
                    } catch (hookErr) { Log.w(netLogTag, '[!] URL.$init(proto,host,port,file) hook err: ' + hookErr); }
                };
                Log.d(netLogTag, '[+] URL.$init(proto,host,port,file) hooked');
            } catch (e) { Log.d(netLogTag, '[-] URL.$init(proto,host,port,file): ' + e); }

            // openConnection — secondary enforcement (catches any URL that
            // bypassed $init hooks, e.g. created via native code)
            var _urlOpen0 = URL.openConnection.overload();
            _urlOpen0.implementation = function() {
                var u = this.toString();
                if (u.indexOf('http://') === 0 || u.indexOf('https://') === 0) {
                    try {
                        var bm = shouldBlock(u);
                        if (bm !== null) { logBlocked('URL', 'OPEN', u, bm); return _urlOpen0.call(_cls('java.net.URL').$new('http://127.0.0.1:1/blocked')); }
                        var rw = applyRewrites(u);
                        if (rw.changed) { logRewritten('URL', 'OPEN', u, rw.url); return _urlOpen0.call(_cls('java.net.URL').$new(rw.url)); }
                    } catch (hookErr) { Log.w(netLogTag, '[!] URL.openConnection hook err: ' + hookErr); }
                }
                return _urlOpen0.call(this);
            };
            try {
                var _urlOpenProxy = URL.openConnection.overload('java.net.Proxy');
                _urlOpenProxy.implementation = function(proxy) {
                    var u = this.toString();
                    if (u.indexOf('http://') === 0 || u.indexOf('https://') === 0) {
                        try {
                            var bm = shouldBlock(u);
                            if (bm !== null) { logBlocked('URL', 'OPEN_PROXY', u, bm); return _urlOpenProxy.call(_cls('java.net.URL').$new('http://127.0.0.1:1/blocked'), proxy); }
                            var rw = applyRewrites(u);
                            if (rw.changed) { logRewritten('URL', 'OPEN_PROXY', u, rw.url); return _urlOpenProxy.call(_cls('java.net.URL').$new(rw.url), proxy); }
                        } catch (hookErr) { Log.w(netLogTag, '[!] URL.openConnection(Proxy) hook err: ' + hookErr); }
                    }
                    return _urlOpenProxy.call(this, proxy);
                };
            } catch (e) { }
        } catch (err) { Log.d(netLogTag, '[-] URL hooks: ' + err); }

        // --- java.net.URI.create — catches URI-based API calls ---
        // Many modern Android libraries use URI.create() instead of new URL()
        try {
            var URI = Java.use('java.net.URI');
            var _uriCreate = URI.create.overload('java.lang.String');
            _uriCreate.implementation = function(str) {
                var s = str ? str.toString() : '';
                if (s.length > 0 && (s.indexOf('http://') === 0 || s.indexOf('https://') === 0)) {
                    var bm = shouldBlock(s);
                    if (bm !== null) { logBlocked('URI', 'create', s, bm); return _uriCreate.call(this, 'http://127.0.0.1:1/blocked'); }
                    var rw = applyRewrites(s);
                    if (rw.changed) { logRewritten('URI', 'create', s, rw.url); return _uriCreate.call(this, rw.url); }
                }
                return _uriCreate.call(this, str);
            };
            Log.d(netLogTag, '[+] URI.create hooked');
        } catch (e) { Log.d(netLogTag, '[-] URI.create: ' + e); }

        // --- android.net.Uri.parse — most common on Android ---
        // Retrofit, Glide, Picasso, Volley, and most Android libs use Uri.parse()
        try {
            var AndroidUri = Java.use('android.net.Uri');
            var _uriParse = AndroidUri.parse.overload('java.lang.String');
            _uriParse.implementation = function(uriString) {
                var s = uriString ? uriString.toString() : '';
                if (s.length > 0 && (s.indexOf('http://') === 0 || s.indexOf('https://') === 0)) {
                    var bm = shouldBlock(s);
                    if (bm !== null) { logBlocked('Uri', 'parse', s, bm); return _uriParse.call(this, 'http://127.0.0.1:1/blocked'); }
                    var rw = applyRewrites(s);
                    if (rw.changed) { logRewritten('Uri', 'parse', s, rw.url); return _uriParse.call(this, rw.url); }
                }
                return _uriParse.call(this, uriString);
            };
            Log.d(netLogTag, '[+] android.net.Uri.parse hooked');
        } catch (e) { Log.d(netLogTag, '[-] Uri.parse: ' + e); }

        // --- OkHttp3 newCall — block/rewrite ---
        try {
            var OkHttpClient = Java.use('okhttp3.OkHttpClient');
            var _okNewCall = OkHttpClient.newCall.overload('okhttp3.Request');
            _okNewCall.implementation = function(request) {
                var url = request.url().toString();
                var method = request.method();
                var bm = shouldBlock(url);
                if (bm !== null) {
                    logBlocked('OkHttp3', method, url, bm);
                    // v3.44: null-safe blocked URL — parse() can return null for some OkHttp builds
                    var _blockedHU = _cls('okhttp3.HttpUrl').parse('http://127.0.0.1:1/blocked');
                    if (_blockedHU === null) _blockedHU = _cls('okhttp3.HttpUrl').parse('http://0.0.0.0/blocked');
                    if (_blockedHU !== null) {
                        var blockedReq = request.newBuilder().url(_blockedHU).build();
                        return _okNewCall.call(this, blockedReq);
                    }
                    return _okNewCall.call(this, request); // fallback: let it fail naturally
                }
                var rw = applyRewrites(url);
                if (rw.changed) {
                    logRewritten('OkHttp3', method, url, rw.url);
                    var newHttpUrl = _cls('okhttp3.HttpUrl').parse(rw.url);
                if (newHttpUrl !== null) return _okNewCall.call(this, request.newBuilder().url(newHttpUrl).build());
                }
                return _okNewCall.call(this, request);
            };
        } catch (err) { }

        // --- OkHttp3 HttpUrl.parse / HttpUrl.get — preparation-time hook ---
        // Many apps build requests via HttpUrl.parse() or HttpUrl.get() before newCall
        try {
            var HttpUrl = Java.use('okhttp3.HttpUrl');
            try {
                var _httpUrlParse = HttpUrl.parse.overload('java.lang.String');
                _httpUrlParse.implementation = function(url) {
                    var s = url ? url.toString() : '';
                    if (s.length > 0) {
                        var bm = shouldBlock(s);
                        if (bm !== null) { logBlocked('HttpUrl', 'parse', s, bm); return _httpUrlParse.call(this, 'http://127.0.0.1:1/blocked'); }
                        var rw = applyRewrites(s);
                        if (rw.changed) { logRewritten('HttpUrl', 'parse', s, rw.url); return _httpUrlParse.call(this, rw.url); }
                    }
                    return _httpUrlParse.call(this, url);
                };
                Log.d(netLogTag, '[+] OkHttp3 HttpUrl.parse hooked');
            } catch (e) { }
            try {
                var _httpUrlGet = HttpUrl.get.overload('java.lang.String');
                _httpUrlGet.implementation = function(url) {
                    var s = url ? url.toString() : '';
                    if (s.length > 0) {
                        var bm = shouldBlock(s);
                        if (bm !== null) { logBlocked('HttpUrl', 'get', s, bm); return _httpUrlGet.call(this, 'http://127.0.0.1:1/blocked'); }
                        var rw = applyRewrites(s);
                        if (rw.changed) { logRewritten('HttpUrl', 'get', s, rw.url); return _httpUrlGet.call(this, rw.url); }
                    }
                    return _httpUrlGet.call(this, url);
                };
                Log.d(netLogTag, '[+] OkHttp3 HttpUrl.get hooked');
            } catch (e) { }
        } catch (err) { Log.d(netLogTag, '[-] HttpUrl hooks: ' + err); }

        // --- Retrofit2 baseUrl — preparation-time hook ---
        // Retrofit.Builder.baseUrl() sets the root URL for all API calls
        try {
            var RetrofitBuilder = Java.use('retrofit2.Retrofit$Builder');
            var _rfBaseUrl = RetrofitBuilder.baseUrl.overload('java.lang.String');
            _rfBaseUrl.implementation = function(baseUrl) {
                var s = baseUrl ? baseUrl.toString() : '';
                if (s.length > 0) {
                    var rw = applyRewrites(s);
                    if (rw.changed) { logRewritten('Retrofit', 'baseUrl', s, rw.url); return _rfBaseUrl.call(this, rw.url); }
                }
                return _rfBaseUrl.call(this, baseUrl);
            };
            Log.d(netLogTag, '[+] Retrofit2 baseUrl hooked');
        } catch (e) { Log.d(netLogTag, '[-] Retrofit baseUrl: ' + e); }

        // --- Cronet newUrlRequestBuilder — block/rewrite ---
        // Cronet is Chromium's native HTTP stack. Hotstar uses it for most API traffic.
        // It bypasses HttpURLConnection and OkHttp completely.
        try {
            var CronetEngine = Java.use('org.chromium.net.CronetEngine');
            var _cronetNewUrlReq = CronetEngine.newUrlRequestBuilder.overload(
                'java.lang.String', 'org.chromium.net.UrlRequest$Callback', 'java.util.concurrent.Executor'
            );
            _cronetNewUrlReq.implementation = function(url, callback, executor) {
                var u = url ? url.toString() : '';
                var bm = shouldBlock(u);
                if (bm !== null) {
                    logBlocked('Cronet', 'REQUEST', u, bm);
                    return _cronetNewUrlReq.call(this, 'http://127.0.0.1:1/blocked', callback, executor);
                }
                var rw = applyRewrites(u);
                if (rw.changed) {
                    logRewritten('Cronet', 'REQUEST', u, rw.url);
                    return _cronetNewUrlReq.call(this, rw.url, callback, executor);
                }
                return _cronetNewUrlReq.call(this, url, callback, executor);
            };
            Log.i(netLogTag, '[+] Cronet newUrlRequestBuilder hooked');
        } catch (err) { Log.d(netLogTag, '[-] Cronet hook: ' + err); }

        // --- WebView loadUrl — block/rewrite ---
        try {
            var WebView = Java.use('android.webkit.WebView');
            var _wvLoad1 = WebView.loadUrl.overload('java.lang.String');
            _wvLoad1.implementation = function(url) {
                var bm = shouldBlock(url);
                if (bm !== null) { logBlocked('WebView', 'LOAD', url, bm); _wvLoad1.call(this, 'about:blank'); return; }
                var rw = applyRewrites(url);
                if (rw.changed) { logRewritten('WebView', 'LOAD', url, rw.url); _wvLoad1.call(this, rw.url); return; }
                _wvLoad1.call(this, url);
            };
            try {
                var _wvLoad2 = WebView.loadUrl.overload('java.lang.String', 'java.util.Map');
                _wvLoad2.implementation = function(url, headers) {
                    var bm = shouldBlock(url);
                    if (bm !== null) { logBlocked('WebView', 'LOAD', url, bm); _wvLoad1.call(this, 'about:blank'); return; }
                    var rw = applyRewrites(url);
                    if (rw.changed) { logRewritten('WebView', 'LOAD', url, rw.url); _wvLoad2.call(this, rw.url, headers); return; }
                    _wvLoad2.call(this, url, headers);
                };
            } catch (e) { }
            try {
                var _wvPost = WebView.postUrl.overload('java.lang.String', '[B');
                _wvPost.implementation = function(url, data) {
                    var bm = shouldBlock(url);
                    if (bm !== null) { logBlocked('WebView', 'POST', url, bm); _wvLoad1.call(this, 'about:blank'); return; }
                    var rw = applyRewrites(url);
                    if (rw.changed) { logRewritten('WebView', 'POST', url, rw.url); _wvPost.call(this, rw.url, data); return; }
                    _wvPost.call(this, url, data);
                };
            } catch (e) { }
            // WebView.loadDataWithBaseURL — intercept base URL for relative resource loads
            try {
                var _wvLoadData = WebView.loadDataWithBaseURL.overload(
                    'java.lang.String', 'java.lang.String', 'java.lang.String', 'java.lang.String', 'java.lang.String');
                _wvLoadData.implementation = function(baseUrl, data, mimeType, encoding, historyUrl) {
                    if (baseUrl) {
                        var b = baseUrl.toString();
                        var bm = shouldBlock(b);
                        if (bm !== null) { logBlocked('WebView', 'LOAD_DATA_BASE', b, bm); _wvLoadData.call(this, null, data, mimeType, encoding, historyUrl); return; }
                        var rw = applyRewrites(b);
                        if (rw.changed) { logRewritten('WebView', 'LOAD_DATA_BASE', b, rw.url); _wvLoadData.call(this, rw.url, data, mimeType, encoding, historyUrl); return; }
                    }
                    _wvLoadData.call(this, baseUrl, data, mimeType, encoding, historyUrl);
                };
            } catch (e) { }
        } catch (err) { }

        // --- HttpURLConnection — block before connect ---
        try {
            var HttpURLConnection = Java.use('java.net.HttpURLConnection');
            var _hucConnect = HttpURLConnection.connect;
            _hucConnect.implementation = function() {
                var u = this.getURL().toString();
                var bm = shouldBlock(u);
                if (bm !== null) { logBlocked('HttpConn', 'CONN', u, bm); throw _cls('java.io.IOException').$new('HSPatch: blocked: ' + bm); }
                return _hucConnect.call(this);
            };
        } catch (err) { }

        // --- InetAddress/Socket blocking + rewriting for hostname-level rules ---
        // Uses shouldBlockDNS (domain-only rules) so path patterns like /ads/v1/
        // don't accidentally block essential API domains.
        try {
            var InetAddress = Java.use('java.net.InetAddress');
            var _inetGetByName = InetAddress.getByName.overload('java.lang.String');
            _inetGetByName.implementation = function(host) {
                if (host) {
                    var h = host.toString();
                    // Rewrite check first: give neutralized domains a dummy value
                    var rw = applyRewrites(h);
                    if (rw.changed) { logRewritten('InetAddress','getByName',h,rw.url); return _inetGetByName.call(this, rw.url); }
                    var bm = shouldBlockDNS(h);
                    if (bm !== null) {
                        logBlocked('InetAddress', 'getByName', h, bm);
                        throw _cls('java.net.UnknownHostException').$new(h);
                    }
                }
                return _inetGetByName.call(this, host);
            };
            try {
                var _inetGetAll = InetAddress.getAllByName.overload('java.lang.String');
                _inetGetAll.implementation = function(host) {
                    if (host) {
                        var h = host.toString();
                        // Rewrite check first: give neutralized domains a dummy value
                        var rw = applyRewrites(h);
                        if (rw.changed) { logRewritten('InetAddress','getAllByName',h,rw.url); return _inetGetAll.call(this, rw.url); }
                        var bm = shouldBlockDNS(h);
                        if (bm !== null) {
                            logBlocked('InetAddress', 'getAllByName', h, bm);
                            throw _cls('java.net.UnknownHostException').$new(h);
                        }
                    }
                    return _inetGetAll.call(this, host);
                };
            } catch (e) { }
        } catch (err) { }

        Log.i(netLogTag, '[*] Java URL preparation hooks installed (Layer 3)');

        // =========================================================
        //  LAYER 4: ADVANCED HOOKING-BASED BLOCKING
        //  Deep interception at HTTP client execution level.
        //  Works because SSL pinning is already bypassed.
        //  This catches requests that may bypass URL construction hooks.
        //  Kept alongside Layer 3 (legacy) for defense in depth.
        // =========================================================

        var advBlockTag = 'HSPatch-AdvBlock';
        var advBlockCount = 0;

        // --- 4a. OkHttp Interceptor Injection ---
        // Dynamically inject a blocking interceptor into OkHttpClient instances.
        // This runs INSIDE the OkHttp pipeline after SSL is established,
        // catching everything even if URL.$init hooks were bypassed.
        try {
            var OkHttpClientBuilder = Java.use('okhttp3.OkHttpClient$Builder');

            // Register an interceptor class that checks URLs at execution time
            var OkInterceptor = Java.use('okhttp3.Interceptor');
            var Chain = Java.use('okhttp3.Interceptor$Chain');
            var Response = Java.use('okhttp3.Response');
            var ResponseBody = Java.use('okhttp3.ResponseBody');
            var Protocol = Java.use('okhttp3.Protocol');
            var MediaType = Java.use('okhttp3.MediaType');

            var BlockInterceptor = Java.registerClass({
                name: 'hspatch.BlockingInterceptor',
                implements: [OkInterceptor],
                methods: {
                    intercept: [{
                        returnType: 'okhttp3.Response',
                        argumentTypes: ['okhttp3.Interceptor$Chain'],
                        implementation: function(chain) {
                            var request = chain.request();
                            var url = request.url().toString();
                            var bm = shouldBlock(url);
                            if (bm !== null) {
                                logBlocked('OkHttp-Interceptor', request.method(), url, bm);
                                advBlockCount++;
                                // Return empty 204 No Content response via Builder (stable API)
                                var ResponseBuilder = _cls('okhttp3.Response$Builder');
                                return ResponseBuilder.$new()
                                    .request(request)
                                    .protocol(Protocol.HTTP_1_1.value)
                                    .code(204)
                                    .message(_jstr('Blocked by HSPatch'))
                                    .body(ResponseBody.create(
                                        MediaType.parse('text/plain'),
                                        _jstr('')
                                    ))
                                    .build();
                            }
                            // Not blocked — proceed normally
                            return chain.proceed(request);
                        }
                    }]
                }
            });

            // Hook OkHttpClient.Builder.build() to inject our interceptor
            var _builderBuild = OkHttpClientBuilder.build;
            _builderBuild.implementation = function() {
                try {
                    // Add our blocking interceptor as a network interceptor
                    this.addInterceptor(BlockInterceptor.$new());
                } catch (e) {
                    // If interceptor injection fails (e.g. obfuscated OkHttp), proceed silently
                }
                return _builderBuild.call(this);
            };
            Log.i(advBlockTag, '[+] OkHttp interceptor injection active');
        } catch (e) {
            // OkHttp may not be present (or may be heavily obfuscated)
            // Fall back — Response constructor approach
            try {
                // Try simpler approach: hook RealCall.execute/enqueue
                var RealCall = Java.use('okhttp3.internal.connection.RealCall');
                if (!RealCall) RealCall = Java.use('okhttp3.RealCall');

                var _rcExecute = RealCall.execute;
                _rcExecute.implementation = function() {
                    var url = this.request().url().toString();
                    var bm = shouldBlock(url);
                    if (bm !== null) {
                        logBlocked('RealCall', 'EXECUTE', url, bm);
                        advBlockCount++;
                        throw _cls('java.io.IOException').$new('HSPatch: blocked by rule: ' + bm);
                    }
                    return _rcExecute.call(this);
                };
                Log.i(advBlockTag, '[+] RealCall.execute() hooked (fallback)');
            } catch (e2) {
                Log.d(advBlockTag, '[-] OkHttp advanced hooks unavailable: ' + e2);
            }
        }

        // --- 4b. ExoPlayer / MediaPlayer URL blocking ---
        // Block ad/tracker URLs in video player pipelines
        // ExoPlayer is commonly used by streaming apps (Hotstar, etc.)
        try {
            // ExoPlayer DataSource blocking — catches media segment URLs
            var DataSpec = null;
            var dataSpecClasses = [
                'com.google.android.exoplayer2.upstream.DataSpec',
                'androidx.media3.datasource.DataSpec',
                'com.google.android.exoplayer.upstream.DataSpec'
            ];
            for (var dsi = 0; dsi < dataSpecClasses.length; dsi++) {
                try { DataSpec = Java.use(dataSpecClasses[dsi]); break; } catch(e) {}
            }

            if (DataSpec) {
                // Hook the uri field via DataSpec constructors
                try {
                    var _ds1 = DataSpec.$init.overload('android.net.Uri');
                    _ds1.implementation = function(uri) {
                        var u = uri ? uri.toString() : '';
                        var bm = shouldBlock(u);
                        if (bm !== null) {
                            logBlocked('ExoPlayer', 'DataSpec', u, bm);
                            advBlockCount++;
                            return _ds1.call(this, Java.use('android.net.Uri').parse('http://127.0.0.1:1/blocked'));
                        }
                        return _ds1.call(this, uri);
                    };
                    Log.i(advBlockTag, '[+] ExoPlayer DataSpec(Uri) hooked');
                } catch (e) {}

                try {
                    var _ds2 = DataSpec.$init.overload('android.net.Uri', 'long', 'long');
                    _ds2.implementation = function(uri, pos, len) {
                        var u = uri ? uri.toString() : '';
                        var bm = shouldBlock(u);
                        if (bm !== null) {
                            logBlocked('ExoPlayer', 'DataSpec', u, bm);
                            advBlockCount++;
                            return _ds2.call(this, Java.use('android.net.Uri').parse('http://127.0.0.1:1/blocked'), pos, len);
                        }
                        return _ds2.call(this, uri, pos, len);
                    };
                } catch (e) {}
            }

            // MediaPlayer.setDataSource blocking
            try {
                var MediaPlayer = Java.use('android.media.MediaPlayer');
                var _mpSetDs = MediaPlayer.setDataSource.overload('java.lang.String');
                _mpSetDs.implementation = function(path) {
                    var bm = shouldBlock(path);
                    if (bm !== null) {
                        logBlocked('MediaPlayer', 'setDataSource', path, bm);
                        advBlockCount++;
                        throw Java.use('java.io.IOException').$new('HSPatch: blocked media URL: ' + bm);
                    }
                    return _mpSetDs.call(this, path);
                };
                Log.i(advBlockTag, '[+] MediaPlayer.setDataSource hooked');
            } catch (e) {}

            // MediaPlayer.setDataSource(Context, Uri) blocking
            try {
                var MediaPlayer2 = Java.use('android.media.MediaPlayer');
                var _mpSetDs2 = MediaPlayer2.setDataSource.overload('android.content.Context', 'android.net.Uri');
                _mpSetDs2.implementation = function(ctx, uri) {
                    var u = uri ? uri.toString() : '';
                    var bm = shouldBlock(u);
                    if (bm !== null) {
                        logBlocked('MediaPlayer', 'setDataSource(Uri)', u, bm);
                        advBlockCount++;
                        throw Java.use('java.io.IOException').$new('HSPatch: blocked media URL: ' + bm);
                    }
                    return _mpSetDs2.call(this, ctx, uri);
                };
            } catch (e) {}

        } catch (err) {
            Log.d(advBlockTag, '[-] ExoPlayer/MediaPlayer hooks: ' + err);
        }

        // --- 4c. Volley RequestQueue blocking ---
        try {
            var RequestQueue = Java.use('com.android.volley.RequestQueue');
            var _rqAdd = RequestQueue.add.overload('com.android.volley.Request');
            _rqAdd.implementation = function(request) {
                try {
                    var url = request.getUrl();
                    if (url) {
                        var bm = shouldBlock(url);
                        if (bm !== null) {
                            logBlocked('Volley', request.getMethod() + '', url, bm);
                            advBlockCount++;
                            request.cancel();
                            return request;
                        }
                    }
                } catch (e) {}
                return _rqAdd.call(this, request);
            };
            Log.i(advBlockTag, '[+] Volley RequestQueue.add hooked');
        } catch (e) {
            Log.d(advBlockTag, '[-] Volley: ' + e);
        }

        // --- 4d. Glide/Picasso image URL blocking ---
        // Block tracking pixels and ad images loaded through image libraries
        try {
            var Glide = Java.use('com.bumptech.glide.Glide');
            var GlideWith = Glide['with'].overload('android.app.Activity');
            // Can't easily intercept Glide's load chain, but we can hook
            // GlideUrl which wraps all URLs
            try {
                var GlideUrl = Java.use('com.bumptech.glide.load.model.GlideUrl');
                var _glideUrlInit = GlideUrl.$init.overload('java.lang.String');
                _glideUrlInit.implementation = function(url) {
                    var bm = shouldBlock(url);
                    if (bm !== null) {
                        logBlocked('Glide', 'GlideUrl', url, bm);
                        advBlockCount++;
                        return _glideUrlInit.call(this, 'http://127.0.0.1:1/blocked');
                    }
                    return _glideUrlInit.call(this, url);
                };
                Log.i(advBlockTag, '[+] Glide GlideUrl hooked');
            } catch (e) {}
        } catch (e) {
            Log.d(advBlockTag, '[-] Glide: ' + e);
        }

        // --- 4e. Native connect() blocking for blocked IPs ---
        // Block at the native socket level if DNS resolution was bypassed
        // (e.g., app has hardcoded IPs or uses its own DNS resolver)
        // This is handled by Layer 1 connect() with DNS blocking.
        // Layer 4 adds: blocking based on the TLS SNI (Server Name Indication)
        try {
            // Hook SSL_set_tlsext_host_name to catch SNI-based blocking
            var sslLib = null;
            try { sslLib = Process.getModuleByName('libssl.so'); } catch(e) {}
            if (sslLib) {
                var sslSetTlsextHostName = sslLib.getExportByName('SSL_set_tlsext_host_name');
                if (sslSetTlsextHostName) {
                    Interceptor.attach(sslSetTlsextHostName, {
                        onEnter: function(args) {
                            var hostname = args[1].readCString();
                            if (hostname) {
                                var bm = shouldBlockDNS(hostname);
                                if (bm !== null) {
                                    nativeLog('[BLOCKED] TLS SNI: ' + hostname + ' (rule: ' + bm + ')');
                                    advBlockCount++;
                                    // Replace hostname with localhost to fail the connection
                                    args[1].writeUtf8String('localhost');
                                }
                            }
                        }
                    });
                    nativeLog('[+] SSL_set_tlsext_host_name hooked (SNI blocking)');
                }
            }
        } catch (e) {
            nativeLog('[-] SNI hook: ' + e);
        }

        Log.i(advBlockTag, '======================================================');
        Log.i(advBlockTag, '[#] HSPatch v3.52: Advanced Hooking-Based Blocker      [#]');
        Log.i(advBlockTag, '[*] Layer 4 hooks (in addition to Layer 3 legacy):');
        Log.i(advBlockTag, '[*]   OkHttp interceptor injection (build-time)');
        Log.i(advBlockTag, '[*]   ExoPlayer DataSpec + MediaPlayer URL blocking');
        Log.i(advBlockTag, '[*]   Volley RequestQueue.add blocking');
        Log.i(advBlockTag, '[*]   Glide GlideUrl blocking');
        Log.i(advBlockTag, '[*]   TLS SNI-based hostname blocking (native)');
        Log.i(advBlockTag, '======================================================');

        // Count domain vs path rules for summary
        var domainRuleCount = Object.keys(_domainBlockSet).length;
        var pathRuleCount = _pathBlockPatterns.length;
        Log.i(netLogTag, '======================================================');
        Log.i(netLogTag, '[#] HSPatch v3.52: URL preparation-time blocker       [#]');
        Log.i(netLogTag, '[*] Hooks: URL.$init(4), URI.create, Uri.parse,');
        Log.i(netLogTag, '[*]        HttpUrl.parse/get, Retrofit.baseUrl,');
        Log.i(netLogTag, '[*]        OkHttp3, Cronet, WebView, HttpURLConn,');
        Log.i(netLogTag, '[*]        InetAddress, native DNS/connect/TLS');
        Log.i(netLogTag, '[*] Layer 4: OkHttp interceptor, ExoPlayer, Volley, Glide, TLS SNI');
        Log.i(netLogTag, '[*] Blocking: ' + (trafficMonitorEnabled ? 'ENABLED' : 'DISABLED') + ' (toggle via notification)');
        Log.i(netLogTag, '[*] Block: ' + domainRuleCount + ' domains + ' + pathRuleCount + ' path patterns');
        Log.i(netLogTag, '[*] Rewrite rules: ' + rewriteRules.length);
        Log.i(netLogTag, '[*] API dump: ' + (apiDumpEnabled ? 'ENABLED' : 'Create api_dump_enabled.txt to enable'));
        Log.i(netLogTag, '======================================================');

        // Set up in-app blocking toggle notification
        setupBlockingToggleUI();

        // Set up app bar hide toggle
        setupAppBarHideToggle();
}

// Android version-aware launcher:
// - Android 16+ (SDK 36+): Java.performNow() — ART is already attached to the thread
// - Android 10+ (SDK 29+): Java.perform() — waits for ART runtime to be ready
try {
    Java.performNow(_hspatchMain);
} catch (e) {
    Java.perform(_hspatchMain);
}
