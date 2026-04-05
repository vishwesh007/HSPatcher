package com.rk.components

import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.Build
import androidx.compose.material.icons.outlined.List
import androidx.compose.material.icons.outlined.PlayArrow
import androidx.compose.material.icons.outlined.Settings
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.IconButton
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import androidx.lifecycle.lifecycleScope
import com.rk.DefaultScope
import com.rk.activities.main.MainActivity
import com.rk.activities.main.MainViewModel
import com.rk.activities.main.drawerStateRef
import com.rk.activities.main.fileTreeViewModel
import com.rk.activities.main.searchViewModel
import com.rk.commands.ActionContext
import com.rk.commands.CommandProvider
import com.rk.exec.launchTerminal
import com.rk.file.FileObject
import com.rk.file.FileWrapper
import com.rk.file.child
import com.rk.file.createFileIfNot
import com.rk.file.toFileObject
import com.rk.filetree.FileTreeTab
import com.rk.filetree.addProject
import com.rk.filetree.currentDrawerTab
import com.rk.hspatcher.HSPatcherWorkspaceIntegration
import com.rk.icons.CreateNewFile
import com.rk.icons.XedIcon
import com.rk.icons.XedIcons
import com.rk.resources.drawables
import com.rk.resources.strings
import com.rk.search.CodeSearchDialog
import com.rk.search.FileSearchDialog
import com.rk.settings.app.InbuiltFeatures
import com.rk.utils.application
import com.rk.utils.errorDialog
import com.rk.utils.getTempDir
import com.rk.utils.toast
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import androidx.compose.runtime.LaunchedEffect

