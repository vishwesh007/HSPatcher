package com.rk.activities.main

import androidx.lifecycle.viewModelScope
import com.rk.file.BuiltinFileType
import com.rk.file.FileObject
import com.rk.file.FileTypeManager
import com.rk.resources.getString
import com.rk.resources.strings
import com.rk.settings.Settings
import com.rk.tabs.base.TabRegistry
import com.rk.tabs.editor.EditorTab
import com.rk.utils.dialog
import com.rk.utils.expectOOM
import com.rk.utils.hasBinaryChars
import com.rk.utils.isBinaryExtension
import com.rk.utils.toast
import io.github.rosemoe.sora.event.SelectionChangeEvent
import java.nio.charset.Charset
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class EditorManager(private val viewModel: MainViewModel) {

    companion object {
        private const val MAX_EDITOR_PREVIEW_BYTES = 8192
        private const val MAX_SAFE_DIRECT_OPEN_BYTES = 2L * 1024L * 1024L
    }

    fun createEditorTab(file: FileObject, projectRoot: FileObject?): EditorTab {
        return EditorTab(file = file, projectRoot = projectRoot, viewModel = viewModel)
    }

    fun addEditorTab(file: FileObject, projectRoot: FileObject?, switchToTab: Boolean, checkDuplicate: Boolean = true) {
        val editorTab = createEditorTab(file, projectRoot)
        viewModel.tabManager.addTab(editorTab, switchToTab, checkDuplicate)
    }

    suspend fun jumpToPosition(
        file: FileObject,
        projectRoot: FileObject?,
        lineStart: Int,
        charStart: Int,
        lineEnd: Int,
        charEnd: Int,
    ) {
        withContext(Dispatchers.Main) { openFile(file, projectRoot = projectRoot, switchToTab = true) }

        val targetTab = viewModel.tabs.filterIsInstance<EditorTab>().find { it.file == file } ?: return

        // Wait until editor content is loaded
        targetTab.editorState.contentRendered.await()

        withContext(Dispatchers.Main) {
            targetTab.editorState.editor
                .get()
                ?.setSelectionRegion(lineStart, charStart, lineEnd, charEnd, SelectionChangeEvent.CAUSE_SEARCH)

            targetTab.editorState.editor.get()?.ensureSelectionVisible()
        }
    }

    suspend fun openFile(
        fileObject: FileObject,
        projectRoot: FileObject?,
        switchToTab: Boolean,
        checkDuplicate: Boolean = true,
    ) {
        val openGuard = inspectFileForEditor(fileObject)
        if (!openGuard.canOpen) {
            withContext(Dispatchers.Main) { toast(openGuard.message ?: strings.binary_file_notice.getString()) }
            return
        }

        val existingEditorTab = if (checkDuplicate) {
            viewModel.tabs.filterIsInstance<EditorTab>().find { it.file == fileObject }
        } else {
            null
        }

        if (existingEditorTab != null) {
            withContext(Dispatchers.Main) {
                if (switchToTab) {
                    val existingIndex = viewModel.tabs.indexOf(existingEditorTab)
                    if (existingIndex >= 0) {
                        viewModel.tabManager.setCurrentTab(existingIndex)
                    } else {
                        existingEditorTab.onTabSelected()
                    }
                } else {
                    existingEditorTab.onTabSelected()
                }
            }

            if (existingEditorTab.editorState.content != null) {
                existingEditorTab.refresh()
            }
            return
        }

        val function = suspend {
            val tab = TabRegistry.getTab(fileObject, projectRoot, viewModel)
            withContext(Dispatchers.Main) { viewModel.tabManager.addTab(tab, switchToTab, checkDuplicate) }
        }

        if (Settings.oom_prediction && expectOOM(fileObject.length())) {
            dialog(
                title = strings.attention.getString(),
                msg = strings.tab_memory_warning.getString(),
                okString = strings.continue_action,
                onOk = { viewModel.viewModelScope.launch { function.invoke() } },
            )
        } else {
            function.invoke()
        }
    }

    private suspend fun inspectFileForEditor(fileObject: FileObject): OpenGuardResult {
        if (!fileObject.isFile()) {
            return OpenGuardResult(canOpen = true)
        }

        val builtinType = FileTypeManager.fromExtension(fileObject.getExtension())
        if (builtinType == BuiltinFileType.EXECUTABLE) {
            return OpenGuardResult(canOpen = true)
        }

        val fileLength = fileObject.length()
        if (isBinaryExtension(fileObject.getExtension())) {
            return OpenGuardResult(canOpen = false, message = strings.binary_file_notice.getString())
        }

        if (fileLength > MAX_SAFE_DIRECT_OPEN_BYTES) {
            return OpenGuardResult(
                canOpen = false,
                message = "File is too large to open safely in the editor (${fileLength / 1024} KB).",
            )
        }

        val previewText = fileObject.useInputStream { input ->
            val buffer = ByteArray(MAX_EDITOR_PREVIEW_BYTES)
            val read = input.read(buffer)
            if (read <= 0) {
                ""
            } else {
                String(buffer, 0, read, Charset.forName(Settings.encoding))
            }
        }

        return if (Settings.detect_bin_files && hasBinaryChars(previewText)) {
            OpenGuardResult(canOpen = false, message = strings.binary_file_notice.getString())
        } else {
            OpenGuardResult(canOpen = true)
        }
    }

    private data class OpenGuardResult(
        val canOpen: Boolean,
        val message: String? = null,
    )
}
