import Java from "frida-java-bridge";

/*
 * HSPatch Universal Frida Script v3.40
 * - SSL Certificate Pinning Bypass (Java + Native BoringSSL + Cronet)
 * - Security Error Dialog Suppression (JSON config + runtime fallback)
 * - Signature Verification Bypass (runtime layer)
 * - Piracy / License / Integrity Checks Removal
 * - Screenshot / Recording FLAG_SECURE Bypass
 * - Crypto Exception Resilience (Cipher.doFinal BadPaddingException safety net)
 * - Network Traffic Monitoring, Blocking & Modification
 * - URL Preparation-Time Content Blocker (URL.$init, URI.create, Uri.parse,
 *   HttpUrl.parse/get, Retrofit.baseUrl, OkHttp3, Cronet, WebView, DNS)
 *
 * NOTE: Java.performNow() is used for Android 16+ compatibility.
 * Java bridge imported via frida-java-bridge for Frida 17+ support.
 * performNow() runs synchronously on the current thread which already
 * has ART attached, ensuring hooks install before Application.onCreate().
 */

Java.performNow(function() {
    var TAG = "HSPatch-Frida";

    // Diagnostic: log Frida script engine status
    try {
        var AndroidLog = Java.use('android.util.Log');
        AndroidLog.i(TAG, 'Java.performNow() callback FIRED - SDK=' + Java.use('android.os.Build$VERSION').SDK_INT.value);
    } catch(e) {}

        console.log('');
        console.log('======================================================');
        console.log('[#] HSPatch Universal Bypass Suite v3.40              [#]');
        console.log('======================================================');


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

            // Delayed attempt: find the error-mapping class after classes are loaded
            function attemptErrorMapperHook() {
                Java.perform(function() {
                    try {
                        // Use Java.enumerateMethods to find the class dynamically
                        // Pattern: class with method a(IOException) in a 2-char package
                        var candidates = [];
                        try {
                            // Search for methods named 'a' in short-package classes
                            // that take IOException and return an enum-like type
                            var results = Java.enumerateMethods('*!a/s');
                            for (var ri = 0; ri < results.length; ri++) {
                                var group = results[ri];
                                for (var ci = 0; ci < group.classes.length; ci++) {
                                    var cls = group.classes[ci];
                                    var name = cls.name;
                                    // Look for 2-segment names like Nh.k, Ab.c, etc.
                                    if (/^[A-Z][a-z]\.[a-z]$/.test(name)) {
                                        for (var mi = 0; mi < cls.methods.length; mi++) {
                                            var sig = cls.methods[mi];
                                            if (sig.indexOf('IOException') !== -1) {
                                                candidates.push(name);
                                            }
                                        }
                                    }
                                }
                            }
                        } catch(eEnum) {
                            Log.w(TAG, '[-] enumerateMethods failed: ' + eEnum);
                        }

                        if (candidates.length > 0) {
                            Log.i(TAG, '[+] Error mapper candidates: ' + JSON.stringify(candidates));
                            for (var ci2 = 0; ci2 < candidates.length; ci2++) {
                                try {
                                    var candidateName = candidates[ci2];
                                    // Find the right classloader
                                    var factory = null;
                                    Java.enumerateClassLoaders({
                                        onMatch: function(loader) {
                                            try {
                                                loader.loadClass(candidateName);
                                                factory = Java.ClassFactory.get(loader);
                                            } catch(e) {}
                                        },
                                        onComplete: function() {}
                                    });

                                    if (!factory) continue;

                                    var MapperClass = factory.use(candidateName);
                                    var methods = MapperClass.a.overloads;
                                    for (var oi = 0; oi < methods.length; oi++) {
                                        var argTypes = methods[oi].argumentTypes;
                                        if (argTypes.length === 1) {
                                            var argClass = argTypes[0].className;
                                            if (argClass === 'java.io.IOException' || argClass === 'java.lang.Exception') {
                                                var retType = methods[oi].returnType.className;
                                                // Get the enum's generic-error field
                                                var EnumClass = factory.use(retType);
                                                var genericValue = null;
                                                // Try common field names for NET_104 (generic error)
                                                try { genericValue = EnumClass.f.value; } catch(e) {}
                                                if (!genericValue) {
                                                    try { genericValue = EnumClass.b.value; } catch(e) {}
                                                }

                                                if (genericValue) {
                                                    var SSLExc = Java.use('javax.net.ssl.SSLException').class;
                                                    (function(method, gv, cn) {
                                                        method.implementation = function(exc) {
                                                            if (SSLExc.isInstance(exc)) {
                                                                Log.i(TAG, '[!] SSL error reclassified via ' + cn + ': ' + exc.getMessage());
                                                                return gv;
                                                            }
                                                            return method.call(this, exc);
                                                        };
                                                        Log.i(TAG, '[+] ' + cn + '.a(IOException) hooked → generic error');
                                                    })(methods[oi], genericValue, candidateName);
                                                }
                                            }
                                        }
                                    }
                                } catch(eCand) {
                                    Log.w(TAG, '[-] Candidate ' + candidates[ci2] + ' failed: ' + eCand);
                                }
                            }
                        } else {
                            Log.d(TAG, '[-] No error mapper class found (JSON config patch handles this)');
                        }
                    } catch(eMapper) {
                        Log.w(TAG, '[-] Error mapper hook failed: ' + eMapper + ' (JSON patch handles this)');
                    }
                });
            }
            // Attempt after 8 seconds when more classes are loaded
            setTimeout(attemptErrorMapperHook, 8000);

            // Suppress SSLHandshakeException at Java level
            try {
                var SSLHandshakeException = Java.use('javax.net.ssl.SSLHandshakeException');
                SSLHandshakeException.$init.overload('java.lang.String').implementation = function(msg) {
                    Log.i(TAG, '[!] SSLHandshakeException SUPPRESSED: ' + msg);
                    this.$init(msg);
                };
            } catch(eSSL) {}

            // Hook Cronet's UrlRequest.Callback.onFailed to suppress SSL errors
            function hookCronetCallbacks() {
                var hookedCount = 0;
                try {
                    Java.enumerateLoadedClasses({
                        onMatch: function(className) {
                            if (className.indexOf('UrlRequest') !== -1 && className.indexOf('Callback') !== -1) {
                                try {
                                    var cls = Java.use(className);
                                    if (cls.onFailed) {
                                        cls.onFailed.implementation = function(request, info, error) {
                                            var errMsg = error ? error.toString() : 'null';
                                            if (errMsg.indexOf('SSL') !== -1 || errMsg.indexOf('ERR_CERT') !== -1 ||
                                                errMsg.indexOf('ERR_SSL') !== -1 || errMsg.indexOf('handshake') !== -1 ||
                                                errMsg.indexOf('CERT_') !== -1) {
                                                Log.i(TAG, '[!] Cronet onFailed SUPPRESSED: ' + errMsg);
                                                return; // Suppress SSL errors
                                            }
                                            this.onFailed(request, info, error);
                                        };
                                        hookedCount++;
                                        console.log('[+] Cronet callback hooked: ' + className);
                                    }
                                } catch(cbE) {}
                            }
                        },
                        onComplete: function() {}
                    });
                } catch(eCronet) {}
                return hookedCount;
            }
            hookCronetCallbacks();

            // Re-hook Cronet callbacks after 5s (catches late-loaded classes)
            setTimeout(function() {
                Java.perform(function() {
                    var cnt = hookCronetCallbacks();
                    if (cnt > 0) Log.i(TAG, '[+] Delayed Cronet callback hooks: ' + cnt);
                });
            }, 5000);

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
            // Hook JSONObject to intercept NET_201 error config lookups at runtime.
            // This catches any code path that reads the security error config,
            // even if the JSON file patching missed it.
            try {
                var JSONObject = Java.use('org.json.JSONObject');

                // Hook getString to intercept security error string lookups
                var _getString = JSONObject.getString;
                _getString.implementation = function(key) {
                    var result = _getString.call(this, key);
                    // Intercept security error title/message strings
                    if (result === 'common-v2__network_security_error_title') {
                        Log.i(TAG, '[!] NET_201: title key intercepted → generic');
                        return 'common-v2__network_error_title';
                    }
                    if (result === 'common-v2__network_security_error_message' ||
                        result === 'common-v2__network_security_error_message_jv') {
                        Log.i(TAG, '[!] NET_201: message key intercepted → generic');
                        return 'common-v2__network_unavailable_message';
                    }
                    return result;
                };

                // Also hook optString (non-throwing variant)
                var optOverloads = JSONObject.optString.overloads;
                for (var oi = 0; oi < optOverloads.length; oi++) {
                    (function(overload) {
                        var origImpl = overload;
                        overload.implementation = function() {
                            var result = origImpl.apply(this, arguments);
                            if (result === 'common-v2__network_security_error_title') {
                                return 'common-v2__network_error_title';
                            }
                            if (result === 'common-v2__network_security_error_message' ||
                                result === 'common-v2__network_security_error_message_jv') {
                                return 'common-v2__network_unavailable_message';
                            }
                            return result;
                        };
                    })(optOverloads[oi]);
                }
                Log.i(TAG, '[+] NET_201 JSONObject runtime suppression active');
            } catch(eNet201) {
                Log.w(TAG, '[-] NET_201 JSONObject hook: ' + eNet201);
            }

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

        // Helper: find a function address by name - tries exports first, then symbols table
        function findSSLFunction(mod, fnName) {
            var addr = mod.findExportByName(fnName);
            if (addr) return addr;
            // For statically-linked BoringSSL (e.g. libwebviewchromium.so),
            // symbols are NOT exported. Use enumerateSymbols() to find them.
            try {
                var syms = mod.enumerateSymbols();
                for (var si = 0; si < syms.length; si++) {
                    if (syms[si].name === fnName) {
                        return syms[si].address;
                    }
                }
            } catch(e) {}
            return null;
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
        var _nativeSslLibs = ['libssl.so', 'libsscronet.so', 'libcronet.so', 'libcronet.102.0.5005.125.so', 'libwebviewchromium.so'];
        for (var nsi = 0; nsi < _nativeSslLibs.length; nsi++) {
            _nativeSslHooked += patchNativeSSLVerify(_nativeSslLibs[nsi]);
        }

        // Also scan ALL loaded modules for SSL exports (catches statically-linked BoringSSL in any lib)
        try {
            var allMods = Process.enumerateModules();
            for (var ami = 0; ami < allMods.length; ami++) {
                var amName = allMods[ami].name;
                // Skip already-tried libs and system/framework libs
                if (_nativeSslLibs.indexOf(amName) !== -1) continue;
                if (amName.indexOf('frida') !== -1 || amName.indexOf('gadget') !== -1) continue;
                if (amName.indexOf('libc.so') !== -1 || amName.indexOf('libm.so') !== -1) continue;
                // Try to find SSL exports - if any exist, hook them
                try {
                    var testMod = Process.getModuleByName(amName);
                    var hasSSL = findSSLFunction(testMod, 'SSL_CTX_set_custom_verify') ||
                                 findSSLFunction(testMod, 'SSL_set_custom_verify') ||
                                 findSSLFunction(testMod, 'SSL_CTX_set_verify') ||
                                 findSSLFunction(testMod, 'SSL_set_verify') ||
                                 findSSLFunction(testMod, 'SSL_new');
                    if (hasSSL) {
                        var ap = patchNativeSSLVerify(amName);
                        if (ap > 0) {
                            _nativeSslHooked += ap;
                            console.log('[+] Found SSL in unexpected lib: ' + amName + ' (' + ap + ' hooks)');
                        }
                    }
                } catch(scanE) {}
            }
        } catch(enumE) {
            console.log('[-] Module enumeration failed: ' + enumE);
        }

        // Watch for ALL late-loaded libs - scan each one for SSL exports
        try {
            var _patchedModules = {};
            Process.attachModuleObserver({
                onAdded: function(mod) {
                    var name = mod.name;
                    if (_patchedModules[name]) return; // Already patched
                    if (name.indexOf('frida') !== -1 || name.indexOf('gadget') !== -1) return;
                    // Check if this module has SSL exports or symbols
                    try {
                        var hasSslExport = findSSLFunction(mod, 'SSL_CTX_set_custom_verify') ||
                                          findSSLFunction(mod, 'SSL_set_custom_verify') ||
                                          findSSLFunction(mod, 'SSL_CTX_set_verify') ||
                                          findSSLFunction(mod, 'SSL_set_verify') ||
                                          findSSLFunction(mod, 'SSL_new') ||
                                          findSSLFunction(mod, 'SSL_do_handshake');
                        if (hasSslExport) {
                            _patchedModules[name] = true;
                            var p = patchNativeSSLVerify(name);
                            if (p > 0) {
                                _nativeSslHooked += p;
                                console.log('[+] Late-loaded SSL lib patched: ' + name + ' (' + p + ' hooks)');
                            }
                        }
                    } catch(lateE) {}
                }
            });
        } catch (e) {
            // Fallback: retry after 3s for older Frida without attachModuleObserver
            setTimeout(function() {
                for (var nsi2 = 0; nsi2 < _nativeSslLibs.length; nsi2++) {
                    _nativeSslHooked += patchNativeSSLVerify(_nativeSslLibs[nsi2]);
                }
                // Also try a broad scan again
                try {
                    var lateMods = Process.enumerateModules();
                    for (var lmi = 0; lmi < lateMods.length; lmi++) {
                        var lmName = lateMods[lmi].name;
                        if (_nativeSslLibs.indexOf(lmName) !== -1) continue;
                        try {
                            var lm = Process.getModuleByName(lmName);
                            if (findSSLFunction(lm, 'SSL_CTX_set_verify') || findSSLFunction(lm, 'SSL_new')) {
                                var lp = patchNativeSSLVerify(lmName);
                                if (lp > 0) {
                                    _nativeSslHooked += lp;
                                    console.log('[+] Delayed scan found SSL in: ' + lmName);
                                }
                            }
                        } catch(dscanE) {}
                    }
                } catch(deE) {}
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

        // Root detection - hide known root paths
        try {
            var File = Java.use('java.io.File');
            var origExists = File.exists;
            File.exists.implementation = function() {
                var path = this.getAbsolutePath();
                var rootPaths = ['/system/app/Superuser.apk', '/system/xbin/su', '/system/bin/su',
                    '/sbin/su', '/data/local/xbin/su', '/data/local/bin/su',
                    '/su/bin/su', '/data/adb/magisk'];
                for (var i = 0; i < rootPaths.length; i++) {
                    if (path === rootPaths[i]) {
                        console.log('[+] ROOT: Hiding path: ' + path);
                        return false;
                    }
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
        var blockPatterns = [];
        var rewriteRules = [];
        var apiDumpEnabled = false;
        var trafficMonitorEnabled = true; // Toggled via in-app notification, persisted via flag file
        var toggleReceiverRegistered = false;
        var NOTIF_ID = 19730;
        var NOTIF_CHANNEL = 'hspatch_block';
        var apiDumpMaxBytes = 10 * 1024 * 1024;

        function getInternalFilePath(fileName) {
            try {
                var HSConfig = Java.use('in.startv.hotstar.HSPatchConfig');
                return HSConfig.getFilePath(fileName);
            } catch (e) { }
            try {
                var ctx2 = Java.use('android.app.ActivityThread').currentApplication();
                if (ctx2 !== null) return ctx2.getFilesDir().getAbsolutePath() + '/' + fileName;
            } catch (e2) { }
            return null;
        }

        function apiDumpWrite(line) {
            if (!apiDumpEnabled) return;
            try {
                var path = getInternalFilePath('api_dump.txt');
                if (path === null) return;
                var File2 = Java.use('java.io.File');
                var f2 = File2.$new(path);
                if (f2.exists() && f2.length() > apiDumpMaxBytes) return;
                var ts2 = Java.use('java.text.SimpleDateFormat').$new('HH:mm:ss.SSS')
                    .format(Java.use('java.util.Date').$new());
                var fw2 = Java.use('java.io.FileWriter').$new(path, true);
                fw2.write(ts2 + ' ' + line + '\n');
                fw2.flush();
                fw2.close();
            } catch (e3) { }
        }

        function apiDumpEvent(source, method, urlOrMsg) {
            try { apiDumpWrite('[' + source + '] ' + method + ' ' + urlOrMsg); } catch (e4) { }
        }

        function loadBlockingRules() {
            try {
                var ctx = Java.use('android.app.ActivityThread').currentApplication();
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
                    var File0 = Java.use('java.io.File');
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

                var File = Java.use('java.io.File');
                var BufferedReader = Java.use('java.io.BufferedReader');
                var FileReader = Java.use('java.io.FileReader');
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

        function scheduleRuleReload() {
            setTimeout(function() {
                Java.perform(function() {
                    var ob = blockPatterns.length, or2 = rewriteRules.length, od = apiDumpEnabled;
                    blockPatterns = []; rewriteRules = [];
                    loadBlockingRules();
                    if (blockPatterns.length !== ob || rewriteRules.length !== or2 || apiDumpEnabled !== od) {
                        Log.i(netLogTag, '[RULES] Reloaded: ' + blockPatterns.length + ' block, ' + rewriteRules.length + ' rewrite, dump=' + (apiDumpEnabled?'ON':'OFF'));
                    }
                });
                scheduleRuleReload();
            }, 5000);
        }
        loadBlockingRules();
        scheduleRuleReload();

        // Restore toggle state from SharedPreferences (primary), flag file (fallback)
        try {
            var ctx0 = Java.use('android.app.ActivityThread').currentApplication();
            if (ctx0 !== null) {
                var prefs = ctx0.getSharedPreferences(
                    Java.use('java.lang.String').$new('hspatch_config'), 0);
                if (prefs.contains(Java.use('java.lang.String').$new('blocking_enabled'))) {
                    trafficMonitorEnabled = prefs.getBoolean(
                        Java.use('java.lang.String').$new('blocking_enabled'), true);
                    Log.i(netLogTag, '[TOGGLE] State restored from preferences: ' + (trafficMonitorEnabled ? 'ON' : 'OFF'));
                } else {
                    Log.i(netLogTag, '[TOGGLE] No saved preference, using default (ON)');
                }
            }
        } catch(ep) {
            Log.w(netLogTag, '[TOGGLE] Could not read preferences: ' + ep);
        }

        // =================== IN-APP BLOCKING TOGGLE (Notification) ===================
        function saveBlockingState(enabled) {
            try {
                var ctx = Java.use('android.app.ActivityThread').currentApplication();
                if (ctx === null) return;
                var prefs = ctx.getSharedPreferences(
                    Java.use('java.lang.String').$new('hspatch_config'), 0);
                prefs.edit()
                    .putBoolean(Java.use('java.lang.String').$new('blocking_enabled'), enabled)
                    .apply();
                Log.i(netLogTag, '[TOGGLE] State saved to preferences: ' + (enabled ? 'ON' : 'OFF'));
            } catch(e) {
                Log.e(netLogTag, '[TOGGLE] Save error: ' + e);
            }
        }

        function updateBlockingNotification() {
            try {
                var ctx = Java.use('android.app.ActivityThread').currentApplication();
                if (ctx === null) return;
                var context = Java.cast(ctx, Java.use('android.content.Context'));

                var Intent = Java.use('android.content.Intent');
                var PendingIntent = Java.use('android.app.PendingIntent');
                var toggleIntent = Intent.$new(Java.use('java.lang.String').$new('hspatch.TOGGLE_BLOCK'));
                // FLAG_UPDATE_CURRENT | FLAG_IMMUTABLE
                var piFlags = 0x08000000 | 0x04000000;
                var togglePi = PendingIntent.getBroadcast(context, 0, toggleIntent, piFlags);

                var Builder = Java.use('android.app.Notification$Builder');
                var builder = Builder.$new(context, Java.use('java.lang.String').$new(NOTIF_CHANNEL));

                var title = trafficMonitorEnabled
                    ? '\uD83D\uDEE1 Blocking: ON'
                    : '\uD83D\uDEE1 Blocking: OFF';
                var text = trafficMonitorEnabled
                    ? 'Ad/tracker blocking active \u2022 Tap to disable'
                    : 'Blocking disabled \u2022 Tap to enable';

                var iconId = 17301624; // android.R.drawable.ic_lock_idle_lock
                try { iconId = ctx.getApplicationInfo().icon.value; } catch(e) {}

                builder.setSmallIcon(iconId);
                builder.setContentTitle(Java.use('java.lang.String').$new(title));
                builder.setContentText(Java.use('java.lang.String').$new(text));
                builder.setOngoing(true);
                builder.setContentIntent(togglePi);
                // Add explicit action button
                var actionLabel = trafficMonitorEnabled ? '\u274C Turn OFF' : '\u2705 Turn ON';
                builder.addAction(iconId,
                    Java.cast(Java.use('java.lang.String').$new(actionLabel), Java.use('java.lang.CharSequence')),
                    togglePi);

                var nm = Java.cast(context.getSystemService(Java.use('java.lang.String').$new('notification')),
                                   Java.use('android.app.NotificationManager'));
                nm.notify(NOTIF_ID, builder.build());
            } catch(e) {
                Log.e(netLogTag, '[TOGGLE] Notification error: ' + e);
            }
        }

        function setupBlockingToggleUI() {
            try {
                var ctx = Java.use('android.app.ActivityThread').currentApplication();
                if (ctx === null) {
                    Log.w(netLogTag, '[TOGGLE] No context yet, retrying in 3s...');
                    setTimeout(function() { Java.perform(function() { setupBlockingToggleUI(); }); }, 3000);
                    return;
                }
                var context = Java.cast(ctx, Java.use('android.content.Context'));

                // Create notification channel (Android O+)
                var NotificationChannel = Java.use('android.app.NotificationChannel');
                var nm = Java.cast(context.getSystemService(Java.use('java.lang.String').$new('notification')),
                                   Java.use('android.app.NotificationManager'));
                var ch = NotificationChannel.$new(
                    Java.use('java.lang.String').$new(NOTIF_CHANNEL),
                    Java.cast(Java.use('java.lang.String').$new('HSPatch Blocking Control'), Java.use('java.lang.CharSequence')),
                    2); // IMPORTANCE_LOW — no sound
                ch.setDescription(Java.use('java.lang.String').$new('Toggle ad/tracker blocking on or off'));
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
                                        Log.i(netLogTag, '[TOGGLE] Blocking ' + (trafficMonitorEnabled ? 'ENABLED' : 'DISABLED') + ' via notification');
                                        saveBlockingState(trafficMonitorEnabled);
                                        updateBlockingNotification();
                                        // Show toast
                                        try {
                                            var ctx2 = Java.use('android.app.ActivityThread').currentApplication();
                                            var Toast = Java.use('android.widget.Toast');
                                            var msg = trafficMonitorEnabled ? 'Blocking ON' : 'Blocking OFF';
                                            Toast.makeText(ctx2, Java.cast(Java.use('java.lang.String').$new(msg), Java.use('java.lang.CharSequence')), 0).show();
                                        } catch(et) {}
                                    } catch(e) {
                                        Log.e(netLogTag, '[TOGGLE] onReceive error: ' + e);
                                    }
                                }
                            }]
                        }
                    });

                    var filter = Java.use('android.content.IntentFilter').$new(
                        Java.use('java.lang.String').$new('hspatch.TOGGLE_BLOCK'));
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

                // Show initial notification
                updateBlockingNotification();
                Log.i(netLogTag, '[TOGGLE] In-app blocking toggle ready (notification)');
            } catch(e) {
                Log.e(netLogTag, '[TOGGLE] Setup error: ' + e);
            }
        }

        // Separate domain-only rules from path rules for smarter matching
        // Domain rules: no '/' → apply to DNS + URL hooks
        // Path rules: contain '/' → apply to URL hooks only (not DNS)
        function isDomainRule(pattern) {
            return pattern.indexOf('/') === -1;
        }

        function shouldBlock(url) {
            if (!trafficMonitorEnabled) return null;
            for (var i = 0; i < blockPatterns.length; i++) {
                if (url.indexOf(blockPatterns[i]) !== -1) return blockPatterns[i];
            }
            return null;
        }

        // DNS-safe version: only checks domain-level rules (no path patterns)
        function shouldBlockDNS(hostname) {
            if (!trafficMonitorEnabled) return null;
            for (var i = 0; i < blockPatterns.length; i++) {
                if (isDomainRule(blockPatterns[i]) && hostname.indexOf(blockPatterns[i]) !== -1) {
                    return blockPatterns[i];
                }
            }
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
                var ctx = Java.use('android.app.ActivityThread').currentApplication();
                if (ctx === null) return;
                Java.use('in.startv.hotstar.NetworkLogger').init(ctx);
            } catch (e) { }
        }
        function safeNetworkLoggerLog(line) {
            try { ensureNetworkLoggerInitialized(); Java.use('in.startv.hotstar.NetworkLogger').log(line); } catch (e) { }
        }
        function logRewritten(source, method, before, after) {
            Log.i(netLogTag, '[REWRITE] [' + source + '] ' + method + ' ' + before + ' -> ' + after);
            safeNetworkLoggerLog('[REWRITE] [' + source + '] ' + method + ' ' + before + ' -> ' + after);
            apiDumpEvent(source, method, before + ' -> ' + after);
        }
        function logBlocked(source, method, url, pattern) {
            Log.i(netLogTag, '[BLOCKED] [' + source + '] ' + method + ' ' + url + ' (matched: ' + pattern + ')');
            safeNetworkLoggerLog('[BLOCKED] [' + source + '] ' + method + ' ' + url + ' (matched: ' + pattern + ')');
            try {
                var bp = getInternalFilePath('blocked_urls.txt');
                if (bp) { var fw = Java.use('java.io.FileWriter').$new(bp, true); fw.write(url + '\n'); fw.flush(); fw.close(); }
            } catch(e2) {}
            apiDumpEvent(source, method, 'BLOCK ' + url + ' (matched: ' + pattern + ')');
        }

        // =========================================================
        //  LAYER 1: NATIVE libc HOOKS  — GROUND TRUTH
        //  Every TCP/UDP/DNS call on Android goes through these.
        //  No Java library, native SDK, or JNI code can bypass them.
        // =========================================================

        // fd → destination map for correlating send/recv with connections
        var _fdMap = {};
        // Throttle: don't spam logcat for every send/recv on the same fd
        var _fdLoggedSend = {};
        var _fdLoggedRecv = {};

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
        try {
            var _connectPtr = Process.getModuleByName('libc.so').getExportByName('connect');
            Interceptor.attach(_connectPtr, {
                onEnter: function(args) {
                    this.fd = args[0].toInt32();
                    this.sa = parseSockaddr(args[1], args[2].toInt32());
                },
                onLeave: function(retval) {
                    if (this.sa === null) return;
                    var dest = this.sa.ip + ':' + this.sa.port;
                    _fdMap[this.fd] = dest;
                    _fdLoggedSend[this.fd] = 0;
                    _fdLoggedRecv[this.fd] = 0;

                    // Skip loopback noise
                    if (this.sa.ip === '127.0.0.1' || this.sa.ip === '0:0:0:0:0:0:0:1') return;

                    var ret = retval.toInt32();
                    var status = (ret === 0 || ret === -1) ? '' : ' err=' + ret;
                    // -1 with EINPROGRESS is normal for non-blocking sockets

                    console.log('[NET] CONNECT fd=' + this.fd + ' -> ' + dest + status);
                    nativeLog('[NET] CONNECT fd=' + this.fd + ' -> ' + dest + status);
                    apiDumpEvent('NATIVE', 'CONNECT', 'fd=' + this.fd + ' ' + this.sa.family + ' ' + dest + status);
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

        // === send(fd, buf, len, flags) — outbound data on sockets ===
        try {
            var _sendPtr = Process.getModuleByName('libc.so').getExportByName('send');
            Interceptor.attach(_sendPtr, {
                onEnter: function(args) {
                    this.fd = args[0].toInt32();
                    this.buf = args[1];
                    this.len = args[2].toInt32();
                },
                onLeave: function(retval) {
                    var sent = retval.toInt32();
                    if (sent <= 0) return;
                    var dest = _fdMap[this.fd];
                    if (!dest) return; // Not a tracked socket (local/IPC)

                    // Log first occurrence per fd, then only every 50th to reduce spam
                    if (!_fdLoggedSend[this.fd]) _fdLoggedSend[this.fd] = 0;
                    _fdLoggedSend[this.fd]++;
                    if (_fdLoggedSend[this.fd] === 1 || _fdLoggedSend[this.fd] % 50 === 0) {
                        var peek = peekBuf(this.buf, this.len, 128);
                        console.log('[NET] >> SEND fd=' + this.fd + ' ' + dest + ' ' + sent + 'B' + (peek.length > 0 ? ' [' + peek.substring(0, 80) + ']' : ''));
                    }
                    apiDumpEvent('NATIVE', 'SEND', dest + ' ' + sent + 'B fd=' + this.fd);
                    if (apiDumpEnabled && this.len > 0) {
                        var p = peekBuf(this.buf, this.len, 512);
                        if (p.length > 0) apiDumpWrite('  >> ' + p);
                    }
                }
            });
            console.log('[+] Native send() hooked');
        } catch (e) { console.log('[-] send hook: ' + e); }

        // === sendto(fd, buf, len, flags, dest_addr, addrlen) — UDP + unconnected sends ===
        try {
            var _sendtoPtr = Process.getModuleByName('libc.so').getExportByName('sendto');
            Interceptor.attach(_sendtoPtr, {
                onEnter: function(args) {
                    this.fd = args[0].toInt32();
                    this.buf = args[1];
                    this.len = args[2].toInt32();
                    // arg[4] = dest sockaddr (for UDP)
                    if (!args[4].isNull()) {
                        this.dest = parseSockaddr(args[4], args[5].toInt32());
                    } else {
                        this.dest = null;
                    }
                },
                onLeave: function(retval) {
                    var sent = retval.toInt32();
                    if (sent <= 0) return;
                    var dest = this.dest ? (this.dest.ip + ':' + this.dest.port) : (_fdMap[this.fd] || null);
                    if (!dest) return;
                    if (dest.indexOf('127.0.0.1') === 0) return;

                    console.log('[NET] >> SENDTO fd=' + this.fd + ' ' + dest + ' ' + sent + 'B');
                    apiDumpEvent('NATIVE', 'SENDTO', dest + ' ' + sent + 'B fd=' + this.fd);
                    if (apiDumpEnabled && this.len > 0) {
                        var p = peekBuf(this.buf, this.len, 512);
                        if (p.length > 0) apiDumpWrite('  >> ' + p);
                    }
                }
            });
            console.log('[+] Native sendto() hooked');
        } catch (e) { console.log('[-] sendto hook: ' + e); }

        // === recvfrom(fd, buf, len, flags, src_addr, addrlen) — incoming data ===
        try {
            var _recvfromPtr = Process.getModuleByName('libc.so').getExportByName('recvfrom');
            Interceptor.attach(_recvfromPtr, {
                onEnter: function(args) {
                    this.fd = args[0].toInt32();
                    this.buf = args[1];
                    this.len = args[2].toInt32();
                },
                onLeave: function(retval) {
                    var recvd = retval.toInt32();
                    if (recvd <= 0) return;
                    var src = _fdMap[this.fd];
                    if (!src) return;

                    if (!_fdLoggedRecv[this.fd]) _fdLoggedRecv[this.fd] = 0;
                    _fdLoggedRecv[this.fd]++;
                    if (_fdLoggedRecv[this.fd] === 1 || _fdLoggedRecv[this.fd] % 50 === 0) {
                        console.log('[NET] << RECV fd=' + this.fd + ' ' + src + ' ' + recvd + 'B');
                    }
                    apiDumpEvent('NATIVE', 'RECV', src + ' ' + recvd + 'B fd=' + this.fd);
                    if (apiDumpEnabled && recvd > 0) {
                        var p = peekBuf(this.buf, recvd, 512);
                        if (p.length > 0) apiDumpWrite('  << ' + p);
                    }
                }
            });
            console.log('[+] Native recvfrom() hooked');
        } catch (e) { console.log('[-] recvfrom hook: ' + e); }

        // === write(fd, buf, count) — catches HTTP libs that use write() on sockets ===
        try {
            var _writePtr = Process.getModuleByName('libc.so').getExportByName('write');
            Interceptor.attach(_writePtr, {
                onEnter: function(args) {
                    this.fd = args[0].toInt32();
                    this.buf = args[1];
                    this.count = args[2].toInt32();
                },
                onLeave: function(retval) {
                    var written = retval.toInt32();
                    if (written <= 0) return;
                    // Only log if this fd is a known network socket (from connect)
                    var dest = _fdMap[this.fd];
                    if (!dest) return;

                    apiDumpEvent('NATIVE', 'WRITE', dest + ' ' + written + 'B fd=' + this.fd);
                    if (apiDumpEnabled && this.count > 0) {
                        var p = peekBuf(this.buf, this.count, 512);
                        if (p.length > 0) apiDumpWrite('  w> ' + p);
                    }
                }
            });
            console.log('[+] Native write() hooked (socket-filtered)');
        } catch (e) { console.log('[-] write hook: ' + e); }

        // === read(fd, buf, count) — catches responses on sockets ===
        try {
            var _readPtr = Process.getModuleByName('libc.so').getExportByName('read');
            Interceptor.attach(_readPtr, {
                onEnter: function(args) {
                    this.fd = args[0].toInt32();
                    this.buf = args[1];
                },
                onLeave: function(retval) {
                    var rd = retval.toInt32();
                    if (rd <= 0) return;
                    var src = _fdMap[this.fd];
                    if (!src) return;

                    apiDumpEvent('NATIVE', 'READ', src + ' ' + rd + 'B fd=' + this.fd);
                    if (apiDumpEnabled && rd > 0) {
                        var p = peekBuf(this.buf, rd, 512);
                        if (p.length > 0) apiDumpWrite('  r< ' + p);
                    }
                }
            });
            console.log('[+] Native read() hooked (socket-filtered)');
        } catch (e) { console.log('[-] read hook: ' + e); }

        // === close(fd) — cleanup fd tracking ===
        try {
            var _closePtr = Process.getModuleByName('libc.so').getExportByName('close');
            Interceptor.attach(_closePtr, {
                onEnter: function(args) {
                    var fd = args[0].toInt32();
                    if (_fdMap[fd]) {
                        delete _fdMap[fd];
                        delete _fdLoggedSend[fd];
                        delete _fdLoggedRecv[fd];
                    }
                }
            });
        } catch (e) { }

        console.log('[*] Native libc network hooks installed (Layer 1)');


        // =========================================================
        //  LAYER 2: NATIVE TLS HOOKS — SEE DECRYPTED HTTPS DATA
        //  Hooks SSL_write/SSL_read from BoringSSL (libssl.so)
        //  This lets us see actual HTTP request/response HEADERS
        //  through TLS. Works for ANY HTTP library.
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

            // SSL_read(SSL*, buf, num) → see incoming HTTPS plaintext
            try {
                var sslReadPtr = sslMod.getExportByName('SSL_read');
                if (sslReadPtr) {
                    Interceptor.attach(sslReadPtr, {
                        onEnter: function(args) {
                            this.ssl = args[0];
                            this.buf = args[1];
                            this.num = args[2].toInt32();
                        },
                        onLeave: function(retval) {
                            var rd = retval.toInt32();
                            if (rd <= 0) return;
                            var peek = peekBuf(this.buf, rd, 384);
                            if (peek.length === 0) return;

                            // HTTP response detection
                            var isResponse = /^HTTP\/[12]/.test(peek);
                            if (isResponse) {
                                var firstLine = peek.split('\\r\\n')[0] || peek.split('\\n')[0] || peek.substring(0, 120);
                                console.log('[NET] << TLS-IN: ' + firstLine);
                                apiDumpEvent('TLS', 'RESPONSE', firstLine);
                            }
                            if (apiDumpEnabled) {
                                apiDumpWrite('  TLS<< ' + peek.substring(0, 512));
                            }
                        }
                    });
                    console.log('[+] SSL_read hooked from ' + libName);
                }
            } catch (e) { }

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
                    if (s.length > 0) {
                        var bm = shouldBlock(s);
                        if (bm !== null) { logBlocked('URL', '$init(String)', s, bm); return _urlInit1.call(this, 'http://127.0.0.1:1/blocked'); }
                        var rw = applyRewrites(s);
                        if (rw.changed) { logRewritten('URL', '$init(String)', s, rw.url); return _urlInit1.call(this, rw.url); }
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
                    var bm = shouldBlock(full);
                    if (bm !== null) { logBlocked('URL', '$init(URL,String)', full, bm); _urlInit1.call(this, 'http://127.0.0.1:1/blocked'); return; }
                    var rw = applyRewrites(full);
                    if (rw.changed) { logRewritten('URL', '$init(URL,String)', full, rw.url); _urlInit1.call(this, rw.url); return; }
                };
                Log.d(netLogTag, '[+] URL.$init(URL,String) hooked');
            } catch (e) { Log.d(netLogTag, '[-] URL.$init(URL,String): ' + e); }

            // URL(String protocol, String host, String file) — component constructor
            try {
                var _urlInit3 = URL.$init.overload('java.lang.String', 'java.lang.String', 'java.lang.String');
                _urlInit3.implementation = function(protocol, host, file) {
                    _urlInit3.call(this, protocol, host, file);
                    var full = this.toString();
                    var bm = shouldBlock(full);
                    if (bm !== null) { logBlocked('URL', '$init(proto,host,file)', full, bm); _urlInit1.call(this, 'http://127.0.0.1:1/blocked'); return; }
                    var rw = applyRewrites(full);
                    if (rw.changed) { logRewritten('URL', '$init(proto,host,file)', full, rw.url); _urlInit1.call(this, rw.url); return; }
                };
                Log.d(netLogTag, '[+] URL.$init(proto,host,file) hooked');
            } catch (e) { Log.d(netLogTag, '[-] URL.$init(proto,host,file): ' + e); }

            // URL(String protocol, String host, int port, String file) — full constructor
            try {
                var _urlInit4 = URL.$init.overload('java.lang.String', 'java.lang.String', 'int', 'java.lang.String');
                _urlInit4.implementation = function(protocol, host, port, file) {
                    _urlInit4.call(this, protocol, host, port, file);
                    var full = this.toString();
                    var bm = shouldBlock(full);
                    if (bm !== null) { logBlocked('URL', '$init(proto,host,port,file)', full, bm); _urlInit1.call(this, 'http://127.0.0.1:1/blocked'); return; }
                    var rw = applyRewrites(full);
                    if (rw.changed) { logRewritten('URL', '$init(proto,host,port,file)', full, rw.url); _urlInit1.call(this, rw.url); return; }
                };
                Log.d(netLogTag, '[+] URL.$init(proto,host,port,file) hooked');
            } catch (e) { Log.d(netLogTag, '[-] URL.$init(proto,host,port,file): ' + e); }

            // openConnection — secondary enforcement (catches any URL that
            // bypassed $init hooks, e.g. created via native code)
            var _urlOpen0 = URL.openConnection.overload();
            _urlOpen0.implementation = function() {
                var u = this.toString();
                var bm = shouldBlock(u);
                if (bm !== null) { logBlocked('URL', 'OPEN', u, bm); return _urlOpen0.call(Java.use('java.net.URL').$new('http://127.0.0.1:1/blocked')); }
                var rw = applyRewrites(u);
                if (rw.changed) { logRewritten('URL', 'OPEN', u, rw.url); return _urlOpen0.call(Java.use('java.net.URL').$new(rw.url)); }
                return _urlOpen0.call(this);
            };
            try {
                var _urlOpenProxy = URL.openConnection.overload('java.net.Proxy');
                _urlOpenProxy.implementation = function(proxy) {
                    var u = this.toString();
                    var bm = shouldBlock(u);
                    if (bm !== null) { logBlocked('URL', 'OPEN_PROXY', u, bm); return _urlOpenProxy.call(Java.use('java.net.URL').$new('http://127.0.0.1:1/blocked'), proxy); }
                    var rw = applyRewrites(u);
                    if (rw.changed) { logRewritten('URL', 'OPEN_PROXY', u, rw.url); return _urlOpenProxy.call(Java.use('java.net.URL').$new(rw.url), proxy); }
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
                    var blockedReq = request.newBuilder().url(Java.use('okhttp3.HttpUrl').parse('http://127.0.0.1:1/blocked')).build();
                    return _okNewCall.call(this, blockedReq);
                }
                var rw = applyRewrites(url);
                if (rw.changed) {
                    logRewritten('OkHttp3', method, url, rw.url);
                    var newHttpUrl = Java.use('okhttp3.HttpUrl').parse(rw.url);
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
                if (bm !== null) { logBlocked('HttpConn', 'CONN', u, bm); throw Java.use('java.io.IOException').$new('HSPatch: blocked: ' + bm); }
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
                    var bm = shouldBlockDNS(h);
                    if (bm !== null) {
                        logBlocked('InetAddress', 'getByName', h, bm);
                        throw Java.use('java.net.UnknownHostException').$new(h);
                    }
                    var rw = applyRewrites(h);
                    if (rw.changed) { logRewritten('InetAddress','getByName',h,rw.url); return _inetGetByName.call(this, rw.url); }
                }
                return _inetGetByName.call(this, host);
            };
            try {
                var _inetGetAll = InetAddress.getAllByName.overload('java.lang.String');
                _inetGetAll.implementation = function(host) {
                    if (host) {
                        var h = host.toString();
                        var bm = shouldBlockDNS(h);
                        if (bm !== null) {
                            logBlocked('InetAddress', 'getAllByName', h, bm);
                            throw Java.use('java.net.UnknownHostException').$new(h);
                        }
                        var rw = applyRewrites(h);
                        if (rw.changed) { logRewritten('InetAddress','getAllByName',h,rw.url); return _inetGetAll.call(this, rw.url); }
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
            var Interceptor = Java.use('okhttp3.Interceptor');
            var Chain = Java.use('okhttp3.Interceptor$Chain');
            var Response = Java.use('okhttp3.Response');
            var ResponseBody = Java.use('okhttp3.ResponseBody');
            var Protocol = Java.use('okhttp3.Protocol');
            var MediaType = Java.use('okhttp3.MediaType');

            var BlockInterceptor = Java.registerClass({
                name: 'hspatch.BlockingInterceptor',
                implements: [Interceptor],
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
                                var ResponseBuilder = Java.use('okhttp3.Response$Builder');
                                return ResponseBuilder.$new()
                                    .request(request)
                                    .protocol(Protocol.HTTP_1_1.value)
                                    .code(204)
                                    .message(Java.use('java.lang.String').$new('Blocked by HSPatch'))
                                    .body(ResponseBody.create(
                                        MediaType.parse('text/plain'),
                                        Java.use('java.lang.String').$new('')
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
                        throw Java.use('java.io.IOException').$new('HSPatch: blocked by rule: ' + bm);
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
        Log.i(advBlockTag, '[#] HSPatch v3.40: Advanced Hooking-Based Blocker      [#]');
        Log.i(advBlockTag, '[*] Layer 4 hooks (in addition to Layer 3 legacy):');
        Log.i(advBlockTag, '[*]   OkHttp interceptor injection (build-time)');
        Log.i(advBlockTag, '[*]   ExoPlayer DataSpec + MediaPlayer URL blocking');
        Log.i(advBlockTag, '[*]   Volley RequestQueue.add blocking');
        Log.i(advBlockTag, '[*]   Glide GlideUrl blocking');
        Log.i(advBlockTag, '[*]   TLS SNI-based hostname blocking (native)');
        Log.i(advBlockTag, '======================================================');

        // Count domain vs path rules for summary
        var domainRuleCount = 0, pathRuleCount = 0;
        for (var ri = 0; ri < blockPatterns.length; ri++) {
            if (isDomainRule(blockPatterns[ri])) domainRuleCount++;
            else pathRuleCount++;
        }
        Log.i(netLogTag, '======================================================');
        Log.i(netLogTag, '[#] HSPatch v3.40: URL preparation-time blocker       [#]');
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
    });
