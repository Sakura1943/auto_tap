package com.sakunia.auto_tap

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.accessibilityservice.AccessibilityServiceInfo
import android.view.accessibility.AccessibilityManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.sakunia.auto_tap/clicker"
    private var positionReceiver: BroadcastReceiver? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)

        channel.setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "startClicking" -> {
                        ClickerAccessibilityService.start()
                        result.success(true)
                    }
                    "stopClicking" -> {
                        ClickerAccessibilityService.stop()
                        OverlayService.hide(this)
                        result.success(true)
                    }
                    "updateConfig" -> {
                        val delayMs = call.argument<Int>("delayMs") ?: 1000
                        val clickCount = call.argument<Int>("clickCount") ?: -1
                        ClickerState.delayMs = delayMs.toLong()
                        ClickerState.clickCount = clickCount
                        result.success(mapOf(
                            "delayMs" to ClickerState.delayMs,
                            "clickCount" to ClickerState.clickCount
                        ))
                    }
                    "getState" -> {
                        result.success(mapOf(
                            "isRunning" to ClickerState.isRunning,
                            "delayMs" to ClickerState.delayMs,
                            "clickCount" to ClickerState.clickCount,
                            "currentClicks" to ClickerState.currentClicks,
                            "posX" to ClickerState.posX,
                            "posY" to ClickerState.posY
                        ))
                    }
                    "isAccessibilityEnabled" -> {
                        result.success(isAccessibilityServiceEnabled())
                    }
                    "openAccessibilitySettings" -> {
                        openAccessibilitySettings()
                        result.success(true)
                    }
                    "canDrawOverlays" -> {
                        result.success(
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M)
                                Settings.canDrawOverlays(this)
                            else true
                        )
                    }
                    "openOverlayPermissionSettings" -> {
                        openOverlayPermissionSettings()
                        result.success(true)
                    }
                    "showOverlay" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !Settings.canDrawOverlays(this)) {
                            result.error("NO_PERMISSION", "Overlay permission not granted", null)
                        } else {
                            OverlayService.show(this)
                            result.success(true)
                        }
                    }
                    "hideOverlay" -> {
                        OverlayService.hide(this)
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            } catch (e: Exception) {
                result.error("ERROR", e.message, null)
            }
        }

        positionReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                when (intent?.action) {
                    OverlayService.ACT_POS -> {
                        channel.invokeMethod("positionUpdated", mapOf(
                            "posX" to ClickerState.posX,
                            "posY" to ClickerState.posY
                        ))
                    }
                    OverlayService.ACT_STATE -> {
                        channel.invokeMethod("stateUpdated", mapOf(
                            "isRunning" to ClickerState.isRunning
                        ))
                    }
                }
            }
        }
        try {
            val filter = IntentFilter().apply {
                addAction(OverlayService.ACT_POS)
                addAction(OverlayService.ACT_STATE)
            }
            registerReceiver(positionReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } catch (_: Exception) {}
    }

    override fun onDestroy() {
        positionReceiver?.let {
            try { unregisterReceiver(it) } catch (_: Exception) {}
        }
        super.onDestroy()
    }

    private fun isAccessibilityServiceEnabled(): Boolean {
        return try {
            val expectedComponent = android.content.ComponentName(
                this,
                ClickerAccessibilityService::class.java
            )
            val am = getSystemService(Context.ACCESSIBILITY_SERVICE) as AccessibilityManager
            val enabled = am.getEnabledAccessibilityServiceList(AccessibilityServiceInfo.FEEDBACK_ALL_MASK)
            for (info in enabled) {
                val infoComponent = android.content.ComponentName.unflattenFromString(info.id)
                if (infoComponent?.equals(expectedComponent) == true) {
                    return true
                }
            }
            false
        } catch (e: Exception) {
            android.util.Log.e("Clicker", "检查无障碍服务状态失败", e)
            false
        }
    }

    private fun openAccessibilitySettings() {
        val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
        startActivity(intent)
    }

    private fun openOverlayPermissionSettings() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val intent = Intent(
                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                Uri.parse("package:$packageName")
            )
            startActivity(intent)
        }
    }
}
