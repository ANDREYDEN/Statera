import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';

/// Handles the notification [message] (tapping on a notification) from a particular app [context]. 
/// Because different places in the app will try to handle a notification tap (opening vs launching)
/// this method ensures that each notification will be handled exactly once 
/// (ignoring all invocations for a given period of time)
/// TODO: add cooldown
void handleMessage(RemoteMessage message, BuildContext context) {
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
