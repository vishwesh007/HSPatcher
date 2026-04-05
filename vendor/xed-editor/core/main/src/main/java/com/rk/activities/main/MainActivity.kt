package com.rk.activities.main

import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.os.SystemClock
import android.view.KeyEvent
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity
import androidx.appcompat.app.AppCompatDelegate
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.runtime.LaunchedEffect
import androidx.lifecycle.lifecycleScope
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.rk.commands.KeybindingsManager
import com.rk.file.FileManager
import com.rk.file.FilePermission
import com.rk.file.FileWrapper
import com.rk.file.toFileObject
import com.rk.filetree.addProject
import com.rk.filetree.DrawerPersistence
import com.rk.hspatcher.HSPatcherWorkspaceIntegration
import com.rk.lsp.LspRegistry
import com.rk.resources.getFilledString
import com.rk.resources.strings
import com.rk.settings.AppOrientation
import com.rk.settings.Settings
import com.rk.settings.support.handleSupport
import com.rk.tabs.editor.EditorTab
import com.rk.tabs.editor.applyHighlightingAndConnectLSP
import com.rk.utils.errorDialog
import com.rk.utils.toast
import java.io.File
import java.lang.ref.WeakReference
import kotlinx.coroutines.DelicateCoroutinesApi
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.cancelAndJoin
import kotlinx.coroutines.coroutineScope
import kotlinx.coroutines.currentCoroutineContext
import kotlinx.coroutines.delay
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class MainActivity : AppCompatActivity() {
    val viewModel: MainViewModel by viewModels()
    val fileManager = FileManager(this)
    private var lastHandledIntentSignature: String? = null

    // suspend (isForeground) -> Unit
    val foregroundListener = hashMapOf<Any, suspend (Boolean) -> Unit>()

    companion object {
        var isPaused = false
        private var activityRef = WeakReference<MainActivity?>(null)
        var instance: MainActivity?
            get() = activityRef.get()
            private set(value) {
                activityRef = WeakReference(value)
            }
    }

    @OptIn(DelicateCoroutinesApi::class)
    override fun onPause() {
        isPaused = true
        GlobalScope.launch(Dispatchers.IO) {
            SessionManager.saveSession(viewModel.tabs, viewModel.currentTabIndex)
            DrawerPersistence.saveState()
            foregroundListener.values.forEach { it.invoke(false) }

            LspRegistry.updateConfiguration(this@MainActivity)
        }
        super.onPause()
    }

    override fun onResume() {
        super.onResume()
        AppOrientation.apply(this)
        isPaused = false
        instance = this
        lifecycleScope.launch(Dispatchers.IO) {
            if (shouldHandleIntent(intent)) {
                handleIntent(intent)
            }
            foregroundListener.values.forEach { it.invoke(true) }
            if (!isActive) return@launch
            delay(1000)
            if (!isActive) return@launch
            handleSupport()

            val lspConfigChanges = LspRegistry.getConfigurationChanges(this@MainActivity)
            if (lspConfigChanges.isNotEmpty()) {
                val affectedExtensions = lspConfigChanges.flatMap { it.supportedExtensions }
                viewModel.tabs
                    .filterIsInstance<EditorTab>()
                    .filter { affectedExtensions.contains(it.file.getExtension()) }
                    .forEach { tab -> tab.applyHighlightingAndConnectLSP() }
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
    }

    private fun shouldHandleIntent(intent: Intent): Boolean {
        val signature = buildString {
            append(intent.action.orEmpty())
            append('|')
            append(intent.dataString.orEmpty())
            append('|')
            append(intent.getStringExtra(HSPatcherWorkspaceIntegration.EXTRA_IMPORT_APK_PATH).orEmpty())
            append('|')
            append(intent.getStringExtra(HSPatcherWorkspaceIntegration.EXTRA_WORKSPACE_PATH).orEmpty())
            append('|')
            append(intent.getStringExtra(HSPatcherWorkspaceIntegration.EXTRA_FOCUS_FILE).orEmpty())
        }
        if (signature == "||||") {
            return false
        }
        if (signature == lastHandledIntentSignature) {
            return false
        }
        lastHandledIntentSignature = signature
        return true
    }

    suspend fun handleIntent(intent: Intent) {
        val importApkPath = intent.getStringExtra(HSPatcherWorkspaceIntegration.EXTRA_IMPORT_APK_PATH)
        val requestedWorkspacePath = intent.getStringExtra(HSPatcherWorkspaceIntegration.EXTRA_WORKSPACE_PATH)
        if (!importApkPath.isNullOrBlank() && !requestedWorkspacePath.isNullOrBlank()) {
            val stagedApk = File(importApkPath)
            val workspaceDir = File(requestedWorkspacePath)
            val importResult = importApkIntoWorkspaceWithProgress(stagedApk, workspaceDir)
            val importedWorkspace = importResult.getOrElse {
                toast(it.message ?: "APKEditor.jar import failed")
                setIntent(Intent())
                return
            }

            val projectRoot = HSPatcherWorkspaceIntegration.resolveProjectRoot(importedWorkspace.absolutePath)
            if (projectRoot != null) {
                viewModel.awaitSessionRestoration()
                addProject(FileWrapper(projectRoot), save = true)

                val focusFile = HSPatcherWorkspaceIntegration.getWorkspaceDefaultFocusFile(importedWorkspace)
                if (focusFile != null) {
                    viewModel.editorManager.openFile(
                        fileObject = FileWrapper(focusFile),
                        projectRoot = FileWrapper(projectRoot),
                        checkDuplicate = true,
                        switchToTab = true,
                    )
                }
            }
            setIntent(Intent())
            lastHandledIntentSignature = null
            return
        }

        val workspaceRoot =
            HSPatcherWorkspaceIntegration.resolveProjectRoot(
                requestedWorkspacePath,
            )
        if (workspaceRoot != null) {
            viewModel.awaitSessionRestoration()
            addProject(FileWrapper(workspaceRoot), save = true)

            val focusFilePath = intent.getStringExtra(HSPatcherWorkspaceIntegration.EXTRA_FOCUS_FILE)
            val focusFile = focusFilePath?.let(::File)?.takeIf { it.isFile }
            if (focusFile != null) {
                viewModel.editorManager.openFile(
                    fileObject = FileWrapper(focusFile),
                    projectRoot = FileWrapper(workspaceRoot),
                    checkDuplicate = true,
                    switchToTab = true,
                )
            }
            setIntent(Intent())
            lastHandledIntentSignature = null
            return
        }

        if (Intent.ACTION_VIEW == intent.action || Intent.ACTION_EDIT == intent.action) {
            if (intent.data == null) {
                errorDialog(strings.invalid_intent.getFilledString(intent.toString()))
                return
            }

            val uri = intent.data!!

            if (uri.toString().startsWith("content://telephony")) {
                toast(strings.unsupported_content)
                return
            }

            val file = uri.toFileObject(expectedIsFile = true)

            viewModel.awaitSessionRestoration()
            viewModel.editorManager.openFile(file, projectRoot = null, switchToTab = true)
            setIntent(Intent())
            lastHandledIntentSignature = null
        }
    }

    private suspend fun importApkIntoWorkspaceWithProgress(stagedApk: File, workspaceDir: File) = coroutineScope {
        val startedAt = SystemClock.elapsedRealtime()
        withContext(Dispatchers.Main) {
            ApkImportProgressController.start(stagedApk.name)
        }
        val progressJob = launch(Dispatchers.IO) {
            monitorWorkspaceImportProgress(workspaceDir, startedAt)
        }

        try {
            val result = HSPatcherWorkspaceIntegration.importApkIntoWorkspace(this@MainActivity, stagedApk, workspaceDir)
            val elapsedLabel = formatElapsedLabel(SystemClock.elapsedRealtime() - startedAt)
            withContext(Dispatchers.Main) {
                if (result.isSuccess) {
                    ApkImportProgressController.finish(
                        message = "Workspace import finished",
                        detail = "Decoded project is ready to open.",
                        elapsedLabel = elapsedLabel,
                    )
                } else {
                    ApkImportProgressController.finish(
                        message = "Workspace import failed",
                        detail = result.exceptionOrNull()?.message ?: "APKEditor.jar import failed",
                        elapsedLabel = elapsedLabel,
                    )
                }
            }
            result
        } finally {
            progressJob.cancelAndJoin()
            withContext(Dispatchers.Main) {
                delay(1200)
                ApkImportProgressController.hide()
            }
        }
    }

    private suspend fun monitorWorkspaceImportProgress(workspaceDir: File, startedAt: Long) {
        val logFile = workspaceDir.resolve("apkeditor-decode.log")
        while (currentCoroutineContext().isActive) {
            val snapshot = parseImportProgress(logFile, SystemClock.elapsedRealtime() - startedAt)
            withContext(Dispatchers.Main) {
                ApkImportProgressController.update(
                    message = snapshot.message,
                    detail = snapshot.detail,
                    elapsedLabel = snapshot.elapsedLabel,
                    progress = snapshot.progress,
                )
            }
            delay(1500)
        }
    }

    private fun parseImportProgress(logFile: File, elapsedMs: Long): ImportProgressSnapshot {
        val elapsedLabel = formatElapsedLabel(elapsedMs)
        if (!logFile.isFile) {
            return ImportProgressSnapshot(
                message = "Preparing APKEditor workspace",
                detail = "Provisioning framework files and decoder environment.",
                elapsedLabel = elapsedLabel,
                progress = null,
            )
        }

        val content = runCatching { logFile.readText() }.getOrDefault("")
        if (content.isBlank()) {
            return ImportProgressSnapshot(
                message = "Preparing APKEditor workspace",
                detail = "Waiting for decoder output...",
                elapsedLabel = elapsedLabel,
                progress = null,
            )
        }

        val totalDex = Regex("""Dex files:\s+(\d+)""")
            .find(content)
            ?.groupValues
            ?.getOrNull(1)
            ?.toIntOrNull()
            ?: 0
        val completedDex = Regex("""Baksmali:.*?\s(classes\d*\.dex)""")
            .findAll(content)
            .count()
        val latestLine = content.lineSequence().lastOrNull { it.isNotBlank() }.orEmpty().trim()

        val message: String
        val detail: String
        val progress: Float?

        when {
            "Saved to:" in content -> {
                message = "Opening decoded workspace"
                detail = latestLine.ifBlank { "Import finished successfully." }
                progress = 1f
            }
            "Dumping signatures" in content -> {
                message = "Finalizing workspace"
                detail = "Writing signatures and root files before opening the project."
                progress = 0.96f
            }
            "Extracting root files" in content -> {
                message = "Extracting root files"
                detail = "Copying remaining decoded assets into the workspace."
                progress = 0.9f
            }
            completedDex > 0 && totalDex > 0 -> {
                val percent = 0.35f + (completedDex.coerceAtMost(totalDex) / totalDex.toFloat()) * 0.5f
                message = "Decoding dex ${completedDex} of ${totalDex}"
                detail = latestLine.ifBlank { "Baksmali is processing dex files." }
                progress = percent.coerceAtMost(0.88f)
            }
            "Loading full dex files" in content -> {
                message = "Loading dex files"
                detail = "APKEditor is reading all dex files into memory for smali decode."
                progress = 0.35f
            }
            "Dex files:" in content -> {
                message = "Preparing smali decode"
                detail = latestLine.ifBlank { "Resource decode finished; dex decode is next." }
                progress = 0.28f
            }
            "Res files:" in content -> {
                message = "Decoding resources"
                detail = latestLine.ifBlank { "Manifest and resources are being expanded into XML." }
                progress = 0.18f
            }
            "Loading external framework" in content || "Loading android framework" in content -> {
                message = "Preparing framework"
                detail = latestLine.ifBlank { "Loading framework tables for resource and dex comments." }
                progress = 0.08f
            }
            else -> {
                message = "Starting decode"
                detail = latestLine.ifBlank { "APKEditor has started processing the APK." }
                progress = null
            }
        }

        return ImportProgressSnapshot(
            message = message,
            detail = detail,
            elapsedLabel = elapsedLabel,
            progress = progress,
        )
    }

    private fun formatElapsedLabel(elapsedMs: Long): String {
        val totalSeconds = (elapsedMs / 1000L).coerceAtLeast(0L)
        val minutes = totalSeconds / 60L
        val seconds = totalSeconds % 60L
        return if (minutes > 0L) {
            "${minutes}m ${seconds}s elapsed"
        } else {
            "${seconds}s elapsed"
        }
    }

    private data class ImportProgressSnapshot(
        val message: String,
        val detail: String,
        val elapsedLabel: String,
        val progress: Float?,
    )

    override fun dispatchKeyEvent(event: KeyEvent): Boolean {
        val handledEvent = KeybindingsManager.handleGlobalEvent(event, this)
        if (handledEvent) return true
        return super.dispatchKeyEvent(event)
    }

    @OptIn(ExperimentalMaterial3Api::class)
    override fun onCreate(savedInstanceState: Bundle?) {
        AppCompatDelegate.setDefaultNightMode(Settings.theme_mode)
        AppOrientation.apply(this)
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        instance = this
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            window.isNavigationBarContrastEnforced = false
        }

        setContent {
            val navController = rememberNavController()
            NavHost(
                navController = navController,
                startDestination =
                    if (Settings.shown_disclaimer) {
                        MainRoutes.Main.route
                    } else {
                        MainRoutes.Disclaimer.route
                    },
            ) {
                composable(MainRoutes.Main.route) {
                    MainContentHost()
                    LaunchedEffect(Unit) {
                        viewModel.onUiReady()
                        FilePermission.verifyStoragePermission(this@MainActivity)
                    }
                }
                composable(MainRoutes.Disclaimer.route) { DisclaimerScreen(navController) { finishAffinity() } }
            }
        }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        FilePermission.onRequestPermissionsResult(requestCode, grantResults, lifecycleScope, this)
    }
}
