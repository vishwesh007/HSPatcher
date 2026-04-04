package com.rk.hspatcher

import android.content.Context
import android.content.Intent
import com.rk.exec.ShellUtils
import com.rk.exec.TerminalCommand
import com.rk.exec.isTerminalInstalled
import com.rk.file.FileObject
import com.rk.file.child
import com.rk.file.sandboxHomeDir
import java.io.BufferedInputStream
import java.io.File
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.Properties
import java.util.zip.ZipFile
import kotlin.math.roundToInt
import kotlinx.coroutines.runBlocking

object HSPatcherWorkspaceIntegration {
    const val EXTRA_WORKSPACE_PATH = "hsp_workspace_path"
    const val EXTRA_FOCUS_FILE = "hsp_workspace_focus_file"
    const val EXTRA_DIRECT_JAR_WORKFLOW = "hsp_direct_jar_workflow"
    const val EXTRA_IMPORT_APK_PATH = "hsp_import_apk_path"
    const val EXTRA_IMPORT_APP_NAME = "hsp_import_app_name"

    private const val PREFS_NAME = "apk_editor_prefs"
    private const val PREF_LAST_WORKSPACE = "last_workspace"
    private const val META_FILE = ".hsp_workspace.properties"
    private const val APK_EDITOR_VERSION = "1.4.8"
    private const val ANDROID_FRAMEWORK_VERSION = 35
    private const val FRAMEWORK_FILE_NAME = "android-$ANDROID_FRAMEWORK_VERSION.apk"
    private const val SDK_JAR_FILE_NAME = "android.jar"
    private const val STAGED_SDK_JAR_RELATIVE_PATH = "android-sdk/platforms/android-$ANDROID_FRAMEWORK_VERSION/$SDK_JAR_FILE_NAME"
    private const val DECODE_LOG_FILE = "apkeditor-decode.log"
    private const val APK_EDITOR_URL =
        "https://github.com/REAndroid/APKEditor/releases/download/V1.4.8/APKEditor-1.4.8.jar"
    private const val FRAMEWORK_URL =
        "https://raw.githubusercontent.com/REAndroid/ARSCLib/main/src/main/resources/frameworks/android/android-35.apk"
    private val DEX_NAME_REGEX = Regex("""classes(\\d*)\\.dex""")

    @JvmStatic
    fun createDirectJarWorkflowIntent(context: Context, activityClassName: String): Intent {
        return Intent().apply {
            setClassName(context.packageName, activityClassName)
            putExtra(EXTRA_DIRECT_JAR_WORKFLOW, true)
        }
    }

    @JvmStatic
    fun createImportIntent(
        context: Context,
        activityClassName: String,
        workspacePath: String,
        apkPath: String,
        appName: String,
    ): Intent {
        return Intent().apply {
            setClassName(context.packageName, activityClassName)
            putExtra(EXTRA_WORKSPACE_PATH, workspacePath)
            putExtra(EXTRA_IMPORT_APK_PATH, apkPath)
            putExtra(EXTRA_IMPORT_APP_NAME, appName)
        }
    }

    fun getLastWorkspaceDir(context: Context): File? {
        val path = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .getString(PREF_LAST_WORKSPACE, null)
            ?: return null
        return File(path).takeIf { it.isDirectory }
    }

    fun resolveProjectRoot(path: String?): File? {
        if (path.isNullOrBlank()) {
            return null
        }
        val direct = File(path)
        if (!direct.exists()) {
            return null
        }
        if (direct.isDirectory && direct.name == "decoded") {
            return direct
        }
        val decoded = File(direct, "decoded")
        return if (decoded.isDirectory) decoded else direct.takeIf { it.isDirectory }
    }

    fun isHSPatcherWorkspace(root: FileObject?): Boolean {
        if (root == null) {
            return false
        }
        return isHSPatcherWorkspace(File(root.getAbsolutePath()))
    }

    fun isHSPatcherWorkspace(root: File): Boolean {
        if (!root.isDirectory) {
            return false
        }
        if (File(root, META_FILE).isFile) {
            return true
        }
        val workspaceDir = if (root.name == "decoded") root.parentFile else root
        return workspaceDir != null && File(workspaceDir, META_FILE).isFile
    }

    fun getFrameworkWorkspaceDir(): File {
        return sandboxHomeDir().child("reandroid-workspace").also { it.mkdirs() }
    }

