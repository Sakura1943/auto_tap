package com.sakunia.auto_tap

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.GestureDescription
import android.graphics.Path
import android.os.Handler
import android.os.Looper
import android.view.accessibility.AccessibilityEvent

class ClickerAccessibilityService : AccessibilityService() {

    private val handler = Handler(Looper.getMainLooper())

    private val tick = object : Runnable {
        override fun run() {
            if (!ClickerState.shouldContinue()) {
                stopService()
                return
            }
            performClick(ClickerState.posX, ClickerState.posY)
            ClickerState.currentClicks++
            handler.postDelayed(this, ClickerState.delayMs)
        }
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {}

    override fun onInterrupt() {
        stopService()
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        instance = this
    }

    override fun onDestroy() {
        instance = null
        handler.removeCallbacks(tick)
        super.onDestroy()
    }

    private fun stopService() {
        ClickerState.isRunning = false
        handler.removeCallbacks(tick)
    }

    private fun performClick(x: Float, y: Float) {
        try {
            val path = Path().apply {
                moveTo(x, y)
                lineTo(x + 1f, y)
            }
            dispatchGesture(
                GestureDescription.Builder()
                    .addStroke(GestureDescription.StrokeDescription(path, 0, 50))
                    .build(),
                null, null
            )
        } catch (_: Exception) {}
    }

    companion object {
        var instance: ClickerAccessibilityService? = null
            private set

        fun start() {
            ClickerState.isRunning = true
            ClickerState.reset()
            instance?.let { svc ->
                svc.handler.removeCallbacks(svc.tick)
                svc.handler.post(svc.tick)
            }
        }

        fun stop() {
            ClickerState.isRunning = false
            instance?.let { svc ->
                svc.handler.removeCallbacks(svc.tick)
            }
        }
    }
}
