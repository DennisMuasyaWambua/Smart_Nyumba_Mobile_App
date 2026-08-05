package com.example.smart_nyumba

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        createNotificationChannel()
    }

    /**
     * Create the high-importance notification channel that FCM references via
     * the `default_notification_channel_id` meta-data in AndroidManifest.xml.
     * Without this channel, FCM falls back to a default-importance channel and
     * notifications don't appear as heads-up banners.
     */
    private fun createNotificationChannel() {
        // Notification channels only exist on Android 8.0 (API 26) and above.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "high_importance_channel",
                "General Notifications",
                NotificationManager.IMPORTANCE_HIGH,
            ).apply {
                description = "Rent, service charge, repair and account alerts"
                enableVibration(true)
            }
            getSystemService(NotificationManager::class.java)
                ?.createNotificationChannel(channel)
        }
    }
}
