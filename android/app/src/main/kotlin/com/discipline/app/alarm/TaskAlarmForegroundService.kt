package com.discipline.app.alarm

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.Ringtone
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.os.IBinder
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import androidx.core.app.NotificationCompat

class TaskAlarmForegroundService : Service() {
    private var ringtone: Ringtone? = null

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val taskId = intent?.getStringExtra(EXTRA_TASK_ID) ?: run {
            stopSelf()
            return START_NOT_STICKY
        }

        val payload = AlarmPreferences(this).getPayload(taskId) ?: run {
            stopSelf()
            return START_NOT_STICKY
        }

        if (payload.isCompleted) {
            stopSelf()
            return START_NOT_STICKY
        }

        createChannel()
        val notification = buildNotification(payload)
        startForeground(NOTIFICATION_ID, notification)

        if (payload.soundEnabled) {
            playAlarmSound()
        }
        if (payload.vibrationEnabled) {
            vibrate()
        }

        return START_NOT_STICKY
    }

    override fun onDestroy() {
        stopEffects()
        super.onDestroy()
    }

    private fun playAlarmSound() {
        val uri: Uri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
            ?: RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
        ringtone = RingtoneManager.getRingtone(this, uri)?.apply {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                isLooping = true
                audioAttributes = AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_ALARM)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .build()
            }
            play()
        }
    }

    private fun vibrate() {
        val pattern = longArrayOf(0, 800, 400, 800, 400, 800)
        val vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            (getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager)
                .defaultVibrator
        } else {
            @Suppress("DEPRECATION")
            getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
        }

        activeVibrator = vibrator
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            vibrator.vibrate(VibrationEffect.createWaveform(pattern, 0))
        } else {
            @Suppress("DEPRECATION")
            vibrator.vibrate(pattern, 0)
        }
    }

    private fun stopEffects() {
        ringtone?.stop()
        ringtone = null
        activeVibrator?.cancel()
        if (activeVibrator != null) {
            activeVibrator = null
        }
    }

    private fun buildNotification(payload: AlarmPayload): Notification {
        val fullScreenIntent = TaskAlarmActivity.buildIntent(this, payload)
        val fullScreenPendingIntent = PendingIntent.getActivity(
            this,
            AlarmScheduler.requestCode(payload.taskId) + 1,
            fullScreenIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .setContentTitle(payload.heading)
            .setContentText(payload.subHeading.ifBlank { "Task reminder" })
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setOngoing(true)
            .setAutoCancel(false)
            .setFullScreenIntent(fullScreenPendingIntent, true)
            .setContentIntent(fullScreenPendingIntent)
            .build()
    }

    private fun createChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val channel = NotificationChannel(
            CHANNEL_ID,
            "Task Alarms",
            NotificationManager.IMPORTANCE_HIGH,
        ).apply {
            description = "Discipline task enforcement alarms"
            setBypassDnd(true)
            lockscreenVisibility = Notification.VISIBILITY_PUBLIC
            val soundUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
            setSound(
                soundUri,
                AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_ALARM)
                    .build(),
            )
            enableVibration(true)
        }
        val manager = getSystemService(NotificationManager::class.java)
        manager.createNotificationChannel(channel)
    }

    companion object {
        private const val CHANNEL_ID = "discipline_task_alarms"
        private const val NOTIFICATION_ID = 7001
        private const val EXTRA_TASK_ID = "extra_task_id"

        @Volatile
        private var activeVibrator: Vibrator? = null

        fun start(context: Context, payload: AlarmPayload) {
            val intent = Intent(context, TaskAlarmForegroundService::class.java).apply {
                putExtra(EXTRA_TASK_ID, payload.taskId)
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
        }

        fun stop(context: Context) {
            activeVibrator?.cancel()
            activeVibrator = null
            context.stopService(Intent(context, TaskAlarmForegroundService::class.java))
            val manager = context.getSystemService(NotificationManager::class.java)
            manager.cancel(NOTIFICATION_ID)
        }
    }
}
