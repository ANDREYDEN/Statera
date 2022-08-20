import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/data/services/notifications_repository.dart';

class NotificationsHandler extends StatefulWidget {
  final Widget child;

  const NotificationsHandler({Key? key, required this.child}) : super(key: key);

  @override
  State<NotificationsHandler> createState() => _NotificationsHandlerState();
}

class _NotificationsHandlerState extends State<NotificationsHandler> {
  late final NotificationsRepository _notificationsRepository;

  void _handleMessage(RemoteMessage message) {
    log('handling message ${message.data}');
    if (message.data['type'] == 'new_expense' &&
        message.data['expenseId'] != null) {
      Navigator.pushNamed(context, '/expense/${message.data['expenseId']}');
    }

    if (message.data['type'] == 'expense_completed' &&
        message.data['groupId'] != null) {
      Navigator.pushNamed(context, '/group/${message.data['groupId']}');
    }
  }

  @override
  void initState() {
    var authBloc = context.read<AuthBloc>();
    _notificationsRepository = context.read<NotificationsRepository>();

    _notificationsRepository.setupNotifications(
      uid: authBloc.uid,
      onMessage: _handleMessage,
    );
    super.initState();
  }

  @override
  void dispose() {
    _notificationsRepository.cancelSubscriptions();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
