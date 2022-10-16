import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';

class NotificationMessageHandler {
  static const Duration cooldown = Duration(seconds: 1);

  static DateTime? _lastMessageHandledAt;

  bool get acceptingMessages =>
      _lastMessageHandledAt == null ||
      DateTime.now().difference(_lastMessageHandledAt!) > cooldown;

  /// Handles the notification [message] (tapping on a notification) from a particular app [context].
  /// Because different places in the app will try to handle a notification tap (opening vs launching)
  /// this method ensures that each notification will be handled exactly once
  /// (ignoring all invocations for a given period of time)
  void handleMessage(RemoteMessage message, BuildContext context) {
    if (!acceptingMessages) return;
    _lastMessageHandledAt = DateTime.now();

    log('handling message ${message.data}');
    if (message.data['type'] == null) return;

    switch (message.data['type']) {
      case 'expense_created':
      case 'expense_finalized':
        if (message.data['expenseId'] != null) {
          Navigator.pushNamed(context, '/expense/${message.data['expenseId']}');
        }
        break;
      case 'group_debt_threshold_reached':
      case 'expense_completed':
        if (message.data['groupId'] != null) {
          Navigator.pushNamed(context, '/group/${message.data['groupId']}');
        }
        break;
      default:
        return;
    }
  }
}