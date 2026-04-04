package com.rk.tabs.binary

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.RowScope
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.text.selection.SelectionContainer
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.MutableState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.produceState
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.unit.dp
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.Info
import com.rk.activities.main.FileTabState
import com.rk.activities.main.TabState
import com.rk.file.FileObject
import com.rk.tabs.base.Tab
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

private const val PREVIEW_BYTES = 8192
private const val BYTES_PER_ROW = 16

class BinaryPreviewTab(override val file: FileObject) : Tab() {

    override val name: String
        get() = "Binary Preview"

    override val icon: ImageVector
        get() = Icons.Outlined.Info

    override var tabTitle: MutableState<String> = mutableStateOf(file.getName())

    override fun getState(): TabState = FileTabState(file)

    @Composable
    override fun Content() {
        val previewState by produceState<BinaryPreviewState>(initialValue = BinaryPreviewState.Loading, file) {
            value = withContext(Dispatchers.IO) { loadBinaryPreview(file) }
        }

        when (val state = previewState) {
            BinaryPreviewState.Loading -> {
                Column(
                    modifier = Modifier.fillMaxSize().padding(16.dp),
                    verticalArrangement = Arrangement.spacedBy(12.dp),
                ) {
                    Text("Loading binary preview...", style = MaterialTheme.typography.bodyLarge)
                }
            }

            is BinaryPreviewState.Error -> {
                Column(
                    modifier = Modifier.fillMaxSize().padding(16.dp),
                    verticalArrangement = Arrangement.spacedBy(12.dp),
                ) {
                    Text(state.message, color = MaterialTheme.colorScheme.error)
                }
            }

            is BinaryPreviewState.Ready -> {
                Column(
                    modifier = Modifier.fillMaxSize().verticalScroll(rememberScrollState()).padding(12.dp),
                    verticalArrangement = Arrangement.spacedBy(12.dp),
                ) {
                    Surface(shape = MaterialTheme.shapes.medium, tonalElevation = 2.dp) {
                        Column(modifier = Modifier.fillMaxWidth().padding(16.dp), verticalArrangement = Arrangement.spacedBy(6.dp)) {
                            Text(file.getName(), style = MaterialTheme.typography.titleMedium)
                            Text("Size: ${state.fileSize} bytes", style = MaterialTheme.typography.bodyMedium)
                            Text(
                                state.summary,
                                style = MaterialTheme.typography.bodySmall,
                                color = MaterialTheme.colorScheme.onSurfaceVariant,
                            )
                        }
                    }

                    if (state.asciiStrings.isNotEmpty()) {
                        Surface(shape = MaterialTheme.shapes.medium, tonalElevation = 2.dp) {
                            Column(modifier = Modifier.fillMaxWidth().padding(16.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                                Text("Detected strings", style = MaterialTheme.typography.titleSmall)
                                SelectionContainer {
                                    Text(
                                        state.asciiStrings,
                                        style = MaterialTheme.typography.bodySmall,
                                        fontFamily = FontFamily.Monospace,
                                    )
                                }
                            }
                        }
                    }

                    Surface(shape = MaterialTheme.shapes.medium, tonalElevation = 2.dp) {
                        Column(modifier = Modifier.fillMaxWidth().padding(16.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                            Text("Hex preview", style = MaterialTheme.typography.titleSmall)
                            SelectionContainer {
                                Text(
                                    text = state.hexDump,
                                    style = MaterialTheme.typography.bodySmall,
                                    fontFamily = FontFamily.Monospace,
                                    modifier = Modifier.fillMaxWidth(),
                                )
                            }
                        }
                    }
                }
            }
        }
    }

    @Composable
    override fun RowScope.Actions() {
        Icon(
            imageVector = icon,
            contentDescription = null,
            modifier = Modifier.height(20.dp),
            tint = MaterialTheme.colorScheme.primary,
        )
    }
}

private sealed interface BinaryPreviewState {
    data object Loading : BinaryPreviewState

    data class Ready(
        val fileSize: Long,
        val summary: String,
        val asciiStrings: String,
        val hexDump: String,
    ) : BinaryPreviewState

    data class Error(val message: String) : BinaryPreviewState
}

private suspend fun loadBinaryPreview(file: FileObject): BinaryPreviewState {
    return runCatching {
        val fileSize = file.length()
        val bytes = file.useInputStream { input ->
            val buffer = ByteArray(PREVIEW_BYTES)
            val read = input.read(buffer)
            if (read <= 0) ByteArray(0) else buffer.copyOf(read)
        }

        val truncated = fileSize > bytes.size
        BinaryPreviewState.Ready(
            fileSize = fileSize,
            summary = if (truncated) {
                "Showing the first ${bytes.size} bytes. Open in an external binary editor for full patching."
            } else {
                "Showing the full file preview in read-only mode."
            },
            asciiStrings = extractAsciiStrings(bytes),
            hexDump = formatHexDump(bytes),
        )
    }.getOrElse {
        BinaryPreviewState.Error(it.message ?: "Failed to read binary file")
    }
}

private fun formatHexDump(bytes: ByteArray): String {
    if (bytes.isEmpty()) return "<empty file>"

    return bytes
        .toList()
        .chunked(BYTES_PER_ROW)
        .mapIndexed { rowIndex, row ->
            val offset = (rowIndex * BYTES_PER_ROW).toString(16).padStart(8, '0')
            val hexPart = row.joinToString(" ") { byte -> (byte.toInt() and 0xFF).toString(16).padStart(2, '0') }
                .padEnd(BYTES_PER_ROW * 3 - 1, ' ')
            val asciiPart = row.joinToString(separator = "") { byte ->
                val value = byte.toInt() and 0xFF
                if (value in 32..126) value.toChar().toString() else "."
            }
            "$offset  $hexPart  $asciiPart"
        }
        .joinToString("\n")
}

private fun extractAsciiStrings(bytes: ByteArray): String {
    val builder = StringBuilder()
    val current = StringBuilder()

    fun flush() {
        if (current.length >= 4) {
            if (builder.isNotEmpty()) builder.append('\n')
            builder.append(current)
        }
        current.clear()
    }

    bytes.forEach { byte ->
        val value = byte.toInt() and 0xFF
        if (value in 32..126) {
            current.append(value.toChar())
        } else {
            flush()
        }
    }
    flush()

    return builder.toString().ifBlank { "<no readable ASCII strings in preview>" }
}