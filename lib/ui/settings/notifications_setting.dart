import 'package:app_settings/app_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/notifications/notifications_cubit.dart';
import 'package:statera/ui/widgets/section_title.dart';

class NotificationsSetting extends StatefulWidget {
  const NotificationsSetting({Key? key}) : super(key: key);

  @override
  State<NotificationsSetting> createState() => _NotificationsSettingState();
}

class _NotificationsSettingState extends State<NotificationsSetting>
    with WidgetsBindingObserver {
  bool _notifyWhenExpenseCreated = false;
  bool _notifyWhenExpenseFinalized = true;
  bool _notifyWhenExpenseCompleted = false;
  bool _notifyWhenGroupOwageThresholdReached = false;

  NotificationsCubit get _notificationsCubit =>
      context.read<NotificationsCubit>();

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _notificationsCubit.requestPermission();
  }

// TODO: use this
  List<Widget> get notificationPermissionToggles {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('New expense was created'),
          Switch(
            value: _notifyWhenExpenseCreated,
            onChanged: _notificationsCubit.state.allowed ? (newValue) {} : null,
          ),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Expense was finalized by its author'),
          Switch(
            value: _notifyWhenExpenseFinalized,
            onChanged: _notificationsCubit.state.allowed ? (newValue) {} : null,
          ),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Expense is ready to be finalized'),
          Switch(
            value: _notifyWhenExpenseCompleted,
            onChanged: _notificationsCubit.state.allowed ? (newValue) {} : null,
          ),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Reached group owage threshold'),
          Switch(
            value: _notifyWhenGroupOwageThresholdReached,
            onChanged: _notificationsCubit.state.allowed ? (newValue) {} : null,
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsCubit, NotificationsState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionTitle('Notifications Preferences'),
            if (!state.allowed)
              ElevatedButton(
                onPressed: () async {
                  if (kIsWeb) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Please turn on notifications for this website',
                        ),
                      ),
                    );
                    return;
                  }

                  await AppSettings.openAppSettings(
                    type: AppSettingsType.notification,
                    asAnotherTask: true,
                  );
                },
                child: Text('Enable notifications'),
              )
            else
              Column(
                children: [
                  Text('Coming Soon...')
                ], //notificationPermissionToggles
              )
          ],
        );
      },
    );
  }
}
