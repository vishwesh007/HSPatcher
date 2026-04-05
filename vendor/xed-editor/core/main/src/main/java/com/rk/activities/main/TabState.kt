package com.rk.activities.main

import com.rk.file.FileObject
import com.rk.tabs.base.Tab
import com.rk.tabs.base.TabRegistry
import java.io.Serializable

sealed interface TabState : Serializable {
    suspend fun toTab(): Tab?
}

data class EditorTabState(
    val fileObject: FileObject,
    val projectRoot: FileObject?,
    val cursor: EditorCursorState,
    val scrollX: Int,
    val scrollY: Int,
    val unsavedContent: String?,
) : TabState {
    override suspend fun toTab(): Tab? {
        if (!fileObject.exists() && !fileObject.canRead()) return null

        MainActivity.instance!!.viewModel.apply {
            val editorTab = editorManager.createEditorTab(fileObject, projectRoot)
            editorTab.queueSessionRestore(cursor, scrollX, scrollY, unsavedContent)

            return editorTab
        }
    }
}

data class EditorCursorState(val lineLeft: Int, val columnLeft: Int, val lineRight: Int, val columnRight: Int) :
    Serializable

data class FileTabState(val fileObject: FileObject) : TabState {
    override suspend fun toTab() = TabRegistry.getTab(fileObject, null, MainActivity.instance!!.viewModel)
}