    @JvmStatic
    fun createWorkspaceBaseDir(context: Context): File {
        val external = context.getExternalFilesDir("apk_editor")
        val baseDir = external ?: File(context.filesDir, "apk_editor")
        if (!baseDir.exists()) {
            baseDir.mkdirs()
        }
        return baseDir
    }

    @JvmStatic
    fun getLatestWorkspaceDir(context: Context): File? {
        val baseDir = createWorkspaceBaseDir(context)
        return baseDir.listFiles()
            ?.filter { it.isDirectory }
            ?.maxByOrNull { it.lastModified() }
    }

    @JvmStatic
    fun createWorkspaceDir(context: Context, appName: String): File {
        val safeName = sanitizeName(appName)
        val stamp = SimpleDateFormat("yyyyMMdd_HHmmss", Locale.US).format(Date())
        val workspaceDir = createWorkspaceBaseDir(context).child("${stamp}_${safeName}")
        workspaceDir.mkdirs()
        return workspaceDir
    }

    @JvmStatic
    @Throws(Exception::class)
    fun prepareFrameworkWorkspaceBlocking(): File = runBlocking {
        prepareFrameworkWorkspace().getOrThrow()
    }

    @JvmStatic
    @Throws(Exception::class)
    fun decompileWithApkEditorBlocking(context: Context, stagedApk: File, workspaceDir: File): File = runBlocking {
        decodeWithApkEditor(context, stagedApk, workspaceDir).getOrThrow()
    }

    suspend fun importApkIntoWorkspace(
        context: Context,
        stagedApk: File,
        workspaceDir: File,
    ): Result<File> {
        return decodeWithApkEditor(context, stagedApk, workspaceDir).map { workspaceDir }
    }

    fun getWorkspaceDefaultFocusFile(workspaceDir: File): File? {
        val projectRoot = resolveProjectRoot(workspaceDir.absolutePath) ?: return null
        val candidates = listOf(
            projectRoot.child("root").child("AndroidManifest.xml"),
            projectRoot.child("AndroidManifest.xml"),
            projectRoot.child("archive-info.json"),
            projectRoot.child("path-map.json"),
        )

        candidates.firstOrNull { it.isFile && !isLikelyBinary(it) }?.let { return it }

        projectRoot.walkTopDown()
            .maxDepth(3)
            .firstOrNull { candidate ->
                candidate.isFile &&
                    candidate.extension.lowercase() in setOf("xml", "json", "smali", "txt", "md", "properties") &&
                    !isLikelyBinary(candidate)
            }
            ?.let { return it }

        return null
    }

