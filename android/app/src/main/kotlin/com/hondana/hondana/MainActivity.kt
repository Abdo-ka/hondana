package com.hondana

import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Reader screen controls: keep-awake + brightness ("hondana/native").
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "hondana/native")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "keepScreenOn" -> {
                        if (call.argument<Boolean>("on") == true) {
                            window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                        } else {
                            window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                        }
                        result.success(null)
                    }
                    "setBrightness" -> {
                        val value = call.argument<Double>("value")
                        val attributes = window.attributes
                        attributes.screenBrightness = value?.toFloat()
                            ?: WindowManager.LayoutParams.BRIGHTNESS_OVERRIDE_NONE
                        window.attributes = attributes
                        result.success(null)
                    }
                    "getBrightness" ->
                        result.success(window.attributes.screenBrightness.toDouble())
                    else -> result.notImplemented()
                }
            }
    }
}
