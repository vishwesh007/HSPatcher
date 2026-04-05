package com.rk.search

import android.app.ActivityManager
import android.content.Context
import androidx.compose.runtime.derivedStateOf
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateMapOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.compose.runtime.snapshots.SnapshotStateList
import androidx.compose.runtime.snapshots.Snapshot
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import androidx.room.withTransaction
import com.rk.activities.main.MainViewModel
import com.rk.file.FileObject
import com.rk.file.toFileWrapper
import com.rk.settings.Preference
import com.rk.settings.Settings
import com.rk.tabs.editor.EditorTab
import com.rk.utils.hasBinaryChars
import com.rk.utils.isBinaryExtension
import com.rk.utils.parseExtensions
import java.io.File
import java.io.InputStreamReader
import java.nio.charset.Charset
import java.util.concurrent.atomic.AtomicInteger
import java.util.concurrent.atomic.AtomicLong
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.coroutineScope
import kotlinx.coroutines.currentCoroutineContext
import kotlinx.coroutines.delay
import kotlinx.coroutines.ensureActive
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.channelFlow
import kotlinx.coroutines.flow.flowOn
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import android.util.Log

private const val TAG = "SearchTiming"

class SearchViewModel : ViewModel() {
    enum class SearchBackend {
        IDLE,
        RAM,
        INDEX,
        DISK,
    }

    private var isIndexing = mutableStateMapOf<FileObject, Boolean>()
    private var indexJob: Job? = null
    private val discoveredCounter = AtomicInteger(0)
    private val scannedCounter = AtomicInteger(0)

    // File search dialog
    var fileSearchQuery by mutableStateOf("")
    var isSearchingFiles by mutableStateOf(false)
    var fileSearchResults by mutableStateOf<List<FileMeta>>(emptyList())
    private var fileSearchJob: Job? = null

    // Code search dialog
    var showFileMaskDialog by mutableStateOf(false)
    var fileMaskText by mutableStateOf(Settings.file_mask)
    var fileMask = derivedStateOf { parseExtensions(fileMaskText) }
    private val excluder by derivedStateOf { GlobExcluder(Settings.excluded_files_search) }

    var isSearchingCode by mutableStateOf(false)
    var totalCodeSearchResults by mutableIntStateOf(0)
    var discoveredCodeSearchFiles by mutableIntStateOf(0)
    var scannedCodeSearchFiles by mutableIntStateOf(0)
    var isPreparingInMemoryProject by mutableStateOf(false)
    var inMemoryProjectLoadedBytes by mutableStateOf(0L)
    var inMemoryProjectTotalBytes by mutableStateOf(0L)
    var useInMemoryProject by mutableStateOf(false)
    var activeSearchBackend by mutableStateOf(SearchBackend.IDLE)
    var firstResultLatencyMs by mutableStateOf<Long?>(null)
    var searchElapsedMs by mutableStateOf<Long?>(null)
    val codeSearchResultsOrder = mutableStateListOf<FileObject>()
    val codeSearchResults = mutableStateMapOf<FileObject, SnapshotStateList<CodeItem>>()
    private var codeSearchJob: Job? = null
    private var inMemoryProjectSnapshot: InMemoryProjectSnapshot? = null

    var codeSearchQuery by mutableStateOf("")
    var codeReplaceQuery by mutableStateOf("")
    var showOptionsMenu by mutableStateOf(false)
    var ignoreCase by mutableStateOf(true)
    var isReplaceShown by mutableStateOf(false)
        private set

    companion object {
        // NOTE: Occurrence that are between the borders of two chunks won't be found, this is a known issue
        private const val MAX_CHUNK_SIZE = 1_000_000 // 1 MB limit per column to avoid CursorWindow crash
        const val MAX_CODE_RESULTS = 10_000 // Max amount of code search results to show in UI
        private const val MAX_FILE_SIZE_SEARCH = 10_000_000 // Max size for code search (10 MB)
        private const val CODE_BATCH_SIZE = 5_000 // Insert code mid-traversal in chunks to avoid OOM
        private const val MIN_SEARCH_PARALLELISM = 4
        private const val MAX_SEARCH_PARALLELISM = 16
        private const val SEARCH_RESULT_UI_BATCH_SIZE = 24
        private const val SEARCH_RESULT_UI_FLUSH_MS = 50L
        private const val MAX_IN_MEMORY_PROJECT_BYTES = 1024L * 1024L * 1024L
    }

    private fun searchParallelism(): Int {
        val availableProcessors = Runtime.getRuntime().availableProcessors().coerceAtLeast(1)
        return (availableProcessors * 2).coerceIn(MIN_SEARCH_PARALLELISM, MAX_SEARCH_PARALLELISM)
    }

    private fun searchDispatcher() = Dispatchers.IO.limitedParallelism(searchParallelism())

    fun cleanupJobs(projectRoot: FileObject) {
        fileSearchJob?.cancel()
        fileSearchJob = null

        codeSearchJob?.cancel()
        codeSearchJob = null

        indexJob?.cancel()
        indexJob = null
        isIndexing.remove(projectRoot)
    }

    override fun onCleared() {
        invalidateInMemoryProject()
        super.onCleared()
    }

    fun matchesFileMask(fileExt: String): Boolean {
        if (fileMask.value.isEmpty()) return true
        return fileMask.value.any { it == fileExt }
    }

    fun cancelFileSearch() {
        fileSearchJob?.cancel()
        fileSearchJob = null
        isSearchingFiles = false
    }

    fun launchFileSearch(context: Context, projectRoot: FileObject) {
        cancelFileSearch()

        isSearchingFiles = true
        fileSearchJob =
            viewModelScope.launch(searchDispatcher()) {
                val startedAt = System.currentTimeMillis()
                withContext(Dispatchers.Main.immediate) {
                    searchElapsedMs = null
                    firstResultLatencyMs = null
                }

                val results =
                    searchFileName(
                        context = context,
                        projectRoot = projectRoot,
                        query = fileSearchQuery,
                        useIndex =
                            Preference.getBoolean(
                                "enable_indexing_${projectRoot.hashCode()}",
                                Settings.always_index_projects,
                            ),
                    )
                withContext(Dispatchers.Main.immediate) {
                    fileSearchResults = results
                    searchElapsedMs = System.currentTimeMillis() - startedAt
                    isSearchingFiles = false
                }
            }
    }

