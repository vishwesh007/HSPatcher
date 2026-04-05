package com.rk.settings

import android.app.Activity
import android.content.pm.ActivityInfo

object AppOrientation {
    const val MODE_PORTRAIT = 0
    const val MODE_LANDSCAPE = 1

    fun requestedOrientationFor(mode: Int): Int {
        return when (mode) {
            MODE_LANDSCAPE -> ActivityInfo.SCREEN_ORIENTATION_SENSOR_LANDSCAPE
            else -> ActivityInfo.SCREEN_ORIENTATION_SENSOR_PORTRAIT
        }
    }

    fun apply(activity: Activity) {
        val requestedOrientation = requestedOrientationFor(Settings.app_orientation_mode)
        if (activity.requestedOrientation != requestedOrientation) {
            activity.requestedOrientation = requestedOrientation
        }
    }
}