package com.rk.hspatcher

import android.content.Context
import android.content.Intent
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.Build
import androidx.compose.material.icons.outlined.Edit
import androidx.compose.material.icons.outlined.Info
import androidx.compose.material.icons.outlined.List
import androidx.compose.material.icons.outlined.Lock
import androidx.compose.material.icons.outlined.PlayArrow
import androidx.compose.material.icons.outlined.Search
import androidx.compose.material.icons.outlined.Settings
import androidx.compose.material3.Card
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import androidx.compose.runtime.rememberCoroutineScope
import com.rk.activities.main.AppWalkthroughController
import com.rk.filetree.DrawerTab
import com.rk.utils.toast
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class HSPatcherTab : DrawerTab() {

    @Composable
    override fun Content(modifier: Modifier) {
        val context = LocalContext.current
        val scope = rememberCoroutineScope()
        Column(
            modifier = modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(12.dp)
        ) {
            Text(
                text = "HSPatcher Tools",
                style = MaterialTheme.typography.titleMedium,
                modifier = Modifier.padding(bottom = 12.dp)
            )

            ToolItem(
                icon = Icons.Outlined.Info,
                title = "App Walkthrough",
                description = "See the guided flow for decode, edit, build and install",
                onClick = { AppWalkthroughController.show() }
            )

            ToolItem(
                icon = Icons.Outlined.Edit,
                title = "APK Editor (Faster)",
                description = "Use Frida Packer unpack first, then open the decoded workspace in Xed",
                onClick = { launchJarWorkflow(context, "in.startv.hspatcher.ApkEditorActivity") }
            )

            ToolItem(
                icon = Icons.Outlined.List,
                title = "Open Last Workspace",
                description = "Re-open the most recently decoded APK workspace",
                onClick = {
                    scope.launch {
                        val workspace = withContext(Dispatchers.IO) {
                            HSPatcherWorkspaceIntegration.getLastWorkspaceDir(context)
                        }
                        val projectRoot = withContext(Dispatchers.IO) {
                            workspace?.let { HSPatcherWorkspaceIntegration.resolveProjectRoot(it.absolutePath) }
                        }
                        if (projectRoot != null) {
                            val intent = HSPatcherWorkspaceIntegration.createDirectJarWorkflowIntent(context, "com.rk.activities.main.MainActivity")
                            intent.putExtra(HSPatcherWorkspaceIntegration.EXTRA_WORKSPACE_PATH, workspace!!.absolutePath)
                            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            context.startActivity(intent)
                        } else {
                            toast("No workspace found — use APK Editor first")
                        }
                    }
                }
            )

            ToolItem(
                icon = Icons.Outlined.Settings,
                title = "REAndroid Framework (Slower)",
                description = "Prepare APKEditor plus Android framework files inside Xed's Ubuntu path",
                onClick = {
                    scope.launch(Dispatchers.IO) {
                        val result = HSPatcherWorkspaceIntegration.prepareFrameworkWorkspace()
                        result.onSuccess { projectDir ->
                            launch(Dispatchers.Main) {
                                toast("REAndroid workspace ready")
                            }
                        }.onFailure { error ->
                            launch(Dispatchers.Main) {
                                toast(error.message ?: "Failed to prepare REAndroid workspace")
                            }
                        }
                    }
                }
            )

            ToolItem(
                icon = Icons.Outlined.PlayArrow,
                title = "Sign & Install",
                description = "Sign the last built APK and launch installer",
                onClick = {
                    scope.launch {
                        val result = withContext(Dispatchers.IO) {
                            val workspace = HSPatcherWorkspaceIntegration.getLatestWorkspaceDir(context)
                                ?: return@withContext "No workspace found"
                            val builtApk = HSPatcherWorkspaceIntegration.findBuiltApk(workspace)
                                ?: return@withContext "No built APK found — run Build first"
                            try {
                                val signed = HSPatcherWorkspaceIntegration.signBuiltApk(context, builtApk)
                                return@withContext signed
                            } catch (e: Exception) {
                                return@withContext "Sign failed: ${e.message}"
                            }
                        }
                        when (result) {
                            is java.io.File -> HSPatcherWorkspaceIntegration.installApk(context, result)
                            is String -> toast(result)
                        }
                    }
                }
            )

            HorizontalDivider(modifier = Modifier.padding(vertical = 8.dp))

            ToolItem(
                icon = Icons.Outlined.Build,
                title = "Patch APK",
                description = "Decode, patch & rebuild APKs",
                onClick = { launchActivity(context, "in.startv.hspatcher.MainActivity") }
            )

            ToolItem(
                icon = Icons.Outlined.List,
                title = "App List",
                description = "Browse & extract installed apps",
                onClick = { launchActivity(context, "in.startv.hspatcher.AppListActivity") }
            )

            ToolItem(
                icon = Icons.Outlined.Lock,
                title = "APK Signer",
                description = "Sign APKs with custom certificates",
                onClick = { launchActivity(context, "in.startv.hspatcher.ApkSignerActivity") }
            )

            ToolItem(
                icon = Icons.Outlined.Search,
                title = "Text Replace",
                description = "Search & replace text in files",
                onClick = { launchActivity(context, "in.startv.hspatcher.TextReplaceActivity") }
            )

            ToolItem(
                icon = Icons.Outlined.Edit,
                title = "DB Editor",
                description = "Browse & edit SQLite databases",
                onClick = { launchActivity(context, "in.startv.hspatcher.DbEditorActivity") }
            )

            ToolItem(
                icon = Icons.Outlined.Search,
                title = "Local Network Tools",
                description = "Wi-Fi server, FTP server and QR scan/connect utilities",
                onClick = { launchActivity(context, "com.rk.hspatcher.LocalNetworkToolsActivity") }
            )
        }
    }

    override fun getName(): String = "HSPatcher"

    override fun getIcon(): com.rk.icons.Icon =
        com.rk.icons.Icon.VectorIcon(Icons.Outlined.Build)

    private fun launchActivity(context: Context, className: String) {
        val intent = Intent()
        intent.setClassName(context.packageName, className)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        context.startActivity(intent)
    }

    private fun launchJarWorkflow(context: Context, className: String) {
        val intent = HSPatcherWorkspaceIntegration.createDirectJarWorkflowIntent(context, className)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        context.startActivity(intent)
    }
}

@Composable
private fun ToolItem(
    icon: ImageVector,
    title: String,
    description: String,
    onClick: () -> Unit
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 4.dp)
            .clickable(onClick = onClick)
    ) {
        Row(
            modifier = Modifier.padding(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Icon(
                imageVector = icon,
                contentDescription = null,
                modifier = Modifier.size(24.dp),
                tint = MaterialTheme.colorScheme.primary
            )
            Spacer(modifier = Modifier.width(16.dp))
            Column {
                Text(text = title, style = MaterialTheme.typography.bodyLarge)
                Text(
                    text = description,
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        }
    }
}
