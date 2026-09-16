package com.minikkalpler.minik_kalpler

import android.content.Context
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
  private val hapticsChannel = "minik_kalpler/haptics"

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, hapticsChannel)
      .setMethodCallHandler { call, result ->
        when (call.method) {
          "vibrate" -> {
            val ms = (call.argument<Number>("ms")?.toLong() ?: 35L).coerceIn(10L, 120L)
            vibrate(ms)
            result.success(null)
          }
          else -> result.notImplemented()
        }
      }
  }

  private fun vibrate(ms: Long) {
    val vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
      val manager = getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
      manager.defaultVibrator
    } else {
      @Suppress("DEPRECATION")
      getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
    }
    if (!vibrator.hasVibrator()) return
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      vibrator.vibrate(
        VibrationEffect.createOneShot(ms, VibrationEffect.DEFAULT_AMPLITUDE),
      )
    } else {
      @Suppress("DEPRECATION")
      vibrator.vibrate(ms)
    }
  }
}
