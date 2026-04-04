package com.rk.hspatcher

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.enableEdgeToEdge
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.Build
import androidx.compose.material.icons.outlined.Edit
import androidx.compose.material.icons.outlined.PlayArrow
import androidx.compose.material.icons.outlined.Search
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.produceState
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.unit.dp
import com.google.zxing.BarcodeFormat
import com.journeyapps.barcodescanner.BarcodeEncoder
import com.journeyapps.barcodescanner.ScanContract
import com.journeyapps.barcodescanner.ScanOptions
import com.rk.exec.TerminalCommand
import com.rk.exec.launchTerminal
import com.rk.theme.XedTheme
import com.rk.utils.copyToClipboard
import com.rk.utils.toast
import fi.iki.elonen.NanoHTTPD
import java.io.File
import java.net.NetworkInterface
import java.net.URLDecoder
import java.net.URLEncoder

class LocalNetworkToolsActivity : ComponentActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        enableEdgeToEdge()
        super.onCreate(savedInstanceState)

        setContent {
            XedTheme {
                LocalNetworkToolsScreen(
                    onLaunchFtpServer = {
                        launchTerminal(this, createFtpServerCommand())
                    },
                    onOpenScannedUri = { value -> openScannedValue(value) },
                )
            }
        }
    }

    private fun openScannedValue(value: String) {
        copyToClipboard("local_network_scan", value, showToast = false)
        val normalized = when {
            value.startsWith("http://") || value.startsWith("https://") || value.startsWith("ftp://") -> value
            value.matches(Regex("^\\d+\\.\\d+\\.\\d+\\.\\d+(:\\d+)?(/.*)?$")) -> "http://$value"
            else -> {
                toast("Scanned value copied to clipboard")
                return
            }
        }
        startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(normalized)))
    }
}

@Composable
private fun LocalNetworkToolsScreen(
    onLaunchFtpServer: () -> Unit,
    onOpenScannedUri: (String) -> Unit,
) {
    val context = androidx.compose.ui.platform.LocalContext.current
    val sharedRoot = remember { context.getExternalFilesDir(null)?.absolutePath.orEmpty() }
    val deviceIp by produceState(initialValue = detectLocalIpAddress()) { value = detectLocalIpAddress() }
    var serverInfo by remember {
        mutableStateOf(
            LocalHttpServerInfo(
                running = false,
                url = buildUrl(deviceIp, HTTP_PORT),
                rootPath = sharedRoot,
            ),
        )
    }
    var lastScan by remember { mutableStateOf<String?>(null) }

    DisposableEffect(Unit) {
        onDispose { LocalHttpShareServer.stop() }
    }

    val scannerLauncher = rememberLauncherForActivityResult(ScanContract()) { result ->
        val contents = result.contents ?: return@rememberLauncherForActivityResult
        lastScan = contents
        onOpenScannedUri(contents)
    }

    val wifiQrBitmap = remember(serverInfo.url) { buildQrBitmap(serverInfo.url) }
    val ftpUrl = remember(deviceIp) { buildUrl(deviceIp, FTP_PORT, scheme = "ftp") }
    val ftpQrBitmap = remember(ftpUrl) { buildQrBitmap(ftpUrl) }

    Scaffold { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .verticalScroll(rememberScrollState())
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp),
        ) {
            Text("Local Network Tools", style = MaterialTheme.typography.titleLarge)
            Text(
                "Share decoded projects on your LAN, launch an FTP server in the terminal, or scan QR codes to connect quickly.",
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )

            UtilityCard(
                icon = Icons.Outlined.Build,
                title = "Wi-Fi Server",
                description = "Start a lightweight HTTP server for the app files directory and show a QR code for quick browser access.",
            ) {
                Text("Shared folder", style = MaterialTheme.typography.labelLarge)
                Text(sharedRoot, fontFamily = FontFamily.Monospace, style = MaterialTheme.typography.bodySmall)
                Text("URL", style = MaterialTheme.typography.labelLarge)
                Text(serverInfo.url, fontFamily = FontFamily.Monospace, style = MaterialTheme.typography.bodyMedium)
                QrPreview(bitmap = wifiQrBitmap, emptyLabel = "QR unavailable until an IP address is detected")
                Row(horizontalArrangement = Arrangement.spacedBy(8.dp), modifier = Modifier.fillMaxWidth()) {
                    Button(
                        onClick = {
                            serverInfo = if (serverInfo.running) {
                                LocalHttpShareServer.stop()
                                serverInfo.copy(running = false)
                            } else {
                                val started = LocalHttpShareServer.start(sharedRoot)
                                LocalHttpServerInfo(
                                    running = started,
                                    url = buildUrl(deviceIp, HTTP_PORT),
                                    rootPath = sharedRoot,
                                )
                            }
                        },
                    ) {
                        Text(if (serverInfo.running) "Stop Server" else "Start Server")
                    }
                    OutlinedButton(onClick = { copyToClipboard("wifi_server_url", serverInfo.url) }) {
                        Text("Copy URL")
                    }
                }
            }

            UtilityCard(
                icon = Icons.Outlined.PlayArrow,
                title = "FTP Server",
                description = "Launch a writable FTP server inside the Ubuntu terminal using pyftpdlib. The terminal stays open so you can monitor transfers.",
            ) {
                Text("Expected URL", style = MaterialTheme.typography.labelLarge)
                Text(ftpUrl, fontFamily = FontFamily.Monospace, style = MaterialTheme.typography.bodyMedium)
                QrPreview(bitmap = ftpQrBitmap, emptyLabel = "QR unavailable until an IP address is detected")
                Row(horizontalArrangement = Arrangement.spacedBy(8.dp), modifier = Modifier.fillMaxWidth()) {
                    Button(onClick = onLaunchFtpServer) {
                        Icon(Icons.Outlined.Edit, contentDescription = null)
                        Text(" Launch in Terminal")
                    }
                    OutlinedButton(onClick = { copyToClipboard("ftp_server_url", ftpUrl) }) {
                        Text("Copy FTP URL")
                    }
                }
            }

            UtilityCard(
                icon = Icons.Outlined.Search,
                title = "QR Connect",
                description = "Scan a local network QR code and open the decoded HTTP or FTP address immediately.",
            ) {
                Button(
                    onClick = {
                        val options = ScanOptions()
                            .setPrompt("Scan local network QR")
                            .setBeepEnabled(false)
                            .setOrientationLocked(false)
                        scannerLauncher.launch(options)
                    },
                ) {
                    Text("Scan QR Code")
                }
                if (!lastScan.isNullOrBlank()) {
                    Text("Last scanned value", style = MaterialTheme.typography.labelLarge)
                    Text(lastScan!!, fontFamily = FontFamily.Monospace, style = MaterialTheme.typography.bodySmall)
                    TextButton(onClick = { copyToClipboard("last_scan", lastScan!!) }) {
                        Text("Copy scanned value")
                    }
                }
            }
        }
    }
}

