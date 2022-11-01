import 'package:app_settings/app_settings.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/layout/layout_state.dart';
import 'package:statera/business_logic/notifications/notifications_cubit.dart';
import 'package:statera/data/models/author.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/ui/widgets/author_avatar.dart';
import 'package:statera/ui/widgets/buttons/danger_button.dart';
import 'package:statera/ui/widgets/danger_zone.dart';
import 'package:statera/ui/widgets/dialogs/danger_dialog.dart';
import 'package:statera/ui/widgets/page_scaffold.dart';
import 'package:statera/ui/widgets/section_title.dart';

class Settings extends StatefulWidget {
  static const String route = '/settings';

  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final _displayNameController = TextEditingController();
  String? _displayNameErrorText = null;
  late bool _notifyWhenExpenseCreated;
  late bool _notifyWhenExpenseFinalized;
  late bool _notifyWhenExpenseCompleted;
  late bool _notifyWhenGroupOwageThresholdReached;

  AuthBloc get authBloc => context.read<AuthBloc>();
  NotificationsCubit get notificationsCubit =>
      context.read<NotificationsCubit>();
  FirebaseStorageRepository get _firebaseStorageRepository =>
      context.read<FirebaseStorageRepository>();
  LayoutState get layoutState => context.read<LayoutState>();

  @override
  void initState() {
    _displayNameController.text = authBloc.user.displayName ?? 'anonymous';
    _notifyWhenExpenseCreated = false;
    _notifyWhenExpenseFinalized = true;
    _notifyWhenExpenseCompleted = false;
    _notifyWhenGroupOwageThresholdReached = false;
    super.initState();
  }

  void _handleDeleteAccount() {
    showDialog<bool>(
      context: context,
      builder: (context) => DangerDialog(
        title: 'You are about to DELETE you account',
        valueName: 'username',
        value: authBloc.user.displayName ?? 'anonymous',
        onConfirm: () {
          authBloc.add(AccountDeletionRequested());
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ImagePicker _picker = ImagePicker();

    return PageScaffold(
      title: 'Settings',
      child: Center(
        child: Container(
          width:
              layoutState.isWide ? MediaQuery.of(context).size.width / 3 : null,
          padding: const EdgeInsets.all(20.0),
          child: ListView(
            children: [
              SectionTitle('Profile Information'),
              Align(
                alignment: Alignment.center,
                child: Stack(
                  children: [
                    AuthorAvatar(
                      author: Author.fromUser(authBloc.user),
                      width: 200,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: IconButton(
                        onPressed: () async {
                          try {
                            final pickedFile = await _picker.pickImage(
                                source: ImageSource.gallery);
                            if (pickedFile == null) return;

                            String url = await _firebaseStorageRepository
                                .uploadPickedFile(
                              pickedFile,
                              path: 'profileUrls/',
                            );

                            authBloc.add(UserDataUpdated(photoURL: url));
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Error while updating profile: $e'),
                            ));
                            FirebaseCrashlytics.instance.recordError(
                              e,
                              null,
                              reason: 'Profile image update failed',
                            );
                          }
                        },
                        icon: Icon(Icons.add_a_photo),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _displayNameController,
                decoration: InputDecoration(
                  label: Text('Display Name'),
                  errorText: _displayNameErrorText,
                ),
                onChanged: (value) {
                  setState(() {
                    _displayNameErrorText =
                        value == '' ? 'Can not be empty' : null;
                  });
                },
                onEditingComplete: () {
                  if (_displayNameController.text == '') return;

                  authBloc
                      .add(UserDataUpdated(name: _displayNameController.text));
                },
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  authBloc.add(LogoutRequested());
                  Navigator.pop(context);
                },
                child: Text('Log Out'),
              ),
              SizedBox(height: 40),
              BlocBuilder<NotificationsCubit, NotificationsState>(
                builder: (context, state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SectionTitle('Notifications Preferences'),
                      if (!state.allowed)
                        ElevatedButton(
                          onPressed: () {
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

                            AppSettings.openNotificationSettings();
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
              ),
              SizedBox(height: 40),
              DangerZone(
                children: [
                  ListTile(
                    title: Text('Delete your Account'),
                    subtitle: Text(
                        'Deleting your account will remove your user data from the system. There is no way to undo this action.'),
                    trailing: DangerButton(
                      text: 'Delete Account',
                      onPressed: _handleDeleteAccount,
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
            onChanged: notificationsCubit.state.allowed ? (newValue) {} : null,
          ),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Expense was finalized by its author'),
          Switch(
            value: _notifyWhenExpenseFinalized,
            onChanged: notificationsCubit.state.allowed ? (newValue) {} : null,
          ),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Expense is ready to be finalized'),
          Switch(
            value: _notifyWhenExpenseCompleted,
            onChanged: notificationsCubit.state.allowed ? (newValue) {} : null,
          ),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Reached group owage threshold'),
          Switch(
            value: _notifyWhenGroupOwageThresholdReached,
            onChanged: notificationsCubit.state.allowed ? (newValue) {} : null,
          ),
        ],
      ),
    ];
  }
}
