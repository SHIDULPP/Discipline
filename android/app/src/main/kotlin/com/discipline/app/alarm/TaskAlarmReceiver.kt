package com.discipline.app.alarm

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class TaskAlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        val taskId = intent?.getStringExtra(EXTRA_TASK_ID) ?: return
        val preferences = AlarmPreferences(context)
        val payload = preferences.getPayload(taskId)

        if (payload == null || payload.isCompleted) {
            AlarmScheduler.cancel(context, taskId)
            return
        }

        Log.d(TAG, "Alarm fired for $taskId")

        TaskAlarmForegroundService.start(context, payload)
        TaskAlarmActivity.launch(context, payload)

        val latest = preferences.getPayload(taskId)
        if (latest == null || latest.isCompleted) {
            TaskAlarmForegroundService.stop(context)
            return
        }

        val nextTrigger = System.currentTimeMillis() + latest.repeatIntervalMillis
        AlarmScheduler.schedule(
            context,
            latest.copy(
                triggerAtMillis = nextTrigger,
                isCompleted = false,
            ),
        )
    }

    companion object {
        private const val TAG = "TaskAlarmReceiver"
        const val ACTION_TASK_ALARM = "com.discipline.app.ACTION_TASK_ALARM"
        const val EXTRA_TASK_ID = "extra_task_id"

        fun buildIntent(context: Context, taskId: String): Intent {
            return Intent(context, TaskAlarmReceiver::class.java).apply {
                action = ACTION_TASK_ALARM
                putExtra(EXTRA_TASK_ID, taskId)
            }
        }
    }
}
