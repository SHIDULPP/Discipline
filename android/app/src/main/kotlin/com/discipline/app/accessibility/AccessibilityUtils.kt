package com.discipline.app.accessibility

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.provider.Settings
import android.text.TextUtils

object AccessibilityUtils {
    fun isServiceEnabled(context: Context): Boolean {
        if (!isAccessibilityGloballyEnabled(context)) return false

        val expected = ComponentName(context, DisciplineAccessibilityService::class.java)
        val enabledServices = Settings.Secure.getString(
            context.contentResolver,
            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES,
        ) ?: return false

        if (enabledServices.isEmpty()) return false

        val splitter = TextUtils.SimpleStringSplitter(':')
        splitter.setString(enabledServices)
        while (splitter.hasNext()) {
            val enabled = ComponentName.unflattenFromString(splitter.next()) ?: continue
            if (matchesDisciplineService(expected, enabled)) {
                return true
            }
        }

        return false
    }

    private fun isAccessibilityGloballyEnabled(context: Context): Boolean {
        return try {
            Settings.Secure.getInt(
                context.contentResolver,
                Settings.Secure.ACCESSIBILITY_ENABLED,
                0,
            ) == 1
        } catch (_: Settings.SettingNotFoundException) {
            false
        }
    }

    private fun matchesDisciplineService(
        expected: ComponentName,
        enabled: ComponentName,
    ): Boolean {
        if (expected == enabled) return true
        if (expected.packageName != enabled.packageName) return false

        val expectedClass = normalizeClassName(expected.packageName, expected.className)
        val enabledClass = normalizeClassName(enabled.packageName, enabled.className)
        return expectedClass == enabledClass
    }

    private fun normalizeClassName(packageName: String, className: String): String {
        return if (className.startsWith(".")) {
            packageName + className
        } else {
            className
        }
    }

    fun openAccessibilitySettings(context: Context) {
        val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        }
        context.startActivity(intent)
    }

    fun getInstalledCandidates(context: Context): List<Map<String, String>> {
        val packageManager = context.packageManager
        return EnforcementPreferences.DISTRACTION_CANDIDATES.mapNotNull { (packageName, label) ->
            val installed = try {
                packageManager.getPackageInfo(packageName, 0)
                true
            } catch (_: PackageManager.NameNotFoundException) {
                false
            }
            if (!installed) return@mapNotNull null
            mapOf("packageName" to packageName, "label" to label)
        }
    }
}
