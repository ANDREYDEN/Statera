import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/notifications/notifications_cubit.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/ui/widgets/buttons/cancel_button.dart';

class NotificationsReminder extends StatelessWidget {
  final Widget child;

  const NotificationsReminder({Key? key, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<NotificationsCubit, NotificationsState>(
      listenWhen: (previous, current) => !current.allowed,
      listener: (context, state) async {
        final preferencesService = context.read<PreferencesService>();

        final notificationsReminderShown =
            await preferencesService.checkNotificationsReminderShown();

        if (notificationsReminderShown) return;

        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Notifications'),
            content: Text(
                'Head over to Settings to enable app notification permissions'),
            actions: [
              CancelButton(),
              FilledButton(
                onPressed: () async {
                  await AppSettings.openAppSettings(
                    type: AppSettingsType.notification,
                    asAnotherTask: true,
                  );
                  Navigator.pop(context);
                },
                child: Text('Open Settings'),
              )
            ],
          ),
        );

        await preferencesService.recordNotificationsReminderShown();
      },
      child: child,
    );
  }
}
