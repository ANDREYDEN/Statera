import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

class AppLaunchHandler {
  static const Duration cooldown = Duration(seconds: 1);

  static DateTime? _lastLaunchHandledAt;

  static bool get canHandleLaunch =>
      _lastLaunchHandledAt == null ||
      DateTime.now().difference(_lastLaunchHandledAt!) > cooldown;

  static void _ensureCanHandleLaunch() {
    if (!canHandleLaunch) return;
    _lastLaunchHandledAt = DateTime.now();
  }

  /// Handles the notification [message] (tapping on a notification) from a particular app [context].
  /// This method ensures that each notification will be handled exactly once
  /// (ignoring all invocations for a given period of time)
  static void handleNotificationMessage(
    RemoteMessage message,
    BuildContext context,
  ) {
    _ensureCanHandleLaunch();
    log('handling message ${message.data}');

    final path = getPath(message);
    if (path == null) return;

    context.go(path);
  }

  /// Handles the dynamic link [path] from a particular app [context].
  /// This method ensures that each dynamic link will be handled exactly once
  /// (ignoring all invocations for a given period of time)
  static void handleDynamicLink(String path, BuildContext context) {
    _ensureCanHandleLaunch();
    log('handling dynamic link $path');

    context.go(path);
  }

  static String? getPath(RemoteMessage? message) {
    if (message == null) return null;
    switch (message.data['type']) {
      case 'expense_created':
      case 'expense_finalized':
        if (message.data['expenseId'] != null) {
          return '/expense/${message.data['expenseId']}';
        }
        break;
      case 'group_debt_threshold_reached':
      case 'expense_completed':
        if (message.data['groupId'] != null) {
          return '/group/${message.data['groupId']}';
        }
        break;
      default:
        return null;
    }

    return null;
  }
}
