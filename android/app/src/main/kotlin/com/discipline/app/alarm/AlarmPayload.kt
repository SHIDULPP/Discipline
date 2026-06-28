package com.discipline.app.alarm

import org.json.JSONObject

data class AlarmPayload(
    val taskId: String,
    val heading: String,
    val subHeading: String,
    val startTimeMillis: Long,
    val completionDurationMillis: Long,
    val triggerAtMillis: Long,
    val repeatIntervalMillis: Long,
    val soundEnabled: Boolean,
    val vibrationEnabled: Boolean,
    val isCompleted: Boolean = false,
) {
    fun toJson(): JSONObject = JSONObject().apply {
        put("taskId", taskId)
        put("heading", heading)
        put("subHeading", subHeading)
        put("startTimeMillis", startTimeMillis)
        put("completionDurationMillis", completionDurationMillis)
        put("triggerAtMillis", triggerAtMillis)
        put("repeatIntervalMillis", repeatIntervalMillis)
        put("soundEnabled", soundEnabled)
        put("vibrationEnabled", vibrationEnabled)
        put("isCompleted", isCompleted)
    }

    companion object {
        fun fromJson(json: JSONObject): AlarmPayload = AlarmPayload(
            taskId = json.getString("taskId"),
            heading = json.getString("heading"),
            subHeading = json.getString("subHeading"),
            startTimeMillis = json.optLong("startTimeMillis", json.getLong("triggerAtMillis")),
            completionDurationMillis = json.optLong("completionDurationMillis", 3_600_000L),
            triggerAtMillis = json.getLong("triggerAtMillis"),
            repeatIntervalMillis = json.getLong("repeatIntervalMillis"),
            soundEnabled = json.getBoolean("soundEnabled"),
            vibrationEnabled = json.getBoolean("vibrationEnabled"),
            isCompleted = json.optBoolean("isCompleted", false),
        )

        fun fromMap(map: Map<String, Any?>): AlarmPayload = AlarmPayload(
            taskId = map["taskId"] as String,
            heading = map["heading"] as String,
            subHeading = map["subHeading"] as String,
            startTimeMillis = (map["startTimeMillis"] as? Number)?.toLong()
                ?: (map["triggerAtMillis"] as Number).toLong(),
            completionDurationMillis = (map["completionDurationMillis"] as? Number)?.toLong()
                ?: 3_600_000L,
            triggerAtMillis = (map["triggerAtMillis"] as Number).toLong(),
            repeatIntervalMillis = (map["repeatIntervalMillis"] as Number).toLong(),
            soundEnabled = map["soundEnabled"] as Boolean,
            vibrationEnabled = map["vibrationEnabled"] as Boolean,
            isCompleted = map["isCompleted"] as? Boolean ?: false,
        )
    }
}