    private suspend fun decodeWithApkEditor(context: Context, stagedApk: File, workspaceDir: File): Result<File> {
        if (!stagedApk.isFile()) {
            return Result.failure(IllegalArgumentException("Input APK missing: ${stagedApk.absolutePath}"))
        }
        if (!isTerminalInstalled()) {
            return Result.failure(IllegalStateException("Ubuntu terminal is not installed yet"))
        }

        prepareFrameworkWorkspace().getOrElse { return Result.failure(it) }

        val decodedDir = workspaceDir.child("decoded")
        val decodeLogFile = workspaceDir.child(DECODE_LOG_FILE)
        val toolDir = getFrameworkWorkspaceDir().child("tools")
        val jarPath = toolDir.child("APKEditor-$APK_EDITOR_VERSION.jar").absolutePath
        val expectedDexFiles = stagedApk.listApkDexEntries()
        val frameworkCandidates = buildList {
            add(resolveFrameworkPath())
            val fallbackFramework = getFrameworkWorkspaceDir()
                .child("platforms")
                .child("android-$ANDROID_FRAMEWORK_VERSION")
                .child(FRAMEWORK_FILE_NAME)
            if (fallbackFramework.isFile && fallbackFramework.absolutePath !in this@buildList.map { it.absolutePath }) {
                add(fallbackFramework)
            }
        }

        val attempts = buildList {
            frameworkCandidates.forEach { framework ->
                add(listOf("-framework", framework.absolutePath))
            }
            add(emptyList())
        }

        var lastFailure: String? = null
        attempts.forEachIndexed { index, extraArgs ->
            val attemptStartedAt = System.currentTimeMillis()
            val attemptLabel = buildString {
                append("attempt ")
                append(index + 1)
                if (extraArgs.size >= 2) {
                    append(" using ")
                    append(File(extraArgs[1]).name)
                } else {
                    append(" without external framework")
                }
            }
            val decodeCommand = buildString {
                append("java -Xmx2560m -jar '")
                append(escapeForSingleQuotes(jarPath))
                append("' d -t xml -i '")
                append(escapeForSingleQuotes(stagedApk.absolutePath))
                append("' -o '")
                append(escapeForSingleQuotes(decodedDir.absolutePath))
                append("' -f")
                append(" -dex-lib internal")
                if (extraArgs.isNotEmpty()) {
                    append(" -framework '")
                    append(escapeForSingleQuotes(extraArgs[1]))
                    append("'")
                }
            }

            val shellScript = """
                set -e
                rm -rf '${escapeForSingleQuotes(decodedDir.absolutePath)}'
                mkdir -p '${escapeForSingleQuotes(workspaceDir.absolutePath)}'
                printf '== %s ==\n' '${escapeForSingleQuotes(attemptLabel)}' > '${escapeForSingleQuotes(decodeLogFile.absolutePath)}'
                (
                  ${decodeCommand}
                ) >> '${escapeForSingleQuotes(decodeLogFile.absolutePath)}' 2>&1
            """.trimIndent()

            val result = ShellUtils.runUbuntu(
                workingDir = workspaceDir.absolutePath,
                "sh",
                "-lc",
                shellScript,
                timeoutSeconds = 1800,
            )
            val attemptDurationMs = System.currentTimeMillis() - attemptStartedAt
            decodeLogFile.appendText("\n== duration ${formatDurationLabel(attemptDurationMs)} ==\n")

            if (result.exitCode == 0 && isDecodedWorkspaceUsable(decodedDir, expectedDexFiles)) {
                saveWorkspaceMetadata(context, workspaceDir, stagedApk, expectedDexFiles, attemptDurationMs, attemptLabel)
                return Result.success(decodedDir)
            }

            val decodeLog = decodeLogFile.takeIf { it.isFile }?.readText()?.trim().orEmpty()
            lastFailure = buildString {
                append("APKEditor decode validation failed on ")
                append(attemptLabel)
                if (decodeLog.isNotBlank()) {
                    append('\n')
                    append(decodeLog)
                } else {
                    val message = result.error.ifBlank { result.output }.ifBlank { "APKEditor decode failed" }
                    append('\n')
                    append(message)
                }
            }
        }

        return Result.failure(IllegalStateException(lastFailure ?: "APKEditor decode failed"))
    }

    private fun saveWorkspaceMetadata(
        context: Context,
        workspaceDir: File,
        stagedApk: File,
        expectedDexFiles: Set<String>,
        decodeDurationMs: Long,
        decodeAttempt: String,
    ) {
        val properties = Properties().apply {
            setProperty("original_apk", stagedApk.absolutePath)
            setProperty("workspace_dir", workspaceDir.absolutePath)
            setProperty("decode_engine", "apkeditor_jar")
            setProperty("package_name", workspaceDir.name)
            setProperty("expected_dex_count", expectedDexFiles.size.toString())
            setProperty("expected_dex_files", expectedDexFiles.sorted().joinToString(","))
            setProperty("decode_duration_ms", decodeDurationMs.toString())
            setProperty("decode_duration_label", formatDurationLabel(decodeDurationMs))
            setProperty("decode_attempt", decodeAttempt)
        }
        workspaceDir.child(META_FILE).outputStream().use { output ->
            properties.store(output, "HSPatcher APKEditor.jar Workspace")
        }
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .edit()
            .putString(PREF_LAST_WORKSPACE, workspaceDir.absolutePath)
            .apply()
    }

    private fun sanitizeName(value: String): String {
        val trimmed = value.trim()
        if (trimmed.isEmpty()) {
            return "apkeditor_workspace"
        }
        return trimmed.replace(Regex("[^A-Za-z0-9._-]"), "_")
    }

    private fun formatDurationLabel(durationMs: Long): String {
        val totalSeconds = (durationMs / 1000.0).coerceAtLeast(0.0)
        val minutes = (totalSeconds / 60.0).toInt()
        val seconds = (totalSeconds % 60.0)
        return if (minutes > 0) {
            "${minutes}m ${seconds.roundToInt()}s"
        } else {
            "${seconds.roundToInt()}s"
        }
    }