    fun warmInMemoryProject(context: Context, projectRoot: FileObject) {
        useInMemoryProject = true
        if (isPreparingInMemoryProject) return

        val existingSnapshot = inMemoryProjectSnapshot
        if (existingSnapshot != null && existingSnapshot.rootPath == projectRoot.getAbsolutePath()) return

        viewModelScope.launch(searchDispatcher()) {
            prepareInMemoryProjectIfEligible(context, projectRoot)
        }
    }

    fun disableInMemoryProject(projectRoot: FileObject) {
        useInMemoryProject = false
        invalidateInMemoryProject(projectRoot)
    }

    /** Cancels any running search */
    fun cancelCodeSearch() {
        codeSearchJob?.cancel()
        codeSearchJob = null

        Snapshot.withMutableSnapshot {
            totalCodeSearchResults = 0
            discoveredCodeSearchFiles = discoveredCounter.get()
            scannedCodeSearchFiles = scannedCounter.get()
            codeSearchResults.clear()
            codeSearchResultsOrder.clear()
            isSearchingCode = false
            activeSearchBackend = SearchBackend.IDLE
            firstResultLatencyMs = null
            searchElapsedMs = null
        }
    }

    /** Executes a search */
    fun launchCodeSearch(context: Context, mainViewModel: MainViewModel, projectRoot: FileObject) {
        cancelCodeSearch()

        if (codeSearchQuery.isBlank()) {
            totalCodeSearchResults = 0
            codeSearchResults.clear()
            return
        }

        codeSearchJob =
            viewModelScope.launch(searchDispatcher()) {
                val startedAt = System.currentTimeMillis()
                discoveredCounter.set(0)
                scannedCounter.set(0)
                withContext(Dispatchers.Main.immediate) {
                    Snapshot.withMutableSnapshot {
                        isSearchingCode = true
                        discoveredCodeSearchFiles = 0
                        scannedCodeSearchFiles = 0
                        firstResultLatencyMs = null
                        searchElapsedMs = null
                    }
                }

                val progressJob =
                    launch {
                        while (true) {
                            withContext(Dispatchers.Main.immediate) {
                                Snapshot.withMutableSnapshot {
                                    discoveredCodeSearchFiles = discoveredCounter.get()
                                    scannedCodeSearchFiles = scannedCounter.get()
                                }
                            }
                            delay(75)
                        }
                    }

                val pendingResults = ArrayList<CodeItem>(SEARCH_RESULT_UI_BATCH_SIZE)
                var lastFlushAt = 0L

                searchCode(
                        context = context,
                        projectRoot = projectRoot,
                        query = codeSearchQuery,
                        mainViewModel = mainViewModel,
                        useIndex =
                            Preference.getBoolean(
                                "enable_indexing_${projectRoot.hashCode()}",
                                Settings.always_index_projects,
                            ),
                    )
                    .collect {
                        if (firstResultLatencyMs == null) {
                            val latency = System.currentTimeMillis() - startedAt
                            Log.d(TAG, "[$activeSearchBackend] first-result: ${latency}ms")
                            withContext(Dispatchers.Main.immediate) {
                                Snapshot.withMutableSnapshot {
                                    firstResultLatencyMs = latency
                                }
                            }
                        }
                        pendingResults.add(it)

                        val now = System.currentTimeMillis()
                        val shouldFlush =
                            pendingResults.size == 1 ||
                                pendingResults.size >= SEARCH_RESULT_UI_BATCH_SIZE ||
                                (now - lastFlushAt) >= SEARCH_RESULT_UI_FLUSH_MS
                        if (shouldFlush) {
                            lastFlushAt = now
                            val reachedLimit = withContext(Dispatchers.Main.immediate) {
                                flushCodeSearchResults(pendingResults)
                            }
                            if (reachedLimit) {
                                withContext(Dispatchers.Main.immediate) {
                                    Snapshot.withMutableSnapshot { isSearchingCode = false }
                                }
                                codeSearchJob?.cancel()
                            }
                        }
                    }

                progressJob.cancel()
                withContext(Dispatchers.Main.immediate) {
                    flushCodeSearchResults(pendingResults)
                    Snapshot.withMutableSnapshot {
                        discoveredCodeSearchFiles = discoveredCounter.get()
                        scannedCodeSearchFiles = scannedCounter.get()
                        searchElapsedMs = System.currentTimeMillis() - startedAt
                        Log.d(TAG, "[$activeSearchBackend] total: ${searchElapsedMs}ms, results: ${codeSearchResults.size}")
                        isSearchingCode = false
                    }
                }
            }
    }

    private fun flushCodeSearchResults(pendingResults: MutableList<CodeItem>): Boolean {
        if (pendingResults.isEmpty()) return false

        var reachedLimit = false
        Snapshot.withMutableSnapshot {
            pendingResults.forEach { item ->
                if (totalCodeSearchResults >= MAX_CODE_RESULTS) {
                    reachedLimit = true
                    return@forEach
                }

                totalCodeSearchResults++
                if (!codeSearchResults.containsKey(item.file)) {
                    codeSearchResultsOrder.add(item.file)
                }
                val fileList = codeSearchResults.getOrPut(item.file) { mutableStateListOf() }
                fileList.add(item)
            }
        }

        pendingResults.clear()
        return reachedLimit
    }

    fun toggleReplaceShown() {
        isReplaceShown = !isReplaceShown
    }

    suspend fun replaceIn(mainViewModel: MainViewModel, codeItem: CodeItem) {
        withContext(Dispatchers.IO) {
            val lineIndex = codeItem.line
            val startCol = codeItem.column
            val diff = codeItem.snippet.highlight.endIndex - codeItem.snippet.highlight.startIndex
            val endCol = codeItem.column + diff

            if (codeItem.isOpen) {
                val tab =
                    mainViewModel.tabs.filterIsInstance<EditorTab>().find { tab -> tab.file == codeItem.file }
                        ?: return@withContext
                val editor = tab.editorState.editor.get() ?: return@withContext

                withContext(Dispatchers.Main) {
                    editor.text.replace(lineIndex, startCol, lineIndex, endCol, codeReplaceQuery)
                }
            } else {
                val charset = Charset.forName(Settings.encoding)
                val content = readTextForReplace(codeItem.file, charset) ?: return@withContext
                val lineOffsets = computeLineStartOffsets(content)
                val startOffset = absoluteOffsetFor(codeItem, lineOffsets, content.length)
                val updatedContent =
                    StringBuilder(content).apply {
                        replace(startOffset, (startOffset + diff).coerceAtMost(length), codeReplaceQuery)
                    }
                codeItem.file.writeText(updatedContent.toString(), charset)
                updateCachedFileContent(codeItem.file, updatedContent.toString())
            }
        }
    }

