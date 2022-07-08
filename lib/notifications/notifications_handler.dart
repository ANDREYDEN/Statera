import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/data/services/callables.dart';

class NotificationsHandler extends StatefulWidget {
  final Widget child;

  const NotificationsHandler({Key? key, required this.child}) : super(key: key);

  @override
  State<NotificationsHandler> createState() => _NotificationsHandlerState();
}

class _NotificationsHandlerState extends State<NotificationsHandler> {
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

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      final fcmToken = await FirebaseMessaging.instance.getToken(
          vapidKey: kIsWeb
              ? 'BHoZVDZZVKABVk2HzVWdgwqYy3RX2bshNn_dFXq51Sa9qsIssT-gOYTiHiQZ9boNuUQMJ57fqT1sGdjzVB0mruI'
              : null);
      if (fcmToken == null) throw Exception("Could not get FCM token");
      
      await Callables.updateUserNotificationToken(uid: authBloc.uid, token: fcmToken);

      RemoteMessage? initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();

      if (initialMessage != null) {
        _handleMessage(initialMessage);
      }

      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
      // FirebaseMessaging.onMessage.listen(_handleMessage); // foreground
    }
  }

  void _handleMessage(RemoteMessage message) {
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
  Widget build(BuildContext context) {
    return widget.child;
  }
}
