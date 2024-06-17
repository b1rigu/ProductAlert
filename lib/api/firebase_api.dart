import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:productalert/api/supabase_api.dart';
import 'package:productalert/main.dart';

class FireaseApi {
  static Future<void> initNotifications(BuildContext context) async {
    if (supabase.auth.currentSession != null) {
      await firebaseMessaging.requestPermission();

      await firebaseMessaging.getAPNSToken();

      final fCMToken = await firebaseMessaging.getToken();

      if (fCMToken != null) {
        if (context.mounted) {
          await SupabaseApi.updateFCMToken(fCMToken, context);
        }
      }

      firebaseMessaging.onTokenRefresh.listen((token) async {
        if (context.mounted) {
          await SupabaseApi.updateFCMToken(token, context);
        }
      });

      FirebaseMessaging.onMessage.listen((payload) async {
        final notification = payload.notification;
        if (notification != null && context.mounted) {
          context.showSnackBar("${notification.title} - ${notification.body}");
        }
      });
    }
  }
}