    suspend fun replaceAllIn(mainViewModel: MainViewModel, codeItems: List<CodeItem>) {
        withContext(Dispatchers.IO) {
            codeItems.groupBy { it.file }.values.forEach { itemsForFile ->
                replaceAllInSingleFile(mainViewModel, itemsForFile)
            }
        }
    }

    private suspend fun replaceAllInSingleFile(mainViewModel: MainViewModel, codeItems: List<CodeItem>) {
        if (codeItems.isEmpty()) return

        val sortedItems =
            codeItems.sortedWith(compareByDescending<CodeItem> { it.line }.thenByDescending { it.column })
        val sampleItem = sortedItems.first()

        if (sampleItem.isOpen) {
            val tab =
                mainViewModel.tabs.filterIsInstance<EditorTab>().find { tab -> tab.file == sampleItem.file }
                    ?: return
            val editor = tab.editorState.editor.get() ?: return

            withContext(Dispatchers.Main) {
                sortedItems.forEach { codeItem ->
                    val startCol = codeItem.column
                    val endCol = startCol + matchLength(codeItem)
                    editor.text.replace(codeItem.line, startCol, codeItem.line, endCol, codeReplaceQuery)
                }
            }
            return
        }

        val charset = Charset.forName(Settings.encoding)
        val content = readTextForReplace(sampleItem.file, charset) ?: return
        val lineOffsets = computeLineStartOffsets(content)
        val builder = StringBuilder(content)

        sortedItems.forEach { codeItem ->
            val startOffset = absoluteOffsetFor(codeItem, lineOffsets, builder.length)
            val endOffset = (startOffset + matchLength(codeItem)).coerceAtMost(builder.length)
            builder.replace(startOffset, endOffset, codeReplaceQuery)
        }

        sampleItem.file.writeText(builder.toString(), charset)
        updateCachedFileContent(sampleItem.file, builder.toString())
    }

    private suspend fun readTextForReplace(file: FileObject, charset: Charset): String? {
        val snapshot = inMemoryProjectSnapshot
        val cached = snapshot?.searchableFilesByPath?.get(file.getAbsolutePath())
        return cached?.content ?: file.readText(charset)
    }

    private fun matchLength(codeItem: CodeItem): Int {
        return codeItem.snippet.highlight.endIndex - codeItem.snippet.highlight.startIndex
    }

    private fun computeLineStartOffsets(content: String): IntArray {
        val offsets = ArrayList<Int>()
        offsets.add(0)

        var index = 0
        while (index < content.length) {
            when (content[index]) {
                '\n' -> offsets.add(index + 1)
                '\r' -> {
                    if (index + 1 < content.length && content[index + 1] == '\n') {
                        offsets.add(index + 2)
                        index++
                    } else {
                        offsets.add(index + 1)
                    }
                }
            }
            index++
        }

        return offsets.toIntArray()
    }

    private fun absoluteOffsetFor(codeItem: CodeItem, lineOffsets: IntArray, contentLength: Int): Int {
        val lineStart = lineOffsets.getOrElse(codeItem.line) { contentLength }
        return (lineStart + codeItem.column).coerceAtMost(contentLength)
    }

    fun isIndexing(projectRoot: FileObject): Boolean {
        return isIndexing[projectRoot] ?: false
    }

    data class IndexingStats(val totalFiles: Int, val databaseSize: Long)

    suspend fun getStats(context: Context, projectRoot: FileObject): IndexingStats {
        val totalFiles = getDatabase(context, projectRoot).fileMetaDao().getCount()
        val databaseSize = IndexDatabase.getDatabaseSize(context, projectRoot)
        return IndexingStats(totalFiles, databaseSize)
    }

    private fun getDatabase(context: Context, projectRoot: FileObject): IndexDatabase {
        return IndexDatabase.getDatabase(context, projectRoot)
    }

    suspend fun searchFileName(
        context: Context,
        projectRoot: FileObject,
        query: String,
        useIndex: Boolean = true,
    ): List<FileMeta> {
        val snapshot =
            if (useInMemoryProject) {
                prepareInMemoryProjectIfEligible(context, projectRoot)
            } else {
                null
            }
        if (snapshot != null) {
            activeSearchBackend = SearchBackend.RAM
            return snapshot.fileMetas.filter { it.fileName.contains(query, ignoreCase = true) }
        }

        return if (useIndex) {
            activeSearchBackend = SearchBackend.INDEX
            searchFileNameWithIndex(context, projectRoot, query)
        } else {
            activeSearchBackend = SearchBackend.DISK
            searchFileNameWithoutIndex(projectRoot, query)
        }
    }

    private suspend fun searchFileNameWithIndex(
        context: Context,
        projectRoot: FileObject,
        query: String,
    ): List<FileMeta> = getDatabase(context, projectRoot).fileMetaDao().search(query)

    private suspend fun searchFileNameWithoutIndex(projectRoot: FileObject, query: String): List<FileMeta> {
        val results = java.util.concurrent.CopyOnWriteArrayList<FileMeta>()
        val fileChannel = Channel<FileObject>(256)
        val workerDispatcher = searchDispatcher()

        coroutineScope {
            launch {
                streamAllFileObjects(projectRoot) { item -> fileChannel.send(item) }
                fileChannel.close()
            }

            repeat(searchParallelism()) {
                launch(workerDispatcher) {
                    for (file in fileChannel) {
                        currentCoroutineContext().ensureActive()
                        if (file.getName().contains(query, ignoreCase = true)) {
                            results.add(
                                FileMeta(
                                    path = file.getAbsolutePath(),
                                    fileName = file.getName(),
                                    lastModified = 0,
                                    size = 0,
                                )
                            )
                        }
                    }
                }
            }
        }
        return results
    }

