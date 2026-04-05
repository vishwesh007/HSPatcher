package com.rk.activities.main

import androidx.activity.compose.BackHandler
import androidx.compose.animation.core.spring
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.isImeVisible
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.DrawerState
import androidx.compose.material3.DrawerValue
import androidx.compose.material3.Scaffold
import androidx.compose.material3.ScaffoldDefaults
import androidx.compose.material3.SnackbarHost
import androidx.compose.material3.SnackbarHostState
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.rememberDrawerState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.remember
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.getValue
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.input.nestedscroll.nestedScroll
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.platform.rememberNestedScrollInteropConnection
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsCompat
import androidx.lifecycle.viewmodel.compose.viewModel
import com.rk.components.ResponsiveDrawer
import com.rk.filetree.DrawerContent
import com.rk.filetree.DrawerPersistence
import com.rk.filetree.FileTreeViewModel
import com.rk.filetree.createServices
import com.rk.filetree.isLoading
import com.rk.git.GitViewModel
import com.rk.resources.getString
import com.rk.resources.strings
import com.rk.search.SearchViewModel
import com.rk.settings.Settings
import com.rk.tabs.editor.EditorTab
import com.rk.theme.XedTheme
import com.rk.utils.dialog
import java.lang.ref.WeakReference
import kotlinx.coroutines.launch

var fileTreeViewModel = WeakReference<FileTreeViewModel?>(null)
var gitViewModel = WeakReference<GitViewModel?>(null)
var searchViewModel = WeakReference<SearchViewModel?>(null)

var snackbarHostStateRef: WeakReference<SnackbarHostState?> = WeakReference(null)
var drawerStateRef: WeakReference<DrawerState?> = WeakReference(null)

@OptIn(ExperimentalLayoutApi::class)
@Composable
fun MainActivity.MainContentHost(
    gitViewModel: GitViewModel = viewModel(),
    fileTreeViewModel: FileTreeViewModel = viewModel(),
    searchViewModel: SearchViewModel = viewModel(),
) {
    com.rk.activities.main.fileTreeViewModel = WeakReference(fileTreeViewModel)
    com.rk.activities.main.gitViewModel = WeakReference(gitViewModel)
    com.rk.activities.main.searchViewModel = WeakReference(searchViewModel)

    XedTheme {
        Surface(modifier = Modifier.fillMaxSize()) {
            val drawerState = rememberDrawerState(initialValue = DrawerValue.Closed)
            val snackbarHostState = remember { SnackbarHostState() }
            var drawerStateRestored by remember { mutableStateOf(false) }
            var servicesCreated by remember { mutableStateOf(false) }

            LaunchedEffect(drawerState) { drawerStateRef = WeakReference(drawerState) }
            LaunchedEffect(snackbarHostState) { snackbarHostStateRef = WeakReference(snackbarHostState) }

            LaunchedEffect(drawerState.isOpen) {
                val viewModel = MainActivity.instance?.viewModel ?: return@LaunchedEffect
                if (drawerState.isOpen) {
                    viewModel.tabManager.currentTab?.let {
                        if (it is EditorTab) {
                            it.editorState.editor.get()?.clearFocus()
                        }
                    }
                } else if (drawerState.isClosed) {
                    viewModel.tabManager.currentTab?.let {
                        if (it is EditorTab) {
                            it.editorState.editor.get()?.apply {
                                requestFocus()
                                requestFocusFromTouch()
                            }
                        }
                    }
                }
            }

            LaunchedEffect(Settings.fullscreen) {
                val controller = WindowCompat.getInsetsController(window, window.decorView)
                val statusBarType = WindowInsetsCompat.Type.statusBars()
                if (Settings.fullscreen) {
                    controller.hide(statusBarType)
                } else {
                    controller.show(statusBarType)
                }
            }

            val keyboardShown = WindowInsets.isImeVisible
            LaunchedEffect(keyboardShown, Settings.smart_toolbar) {
                viewModel.showTopBar = !Settings.smart_toolbar || !keyboardShown
            }

            val scope = rememberCoroutineScope()

            LaunchedEffect(Unit) { isLoading = false }

            LaunchedEffect(drawerState.currentValue) {
                if (!drawerStateRestored && drawerState.currentValue != DrawerValue.Closed) {
                    isLoading = true
                    if (!servicesCreated) {
                        createServices()
                        servicesCreated = true
                    }
                    DrawerPersistence.restoreState()
                    drawerStateRestored = true
                    isLoading = false
                }
            }

            BackHandler {
                if (drawerState.isOpen) {
                    scope.launch { drawerState.close() }
                } else if (viewModel.tabs.isNotEmpty()) {
                    dialog(
                        title = strings.attention.getString(),
                        msg = strings.confirm_exit.getString(),
                        onCancel = {},
                        onOk = { finish() },
                        okString = strings.exit,
                    )
                } else {
                    finish()
                }
            }

            val density = LocalDensity.current
            var accumulator = 0f
            val softThreshold = with(density) { 50.dp.toPx() }
            val hardThreshold = with(density) { 100.dp.toPx() }

            val snackbarBottomPadding =
                if (Settings.show_extra_keys) {
                    if (Settings.split_extra_keys) 88.dp else 48.dp
                } else 0.dp

            val mainContent: @Composable () -> Unit = {
                Scaffold(
                    contentWindowInsets =
                        if (Settings.fullscreen) WindowInsets() else ScaffoldDefaults.contentWindowInsets,
                    snackbarHost = {
                        SnackbarHost(
                            hostState = snackbarHostState,
                            modifier = Modifier.padding(bottom = snackbarBottomPadding),
                        )
                    },
                    modifier = Modifier.nestedScroll(rememberNestedScrollInteropConnection()),
                    topBar = {
                        XedTopBar(
                            drawerState = drawerState,
                            viewModel = viewModel,
                            fullScreen = Settings.fullscreen,
                            onDrag = { dragAmount ->
                                accumulator += dragAmount

                                viewModel.isDraggingPalette = true

                                scope.launch {
                                    val newProgress = (accumulator / hardThreshold).coerceIn(0f, 1f)
                                    viewModel.draggingPaletteProgress.snapTo(newProgress)
                                }
                            },
                            onDragEnd = {
                                val shouldOpen = accumulator >= softThreshold
                                scope.launch {
                                    viewModel.isDraggingPalette = shouldOpen
                                    viewModel.draggingPaletteProgress.animateTo(
                                        if (shouldOpen) 1f else 0f,
                                        animationSpec = spring(stiffness = 800f),
                                    )
                                }
                                accumulator = 0f
                            },
                        )
                    },
                ) { innerPadding ->
                    MainContent(
                        innerPadding = innerPadding,
                        drawerState = drawerState,
                        mainViewModel = viewModel,
                        fileTreeViewModel = fileTreeViewModel,
                    )
                }
            }

            val sheetContent: @Composable ColumnScope.() -> Unit = {
                DrawerContent(Settings.fullscreen)
            }

            LaunchedEffect(Unit) {
                if (!Settings.shown_walkthrough) {
                    AppWalkthroughController.show()
                }
            }

            Box(modifier = Modifier.fillMaxSize()) {
                ResponsiveDrawer(
                    drawerState = drawerState,
                    fullscreen = Settings.fullscreen,
                    mainContent = mainContent,
                    sheetContent = sheetContent,
                )

                ApkImportProgressController.state?.let { importState ->
                    ApkImportProgressBanner(
                        state = importState,
                        modifier = Modifier
                            .align(Alignment.BottomCenter)
                            .padding(start = 16.dp, end = 16.dp, bottom = 28.dp),
                    )
                }

                AppWalkthroughOverlay(
                    visible = AppWalkthroughController.isVisible,
                    onDismiss = { AppWalkthroughController.dismiss(markShown = true) },
                )
            }
        }
    }
}

