package com.discipline.app.alarm

import android.content.Context
import org.json.JSONObject

class AlarmPreferences(context: Context) {
    private val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

    fun savePayload(payload: AlarmPayload) {
        prefs.edit()
            .putString(alarmKey(payload.taskId), payload.toJson().toString())
            .apply()
    }

    fun getPayload(taskId: String): AlarmPayload? {
        val raw = prefs.getString(alarmKey(taskId), null) ?: return null
        return AlarmPayload.fromJson(JSONObject(raw))
    }

    fun getAllPayloads(): List<AlarmPayload> {
        return prefs.all.mapNotNull { (key, value) ->
            if (!key.startsWith(ALARM_PREFIX) || value !is String) return@mapNotNull null
            runCatching { AlarmPayload.fromJson(JSONObject(value)) }.getOrNull()
        }
    }

    fun removePayload(taskId: String) {
        prefs.edit().remove(alarmKey(taskId)).apply()
    }

    fun clearAll() {
        val keys = prefs.all.keys.filter { it.startsWith(ALARM_PREFIX) }
        if (keys.isEmpty()) return
        val editor = prefs.edit()
        keys.forEach(editor::remove)
        editor.apply()
    }

    fun setCompleted(taskId: String, completed: Boolean) {
        val payload = getPayload(taskId) ?: return
        savePayload(payload.copy(isCompleted = completed))
    }

    fun isCompleted(taskId: String): Boolean = getPayload(taskId)?.isCompleted == true

    fun addPendingCompletion(taskId: String) {
        val current = prefs.getStringSet(PENDING_COMPLETIONS_KEY, emptySet())?.toMutableSet()
            ?: mutableSetOf()
        current.add(taskId)
        prefs.edit().putStringSet(PENDING_COMPLETIONS_KEY, current).apply()
    }

    fun consumePendingCompletions(): Set<String> {
        val current = prefs.getStringSet(PENDING_COMPLETIONS_KEY, emptySet()) ?: emptySet()
        prefs.edit().remove(PENDING_COMPLETIONS_KEY).apply()
        return current
    }

    private fun alarmKey(taskId: String) = "$ALARM_PREFIX$taskId"

    companion object {
        private const val PREFS_NAME = "discipline_alarms"
        private const val ALARM_PREFIX = "alarm_"
        private const val PENDING_COMPLETIONS_KEY = "pending_completions"
    }
}