    /** Streams file objects for parallel file-name search so workers can start immediately. */
    private suspend fun streamAllFileObjects(
        parent: FileObject,
        sendFile: suspend (FileObject) -> Unit,
    ) {
        val childFiles = parent.listFiles()
        for (file in childFiles) {
            val path = file.getAbsolutePath()
            if (excluder.isExcluded(path)) continue

            val isHidden = file.getName().startsWith(".")
            if (isHidden && !Settings.show_hidden_files_search) continue

            sendFile(file)
            if (file.isDirectory()) {
                streamAllFileObjects(file, sendFile)
            }
        }
    }

    private fun findAllIndices(text: String, matcher: FastLiteralMatcher): List<Int> {
        return matcher.findAll(text)
    }

    fun searchCode(
        context: Context,
        mainViewModel: MainViewModel,
        projectRoot: FileObject,
        query: String,
        useIndex: Boolean = true,
    ): Flow<CodeItem> =
        channelFlow {
                val matcher = FastLiteralMatcher.compile(query, ignoreCase)
                val inMemorySnapshot =
                    if (useInMemoryProject) {
                        prepareInMemoryProjectIfEligible(context, projectRoot)
                    } else {
                        null
                    }

                // Search in opened tabs
                val openedEditorTabs = mainViewModel.tabs.mapNotNull { it as? EditorTab }
                val openPaths = openedEditorTabs.map { it.file.getAbsolutePath() }.toSet()

                for (tab in openedEditorTabs) {
                    val fileExt = tab.file.getExtension()
                    if (!matchesFileMask(fileExt)) continue

                    val editor = tab.editorState.editor.get()
                    val content = editor?.text
                    if (content != null) {
                        val lineCount = content.lineCount
                        for (lineIndex in 0 until lineCount) {
                            val line = content.getLine(lineIndex).toString()
                            val indices = findAllIndices(line, matcher)
                            for (index in indices) {
                                currentCoroutineContext().ensureActive()
                                send(
                                    createCodeItem(
                                        context = context,
                                        mainViewModel = mainViewModel,
                                        text = line,
                                        charIndex = index,
                                        query = query,
                                        file = tab.file,
                                        projectRoot = projectRoot,
                                        lineIndex = lineIndex,
                                        isOpen = true,
                                    )
                                )
                            }
                        }
                    }
                }

                // Search through other files
                if (inMemorySnapshot != null) {
                    postSearchBackend(SearchBackend.RAM)
                    searchCodeInMemory(
                        context = context,
                        mainViewModel = mainViewModel,
                        projectRoot = projectRoot,
                        query = query,
                        matcher = matcher,
                        openPaths = openPaths,
                        send = ::send,
                    )
                } else if (!useIndex) {
                    postSearchBackend(SearchBackend.DISK)
                    searchCodeWithoutIndex(
                        context = context,
                        mainViewModel = mainViewModel,
                        parent = projectRoot,
                        projectRoot = projectRoot,
                        query = query,
                        matcher = matcher,
                        openPaths = openPaths,
                        send = ::send,
                    )
                } else {
                    postSearchBackend(SearchBackend.INDEX)
                    searchCodeWithIndex(
                        context = context,
                        mainViewModel = mainViewModel,
                        projectRoot = projectRoot,
                        query = query,
                        matcher = matcher,
                        openPaths = openPaths,
                        send = ::send,
                    )
                }
            }
            .flowOn(Dispatchers.IO)

    private suspend fun searchCodeWithIndex(
        context: Context,
        mainViewModel: MainViewModel,
        projectRoot: FileObject,
        query: String,
        matcher: FastLiteralMatcher,
        openPaths: Set<String>,
        send: suspend (CodeItem) -> Unit,
    ) {
        var resultLimit = 5
        var offset = 0

        val dao = getDatabase(context, projectRoot).codeIndexDao()

        while (true) {
            val results =
                if (ignoreCase) {
                    dao.search(query, resultLimit, offset)
                } else {
                    dao.searchCaseSensitive(query, resultLimit, offset)
                }
            if (results.isEmpty()) break

            for (result in results) {
                if (result.path in openPaths) continue

                val file = File(result.path).toFileWrapper()
                val fileExt = file.getExtension()
                if (!matchesFileMask(fileExt)) continue

                val indices = findAllIndices(result.content, matcher)
                for (index in indices) {
                    val absoluteCharIndex = result.chunkStart + index

                    currentCoroutineContext().ensureActive()
                    send(
                        createCodeItem(
                            context = context,
                            mainViewModel = mainViewModel,
                            text = result.content,
                            charIndex = absoluteCharIndex,
                            query = query,
                            file = file,
                            projectRoot = projectRoot,
                            lineIndex = result.lineNumber,
                        )
                    )
                }
            }
            offset += resultLimit
            resultLimit = 20
        }
    }

    private suspend fun searchCodeWithoutIndex(
        context: Context,
        mainViewModel: MainViewModel,
        parent: FileObject,
        projectRoot: FileObject,
        query: String,
        matcher: FastLiteralMatcher,
        openPaths: Set<String>,
        send: suspend (CodeItem) -> Unit,
        isResultHidden: Boolean = false,
    ) {
        val snapshot =
            if (useInMemoryProject) {
                prepareInMemoryProjectIfEligible(context, projectRoot)
            } else {
                null
            }
        if (snapshot != null) {
            searchCodeInMemory(
                context = context,
                mainViewModel = mainViewModel,
                projectRoot = projectRoot,
                query = query,
                matcher = matcher,
                openPaths = openPaths,
                send = send,
            )
            return
        }

        val fileChannel = Channel<FileObject>(256)
        val resultCount = AtomicInteger(0)
        val workerCount = searchParallelism()
        val workerDispatcher = searchDispatcher()

        coroutineScope {
            launch {
                streamSearchableFiles(parent, openPaths, isResultHidden) { file ->
                    if (resultCount.get() >= MAX_CODE_RESULTS) return@streamSearchableFiles
                    discoveredCounter.incrementAndGet()
                    fileChannel.send(file)
                }
                fileChannel.close()
            }

            repeat(workerCount) {
                launch(workerDispatcher) {
                    val charset = Charset.forName(Settings.encoding)
                    for (file in fileChannel) {
                        if (resultCount.get() >= MAX_CODE_RESULTS) break
                        currentCoroutineContext().ensureActive()
                        searchSingleFile(context, mainViewModel, file, projectRoot, query, matcher, charset, resultCount, send)
                        scannedCounter.incrementAndGet()
                    }
                }
            }
        }
    }

