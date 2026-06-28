package com.discipline.app.platform

import android.content.Context
import com.discipline.app.accessibility.AccessibilityUtils
import com.discipline.app.accessibility.EnforcementPreferences
import com.discipline.app.alarm.AlarmPayload
import com.discipline.app.alarm.AlarmPreferences
import com.discipline.app.alarm.AlarmScheduler
import com.discipline.app.platform.BatteryOptimizationUtils
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class DisciplineMethodChannel(
    private val context: Context,
    flutterEngine: FlutterEngine,
) {
    private val channel = MethodChannel(
        flutterEngine.dartExecutor.binaryMessenger,
        CHANNEL_NAME,
    )

    init {
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "scheduleExactAlarm" -> {
                    val args = call.arguments as? Map<*, *> ?: run {
                        result.error("invalid_args", "Missing arguments", null)
                        return@setMethodCallHandler
                    }
                    try {
                        val payload = AlarmPayload.fromMap(args as Map<String, Any?>)
                        AlarmScheduler.schedule(context, payload)
                        result.success(true)
                    } catch (error: Exception) {
                        result.error("schedule_failed", error.message, null)
                    }
                }

                "cancelExactAlarm" -> {
                    val taskId = call.argument<String>("taskId")
                    if (taskId.isNullOrBlank()) {
                        result.error("invalid_args", "taskId required", null)
                        return@setMethodCallHandler
                    }
                    AlarmScheduler.cancel(context, taskId)
                    result.success(true)
                }

                "cancelAllAlarms" -> {
                    AlarmScheduler.cancelAll(context)
                    result.success(true)
                }

                "rescheduleAllAlarms" -> {
                    AlarmScheduler.rescheduleAll(context)
                    result.success(true)
                }

                "syncTaskCompletion" -> {
                    val taskId = call.argument<String>("taskId")
                    val isCompleted = call.argument<Boolean>("isCompleted") ?: false
                    if (taskId.isNullOrBlank()) {
                        result.error("invalid_args", "taskId required", null)
                        return@setMethodCallHandler
                    }
                    if (isCompleted) {
                        AlarmScheduler.cancel(context, taskId)
                    } else {
                        AlarmPreferences(context).setCompleted(taskId, false)
                    }
                    result.success(true)
                }

                "getPendingCompletions" -> {
                    val pending = AlarmPreferences(context).consumePendingCompletions()
                    result.success(pending.toList())
                }

                "canScheduleExactAlarms" -> {
                    result.success(AlarmScheduler.canScheduleExactAlarms(context))
                }

                "openExactAlarmSettings" -> {
                    AlarmScheduler.openExactAlarmSettings(context)
                    result.success(true)
                }

                "isAccessibilityEnabled" -> {
                    result.success(AccessibilityUtils.isServiceEnabled(context))
                }

                "openAccessibilitySettings" -> {
                    AccessibilityUtils.openAccessibilitySettings(context)
                    result.success(true)
                }

                "setEnforcementState" -> {
                    val enforcementEnabled = call.argument<Boolean>("enforcementEnabled") ?: false
                    val isTaskRunning = call.argument<Boolean>("isTaskRunning") ?: false
                    val activeTaskId = call.argument<String>("activeTaskId")
                    val preferences = EnforcementPreferences(context)
                    preferences.setEnforcementEnabled(enforcementEnabled)
                    preferences.setTaskRunning(isTaskRunning, activeTaskId)
                    result.success(true)
                }

                "setBlockedApps" -> {
                    val packages = call.argument<List<String>>("packages")
                    if (packages == null) {
                        result.error("invalid_args", "packages required", null)
                        return@setMethodCallHandler
                    }
                    EnforcementPreferences(context).setBlockedApps(packages.toSet())
                    result.success(true)
                }

                "getBlockedApps" -> {
                    val blocked = EnforcementPreferences(context).getBlockedApps().toList()
                    result.success(blocked)
                }

                "getInstalledDistractionApps" -> {
                    val apps = AccessibilityUtils.getInstalledCandidates(context)
                    result.success(apps)
                }

                "isIgnoringBatteryOptimizations" -> {
                    result.success(
                        BatteryOptimizationUtils.isIgnoringBatteryOptimizations(context),
                    )
                }

                "openBatteryOptimizationSettings" -> {
                    BatteryOptimizationUtils.openBatteryOptimizationSettings(context)
                    result.success(true)
                }

                else -> result.notImplemented()
            }
        }
    }

    companion object {
        const val CHANNEL_NAME = "com.discipline.app/platform"
    }
}
