package com.rk.search

import java.util.Locale

internal class FastLiteralMatcher private constructor(
    private val ignoreCase: Boolean,
    pattern: String,
) {
    private val normalizedPattern: CharArray = normalize(pattern).toCharArray()
    private val patternLength = normalizedPattern.size
    private val lastPatternIndex = patternLength - 1
    private val shifts = IntArray(65536) { patternLength }

    init {
        for (index in 0 until lastPatternIndex) {
            shifts[normalizedPattern[index].code] = lastPatternIndex - index
        }
    }

    fun findAll(text: String): List<Int> {
        if (patternLength == 0 || text.length < patternLength) return emptyList()

        val matches = ArrayList<Int>()
        val len = text.length
        var start = 0

        if (ignoreCase) {
            // Case-insensitive: compare char-by-char with lowercase, no string allocation
            while (start <= len - patternLength) {
                var patternIndex = lastPatternIndex
                while (patternIndex >= 0 &&
                    text[start + patternIndex].lowercaseChar() == normalizedPattern[patternIndex]
                ) {
                    patternIndex--
                }
                if (patternIndex < 0) {
                    matches.add(start)
                    start += patternLength
                    continue
                }
                start += shifts[text[start + lastPatternIndex].lowercaseChar().code].coerceAtLeast(1)
            }
        } else {
            // Case-sensitive: direct char comparison, no allocation
            while (start <= len - patternLength) {
                var patternIndex = lastPatternIndex
                while (patternIndex >= 0 && text[start + patternIndex] == normalizedPattern[patternIndex]) {
                    patternIndex--
                }
                if (patternIndex < 0) {
                    matches.add(start)
                    start += patternLength
                    continue
                }
                start += shifts[text[start + lastPatternIndex].code].coerceAtLeast(1)
            }
        }

        return matches
    }

    inline fun forEachMatch(text: String, onMatch: (Int) -> Boolean) {
        if (patternLength == 0 || text.length < patternLength) return

        val len = text.length
        var start = 0

        if (ignoreCase) {
            while (start <= len - patternLength) {
                var patternIndex = lastPatternIndex
                while (patternIndex >= 0 &&
                    text[start + patternIndex].lowercaseChar() == normalizedPattern[patternIndex]
                ) {
                    patternIndex--
                }
                if (patternIndex < 0) {
                    if (!onMatch(start)) return
                    start += patternLength
                    continue
                }
                start += shifts[text[start + lastPatternIndex].lowercaseChar().code].coerceAtLeast(1)
            }
        } else {
            while (start <= len - patternLength) {
                var patternIndex = lastPatternIndex
                while (patternIndex >= 0 && text[start + patternIndex] == normalizedPattern[patternIndex]) {
                    patternIndex--
                }
                if (patternIndex < 0) {
                    if (!onMatch(start)) return
                    start += patternLength
                    continue
                }
                start += shifts[text[start + lastPatternIndex].code].coerceAtLeast(1)
            }
        }
    }

    private fun normalize(value: String): String {
        return if (ignoreCase) value.lowercase(Locale.ROOT) else value
    }

    companion object {
        fun compile(pattern: String, ignoreCase: Boolean): FastLiteralMatcher {
            return FastLiteralMatcher(ignoreCase, pattern)
        }
    }
}