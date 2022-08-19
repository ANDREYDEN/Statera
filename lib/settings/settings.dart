import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/data/models/author.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/ui/widgets/author_avatar.dart';
import 'package:statera/ui/widgets/dialogs/dialogs.dart';
import 'package:statera/ui/widgets/page_scaffold.dart';

class Settings extends StatefulWidget {
  static const String route = '/settings';

  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final _displayNameController = TextEditingController();
  String? _displayNameErrorText = null;

  AuthBloc get authBloc => context.read<AuthBloc>();
  FirebaseStorageRepository get _firebaseStorageRepository =>
      context.read<FirebaseStorageRepository>();

  @override
  void initState() {
    _displayNameController.text = authBloc.user.displayName ?? 'anonymous';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authBloc = context.watch<AuthBloc>();
    final ImagePicker _picker = ImagePicker();

    return PageScaffold(
      title: 'Settings',
      child: Center(
        child: Container(
          width: 500,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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

                    authBloc.add(
                        UserDataUpdated(name: _displayNameController.text));
                  },
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    authBloc.add(LogoutRequested());
                  },
                  child: Text('Log Out'),
                ),
                SizedBox(height: 10),
                TextButton(
                  onPressed: () async {
                    var decision = await showDialog<bool>(
                      context: context,
                      builder: (context) => OKCancelDialog(
                        text: 'Are you sure you want to delete your account?',
                      ),
                    );
                    if (decision!) {
                      authBloc.add(AccountDeletionRequested());
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    'Delete Account',
                    style: TextStyle(
                      color: Theme.of(context).errorColor,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
