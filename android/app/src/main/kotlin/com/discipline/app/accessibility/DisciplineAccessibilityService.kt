package com.discipline.app.accessibility

import android.accessibilityservice.AccessibilityService
import android.content.Intent
import android.view.accessibility.AccessibilityEvent
import android.util.Log
import com.discipline.app.MainActivity

class DisciplineAccessibilityService : AccessibilityService() {
    private lateinit var preferences: EnforcementPreferences
    private var lastRedirectAt = 0L

    override fun onServiceConnected() {
        super.onServiceConnected()
        preferences = EnforcementPreferences(this)
        Log.d(TAG, "Accessibility service connected")
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return
        if (event.eventType != AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) return

        val foregroundPackage = event.packageName?.toString() ?: return
        if (!::preferences.isInitialized) {
            preferences = EnforcementPreferences(this)
        }

        if (!preferences.isEnforcementActive()) return
        if (foregroundPackage == packageName) return
        if (IGNORED_PACKAGES.contains(foregroundPackage)) return
        if (!preferences.isBlocked(foregroundPackage)) return

        val now = System.currentTimeMillis()
        if (now - lastRedirectAt < REDIRECT_DEBOUNCE_MS) return
        lastRedirectAt = now

        Log.d(TAG, "Blocked app detected: $foregroundPackage — returning to Discipline")
        bringDisciplineToFront()
    }

    override fun onInterrupt() {
        Log.w(TAG, "Accessibility service interrupted")
    }

    private fun bringDisciplineToFront() {
        val launchIntent = Intent(this, MainActivity::class.java).apply {
            addFlags(
                Intent.FLAG_ACTIVITY_NEW_TASK or
                    Intent.FLAG_ACTIVITY_CLEAR_TOP or
                    Intent.FLAG_ACTIVITY_SINGLE_TOP,
            )
            putExtra(EXTRA_REDIRECTED_FROM_BLOCKED_APP, true)
        }
        startActivity(launchIntent)
    }

    companion object {
        private const val TAG = "DisciplineA11y"
        private const val REDIRECT_DEBOUNCE_MS = 800L
        const val EXTRA_REDIRECTED_FROM_BLOCKED_APP = "redirected_from_blocked_app"

        private val IGNORED_PACKAGES = setOf(
            "com.android.systemui",
            "com.android.launcher",
            "com.android.launcher3",
            "com.google.android.apps.nexuslauncher",
            "com.sec.android.app.launcher",
            "com.miui.home",
            "com.oppo.launcher",
            "com.huawei.android.launcher",
            "android",
        )
    }
}
