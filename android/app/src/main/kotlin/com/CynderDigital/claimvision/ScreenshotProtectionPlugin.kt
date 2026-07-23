package com.CynderDigital.claimvision

import android.app.Activity
import android.os.Build
import android.view.WindowManager
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class ScreenshotProtectionPlugin(private val activity: Activity) {

    fun enable(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB) {
            activity.window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
        }
        result.success(true)
    }

    fun disable(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB) {
            activity.window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
        }
        result.success(true)
    }

    companion object {
        const val CHANNEL = "com.claimvision/screenshot_protection"

        fun register(flutterEngine: FlutterEngine, activity: Activity) {
            val plugin = ScreenshotProtectionPlugin(activity)
            MethodChannel(
                flutterEngine.dartExecutor.binaryMessenger,
                CHANNEL
            ).setMethodCallHandler { call, result ->
                when (call.method) {
                    "enableScreenshotProtection" -> plugin.enable(result)
                    "disableScreenshotProtection" -> plugin.disable(result)
                    else -> result.notImplemented()
                }
            }
        }
    }
}