    private suspend fun searchCodeInMemory(
        context: Context,
        mainViewModel: MainViewModel,
        projectRoot: FileObject,
        query: String,
        matcher: FastLiteralMatcher,
        openPaths: Set<String>,
        send: suspend (CodeItem) -> Unit,
    ) {
        val snapshot = inMemoryProjectSnapshot ?: return
        val resultCount = AtomicInteger(0)
        val workerDispatcher = searchDispatcher()

        coroutineScope {
            val files =
                snapshot.searchableFiles.filter { cachedFile ->
                    cachedFile.path !in openPaths && matchesFileMask(cachedFile.file.getExtension())
                }

            discoveredCounter.set(files.size)
            scannedCounter.set(0)

            val fileChannel = Channel<CachedSearchFile>(256)
            launch {
                files.forEach { cachedFile -> fileChannel.send(cachedFile) }
                fileChannel.close()
            }

            repeat(searchParallelism()) {
                launch(workerDispatcher) {
                    for (cachedFile in fileChannel) {
                        if (resultCount.get() >= MAX_CODE_RESULTS) break
                        currentCoroutineContext().ensureActive()
                        searchCachedFile(
                            context = context,
                            mainViewModel = mainViewModel,
                            cachedFile = cachedFile,
                            projectRoot = projectRoot,
                            query = query,
                            matcher = matcher,
                            resultCount = resultCount,
                            usePlainSnippet = true,
                            send = send,
                        )
                        scannedCounter.incrementAndGet()
                    }
                }
            }
        }
    }

    private suspend fun searchCachedFile(
        context: Context,
        mainViewModel: MainViewModel,
        cachedFile: CachedSearchFile,
        projectRoot: FileObject,
        query: String,
        matcher: FastLiteralMatcher,
        resultCount: AtomicInteger,
        usePlainSnippet: Boolean = false,
        send: suspend (CodeItem) -> Unit,
    ) {
        val content = cachedFile.content
        val lineOffsets = cachedFile.getLineStartOffsets()

        matcher.forEachMatch(content) { matchIndex ->
            if (resultCount.incrementAndGet() > MAX_CODE_RESULTS) return@forEachMatch false

            val lineIndex = findLineIndex(lineOffsets, matchIndex)
            val lineStart = lineOffsets[lineIndex]
            val lineEnd = findLineEndExclusive(content, lineOffsets, lineIndex)
            val lineText = content.substring(lineStart, lineEnd)
            val column = matchIndex - lineStart

            currentCoroutineContext().ensureActive()
            send(
                createCodeItem(
                    context = context,
                    mainViewModel = mainViewModel,
                    text = lineText,
                    charIndex = column,
                    query = query,
                    file = cachedFile.file,
                    projectRoot = projectRoot,
                    lineIndex = lineIndex,
                    usePlainSnippet = usePlainSnippet,
                )
            )
            true
        }
    }

    private fun findLineIndex(lineOffsets: IntArray, absoluteCharIndex: Int): Int {
        val binarySearchIndex = lineOffsets.binarySearch(absoluteCharIndex)
        return if (binarySearchIndex >= 0) binarySearchIndex else (-binarySearchIndex - 2).coerceAtLeast(0)
    }

    private fun findLineEndExclusive(content: String, lineOffsets: IntArray, lineIndex: Int): Int {
        val lineStart = lineOffsets[lineIndex]
        var lineEnd = if (lineIndex + 1 < lineOffsets.size) lineOffsets[lineIndex + 1] else content.length
        while (lineEnd > lineStart && (content[lineEnd - 1] == '\n' || content[lineEnd - 1] == '\r')) {
            lineEnd--
        }
        return lineEnd
    }

    private fun invalidateInMemoryProject(projectRoot: FileObject? = null) {
        val snapshot = inMemoryProjectSnapshot ?: return
        if (projectRoot == null || snapshot.rootPath == projectRoot.getAbsolutePath()) {
            inMemoryProjectSnapshot = null
            isPreparingInMemoryProject = false
            inMemoryProjectLoadedBytes = 0L
            inMemoryProjectTotalBytes = 0L
        }
    }

    private suspend fun prepareInMemoryProjectIfEligible(
        context: Context?,
        projectRoot: FileObject,
    ): InMemoryProjectSnapshot? {
        val existingSnapshot = inMemoryProjectSnapshot
        val settingsKey = currentSnapshotSettingsKey()
        if (existingSnapshot != null && existingSnapshot.rootPath == projectRoot.getAbsolutePath() && existingSnapshot.settingsKey == settingsKey) {
            return existingSnapshot
        }

        val allowedBytes = maxInMemoryProjectBytes(context)
        val estimate = estimateProjectLoadableBytes(projectRoot)
        if (estimate <= 0L || estimate > allowedBytes) {
            invalidateInMemoryProject(projectRoot)
            return null
        }

        val snapshot = buildInMemoryProjectSnapshot(projectRoot, settingsKey, estimate)
        inMemoryProjectSnapshot = snapshot
        return snapshot
    }

    private fun maxInMemoryProjectBytes(context: Context?): Long {
        val hardLimit = MAX_IN_MEMORY_PROJECT_BYTES
        if (context == null) return hardLimit

        val activityManager = context.getSystemService(Context.ACTIVITY_SERVICE) as? ActivityManager
        val memoryClassBytes = (activityManager?.memoryClass ?: 256).toLong() * 1024L * 1024L
        return minOf(hardLimit, memoryClassBytes.toLong())
    }

    private suspend fun estimateProjectLoadableBytes(projectRoot: FileObject): Long {
        var totalBytes = 0L
        suspend fun walk(parent: FileObject, hiddenParent: Boolean = false) {
            for (file in parent.listFiles()) {
                currentCoroutineContext().ensureActive()
                val path = file.getAbsolutePath()
                if (excluder.isExcluded(path)) continue

                val isHidden = hiddenParent || file.getName().startsWith(".")
                if (isHidden && !Settings.show_hidden_files_search) continue

                if (file.isDirectory()) {
                    walk(file, isHidden)
                    continue
                }

                if (file.length() > MAX_FILE_SIZE_SEARCH) continue
                if (isBinaryExtension(file.getExtension())) continue
                totalBytes += file.length()
                if (totalBytes > MAX_IN_MEMORY_PROJECT_BYTES) return
            }
        }

        walk(projectRoot)
        return totalBytes
    }

