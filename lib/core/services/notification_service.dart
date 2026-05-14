import 'package:flutter/material.dart';

class NotificationService {
  static void showNotification(BuildContext context, String title, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(message),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'View',
          onPressed: () {
            // Navigate to relevant screen
          },
        ),
      ),
    );
  }

  // In a real app, this would integrate with Firebase Messaging or OneSignal
  static Future<void> sendLocalAlert(String title, String message) async {
    debugPrint("PUSH NOTIFICATION: $title - $message");
  }
}