@Composable
private fun UtilityCard(
    icon: ImageVector,
    title: String,
    description: String,
    content: @Composable ColumnScope.() -> Unit,
) {
    Card(modifier = Modifier.fillMaxWidth()) {
        Column(
            modifier = Modifier.fillMaxWidth().padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp),
        ) {
            Row(horizontalArrangement = Arrangement.spacedBy(12.dp), verticalAlignment = Alignment.CenterVertically) {
                Icon(icon, contentDescription = null, tint = MaterialTheme.colorScheme.primary)
                Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                    Text(title, style = MaterialTheme.typography.titleMedium)
                    Text(description, style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
                }
            }
            content()
        }
    }
}

@Composable
private fun QrPreview(bitmap: android.graphics.Bitmap?, emptyLabel: String) {
    Surface(shape = MaterialTheme.shapes.medium, tonalElevation = 2.dp) {
        Box(modifier = Modifier.fillMaxWidth().height(220.dp), contentAlignment = Alignment.Center) {
            if (bitmap != null) {
                Image(bitmap = bitmap.asImageBitmap(), contentDescription = null, modifier = Modifier.padding(16.dp))
            } else {
                Text(emptyLabel, style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
            }
        }
    }
}

private data class LocalHttpServerInfo(
    val running: Boolean,
    val url: String,
    val rootPath: String,
)

private object LocalHttpShareServer {
    private var server: NanoHTTPD? = null

    fun start(rootPath: String): Boolean {
        if (server != null) return true
        val root = File(rootPath)
        if (!root.isDirectory) return false
        val httpServer = object : NanoHTTPD(HTTP_PORT) {
            override fun serve(session: IHTTPSession): Response {
                val rawUri = session.uri.ifBlank { "/" }
                val relativePath = URLDecoder.decode(rawUri.removePrefix("/"), Charsets.UTF_8.name())
                val target = if (relativePath.isBlank()) root else File(root, relativePath)
                if (!target.canonicalPath.startsWith(root.canonicalPath)) {
                    return newFixedLengthResponse(Response.Status.FORBIDDEN, MIME_PLAINTEXT, "Forbidden")
                }
                return when {
                    target.isDirectory -> newFixedLengthResponse(buildDirectoryListing(root, target))
                    target.isFile -> newChunkedResponse(Response.Status.OK, guessMimeType(target.name), target.inputStream())
                    else -> newFixedLengthResponse(Response.Status.NOT_FOUND, MIME_PLAINTEXT, "Not found")
                }
            }
        }
        return runCatching {
            httpServer.start(NanoHTTPD.SOCKET_READ_TIMEOUT, false)
            server = httpServer
            true
        }.getOrDefault(false)
    }

    fun stop() {
        server?.stop()
        server = null
    }

    private fun buildDirectoryListing(root: File, dir: File): String {
        val relative = dir.relativeTo(root).path.ifBlank { "/" }
        val entries = dir.listFiles().orEmpty().sortedBy { it.name.lowercase() }
        val body = buildString {
            append("<html><body><h2>HSPatcher Wi-Fi Server</h2>")
            append("<p>Directory: ").append(relative).append("</p><ul>")
            if (dir != root) {
                val parentRelative = dir.parentFile?.relativeTo(root)?.path.orEmpty()
                append("<li><a href=\"/")
                append(URLEncoder.encode(parentRelative, Charsets.UTF_8.name()).replace("+", "%20"))
                append("\">..</a></li>")
            }
            entries.forEach { file ->
                val targetRelative = file.relativeTo(root).path.replace(File.separatorChar, '/')
                append("<li><a href=\"/")
                append(URLEncoder.encode(targetRelative, Charsets.UTF_8.name()).replace("+", "%20"))
                append("\">")
                append(file.name)
                if (file.isDirectory) append("/")
                append("</a></li>")
            }
            append("</ul></body></html>")
        }
        return body
    }
}

private fun createFtpServerCommand(): TerminalCommand {
    val script = """
        set -e
        if ! command -v python3 >/dev/null 2>&1; then
          apt-get update >/dev/null 2>&1
          DEBIAN_FRONTEND=noninteractive apt-get install -y python3 python3-pip >/dev/null 2>&1
        fi
        python3 -m pip show pyftpdlib >/dev/null 2>&1 || python3 -m pip install --no-input pyftpdlib >/dev/null 2>&1
        IP="${'$'}(hostname -I 2>/dev/null | awk '{print ${'$'}1}')"
        if [ -z "${'$'}IP" ]; then
          IP="${'$'}(ip route get 1.1.1.1 2>/dev/null | awk '/src/ {for(i=1;i<=NF;i++) if(${ '$' }i==\"src\"){print ${ '$' }(i+1); exit}}')"
        fi
        echo "Serving ${'$'}PUBLIC_HOME over FTP"
        echo "Connect with: ftp://${'$'}IP:${FTP_PORT}/"
        exec python3 -m pyftpdlib -p ${FTP_PORT} -w -d "${'$'}PUBLIC_HOME"
    """.trimIndent()

    return TerminalCommand(
        sandbox = true,
        exe = "sh",
        args = arrayOf("-lc", script),
        id = "hspatcher-ftp-server",
        terminatePreviousSession = true,
        workingDir = "/home",
    )
}

private fun buildUrl(ip: String?, port: Int, scheme: String = "http"): String {
    val host = ip?.takeIf { it.isNotBlank() } ?: "127.0.0.1"
    return "$scheme://$host:$port/"
}

private fun detectLocalIpAddress(): String? {
    return runCatching {
        NetworkInterface.getNetworkInterfaces().toList()
            .flatMap { it.inetAddresses.toList() }
            .firstOrNull { address ->
                !address.isLoopbackAddress && address.hostAddress?.contains(':') == false
            }
            ?.hostAddress
    }.getOrNull()
}

private fun buildQrBitmap(content: String): android.graphics.Bitmap? {
    if (content.isBlank()) return null
    return runCatching {
        BarcodeEncoder().encodeBitmap(content, BarcodeFormat.QR_CODE, 720, 720)
    }.getOrNull()
}

private fun guessMimeType(name: String): String {
    val extension = name.substringAfterLast('.', "").lowercase()
    return when (extension) {
        "html", "htm" -> "text/html"
        "xml" -> "text/xml"
        "json" -> "application/json"
        "txt", "smali", "log" -> "text/plain"
        "apk" -> "application/vnd.android.package-archive"
        else -> "application/octet-stream"
    }
}

private const val HTTP_PORT = 8080
private const val FTP_PORT = 2121