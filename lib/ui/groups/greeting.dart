import 'dart:developer' as developer;

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/data/services/preferences_service.dart';
import 'package:statera/ui/groups/greeting_dialog.dart';

class Greeting extends StatefulWidget {
  final Widget child;

  const Greeting({super.key, required this.child});

  @override
  State<Greeting> createState() => _GreetingState();
}

class _GreetingState extends State<Greeting> {
  bool _greetingDialogVisible = false;

  Future<void> _showGreetingDialog() async {
    try {
      await FirebaseRemoteConfig.instance.fetchAndActivate();
      final message =
          FirebaseRemoteConfig.instance.getString('greeting_message');
      final showGreetingDialog =
          FirebaseRemoteConfig.instance.getBool('show_greeting_dialog');

      final preferencesService = context.read<PreferencesService>();
      final messageSeen =
          await preferencesService.checkGreetingMessageSeen(message);

      if (!showGreetingDialog || messageSeen || _greetingDialogVisible) return;

      _greetingDialogVisible = true;
      await showDialog(
        context: context,
        builder: (_) => GreetingDialog(message: message),
      );
      _greetingDialogVisible = false;
    } catch (e) {
      developer.log(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, _showGreetingDialog);

    return widget.child;
  }
}