    private suspend fun buildInMemoryProjectSnapshot(
        projectRoot: FileObject,
        settingsKey: String,
        estimatedBytes: Long,
    ): InMemoryProjectSnapshot {
        Snapshot.withMutableSnapshot {
            isPreparingInMemoryProject = true
            inMemoryProjectLoadedBytes = 0L
            inMemoryProjectTotalBytes = estimatedBytes
        }

        val charset = Charset.forName(Settings.encoding)
        val fileMetas = ArrayList<FileMeta>()
        val searchableFiles = ArrayList<CachedSearchFile>()
        val candidateFiles = ArrayList<FileObject>()
        val loadedBytes = AtomicLong(0L)

        suspend fun walk(parent: FileObject, hiddenParent: Boolean = false) {
            for (file in parent.listFiles()) {
                currentCoroutineContext().ensureActive()
                val path = file.getAbsolutePath()
                if (excluder.isExcluded(path)) continue

                val isHidden = hiddenParent || file.getName().startsWith(".")
                if (isHidden && !Settings.show_hidden_files_search) continue

                fileMetas.add(
                    FileMeta(
                        path = path,
                        fileName = file.getName(),
                        lastModified = file.lastModified(),
                        size = file.length(),
                    )
                )

                if (file.isDirectory()) {
                    walk(file, isHidden)
                    continue
                }

                if (file.length() > MAX_FILE_SIZE_SEARCH) continue
                if (isBinaryExtension(file.getExtension())) continue
                candidateFiles.add(file)
            }
        }

        try {
            walk(projectRoot)

            val candidateChannel = Channel<FileObject>(256)
            val workerDispatcher = searchDispatcher()

            coroutineScope {
                val progressJob =
                    launch {
                        while (true) {
                            Snapshot.withMutableSnapshot {
                                inMemoryProjectLoadedBytes = loadedBytes.get()
                            }
                            delay(75)
                        }
                    }

                launch {
                    candidateFiles.forEach { file -> candidateChannel.send(file) }
                    candidateChannel.close()
                }

                repeat(searchParallelism()) {
                    launch(workerDispatcher) {
                        for (file in candidateChannel) {
                            currentCoroutineContext().ensureActive()
                            val content = file.readText(charset) ?: continue
                            if (hasBinaryChars(content.take(1024))) continue

                            synchronized(searchableFiles) {
                                searchableFiles.add(
                                    CachedSearchFile(
                                        file = file,
                                        path = file.getAbsolutePath(),
                                        content = content,
                                    )
                                )
                            }
                            loadedBytes.addAndGet(file.length())
                        }
                    }
                }

                progressJob.cancel()
            }
        } finally {
            Snapshot.withMutableSnapshot {
                inMemoryProjectLoadedBytes = loadedBytes.get()
                isPreparingInMemoryProject = false
            }
        }

        return InMemoryProjectSnapshot(
            rootPath = projectRoot.getAbsolutePath(),
            settingsKey = settingsKey,
            fileMetas = fileMetas,
            searchableFiles = searchableFiles,
        )
    }

    private fun currentSnapshotSettingsKey(): String {
        return listOf(Settings.encoding, Settings.excluded_files_search, Settings.show_hidden_files_search.toString())
            .joinToString("|")
    }

    private suspend fun postSearchBackend(backend: SearchBackend) {
        withContext(Dispatchers.Main.immediate) {
            activeSearchBackend = backend
        }
    }

    private fun updateCachedFileContent(file: FileObject, updatedContent: String) {
        val snapshot = inMemoryProjectSnapshot ?: return
        val path = file.getAbsolutePath()
        val updatedCachedFile = snapshot.searchableFilesByPath[path]?.copy(content = updatedContent) ?: return

        val updatedSearchableFiles = snapshot.searchableFiles.map { cachedFile ->
            if (cachedFile.path == path) updatedCachedFile else cachedFile
        }
        inMemoryProjectSnapshot =
            snapshot.copy(
                searchableFiles = updatedSearchableFiles,
                searchableFilesByPath = updatedSearchableFiles.associateBy { it.path },
            )
    }

    /** Streams searchable files so worker threads can begin before traversal completes. */
    private suspend fun streamSearchableFiles(
        parent: FileObject,
        openPaths: Set<String>,
        isResultHidden: Boolean = false,
        sendFile: suspend (FileObject) -> Unit,
    ) {
        val childFiles = parent.listFiles()
        for (file in childFiles) {
            val path = file.getAbsolutePath()
            if (path in openPaths) continue
            if (excluder.isExcluded(path)) continue

            val isHidden = file.getName().startsWith(".") || isResultHidden
            if (isHidden && !Settings.show_hidden_files_search) continue

            if (file.isDirectory()) {
                streamSearchableFiles(file, openPaths, isHidden, sendFile)
                continue
            }

            val fileExt = file.getExtension()
            if (!matchesFileMask(fileExt)) continue
            // Skip obviously unsearchable files (size/extension) but defer content-based binary detection
            if (file.length() > MAX_FILE_SIZE_SEARCH) continue
            if (isBinaryExtension(file.getExtension())) continue
            sendFile(file)
        }
    }

    /** Searches a single file for matches and sends results. Includes inline binary detection. */
    private suspend fun searchSingleFile(
        context: Context,
        mainViewModel: MainViewModel,
        file: FileObject,
        projectRoot: FileObject,
        query: String,
        matcher: FastLiteralMatcher,
        charset: Charset,
        resultCount: AtomicInteger,
        send: suspend (CodeItem) -> Unit,
    ) {
        file.useInputStream { inputStream ->
            val reader = inputStream.bufferedReader(charset)
            // Inline binary detection on the first chunk of data
            val firstLine = reader.readLine() ?: return@useInputStream
            if (hasBinaryChars(firstLine.take(1024))) return@useInputStream

            // Search first line
            searchLine(
                line = firstLine,
                lineIndex = 0,
                context = context,
                mainViewModel = mainViewModel,
                file = file,
                projectRoot = projectRoot,
                query = query,
                matcher = matcher,
                resultCount = resultCount,
                send = send,
            )

            // Search remaining lines
            var lineIndex = 1
            var nextLine = reader.readLine()
            while (nextLine != null) {
                if (resultCount.get() >= MAX_CODE_RESULTS) break
                searchLine(
                    line = nextLine,
                    lineIndex = lineIndex,
                    context = context,
                    mainViewModel = mainViewModel,
                    file = file,
                    projectRoot = projectRoot,
                    query = query,
                    matcher = matcher,
                    resultCount = resultCount,
                    send = send,
                )
                lineIndex++
                nextLine = reader.readLine()
            }
        }
    }

