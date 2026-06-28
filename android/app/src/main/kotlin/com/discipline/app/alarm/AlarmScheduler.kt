package com.discipline.app.alarm

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.Settings
import android.util.Log

object AlarmScheduler {
    private const val TAG = "AlarmScheduler"

    fun schedule(context: Context, payload: AlarmPayload) {
        val preferences = AlarmPreferences(context)
        if (payload.isCompleted || preferences.isCompleted(payload.taskId)) {
            cancel(context, payload.taskId)
            return
        }

        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S && !alarmManager.canScheduleExactAlarms()) {
            Log.w(TAG, "Exact alarm permission not granted for ${payload.taskId}")
            return
        }

        preferences.savePayload(payload.copy(isCompleted = false))

        val triggerAt = payload.triggerAtMillis.coerceAtLeast(System.currentTimeMillis() + 1_000)
        val intent = TaskAlarmReceiver.buildIntent(context, payload.taskId)
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            requestCode(payload.taskId),
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        alarmManager.cancel(pendingIntent)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            alarmManager.setExactAndAllowWhileIdle(
                AlarmManager.RTC_WAKEUP,
                triggerAt,
                pendingIntent,
            )
        } else {
            alarmManager.setExact(
                AlarmManager.RTC_WAKEUP,
                triggerAt,
                pendingIntent,
            )
        }

        Log.d(TAG, "Scheduled alarm for ${payload.taskId} at $triggerAt")
    }

    fun cancel(context: Context, taskId: String) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = TaskAlarmReceiver.buildIntent(context, taskId)
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            requestCode(taskId),
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        alarmManager.cancel(pendingIntent)
        pendingIntent.cancel()
        AlarmPreferences(context).removePayload(taskId)
        TaskAlarmForegroundService.stop(context)
        Log.d(TAG, "Cancelled alarm for $taskId")
    }

    fun cancelAll(context: Context) {
        val preferences = AlarmPreferences(context)
        preferences.getAllPayloads().forEach { cancel(context, it.taskId) }
        preferences.clearAll()
        TaskAlarmForegroundService.stop(context)
    }

    fun rescheduleAll(context: Context) {
        val preferences = AlarmPreferences(context)
        preferences.getAllPayloads()
            .filter { !it.isCompleted }
            .forEach { payload ->
                val nextTrigger = if (payload.triggerAtMillis > System.currentTimeMillis()) {
                    payload.triggerAtMillis
                } else {
                    System.currentTimeMillis() + payload.repeatIntervalMillis
                }
                schedule(context, payload.copy(triggerAtMillis = nextTrigger))
            }
    }

    fun canScheduleExactAlarms(context: Context): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) return true
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        return alarmManager.canScheduleExactAlarms()
    }

    fun openExactAlarmSettings(context: Context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) return
        val intent = Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM).apply {
            data = android.net.Uri.parse("package:${context.packageName}")
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        }
        context.startActivity(intent)
    }

    fun requestCode(taskId: String): Int = taskId.hashCode() and 0x7fffffff
}