@Composable
private fun ApkImportProgressBanner(state: ApkImportProgressState, modifier: Modifier = Modifier) {
    Card(
        modifier = modifier.fillMaxWidth(),
        shape = RoundedCornerShape(18.dp),
        colors = CardDefaults.cardColors(containerColor = androidx.compose.material3.MaterialTheme.colorScheme.surface.copy(alpha = 0.96f)),
        elevation = CardDefaults.cardElevation(defaultElevation = 4.dp),
    ) {
        androidx.compose.foundation.layout.Column(
            modifier = Modifier.padding(horizontal = 16.dp, vertical = 14.dp),
        ) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                if (state.progress == null) {
                    CircularProgressIndicator(modifier = Modifier.size(20.dp), strokeWidth = 2.5.dp)
                } else {
                    Box(
                        modifier = Modifier
                            .size(20.dp)
                            .background(
                                color = androidx.compose.material3.MaterialTheme.colorScheme.primaryContainer,
                                shape = RoundedCornerShape(10.dp),
                            ),
                        contentAlignment = Alignment.Center,
                    ) {
                        Text(
                            text = "${(state.progress * 100).toInt()}%",
                            style = androidx.compose.material3.MaterialTheme.typography.labelSmall,
                            color = androidx.compose.material3.MaterialTheme.colorScheme.onPrimaryContainer,
                        )
                    }
                }
                Spacer(modifier = Modifier.width(12.dp))
                androidx.compose.foundation.layout.Column(modifier = Modifier.weight(1f)) {
                    Text(
                        text = state.title,
                        style = androidx.compose.material3.MaterialTheme.typography.titleSmall,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis,
                    )
                    Text(
                        text = state.elapsedLabel,
                        style = androidx.compose.material3.MaterialTheme.typography.labelMedium,
                        color = androidx.compose.material3.MaterialTheme.colorScheme.onSurfaceVariant,
                    )
                }
            }
            Spacer(modifier = Modifier.size(10.dp))
            Text(text = state.message, style = androidx.compose.material3.MaterialTheme.typography.bodyMedium)
            Spacer(modifier = Modifier.size(6.dp))
            Text(
                text = state.detail,
                style = androidx.compose.material3.MaterialTheme.typography.bodySmall,
                color = androidx.compose.material3.MaterialTheme.colorScheme.onSurfaceVariant,
                maxLines = 2,
                overflow = TextOverflow.Ellipsis,
            )
            Spacer(modifier = Modifier.size(12.dp))
            if (state.progress == null) {
                LinearProgressIndicator(modifier = Modifier.fillMaxWidth())
            } else {
                LinearProgressIndicator(progress = { state.progress }, modifier = Modifier.fillMaxWidth())
            }
        }
    }
}