    /** Searches a single line (with chunking for very long lines) and sends results. */
    private suspend fun searchLine(
        line: String,
        lineIndex: Int,
        context: Context,
        mainViewModel: MainViewModel,
        file: FileObject,
        projectRoot: FileObject,
        query: String,
        matcher: FastLiteralMatcher,
        resultCount: AtomicInteger,
        usePlainSnippet: Boolean = false,
        send: suspend (CodeItem) -> Unit,
    ) {
        val chunks = line.chunked(MAX_CHUNK_SIZE)
        chunks.forEachIndexed { chunkIndex, chunk ->
            val indices = findAllIndices(chunk, matcher)
            for (index in indices) {
                if (resultCount.incrementAndGet() > MAX_CODE_RESULTS) return
                val absoluteCharIndex = (chunkIndex * MAX_CHUNK_SIZE) + index
                currentCoroutineContext().ensureActive()
                send(
                    createCodeItem(
                        context = context,
                        mainViewModel = mainViewModel,
                        text = chunk,
                        charIndex = absoluteCharIndex,
                        query = query,
                        file = file,
                        projectRoot = projectRoot,
                        lineIndex = lineIndex,
                        usePlainSnippet = usePlainSnippet,
                    )
                )
            }
        }
    }

    private suspend fun createCodeItem(
        context: Context,
        mainViewModel: MainViewModel,
        text: String,
        charIndex: Int,
        query: String,
        file: FileObject,
        projectRoot: FileObject,
        lineIndex: Int,
        isOpen: Boolean = false,
        usePlainSnippet: Boolean = false,
    ): CodeItem {
        val snippetBuilder = SnippetBuilder(context)
        val highlight = Highlight(charIndex, charIndex + query.length)
        val snippetResult =
            if (usePlainSnippet) {
                snippetBuilder.generatePlainSnippet(
                    text = text,
                    highlight = highlight,
                )
            } else {
                snippetBuilder.generateSnippet(
                    text = text,
                    highlight = highlight,
                    fileExt = file.getExtension(),
                )
            }

        val codeItem =
            CodeItem(
                snippet = snippetResult,
                file = file,
                line = lineIndex,
                column = charIndex,
                isOpen = isOpen,
                onClick = {
                    viewModelScope.launch {
                        mainViewModel.editorManager.jumpToPosition(
                            file = file,
                            projectRoot = projectRoot,
                            lineStart = lineIndex,
                            charStart = charIndex,
                            lineEnd = lineIndex,
                            charEnd = charIndex + query.length,
                        )
                    }
                },
            )
        return codeItem
    }

    /**
     * Reads the file content, returning null if it's unsuitable for searching (e.g. if it's too large or likely
     * binary).
     *
     * @param file The file to read.
     * @return The file content as a [String], or null.
     */
    private suspend fun isFileSearchable(file: FileObject): Boolean {
        // Do not search in file if it's over 10MB
        if (file.length() > MAX_FILE_SIZE_SEARCH) return false

        // Do not search in file if it's likely to be binary (file extension based detection)
        val ext = file.getExtension()
        if (isBinaryExtension(ext)) return false

        val charset = Charset.forName(Settings.encoding)

        // Do not search in file if it's likely to be binary (character based detection)
        val isBinary =
            withContext(Dispatchers.IO) {
                try {
                    file.useInputStream { stream ->
                        val buffer = CharArray(1024)
                        val charsRead = InputStreamReader(stream, charset).read(buffer, 0, buffer.size)
                        val sample = String(buffer, 0, charsRead)
                        hasBinaryChars(sample)
                    }
                } catch (e: Exception) {
                    e.printStackTrace()
                    true
                }
            }
        return !isBinary
    }

    suspend fun index(context: Context, projectRoot: FileObject) {
        isIndexing[projectRoot] = true

        val database = getDatabase(context, projectRoot)
        val codeLineDao = database.codeIndexDao()
        val fileMetaDao = database.fileMetaDao()

        val indexedFiles = fileMetaDao.getAll().associateBy { it.path }
        val pathsToKeep = mutableSetOf<String>()

        val newCodeLines = mutableListOf<CodeLine>()
        val newFileMetas = mutableListOf<FileMeta>()

        try {
            suspend fun flushBatch() = this@SearchViewModel.flushBatch(codeLineDao, newCodeLines)

            indexRecursively(projectRoot, indexedFiles, pathsToKeep, newCodeLines, newFileMetas, ::flushBatch)
            finalizeIndex(database, indexedFiles, pathsToKeep, codeLineDao, fileMetaDao, newCodeLines, newFileMetas)
        } finally {
            isIndexing[projectRoot] = false
        }
    }

    fun syncIndex(file: FileObject) {
        indexJob =
            viewModelScope.launch(Dispatchers.IO) {
                val databases = IndexDatabase.findDatabasesFor(file)
                for (database in databases) {
                    isIndexing[database.projectRoot] = true

                    val codeLineDao = database.codeIndexDao()
                    val fileMetaDao = database.fileMetaDao()

                    val indexedFiles = fileMetaDao.getAll().associateBy { it.path }
                    val filteredIndexedFiles = indexedFiles.filter { it.key.startsWith(file.getAbsolutePath()) }
                    val pathsToKeep = mutableSetOf<String>()

                    val newCodeLines = mutableListOf<CodeLine>()
                    val newFileMetas = mutableListOf<FileMeta>()

                    try {
                        suspend fun flushBatch() = this@SearchViewModel.flushBatch(codeLineDao, newCodeLines)

                        if (file == database.projectRoot) {
                            indexRecursively(file, indexedFiles, pathsToKeep, newCodeLines, newFileMetas, ::flushBatch)
                        } else {
                            indexFile(file, indexedFiles, pathsToKeep, newCodeLines, newFileMetas, ::flushBatch)
                        }

                        finalizeIndex(
                            database,
                            filteredIndexedFiles,
                            pathsToKeep,
                            codeLineDao,
                            fileMetaDao,
                            newCodeLines,
                            newFileMetas,
                        )
                    } finally {
                        isIndexing[database.projectRoot] = false
                    }
                }
            }
    }

