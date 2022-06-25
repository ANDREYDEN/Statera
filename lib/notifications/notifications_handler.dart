import 'package:flutter/material.dart';

class NotificationsHandler extends StatefulWidget {
  final Widget child;

  const NotificationsHandler({Key? key, required this.child}) : super(key: key);

  @override
  State<NotificationsHandler> createState() => _NotificationsHandlerState();
}

class _NotificationsHandlerState extends State<NotificationsHandler> {
  Future<void> setupInteractedMessage() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }
  
  void _handleMessage(RemoteMessage message) {
    if (message.data['type'] == 'new_expense' && message.data['expenseId'] != null) {
      Navigator.pushNamed(context, '/expense/${message.data['expenseId']}');
    }
  }

  @override
  void initState() {
    
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}