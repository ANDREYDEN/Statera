import 'dart:async';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:statera/data/services/callables.dart';

class NotificationsRepository {
  StreamSubscription? _tokenRefreshSubscription;
  StreamSubscription? _notificationSubscription;

  Future<bool> setupNotifications({
    required String uid,
    required Function(RemoteMessage) onMessage,
  }) async {
    NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    log('Got permissions: ${settings.authorizationStatus}');
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      RemoteMessage? initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();

      if (initialMessage != null) {
        log('Got initial message: ${initialMessage.data}');
        onMessage(initialMessage);
      }

      if (_notificationSubscription == null) {
        log('Initialized notification handler subscription');
        _notificationSubscription =
            FirebaseMessaging.onMessageOpenedApp.listen((m) {
          log('Got message that opened app: ${m.data}');
          onMessage(m);
        });
      }
      // FirebaseMessaging.onMessage.listen(_handleMessage); // foreground

      return true;
    }

    return false;
  }

  Future<void> updateNotificationToken({required String uid}) async {
    final fcmToken = await FirebaseMessaging.instance
        .getToken(vapidKey: kIsWeb ? dotenv.env['WEB_PUSH_VAPID_KEY'] : null);
    if (fcmToken == null) throw Exception('Could not get FCM token');

    await Callables.updateUserNotificationToken(uid: uid, token: fcmToken);

    if (_tokenRefreshSubscription == null) {
      log('Initialized user notification token refresh subscription');
      _tokenRefreshSubscription = FirebaseMessaging.instance.onTokenRefresh
          .listen((token) => Callables.updateUserNotificationToken(
                uid: uid,
                token: token,
              ));
    }
  }
}
