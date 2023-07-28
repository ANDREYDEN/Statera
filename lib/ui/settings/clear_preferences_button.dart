import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/ui/widgets/buttons/cancel_button.dart';
import 'package:statera/ui/widgets/buttons/danger_button.dart';
import 'package:statera/ui/widgets/buttons/protected_button.dart';

class ClearPreferencesButton extends StatelessWidget {
  const ClearPreferencesButton({Key? key}) : super(key: key);

  void _handleClearPreferences(BuildContext context) {
    final preferencesService = context.read<PreferencesService>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear preferences'),
        content: Text('You are about to CLEAR your app preferences'),
        actions: [
          CancelButton(),
          ProtectedButton(
            onPressed: () async {
              await preferencesService.clear();
              Navigator.pop(context);
            },
            child: Text('Clear'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('Clear Preferences'),
      subtitle: Text(
        'This will clear all your preferences and reset the app to its default state.',
      ),
      trailing: DangerButton(
        text: 'Clear',
        onPressed: () => _handleClearPreferences(context),
      ),
    );
  }
}
