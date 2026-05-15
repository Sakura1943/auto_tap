package com.sakunia.auto_tap

import android.app.*
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.ServiceInfo
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.os.IBinder
import android.view.Gravity
import android.view.MotionEvent
import android.view.WindowManager
import android.widget.TextView
import androidx.core.app.NotificationCompat

class OverlayService : Service() {

    private lateinit var wm: WindowManager
    private var btn: TextView? = null
    private var params: WindowManager.LayoutParams? = null
    private var isClicking = false
    private var hasMoved = false
    private var downRawX = 0f
    private var downRawY = 0f
    private var startX = 0
    private var startY = 0
    private var btnSize = 0
    private var hitOffset = 0 // 点击位置在按钮下方的偏移量

    private val hideR = object : BroadcastReceiver() {
        override fun onReceive(c: Context?, i: Intent?) { stopAndHide() }
    }

    override fun onCreate() {
        super.onCreate()
        wm = getSystemService(WINDOW_SERVICE) as WindowManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val ch = NotificationChannel(CH, "点击器", NotificationManager.IMPORTANCE_LOW)
            ch.description = "屏幕点击器"
            getSystemService(NotificationManager::class.java).createNotificationChannel(ch)
        }
        val f = IntentFilter(ACT_HIDE)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU)
            registerReceiver(hideR, f, Context.RECEIVER_NOT_EXPORTED)
        else registerReceiver(hideR, f)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        try {
            val n = NotificationCompat.Builder(this, CH)
                .setContentTitle("屏幕点击器")
                .setContentText("拖拽移动位置（点击在圆圈下方）")
                .setSmallIcon(R.drawable.ic_notification)
                .setPriority(NotificationCompat.PRIORITY_LOW)
                .setOngoing(true).build()
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE)
                startForeground(NID, n, ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE)
            else startForeground(NID, n)
        } catch (_: Exception) {}
        show()
        return START_STICKY
    }

    override fun onBind(i: Intent?): IBinder? = null
    override fun onDestroy() { stopAndHide(); try { unregisterReceiver(hideR) } catch (_: Exception) {}; super.onDestroy() }

    // ── show ──────────────────────────────────────────────
    private fun show() {
        if (btn != null) return
        val d = resources.displayMetrics.density
        val dp = 48
        btnSize = (dp * d).toInt()
        hitOffset = btnSize / 2 + (10 * d).toInt() // 圆心到点击点 = 半径 + 10dp 间距

        btn = TextView(this).apply {
            text = "▶"
            textSize = 22f
            gravity = Gravity.CENTER
            setTextColor(Color.WHITE)
            bg(false)
            elevation = 8f * d
        }

        params = WindowManager.LayoutParams(
            btnSize, btnSize,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            else WindowManager.LayoutParams.TYPE_PHONE,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
                    WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            // 按钮显示在点击位置上方
            x = ClickerState.posX.toInt() - btnSize / 2
            y = ClickerState.posY.toInt() - hitOffset - btnSize / 2
        }

        startX = params!!.x; startY = params!!.y

        btn?.setOnTouchListener { v, e ->
            when (e.action) {
                MotionEvent.ACTION_DOWN -> {
                    downRawX = e.rawX; downRawY = e.rawY
                    startX = params!!.x; startY = params!!.y
                    hasMoved = false; true
                }
                MotionEvent.ACTION_MOVE -> {
                    val dx = e.rawX - downRawX; val dy = e.rawY - downRawY
                    if (Math.abs(dx) > 5 || Math.abs(dy) > 5) hasMoved = true
                    if (hasMoved) {
                        params!!.x = (startX + dx).toInt()
                        params!!.y = (startY + dy).toInt()
                        wm.updateViewLayout(v, params)
                        // 拖动时实时更新点击位置，让注入点击跟随圆圈移动
                        ClickerState.posX = (params!!.x + btnSize / 2).toFloat()
                        ClickerState.posY = (params!!.y + btnSize / 2 + hitOffset).toFloat()
                    }; true
                }
                MotionEvent.ACTION_UP -> {
                    if (hasMoved) {
                        ClickerState.posX = (params!!.x + btnSize / 2).toFloat()
                        ClickerState.posY = (params!!.y + btnSize / 2 + hitOffset).toFloat()
                        sendBroadcast(Intent(ACT_POS).setPackage(packageName))
                    } else {
                        toggle()
                    }; true
                }
                else -> false
            }
        }
        try { wm.addView(btn, params) } catch (ex: Exception) {}
    }

    private fun toggle() {
        if (isClicking) {
            ClickerAccessibilityService.stop()
            isClicking = false
            btn?.apply { text = "▶"; bg(false) }
        } else {
            ClickerState.isRunning = true
            ClickerState.reset()
            ClickerAccessibilityService.start()
            isClicking = true
            btn?.apply { text = "⏸"; bg(true) }
        }
        sendBroadcast(Intent(ACT_STATE).setPackage(packageName))
    }

    private fun stopAndHide() {
        if (isClicking) { ClickerAccessibilityService.stop(); isClicking = false }
        btn?.let { try { wm.removeView(it) } catch (_: Exception) {} }; btn = null
        stopForeground(STOP_FOREGROUND_REMOVE); stopSelf()
    }

    private fun TextView.bg(active: Boolean) {
        val d = resources.displayMetrics.density
        background = GradientDrawable().apply {
            shape = GradientDrawable.OVAL
            setColor(if (active) Color.parseColor("#FF5722") else Color.parseColor("#4CAF50"))
            setStroke((2.5f * d).toInt(), Color.WHITE)
        }
    }

    companion object {
        const val CH = "clicker_ch"; const val NID = 1001
        const val ACT_HIDE = "com.sakunia.auto_tap.HIDE"
        const val ACT_POS = "com.sakunia.auto_tap.POS"
        const val ACT_STATE = "com.sakunia.auto_tap.STATE"
        fun show(ctx: Context) {
            val i = Intent(ctx, OverlayService::class.java)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) ctx.startForegroundService(i)
            else ctx.startService(i)
        }
        fun hide(ctx: Context) { ctx.sendBroadcast(Intent(ACT_HIDE).setPackage(ctx.packageName)) }
    }
}
