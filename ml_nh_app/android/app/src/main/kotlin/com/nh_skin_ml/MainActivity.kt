package com.nh_skin_ml

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.nh_skin_ml/app_launcher"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "launchGame") {
                var intent = packageManager.getLaunchIntentForPackage("com.mobile.legends")
                if (intent == null) {
                    intent = packageManager.getLaunchIntentForPackage("com.vng.mlbb")
                }
                if (intent != null) {
                    startActivity(intent)
                    result.success(true)
                } else {
                    result.error("UNAVAILABLE", "Mobile Legends is not installed on this device", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
