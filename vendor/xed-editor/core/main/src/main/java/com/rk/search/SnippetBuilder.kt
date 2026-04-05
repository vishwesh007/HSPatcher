package com.rk.search

import android.content.Context
import android.graphics.Typeface
import android.text.Spannable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.buildAnnotatedString
import com.rk.activities.main.MainViewModel
import com.rk.editor.ThemeManager
import com.rk.editor.getSelectionColor
import com.rk.file.FileObject
import com.rk.tabs.editor.EditorTab
import com.rk.utils.toAnnotatedString
import io.github.rosemoe.sora.lsp.editor.text.MarkdownCodeHighlighterRegistry
import io.github.rosemoe.sora.widget.schemes.EditorColorScheme
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.eclipse.lsp4j.Range

data class Snippet(val text: AnnotatedString, val highlight: Highlight)

data class Highlight(val startIndex: Int, val endIndex: Int)

class SnippetBuilder(private val context: Context) {
    private suspend fun resolveHighlightBackground(): Color {
        return getSelectionColor()
            ?: run {
                val colorScheme = ThemeManager.createColorScheme(context, null)
                val background = colorScheme.getColor(EditorColorScheme.MATCHED_TEXT_BACKGROUND)
                Color(background)
            }
    }

    suspend fun generatePlainSnippet(text: String, highlight: Highlight): Snippet {
        val trimmedTargetLine = text.trim()
        val leadingWhitespace = text.indexOf(trimmedTargetLine).coerceAtLeast(0)

        val rangeStartTrimmed = (highlight.startIndex - leadingWhitespace).coerceAtLeast(0)
        val rangeEndTrimmed = (highlight.endIndex - leadingWhitespace).coerceIn(rangeStartTrimmed, trimmedTargetLine.length)
        val backgroundColor = resolveHighlightBackground()

        return Snippet(
            text = buildAnnotatedString {
                append(trimmedTargetLine)
                if (rangeStartTrimmed <= trimmedTargetLine.length && rangeEndTrimmed <= trimmedTargetLine.length) {
                    addStyle(
                        style = SpanStyle(background = backgroundColor),
                        start = rangeStartTrimmed,
                        end = rangeEndTrimmed,
                    )
                }
            },
            highlight = Highlight(rangeStartTrimmed, rangeEndTrimmed),
        )
    }

    /**
     * Generates a text portion of the provided text line that contains the range.
     *
     * The text of the range is printed with the selection color. The code is highlighted with the help of the
     * [MarkdownCodeHighlighterRegistry].
     *
     * @return A [Pair] containing the [AnnotatedString] and the start index of the highlighted text.
     */
    suspend fun generateSnippet(text: String, highlight: Highlight, fileExt: String): Snippet {
        return withContext(Dispatchers.Default) {
            val trimmedTargetLine = text.trim()
            val leadingWhitespace = text.indexOf(trimmedTargetLine).coerceAtLeast(0)

            val rangeStartTrimmed = (highlight.startIndex - leadingWhitespace).coerceAtLeast(0)
            val rangeEndTrimmed = (highlight.endIndex - leadingWhitespace).coerceIn(rangeStartTrimmed, trimmedTargetLine.length)

            val highlightedSpanned =
                MarkdownCodeHighlighterRegistry.global.highlightAsync(
                    code = trimmedTargetLine,
                    language = fileExt,
                    codeTypeface = Typeface.MONOSPACE,
                )

            val highlightedAnnotated = (highlightedSpanned as? Spannable)?.toAnnotatedString() ?: highlightedSpanned

            val backgroundColor = resolveHighlightBackground()

            Snippet(
                text =
                    buildAnnotatedString {
                        append(highlightedAnnotated)
                        if (rangeStartTrimmed <= highlightedAnnotated.length && rangeEndTrimmed <= highlightedAnnotated.length) {
                            addStyle(
                                style = SpanStyle(background = backgroundColor),
                                start = rangeStartTrimmed,
                                end = rangeEndTrimmed,
                            )
                        }
                    },
                highlight = Highlight(rangeStartTrimmed, rangeEndTrimmed),
            )
        }
    }

    /**
     * Generates a text portion of the line in the provided file that contains the range.
     *
     * The text of the range is printed with the selection color. The code is highlighted with the help of the
     * [MarkdownCodeHighlighterRegistry].
     *
     * @return A [Pair] containing the [AnnotatedString] and the start index of the highlighted text.
     */
    suspend fun generateLspSnippet(viewModel: MainViewModel, targetFile: FileObject, range: Range): Snippet {
        return withContext(Dispatchers.IO) {
            val openedTab = viewModel.tabs.find { it is EditorTab && it.file == targetFile } as? EditorTab

            // Only read file if it's not already opened as a tab
            val lines =
                if (openedTab != null) {
                    openedTab.editorState.editor.get()?.text.toString().lines()
                } else {
                    targetFile.readText()?.lines() ?: emptyList()
                }

            val targetLine = lines[range.start.line]

            val fileExt = targetFile.getExtension()
            return@withContext generateSnippet(
                text = targetLine,
                highlight = Highlight(range.start.character, range.end.character),
                fileExt = fileExt,
            )
        }
    }
}
