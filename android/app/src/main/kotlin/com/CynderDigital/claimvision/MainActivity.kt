package com.CynderDigital.claimvision

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine

// local_auth (huella/Face) requiere una FragmentActivity como host; con
// FlutterActivity, authenticate() lanza `no_fragment_activity` y el prompt
// biométrico nunca aparece.
class MainActivity : FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        DeviceInspectorPlugin.register(flutterEngine, applicationContext)
        ScreenshotProtectionPlugin.register(flutterEngine, this)
    }
}
