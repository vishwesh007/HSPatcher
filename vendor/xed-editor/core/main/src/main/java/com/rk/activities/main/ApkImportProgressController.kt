package com.rk.activities.main

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue

data class ApkImportProgressState(
    val title: String,
    val message: String,
    val detail: String,
    val elapsedLabel: String,
    val progress: Float?,
    val isFinished: Boolean = false,
)

object ApkImportProgressController {
    var state by mutableStateOf<ApkImportProgressState?>(null)
        private set

    fun start(apkName: String) {
        state = ApkImportProgressState(
            title = "Importing ${apkName}",
            message = "Preparing APKEditor workspace",
            detail = "Large multi-dex APKs can take several minutes on device.",
            elapsedLabel = "0s elapsed",
            progress = null,
        )
    }

    fun update(message: String, detail: String, elapsedLabel: String, progress: Float?) {
        val current = state ?: return
        state = current.copy(
            message = message,
            detail = detail,
            elapsedLabel = elapsedLabel,
            progress = progress,
            isFinished = false,
        )
    }

    fun finish(message: String, detail: String, elapsedLabel: String) {
        val current = state ?: return
        state = current.copy(
            message = message,
            detail = detail,
            elapsedLabel = elapsedLabel,
            progress = 1f,
            isFinished = true,
        )
    }

    fun hide() {
        state = null
    }
}