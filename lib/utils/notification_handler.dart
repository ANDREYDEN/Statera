import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';

void handleMessage(RemoteMessage message, BuildContext context) {
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
