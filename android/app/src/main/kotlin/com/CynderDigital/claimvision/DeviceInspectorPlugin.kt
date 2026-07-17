package com.CynderDigital.claimvision

import android.content.Context
import android.content.pm.ApplicationInfo
import android.location.LocationManager
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class DeviceInspectorPlugin(private val context: Context) {

    fun inspect(result: MethodChannel.Result) {
        val map = mapOf(
            "isDeveloperOptionsEnabled" to isDeveloperOptionsEnabled(),
            "isAdbEnabled" to isAdbEnabled(),
            "isAppDebuggable" to isAppDebuggable(),
            "isMockLocationActive" to isMockLocationActive(),
            "isEmulator" to isEmulator(),
        )
        result.success(map)
    }

    private fun isDeveloperOptionsEnabled(): Boolean {
        return try {
            Settings.Global.getInt(
                context.contentResolver,
                Settings.Global.DEVELOPMENT_SETTINGS_ENABLED,
                0
            ) == 1
        } catch (_: Exception) {
            false
        }
    }

    private fun isAdbEnabled(): Boolean {
        return try {
            Settings.Global.getInt(
                context.contentResolver,
                Settings.Global.ADB_ENABLED,
                0
            ) == 1
        } catch (_: Exception) {
            false
        }
    }

    private fun isAppDebuggable(): Boolean {
        return try {
            (context.applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE) != 0
        } catch (_: Exception) {
            false
        }
    }

    private fun isMockLocationActive(): Boolean {
        return try {
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
                val allowMock = Settings.Secure.getInt(
                    context.contentResolver,
                    Settings.Secure.ALLOW_MOCK_LOCATION,
                    0
                )
                if (allowMock == 1) return true
            }

            val locationManager =
                context.getSystemService(Context.LOCATION_SERVICE) as LocationManager
            for (provider in locationManager.allProviders) {
                if (locationManager.isProviderEnabled(provider)) {
                    try {
                        val location = locationManager.getLastKnownLocation(provider)
                        if (location != null && location.isFromMockProvider) return true
                    } catch (_: Exception) { }
                }
            }
            false
        } catch (_: Exception) {
            false
        }
    }

    private fun isEmulator(): Boolean {
        return try {
            val buildFingerprint = Build.FINGERPRINT?.lowercase() ?: ""
            if (buildFingerprint.startsWith("google/sdk_gphone") ||
                buildFingerprint.startsWith("generic") ||
                buildFingerprint.contains("emu64")
            ) return true

            val board = Build.BOARD.lowercase()
            if (board in listOf("goldfish", "ranchu", "vega")) return true

            val hardware = Build.HARDWARE.lowercase()
            if (hardware in listOf("goldfish", "ranchu")) return true

            val qemuFiles = listOf(
                "/system/bin/qemu-props",
                "/dev/socket/qemud",
                "/system/lib/libc_malloc_debug_qemu.so",
            )
            if (qemuFiles.any { File(it).exists() }) return true

            false
        } catch (_: Exception) {
            false
        }
    }

    companion object {
        const val CHANNEL = "com.claimvision/device_inspector"

        fun register(flutterEngine: FlutterEngine, context: Context) {
            val plugin = DeviceInspectorPlugin(context)
            MethodChannel(
                flutterEngine.dartExecutor.binaryMessenger,
                CHANNEL
            ).setMethodCallHandler { call, result ->
                if (call.method == "inspect") {
                    plugin.inspect(result)
                } else {
                    result.notImplemented()
                }
            }
        }
    }
}
