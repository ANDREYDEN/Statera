import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/layout/layout_state.dart';
import 'package:statera/business_logic/user/user_cubit.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/ui/authentication/user_builder.dart';
import 'package:statera/ui/settings/notifications_setting.dart';
import 'package:statera/ui/widgets/buttons/cancel_button.dart';
import 'package:statera/ui/widgets/buttons/danger_button.dart';
import 'package:statera/ui/widgets/buttons/protected_button.dart';
import 'package:statera/ui/widgets/danger_zone.dart';
import 'package:statera/ui/widgets/dialogs/danger_dialog.dart';
import 'package:statera/ui/widgets/inputs/setting_input.dart';
import 'package:statera/ui/widgets/page_scaffold.dart';
import 'package:statera/ui/widgets/section_title.dart';
import 'package:statera/ui/widgets/user_avatar.dart';

class Settings extends StatefulWidget {
  static const String route = '/settings';

  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> with WidgetsBindingObserver {
  late ImagePicker _picker;

  AuthBloc get _authBloc => context.read<AuthBloc>();
  FirebaseStorageRepository get _firebaseStorageRepository =>
      context.read<FirebaseStorageRepository>();
  LayoutState get _layoutState => context.read<LayoutState>();
  UserCubit get _userCubit => context.read<UserCubit>();

  @override
  void initState() {
    _picker = ImagePicker();

    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  void _handleDeleteAccount(CustomUser user) {
    showDialog<bool>(
      context: context,
      builder: (context) => DangerDialog(
        title: 'You are about to DELETE you account',
        valueName: 'username',
        value: user.name,
        onConfirm: () {
          _authBloc.add(AccountDeletionRequested());
          Navigator.pop(context);
        },
      ),
    );
  }

  void _handleClearPreferences() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear preferences'),
        content: Text('You are about to CLEAR your app preferences'),
        actions: [
          CancelButton(),
          ProtectedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              Navigator.pop(context);
            },
            child: Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _handlePickPhoto() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;

      String url = await _firebaseStorageRepository.uploadPickedFile(
        pickedFile,
        path: 'profileUrls/',
      );

      _userCubit.updatePhotoUrl(_authBloc.uid, url);
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
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Settings',
      child: UserBuilder(builder: (context, user) {
        return ListView(
          padding: EdgeInsets.symmetric(
            vertical: 20,
            horizontal: _layoutState.isWide
                ? MediaQuery.of(context).size.width / 3
                : 20,
          ),
          children: [
            SectionTitle('Profile Information'),
            Align(
              alignment: Alignment.center,
              child: Stack(
                children: [
                  UserAvatar(author: user, dimension: 100),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: IconButton(
                      icon: Icon(Icons.add_a_photo),
                      onPressed: _handlePickPhoto,
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 10),
            SettingInput(
              label: 'Username',
              initialValue: user.name,
              onPressed: (newName) {
                _userCubit.updateName(user.uid, newName);
              },
            ),
            SizedBox(height: 40),
            NotificationsSetting(),
            SizedBox(height: 40),
            DangerZone(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 15,
                  ),
                  child: DangerButton(
                    text: 'Log Out',
                    onPressed: () {
                      _authBloc.add(LogoutRequested());
                      Navigator.pop(context);
                    },
                  ),
                ),
                ListTile(
                  title: Text('Clear Preferences'),
                  subtitle: Text(
                    'This will clear all your preferences and reset the app to its default state.',
                  ),
                  trailing: DangerButton(
                    text: 'Clear',
                    onPressed: () => _handleClearPreferences(),
                  ),
                ),
                ListTile(
                  title: Text('Delete your Account'),
                  subtitle: Text(
                      'Deleting your account will remove your user data from the system. There is no way to undo this action.'),
                  trailing: DangerButton(
                    text: 'Delete Account',
                    onPressed: () => _handleDeleteAccount(user),
                  ),
                )
              ],
            ),
          ],
        );
      }),
    );
  }
}
