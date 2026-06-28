package com.discipline.app.alarm

import android.app.Activity
import android.content.Intent
import android.graphics.Color
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.View
import android.view.WindowInsets
import android.view.WindowInsetsController
import android.view.WindowManager
import android.widget.Button
import android.widget.TextView
import android.widget.Toast
import androidx.core.content.ContextCompat
import com.discipline.app.MainActivity
import com.discipline.app.R
import kotlin.math.max

class TaskAlarmActivity : Activity() {
    private val handler = Handler(Looper.getMainLooper())
    private var payload: AlarmPayload? = null
    private var taskId: String? = null

    private lateinit var elapsedView: TextView
    private lateinit var headingView: TextView
    private lateinit var subheadingView: TextView

    private val tickRunnable = object : Runnable {
        override fun run() {
            updateElapsed()
            handler.postDelayed(this, 1000L)
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        configureWindow()
        if (!bindPayload(intent)) return
        setupUi()
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        if (bindPayload(intent)) {
            setupUi()
        }
    }

    override fun onResume() {
        super.onResume()
        handler.post(tickRunnable)
    }

    override fun onPause() {
        handler.removeCallbacks(tickRunnable)
        super.onPause()
    }

    private fun configureWindow() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        } else {
            @Suppress("DEPRECATION")
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                    WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON,
            )
        }

        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            window.setDecorFitsSystemWindows(false)
            window.decorView.windowInsetsController?.let { controller ->
                controller.hide(WindowInsets.Type.statusBars() or WindowInsets.Type.navigationBars())
                controller.systemBarsBehavior =
                    WindowInsetsController.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
            }
        } else {
            @Suppress("DEPRECATION")
            window.decorView.systemUiVisibility = (
                View.SYSTEM_UI_FLAG_LAYOUT_STABLE or
                    View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN or
                    View.SYSTEM_UI_FLAG_FULLSCREEN or
                    View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
                )
            @Suppress("DEPRECATION")
            window.statusBarColor = Color.TRANSPARENT
        }
    }

    private fun bindPayload(intent: Intent): Boolean {
        val id = intent.getStringExtra(EXTRA_TASK_ID) ?: run {
            finish()
            return false
        }

        val preferences = AlarmPreferences(this)
        val data = preferences.getPayload(id) ?: run {
            finish()
            return false
        }

        if (data.isCompleted) {
            finish()
            return false
        }

        taskId = id
        payload = data
        return true
    }

    private fun setupUi() {
        val data = payload ?: return
        setContentView(R.layout.activity_task_alarm)

        elapsedView = findViewById(R.id.alarm_elapsed)
        headingView = findViewById(R.id.alarm_heading)
        subheadingView = findViewById(R.id.alarm_subheading)

        headingView.text = data.heading
        subheadingView.text = data.subHeading.ifBlank {
            getString(R.string.alarm_default_subtitle)
        }

        val snoozeMinutes = max(1, (data.repeatIntervalMillis / 60_000L).toInt())
        findViewById<Button>(R.id.btn_snooze).text =
            getString(R.string.alarm_snooze) + " · ${snoozeMinutes}m"

        updateElapsed()

        findViewById<Button>(R.id.btn_done).setOnClickListener { onDone() }
        findViewById<Button>(R.id.btn_snooze).setOnClickListener { onSnooze(data, snoozeMinutes) }
        findViewById<Button>(R.id.btn_continue).setOnClickListener { onContinue() }
    }

    private fun updateElapsed() {
        val data = payload ?: return
        val now = System.currentTimeMillis()
        val elapsed = ElapsedTimeFormatter.format(data.startTimeMillis, now)
        elapsedView.text = if (elapsed == "Waiting") {
            getString(R.string.alarm_elapsed_waiting)
        } else {
            elapsed
        }

        val overdue = ElapsedTimeFormatter.isOverdue(
            data.startTimeMillis,
            data.completionDurationMillis,
            now,
        )
        elapsedView.setTextColor(
            if (overdue) {
                ContextCompat.getColor(this, R.color.alarm_overdue)
            } else {
                ContextCompat.getColor(this, R.color.alarm_primary_text)
            },
        )
    }

    private fun onDone() {
        val id = taskId ?: return
        val preferences = AlarmPreferences(this)
        preferences.addPendingCompletion(id)
        preferences.setCompleted(id, true)
        AlarmScheduler.cancel(this, id)
        stopAlarmEffects()
        launchMainApp(id)
        finish()
    }

    private fun onSnooze(data: AlarmPayload, snoozeMinutes: Int) {
        val snoozeAt = System.currentTimeMillis() + data.repeatIntervalMillis
        AlarmScheduler.schedule(
            this,
            data.copy(
                triggerAtMillis = snoozeAt,
                isCompleted = false,
            ),
        )
        stopAlarmEffects()
        Toast.makeText(
            this,
            getString(R.string.alarm_snooze_toast, snoozeMinutes),
            Toast.LENGTH_SHORT,
        ).show()
        finish()
    }

    private fun onContinue() {
        stopAlarmEffects()
        finish()
    }

    private fun stopAlarmEffects() {
        TaskAlarmForegroundService.stop(this)
    }

    private fun launchMainApp(taskId: String) {
        val intent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra(EXTRA_TASK_ID, taskId)
            putExtra(EXTRA_FROM_ALARM, true)
        }
        startActivity(intent)
    }

    companion object {
        const val EXTRA_TASK_ID = "extra_task_id"
        const val EXTRA_FROM_ALARM = "extra_from_alarm"

        fun launch(context: android.content.Context, payload: AlarmPayload) {
            context.startActivity(buildIntent(context, payload))
        }

        fun buildIntent(context: android.content.Context, payload: AlarmPayload): Intent {
            return Intent(context, TaskAlarmActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or
                    Intent.FLAG_ACTIVITY_CLEAR_TOP or
                    Intent.FLAG_ACTIVITY_SINGLE_TOP
                putExtra(EXTRA_TASK_ID, payload.taskId)
            }
        }
    }
}
