package com.sakunia.auto_tap

object ClickerState {
    var isRunning: Boolean = false
    var delayMs: Long = 1000L
    var clickCount: Int = -1
    var currentClicks: Int = 0
    var posX: Float = 500f
    var posY: Float = 500f

    fun reset() {
        currentClicks = 0
    }

    fun shouldContinue(): Boolean {
        if (!isRunning) return false
        if (clickCount < 0) return true
        return currentClicks < clickCount
    }
}
