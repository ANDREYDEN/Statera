import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/data/services/callables.dart';

class NotificationsHandler extends StatefulWidget {
  final Widget child;

  const NotificationsHandler({Key? key, required this.child}) : super(key: key);

  @override
  State<NotificationsHandler> createState() => _NotificationsHandlerState();
}

class _NotificationsHandlerState extends State<NotificationsHandler> {
  late final StreamSubscription _tokenRefreshSubscription;
  late final StreamSubscription _notificationSubscription;

  Future<void> setupInteractedMessage() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    var authBloc = context.read<AuthBloc>();

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('Got permissions: ${settings.authorizationStatus}');
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      final fcmToken = await FirebaseMessaging.instance
          .getToken(vapidKey: kIsWeb ? dotenv.env['WEB_PUSH_VAPID_KEY'] : null);
      if (fcmToken == null) throw Exception('Could not get FCM token');

      await Callables.updateUserNotificationToken(
        uid: authBloc.uid,
        token: fcmToken,
      );

      _tokenRefreshSubscription = FirebaseMessaging.instance.onTokenRefresh
          .listen((token) => Callables.updateUserNotificationToken(
                uid: authBloc.uid,
                token: token,
              ));

      RemoteMessage? initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();

      print('Got initial message $initialMessage');
      if (initialMessage != null) {
        _handleMessage(initialMessage);
      }

      // TODO: listen only once
      _notificationSubscription =
          FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
      // FirebaseMessaging.onMessage.listen(_handleMessage); // foreground
    }
  }

  void _handleMessage(RemoteMessage message) {
    print('handling message $message');
    if (message.data['type'] == 'new_expense' &&
        message.data['expenseId'] != null) {
      Navigator.pushNamed(context, '/expense/${message.data['expenseId']}');
    }
  }

  @override
  void initState() {
    setupInteractedMessage();
    super.initState();
  }

  @override
  void dispose() {
    _notificationSubscription.cancel();
    _tokenRefreshSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