var addDialog by mutableStateOf(false)
var fileSearchDialog by mutableStateOf(false)
var codeSearchDialog by mutableStateOf(false)
var signInstallInProgress by mutableStateOf(false)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun GlobalToolbarActions(viewModel: MainViewModel) {
    val context = LocalContext.current
    val scope = rememberCoroutineScope()
    var tempFileNameDialog by remember { mutableStateOf(false) }
    val currentProjectRoot = (currentDrawerTab as? FileTreeTab)?.root
    var isHSPatcherProject by remember { mutableStateOf(false) }
    LaunchedEffect(currentProjectRoot) {
        isHSPatcherProject = if (currentProjectRoot != null) {
            kotlinx.coroutines.withContext(Dispatchers.IO) {
                HSPatcherWorkspaceIntegration.isHSPatcherWorkspace(currentProjectRoot)
            }
        } else false
    }

    if (isHSPatcherProject && currentProjectRoot != null) {
        // Build button
        IconButton(
            onClick = {
                val command = HSPatcherWorkspaceIntegration.createBuildCommand(
                    java.io.File(currentProjectRoot.getAbsolutePath()),
                )
                launchTerminal(context, command)
            },
        ) {
            XedIcon(com.rk.icons.Icon.VectorIcon(Icons.Outlined.Build))
        }

        // Sign + Install button
        IconButton(
            enabled = !signInstallInProgress,
            onClick = {
                signInstallInProgress = true
                val projectPath = currentProjectRoot.getAbsolutePath()
                MainActivity.instance?.lifecycleScope?.launch(Dispatchers.IO) {
                    try {
                        val projectFile = java.io.File(projectPath)
                        val builtApk = HSPatcherWorkspaceIntegration.findBuiltApk(projectFile)
                        if (builtApk == null) {
                            launch(Dispatchers.Main) {
                                signInstallInProgress = false
                                toast("No built APK found. Run Build first.")
                            }
                            return@launch
                        }
                        val signedApk = HSPatcherWorkspaceIntegration.signBuiltApk(context, builtApk)
                        launch(Dispatchers.Main) {
                            signInstallInProgress = false
                            HSPatcherWorkspaceIntegration.installApk(context, signedApk)
                        }
                    } catch (e: Exception) {
                        launch(Dispatchers.Main) {
                            signInstallInProgress = false
                            toast("Sign failed: ${e.message}")
                        }
                    }
                }
            },
        ) {
            XedIcon(com.rk.icons.Icon.VectorIcon(
                if (signInstallInProgress) Icons.Outlined.Settings
                else Icons.Outlined.PlayArrow
            ))
        }
    }

    if (viewModel.tabs.isEmpty() || viewModel.currentTab?.showGlobalActions == true) {
        val newFileCommand = CommandProvider.NewFileCommand
        val terminalCommand = CommandProvider.TerminalCommand
        val settingsCommand = CommandProvider.SettingsCommand

        IconButton(onClick = { newFileCommand.action(ActionContext(context as Activity)) }) {
            XedIcon(newFileCommand.getIcon())
        }

        if (InbuiltFeatures.terminal.state.value) {
            IconButton(onClick = { terminalCommand.action(ActionContext(context as Activity)) }) {
                XedIcon(terminalCommand.getIcon())
            }
        }

        IconButton(onClick = { settingsCommand.action(ActionContext(context as Activity)) }) {
            XedIcon(settingsCommand.getIcon())
        }
    }

    if (fileSearchDialog && currentDrawerTab is FileTreeTab) {
        FileSearchDialog(
            searchViewModel = searchViewModel.get()!!,
            projectFile = (currentDrawerTab as FileTreeTab).root,
            onFinish = { fileSearchDialog = false },
            onSelect = { projectFile, fileObject ->
                scope.launch {
                    if (fileObject.isFile()) {
                        viewModel.editorManager.openFile(
                            fileObject = fileObject,
                            projectRoot = projectFile,
                            checkDuplicate = true,
                            switchToTab = true,
                        )
                        drawerStateRef.get()?.close()
                    } else {
                        fileTreeViewModel.get()?.goToFolder(projectFile, fileObject)
                        drawerStateRef.get()!!.open()
                    }
                }
            },
        )
    }

    if (codeSearchDialog && currentDrawerTab is FileTreeTab) {
        CodeSearchDialog(
            mainViewModel = viewModel,
            searchViewModel = searchViewModel.get()!!,
            projectFile = (currentDrawerTab as FileTreeTab).root,
            onFinish = { codeSearchDialog = false },
        )
    }

    if (addDialog) {
        ModalBottomSheet(onDismissRequest = { addDialog = false }) {
            Column(modifier = Modifier.padding(start = 16.dp, end = 16.dp, bottom = 16.dp, top = 0.dp)) {
                AddDialogItem(icon = drawables.file, title = stringResource(strings.temp_file)) {
                    val intent = Intent(Intent.ACTION_CREATE_DOCUMENT)
                    intent.addCategory(Intent.CATEGORY_OPENABLE)
                    intent.setType("application/octet-stream")
                    intent.putExtra(Intent.EXTRA_TITLE, "newfile.txt")

                    val activities =
                        application!!.packageManager.queryIntentActivities(intent, PackageManager.MATCH_ALL)

                    if (activities.isEmpty()) {
                        errorDialog(strings.unsupported_feature)
                    } else {
                        tempFileNameDialog = true
                    }

                    addDialog = false
                }

                AddDialogItem(icon = XedIcons.CreateNewFile, title = stringResource(strings.new_file)) {
                    addDialog = false
                    val intent = Intent(Intent.ACTION_CREATE_DOCUMENT)
                    intent.addCategory(Intent.CATEGORY_OPENABLE)
                    intent.setType("application/octet-stream")
                    intent.putExtra(Intent.EXTRA_TITLE, "newfile.txt")

                    val activities =
                        application!!.packageManager.queryIntentActivities(intent, PackageManager.MATCH_ALL)
                    if (activities.isEmpty()) {
                        errorDialog(strings.unsupported_feature)
                    } else {
                        MainActivity.instance?.apply {
                            fileManager.createNewFile(mimeType = "*/*", title = "newfile.txt") {
                                if (it != null) {
                                    lifecycleScope.launch {
                                        viewModel.editorManager.openFile(
                                            it,
                                            projectRoot = null,
                                            checkDuplicate = true,
                                            switchToTab = true,
                                        )
                                    }
                                }
                            }
                        }
                    }
                }

                AddDialogItem(icon = drawables.file_symlink, title = stringResource(strings.open_file)) {
                    addDialog = false
                    MainActivity.instance?.apply {
                        fileManager.requestOpenFile(mimeType = "*/*") {
                            if (it != null) {
                                lifecycleScope.launch {
                                    viewModel.editorManager.openFile(
                                        it.toFileObject(expectedIsFile = true),
                                        checkDuplicate = true,
                                        projectRoot = null,
                                        switchToTab = true,
                                    )
                                }
                            }
                        }
                    }
                }
                AddDialogItem(
                    icon = Icons.Outlined.List,
                    title = "HSPatcher workspace",
                    description = "Open the last decoded APK workspace as a project",
                ) {
                    addDialog = false
                    val workspace = HSPatcherWorkspaceIntegration.getLastWorkspaceDir(context)
                    val projectRoot = workspace?.let { HSPatcherWorkspaceIntegration.resolveProjectRoot(it.absolutePath) }
                    if (projectRoot == null) {
                        toast("No HSPatcher workspace found yet")
                        return@AddDialogItem
                    }

                    MainActivity.instance?.lifecycleScope?.launch {
                        addProject(FileWrapper(projectRoot), save = true)
                        toast("Opened HSPatcher workspace")
                    }
                }

                AddDialogItem(
                    icon = Icons.Outlined.Settings,
                    title = "REAndroid framework",
                    description = "Prepare APKEditor plus Android framework files for manifest/resource decode",
                ) {
                    addDialog = false
                    MainActivity.instance?.lifecycleScope?.launch(Dispatchers.IO) {
                        val result = HSPatcherWorkspaceIntegration.prepareFrameworkWorkspace()
                        result.onSuccess { projectDir ->
                            launch(Dispatchers.Main) {
                                addProject(FileWrapper(projectDir), save = true)
                                toast("REAndroid workspace ready")
                            }
                        }.onFailure { error ->
                            launch(Dispatchers.Main) {
                                errorDialog(error.message ?: "Failed to prepare REAndroid workspace")
                            }
                        }
                    }
                }

                AddDialogItem(
                    icon = Icons.Outlined.PlayArrow,
                    title = "Select & Import App",
                    description = "Pick an installed app, decode it with APKEditor.jar, and open workspace",
                ) {
                    addDialog = false
                    try {
                        val intent = android.content.Intent()
                        intent.setClassName(context.packageName, "in.startv.hspatcher.ApkEditorActivity")
                        intent.putExtra("hsp_direct_jar_workflow", true)
                        intent.addFlags(android.content.Intent.FLAG_ACTIVITY_NEW_TASK)
                        context.startActivity(intent)
                    } catch (e: Exception) {
                        toast("Could not launch APK Editor: ${e.message}")
                    }
                }
            }
        }
    }

    if (tempFileNameDialog) {
        var fileName by remember { mutableStateOf("untitled.txt") }

        fun getUniqueFileName(baseName: String): String {
            val tempDir = getTempDir().child("temp_editor")
            val extension = baseName.substringAfterLast('.', "")
            val nameWithoutExt = baseName.substringBeforeLast('.', baseName)

            // Check if base name is available
            if (!tempDir.child(baseName).exists()) {
                return baseName
            }

            // Find next available number
            var counter = 1
            var uniqueName: String
            do {
                uniqueName =
                    if (extension.isNotEmpty()) {
                        "${nameWithoutExt}${counter}.${extension}"
                    } else {
                        "${nameWithoutExt}${counter}"
                    }
                counter++
            } while (tempDir.child(uniqueName).exists())

            return uniqueName
        }

        fun getUniqueTempFile(): FileObject {
            val uniqueName = getUniqueFileName(fileName)
            fileName = uniqueName // Update the state with the unique name

            // do not change getTempDir().child("temp_editor") it used for checking in editor tab
            return FileWrapper(getTempDir().child("temp_editor").child(uniqueName))
        }

        val tempFile = getUniqueTempFile()

        SingleInputDialog(
            title = stringResource(strings.temp_file),
            inputValue = fileName,
            onInputValueChange = { fileName = it },
            onConfirm = {
                DefaultScope.launch(Dispatchers.IO) {
                    tempFileNameDialog = false
                    tempFile.createFileIfNot()
                    viewModel.editorManager.openFile(tempFile, projectRoot = null, switchToTab = true)
                }
            },
            onDismiss = { tempFileNameDialog = false },
            singleLineMode = true,
            confirmText = stringResource(strings.ok),
            inputLabel = stringResource(strings.file_name),
        )
    }
}
