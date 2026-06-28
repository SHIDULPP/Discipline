package com.discipline.app.accessibility

import android.content.Context

class EnforcementPreferences(context: Context) {
    private val prefs = context.applicationContext.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

    fun setEnforcementEnabled(enabled: Boolean) {
        prefs.edit().putBoolean(KEY_ENFORCEMENT_ENABLED, enabled).apply()
    }

    fun isEnforcementEnabled(): Boolean =
        prefs.getBoolean(KEY_ENFORCEMENT_ENABLED, false)

    fun setTaskRunning(running: Boolean, taskId: String?) {
        prefs.edit()
            .putBoolean(KEY_TASK_RUNNING, running)
            .putString(KEY_ACTIVE_TASK_ID, taskId)
            .apply()
    }

    fun isTaskRunning(): Boolean = prefs.getBoolean(KEY_TASK_RUNNING, false)

    fun getActiveTaskId(): String? = prefs.getString(KEY_ACTIVE_TASK_ID, null)

    fun isEnforcementActive(): Boolean = isEnforcementEnabled() && isTaskRunning()

    fun setBlockedApps(packages: Set<String>) {
        prefs.edit().putStringSet(KEY_BLOCKED_APPS, packages).apply()
    }

    fun getBlockedApps(): Set<String> {
        return prefs.getStringSet(KEY_BLOCKED_APPS, DEFAULT_BLOCKED_APPS) ?: DEFAULT_BLOCKED_APPS
    }

    fun isBlocked(packageName: String): Boolean = getBlockedApps().contains(packageName)

    companion object {
        private const val PREFS_NAME = "discipline_enforcement"
        private const val KEY_ENFORCEMENT_ENABLED = "enforcement_enabled"
        private const val KEY_TASK_RUNNING = "task_running"
        private const val KEY_ACTIVE_TASK_ID = "active_task_id"
        private const val KEY_BLOCKED_APPS = "blocked_apps"

        val DEFAULT_BLOCKED_APPS: Set<String> = setOf(
            "com.instagram.android",
            "com.google.android.youtube",
            "com.twitter.android",
            "com.facebook.katana",
            "com.snapchat.android",
            "com.zhiliaoapp.musically",
            "com.reddit.frontpage",
            "com.whatsapp",
            "com.facebook.orca",
            "com.discord",
            "com.netflix.mediaclient",
            "com.spotify.music",
            "com.linkedin.android",
            "com.pinterest",
        )

        val DISTRACTION_CANDIDATES: Map<String, String> = mapOf(
            "com.instagram.android" to "Instagram",
            "com.google.android.youtube" to "YouTube",
            "com.twitter.android" to "X (Twitter)",
            "com.facebook.katana" to "Facebook",
            "com.snapchat.android" to "Snapchat",
            "com.zhiliaoapp.musically" to "TikTok",
            "com.reddit.frontpage" to "Reddit",
            "com.whatsapp" to "WhatsApp",
            "com.facebook.orca" to "Messenger",
            "com.discord" to "Discord",
            "com.netflix.mediaclient" to "Netflix",
            "com.spotify.music" to "Spotify",
            "com.linkedin.android" to "LinkedIn",
            "com.pinterest" to "Pinterest",
        )
    }
}