    fun createBuildCommand(projectRoot: File): TerminalCommand {
        val resolvedProjectRoot = resolveProjectRoot(projectRoot.absolutePath) ?: projectRoot
        val toolDir = getFrameworkWorkspaceDir().child("tools")
        toolDir.mkdirs()
        val jarPath = toolDir.child("APKEditor-$APK_EDITOR_VERSION.jar").absolutePath
        val frameworkPath = resolveFrameworkPath().absolutePath
        val workspaceDir = if (resolvedProjectRoot.name == "decoded") resolvedProjectRoot.parentFile else resolvedProjectRoot
        val outputDir = workspaceDir?.child("build") ?: resolvedProjectRoot.child("build")
        outputDir.mkdirs()
        val outputPath = outputDir.child((workspaceDir?.name ?: resolvedProjectRoot.name) + "-reandroid.apk").absolutePath

        val command =
            "java -Xmx2560m -jar '${escapeForSingleQuotes(jarPath)}' b -f -i '${escapeForSingleQuotes(resolvedProjectRoot.absolutePath)}' " +
                "-framework '${escapeForSingleQuotes(frameworkPath)}' -o '${escapeForSingleQuotes(outputPath)}'"

        return TerminalCommand(
            sandbox = true,
            exe = "sh",
            args = arrayOf("-lc", command),
            id = "hspatcher-build-${resolvedProjectRoot.absolutePath.hashCode()}",
            workingDir = resolvedProjectRoot.absolutePath,
        )
    }

    suspend fun prepareFrameworkWorkspace(): Result<File> {
        if (!isTerminalInstalled()) {
            return Result.failure(IllegalStateException("Ubuntu terminal is not installed yet"))
        }

        val workspaceDir = getFrameworkWorkspaceDir()
        val toolsDir = workspaceDir.child("tools").also { it.mkdirs() }
        val platformsDir = workspaceDir.child("platforms").child("android-$ANDROID_FRAMEWORK_VERSION")
            .also { it.mkdirs() }
        val projectDir = workspaceDir.child("framework-project").also { it.mkdirs() }
        val readme = projectDir.child("README.txt")
        if (!readme.exists()) {
            readme.writeText(
                "REAndroid framework workspace\n\n" +
                    "Preferred framework: Android SDK android.jar when available in Ubuntu\n" +
                    "Fallback framework: platforms/android-$ANDROID_FRAMEWORK_VERSION/$FRAMEWORK_FILE_NAME\n" +
                    "APKEditor jar is cached in tools/APKEditor-$APK_EDITOR_VERSION.jar\n"
            )
        }

        val shellScript = """
            set -e
            mkdir -p '${escapeForSingleQuotes(toolsDir.absolutePath)}' '${escapeForSingleQuotes(platformsDir.absolutePath)}'
            if ! command -v curl >/dev/null 2>&1; then
              apt-get update >/dev/null 2>&1
              DEBIAN_FRONTEND=noninteractive apt-get install -y curl openjdk-17-jre-headless >/dev/null 2>&1
            fi
            if ! command -v java >/dev/null 2>&1; then
              apt-get update >/dev/null 2>&1
              DEBIAN_FRONTEND=noninteractive apt-get install -y openjdk-17-jre-headless >/dev/null 2>&1
            fi
                        test -f '${escapeForSingleQuotes(toolsDir.child("APKEditor-$APK_EDITOR_VERSION.jar").absolutePath)}' || \
                            curl -L '${escapeForSingleQuotes(APK_EDITOR_URL)}' -o '${escapeForSingleQuotes(toolsDir.child("APKEditor-$APK_EDITOR_VERSION.jar").absolutePath)}'
                        STAGED_SDK_JAR="${'$'}{PUBLIC_HOME}/${STAGED_SDK_JAR_RELATIVE_PATH}"
                        if [ -f "${'$'}STAGED_SDK_JAR" ] && [ ! -f '${escapeForSingleQuotes(platformsDir.child(SDK_JAR_FILE_NAME).absolutePath)}' ]; then
                            cp "${'$'}STAGED_SDK_JAR" '${escapeForSingleQuotes(platformsDir.child(SDK_JAR_FILE_NAME).absolutePath)}'
                        fi
                        if [ ! -f '${escapeForSingleQuotes(platformsDir.child(SDK_JAR_FILE_NAME).absolutePath)}' ] && [ ! -f '${escapeForSingleQuotes(platformsDir.child(FRAMEWORK_FILE_NAME).absolutePath)}' ]; then
                            curl -L '${escapeForSingleQuotes(FRAMEWORK_URL)}' -o '${escapeForSingleQuotes(platformsDir.child(FRAMEWORK_FILE_NAME).absolutePath)}'
                        fi
        """.trimIndent()

        val result = ShellUtils.runUbuntu(
            workingDir = workspaceDir.absolutePath,
            "sh",
            "-lc",
            shellScript,
            timeoutSeconds = 240,
        )
        if (result.exitCode != 0) {
            val message = result.error.ifBlank { result.output }.ifBlank { "Unknown REAndroid setup failure" }
            return Result.failure(IllegalStateException(message))
        }
        return Result.success(projectDir)
    }