    fun deleteIndex(context: Context, projectRoot: FileObject) {
        cleanupJobs(projectRoot)
        IndexDatabase.removeDatabase(context, projectRoot)
    }

    // Called mid-traversal (to reduce memory allocation size of newCodeLines and newFileMetas)
    private suspend fun flushBatch(codeLineDao: CodeLineDao, newCodeLines: MutableList<CodeLine>) {
        if (newCodeLines.size > CODE_BATCH_SIZE) {
            codeLineDao.insertAll(newCodeLines)
            newCodeLines.clear()
        }
    }

    // Only called once at the end of indexing and sync (handles deletions + remaining inserts)
    private suspend fun finalizeIndex(
        database: IndexDatabase,
        indexedFiles: Map<String, FileMeta>,
        pathsToKeep: MutableSet<String>,
        codeLineDao: CodeLineDao,
        fileMetaDao: FileMetaDao,
        newCodeLines: MutableList<CodeLine>,
        newFileMetas: MutableList<FileMeta>,
    ) {
        currentCoroutineContext().ensureActive()

        database.withTransaction {
            val deletedPaths = indexedFiles.keys - pathsToKeep
            deletedPaths.forEach { path ->
                codeLineDao.deleteByPath(path)
                fileMetaDao.deleteByPath(path)
            }

            codeLineDao.insertAll(newCodeLines)
            fileMetaDao.insertAll(newFileMetas)
        }
    }

    private suspend fun indexRecursively(
        parent: FileObject,
        indexedFiles: Map<String, FileMeta>,
        pathsToKeep: MutableSet<String>,
        codeLineResults: MutableList<CodeLine>,
        fileMetaResults: MutableList<FileMeta>,
        flushBatch: suspend () -> Unit,
        isResultHidden: Boolean = false,
    ) {
        val childFiles = parent.listFiles()

        for (file in childFiles) {
            currentCoroutineContext().ensureActive()
            indexFile(
                file,
                indexedFiles,
                pathsToKeep,
                codeLineResults,
                fileMetaResults,
                flushBatch = flushBatch,
                isResultHidden = isResultHidden,
            )
        }
    }

    private suspend fun indexFile(
        file: FileObject,
        indexedFiles: Map<String, FileMeta>,
        pathsToKeep: MutableSet<String>,
        codeLineResults: MutableList<CodeLine>,
        fileMetaResults: MutableList<FileMeta>,
        flushBatch: suspend () -> Unit,
        isResultHidden: Boolean = false,
    ) {
        val isHidden = file.getName().startsWith(".") || isResultHidden
        if (isHidden && !Settings.show_hidden_files_search) return

        val path = file.getAbsolutePath()
        val lastModified = file.lastModified()

        if (excluder.isExcluded(path)) return

        val indexedFile = indexedFiles[path]
        val isFileModified =
            indexedFile == null || indexedFile.lastModified != lastModified || indexedFile.size != file.length()
        if (!isFileModified) {
            pathsToKeep += path
            if (!file.isDirectory()) return
        } else {
            fileMetaResults.add(
                FileMeta(path = path, fileName = file.getName(), lastModified = lastModified, size = file.length())
            )
            flushBatch()
        }

        if (file.isDirectory()) {
            indexRecursively(
                parent = file,
                indexedFiles = indexedFiles,
                pathsToKeep = pathsToKeep,
                codeLineResults = codeLineResults,
                fileMetaResults = fileMetaResults,
                flushBatch = flushBatch,
                isResultHidden = isHidden,
            )
            return
        }

        if (!isFileSearchable(file)) return
        val charset = Charset.forName(Settings.encoding)

        file.useInputStream { inputStream ->
            inputStream.bufferedReader(charset).useLines { lineSequence ->
                lineSequence.forEachIndexed { lineIndex, line ->
                    val chunks = line.chunked(MAX_CHUNK_SIZE)
                    chunks.forEachIndexed { chunkIndex, chunk ->
                        currentCoroutineContext().ensureActive()
                        codeLineResults.add(
                            CodeLine(
                                content = chunk,
                                path = path,
                                lineNumber = lineIndex,
                                chunkStart = chunkIndex * MAX_CHUNK_SIZE,
                            )
                        )
                        flushBatch()
                    }
                }
            }
        }
    }
}

private class CachedSearchFile(
    val file: FileObject,
    val path: String,
    val content: String,
) {
    @Volatile
    private var lineStartOffsetsCache: IntArray? = null

    fun getLineStartOffsets(): IntArray {
        val existing = lineStartOffsetsCache
        if (existing != null) return existing

        return synchronized(this) {
            val cached = lineStartOffsetsCache
            if (cached != null) {
                cached
            } else {
                computeLineStartOffsetsForCache(content).also { lineStartOffsetsCache = it }
            }
        }
    }

    fun copy(content: String = this.content): CachedSearchFile {
        return CachedSearchFile(
            file = file,
            path = path,
            content = content,
        )
    }

    private fun computeLineStartOffsetsForCache(content: String): IntArray {
        val offsets = ArrayList<Int>()
        offsets.add(0)

        var index = 0
        while (index < content.length) {
            when (content[index]) {
                '\n' -> offsets.add(index + 1)
                '\r' -> {
                    if (index + 1 < content.length && content[index + 1] == '\n') {
                        offsets.add(index + 2)
                        index++
                    } else {
                        offsets.add(index + 1)
                    }
                }
            }
            index++
        }

        return offsets.toIntArray()
    }
}

private data class InMemoryProjectSnapshot(
    val rootPath: String,
    val settingsKey: String,
    val fileMetas: List<FileMeta>,
    val searchableFiles: List<CachedSearchFile>,
    val searchableFilesByPath: Map<String, CachedSearchFile> = searchableFiles.associateBy { it.path },
)
