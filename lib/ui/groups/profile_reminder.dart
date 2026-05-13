import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/user/user_cubit.dart';
import 'package:statera/data/models/custom_user.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/ui/styling/spacing.dart';
import 'package:statera/ui/widgets/dialogs/custom_bottom_sheet.dart';
import 'package:statera/ui/widgets/user_avatar.dart';

class ProfileReminder extends StatefulWidget {
  final Widget child;

  const ProfileReminder({super.key, required this.child});

  @override
  State<ProfileReminder> createState() => _ProfileReminderState();
}

class _ProfileReminderState extends State<ProfileReminder> {
  bool _sheetShown = false;

  void _showSheet(BuildContext context, CustomUser user) {
    _sheetShown = true;
    final userCubit = context.read<UserCubit>();
    final authBloc = context.read<AuthBloc>();
    final filePickerService = context.read<FilePickerService>();
    final fileStorageService = context.read<FileStorageService>();
    final errorService = context.read<ErrorService>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      builder: (_) => _ProfileReminderContent(
        user: user,
        userCubit: userCubit,
        authBloc: authBloc,
        filePickerService: filePickerService,
        fileStorageService: fileStorageService,
        errorService: errorService,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserCubit, UserState>(
      listenWhen: (_, current) => current is UserLoaded && !_sheetShown,
      listener: (context, state) {
        if (state is! UserLoaded) return;
        final user = state.user;
        if (user.name == 'anonymous') {
          _showSheet(context, user);
        }
      },
      child: widget.child,
    );
  }
}

class _ProfileReminderContent extends StatefulWidget {
  final CustomUser user;
  final UserCubit userCubit;
  final AuthBloc authBloc;
  final FilePickerService filePickerService;
  final FileStorageService fileStorageService;
  final ErrorService errorService;

  const _ProfileReminderContent({
    required this.user,
    required this.userCubit,
    required this.authBloc,
    required this.filePickerService,
    required this.fileStorageService,
    required this.errorService,
  });

  @override
  State<_ProfileReminderContent> createState() =>
      _ProfileReminderContentState();
}

class _ProfileReminderContentState extends State<_ProfileReminderContent> {
  late final TextEditingController _nameController;
  bool _isUploadingPhoto = false;
  String? _uploadedPhotoUrl;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handlePickPhoto() async {
    setState(() => _isUploadingPhoto = true);
    try {
      final pickedFile = await widget.filePickerService.pickImage(
        source: ImageFileSource.gallery,
      );
      final url = await widget.fileStorageService.uploadFile(
        pickedFile,
        path: 'profileUrls/',
      );
      setState(() => _uploadedPhotoUrl = url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error uploading photo: $e')));
      }
      await widget.errorService.recordError(
        e,
        reason: 'Profile image update failed',
      );
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  Future<void> _handleSave() async {
    final isValid = _formKey.currentState?.validate();
    if (isValid != true) return;

    final uid = widget.authBloc.uid;
    final name = _nameController.text.trim();

    if (name.isNotEmpty) {
      await widget.userCubit.updateName(uid, name);
    }
    if (_uploadedPhotoUrl != null) {
      await widget.userCubit.updatePhotoUrl(uid, _uploadedPhotoUrl!);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomBottomSheet(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Text('Complete your profile', style: theme.textTheme.titleLarge),
            const SizedBox(height: Spacing.m_10),
            Text(
              'Help others recognize you in groups.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Spacing.l_20),
            Center(
              child: UserAvatar(
                user: _uploadedPhotoUrl != null
                    ? CustomUser(
                        uid: widget.user.uid,
                        name: widget.user.name,
                        photoURL: _uploadedPhotoUrl,
                      )
                    : widget.user,
                dimension: 100,
                loading: _isUploadingPhoto,
                withIcon: true,
                icon: Icons.add_a_photo,
                iconBackgroudColor: Colors.transparent,
                onTap: _isUploadingPhoto ? null : _handlePickPhoto,
              ),
            ),
            const SizedBox(height: Spacing.l_20),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) =>
                  value == 'anonymous' ? 'Please enter a valid name' : null,
            ),
            const SizedBox(height: Spacing.l_20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Skip'),
                ),
                const SizedBox(width: Spacing.s_8),
                FilledButton(onPressed: _handleSave, child: const Text('Save')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