    private fun resolveFrameworkPath(): File {
        val platformsDir = getFrameworkWorkspaceDir().child("platforms").child("android-$ANDROID_FRAMEWORK_VERSION")
        val sdkJar = platformsDir.child("android.jar")
        if (sdkJar.isFile()) {
            return sdkJar
        }
        return platformsDir.child(FRAMEWORK_FILE_NAME)
    }

    private fun escapeForSingleQuotes(value: String): String {
        return value.replace("'", "'\\''")
    }

    private fun isDecodedWorkspaceUsable(decodedDir: File, expectedDexFiles: Set<String>): Boolean {
        if (!decodedDir.isDirectory) {
            return false
        }
        val manifest = decodedDir.child("AndroidManifest.xml")
        val rootManifest = decodedDir.child("root").child("AndroidManifest.xml")
        val hasManifest =
            (manifest.isFile && !isLikelyBinary(manifest)) ||
                (rootManifest.isFile && !isLikelyBinary(rootManifest))
        if (!hasManifest) {
            return false
        }

        val hasMetadata = decodedDir.child("archive-info.json").isFile || decodedDir.child("path-map.json").isFile
        val textLikeFiles = decodedDir.walkTopDown()
            .maxDepth(2)
            .count { candidate ->
                candidate.isFile &&
                    candidate.extension.lowercase() in setOf("xml", "json") &&
                    !isLikelyBinary(candidate)
            }
        if (!hasMetadata && textLikeFiles < 2) {
            return false
        }

        val decodedDexFiles = decodedDir.listDecodedDexArtifacts()
        if (expectedDexFiles.isEmpty()) {
            return true
        }
        return decodedDexFiles.containsAll(expectedDexFiles)
    }

    private fun File.listApkDexEntries(): Set<String> {
        if (!isFile) {
            return emptySet()
        }
        return runCatching {
            ZipFile(this).use { zip ->
                zip.entries().asSequence()
                    .map { it.name.substringAfterLast('/') }
                    .filter { DEX_NAME_REGEX.matches(it) }
                    .toCollection(linkedSetOf())
            }
        }.getOrDefault(emptySet())
    }

    private fun File.listDecodedDexArtifacts(): Set<String> {
        if (!isDirectory) {
            return emptySet()
        }
        val decoded = linkedSetOf<String>()
        walkTopDown().maxDepth(4).forEach { candidate ->
            val relativePath = candidate.relativeTo(this).invariantSeparatorsPath
            when {
                candidate.isFile && DEX_NAME_REGEX.matches(candidate.name) -> {
                    decoded += candidate.name
                }
                candidate.isDirectory && relativePath == "smali" && candidate.containsSmaliFiles() -> {
                    decoded += "classes.dex"
                }
                candidate.isDirectory && relativePath.startsWith("smali_") && candidate.containsSmaliFiles() -> {
                    val suffix = relativePath.removePrefix("smali_").replace('@', '/')
                    decoded += "$suffix.dex"
                }
                candidate.isDirectory && relativePath.startsWith("smali/classes") && candidate.containsSmaliFiles() -> {
                    val suffix = relativePath.removePrefix("smali/")
                    val dexName = when (suffix) {
                        "classes" -> "classes.dex"
                        else -> "$suffix.dex"
                    }
                    if (DEX_NAME_REGEX.matches(dexName)) {
                        decoded += dexName
                    }
                }
            }
        }
        return decoded
    }

    private fun File.containsSmaliFiles(): Boolean {
        return listFiles()?.any { child ->
            when {
                child.isFile -> child.extension.equals("smali", ignoreCase = true)
                child.isDirectory -> child.containsSmaliFiles()
                else -> false
            }
        } == true
    }

    private fun isLikelyBinary(file: File): Boolean {
        return runCatching {
            BufferedInputStream(file.inputStream()).use { input ->
                val sample = ByteArray(1024)
                val read = input.read(sample)
                if (read <= 0) {
                    false
                } else {
                    sample.take(read).any { it == 0.toByte() }
                }
            }
        }.getOrDefault(true)
    }

    /**
     * Find the built (unsigned) APK produced by APKEditor.jar build command.
     * Pattern: <workspaceDir>/build/<workspaceName>-reandroid.apk
     */
    @JvmStatic
    fun findBuiltApk(projectRoot: File): File? {
        val resolvedRoot = resolveProjectRoot(projectRoot.absolutePath) ?: projectRoot
        val workspaceDir = if (resolvedRoot.name == "decoded") resolvedRoot.parentFile else resolvedRoot
        val buildDir = workspaceDir?.let { File(it, "build") } ?: return null
        if (!buildDir.isDirectory) return null

        // Look for the expected output name
        val expectedName = (workspaceDir.name) + "-reandroid.apk"
        val expected = File(buildDir, expectedName)
        if (expected.isFile) return expected

        // Fallback: any .apk in build dir
        return buildDir.listFiles()
            ?.filter { it.isFile && it.extension.equals("apk", ignoreCase = true) }
            ?.maxByOrNull { it.lastModified() }
    }

    /**
     * Sign a built APK using HSPatcher's persistent keystore.
     * Returns the signed APK path.
     */
    @JvmStatic
    @Throws(Exception::class)
    fun signBuiltApk(context: android.content.Context, unsignedApk: File): File {
        val signedApk = File(unsignedApk.parentFile, unsignedApk.nameWithoutExtension + "-signed.apk")
        // Use reflection because package 'in.startv.hspatcher' contains Kotlin keyword 'in'
        val signerClass = Class.forName("in.startv.hspatcher.ApkSigningUtil")
        val signMethod = signerClass.getDeclaredMethod(
            "signApk",
            android.content.Context::class.java,
            File::class.java,
            File::class.java,
            signerClass.classLoader!!.loadClass("in.startv.hspatcher.ApkSigningUtil\$Logger"),
        )
        signMethod.invoke(null, context, unsignedApk, signedApk, null)
        return signedApk
    }

    /**
     * Launch the system installer for a signed APK via HspFileProvider.
     */
    @JvmStatic
    fun installApk(context: android.content.Context, signedApk: File) {
        // Use reflection because package 'in.startv.hspatcher' contains Kotlin keyword 'in'
        val providerClass = Class.forName("in.startv.hspatcher.HspFileProvider")
        val getUriMethod = providerClass.getDeclaredMethod(
            "getUriForFile",
            android.content.Context::class.java,
            File::class.java,
        )
        val uri = getUriMethod.invoke(null, context, signedApk) as android.net.Uri
        val intent = android.content.Intent(android.content.Intent.ACTION_VIEW).apply {
            setDataAndType(uri, "application/vnd.android.package-archive")
            addFlags(android.content.Intent.FLAG_GRANT_READ_URI_PERMISSION)
            addFlags(android.content.Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        context.startActivity(intent)
    }

    /**
     * Validate that decoded workspace files are not binary where they shouldn't be.
     * Returns list of problematic files (binary XMLs, etc).
     */
    @JvmStatic
    fun validateDecodedWorkspace(projectRoot: File): List<String> {
        val problems = mutableListOf<String>()
        val resolvedRoot = resolveProjectRoot(projectRoot.absolutePath) ?: projectRoot

        // Check AndroidManifest.xml is not binary
        val manifestCandidates = listOf(
            File(resolvedRoot, "AndroidManifest.xml"),
            File(resolvedRoot, "root/AndroidManifest.xml"),
        )
        for (manifest in manifestCandidates) {
            if (manifest.isFile && isLikelyBinary(manifest)) {
                problems.add("AndroidManifest.xml is binary (not decoded): ${manifest.absolutePath}")
            }
        }

        // Check for binary XML in res/ that should be text
        val resDir = File(resolvedRoot, "res")
        if (resDir.isDirectory) {
            resDir.walkTopDown().maxDepth(3).forEach { file ->
                if (file.isFile && file.extension.equals("xml", ignoreCase = true) && isLikelyBinary(file)) {
                    problems.add("Binary XML in res: ${file.relativeTo(resolvedRoot).path}")
                }
            }
        }

        return problems
    }
}