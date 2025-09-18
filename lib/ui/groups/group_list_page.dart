import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/groups/groups_cubit.dart';
import 'package:statera/business_logic/user/user_cubit.dart';
import 'package:statera/data/models/group.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/ui/groups/greeting.dart';
import 'package:statera/ui/groups/group_list_body.dart';
import 'package:statera/ui/groups/notifications_reminder.dart';
import 'package:statera/ui/groups/settings_badge.dart';
import 'package:statera/ui/groups/update_banner.dart';
import 'package:statera/ui/platform_context.dart';
import 'package:statera/ui/settings/settings_page.dart';
import 'package:statera/ui/support/support.dart';
import 'package:statera/ui/widgets/dialogs/crud_dialog/crud_dialog.dart';
import 'package:statera/ui/widgets/dialogs/dialogs.dart';
import 'package:statera/ui/widgets/page_scaffold.dart';
import 'package:statera/utils/utils.dart';

class GroupListPage extends StatelessWidget {
  static const String name = 'GroupList';

  const GroupListPage({Key? key}) : super(key: key);

  static Widget init() {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => GroupsCubit(
            context.read<GroupRepository>(),
            context.read<UserRepository>(),
            context.read<UserGroupRepository>(),
          )..load(context.read<AuthBloc>().uid),
        ),
        BlocProvider(
          create: (context) => UserCubit(context.read<UserRepository>())
            ..load(context.read<AuthBloc>().uid),
        )
      ],
      child: GroupListPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    var platformContext = context.read<PlatformContext>();

    return Greeting(
      child: NotificationsReminder(
        child: PageScaffold(
          title: kAppName,
          actions: [
            IconButton(
              onPressed: () => context.goNamed(SupportPage.name),
              icon: Icon(Icons.info_outline_rounded),
            ),
            IconButton(
              onPressed: () => context.goNamed(SettingsPage.name),
              icon: SettingsBadge(child: Icon(Icons.settings_outlined)),
            ),
          ],
          fabText: 'New Group',
          onFabPressed:
              platformContext.isWindows ? null : () => _createGroup(context),
          child: Column(
            children: [
              UpdateBanner(),
              Expanded(child: GroupListBody()),
            ],
          ),
        ),
      ),
    );
  }

  _createGroup(BuildContext context) {
    final authBloc = context.read<AuthBloc>();
    final groupsCubit = context.read<GroupsCubit>();

    final newGroup = Group.empty(name: '');

    showDialog(
      context: context,
      builder: (context) => CRUDDialog(
        title: 'New Group',
        fields: [
          FieldData(
            id: 'name',
            label: 'Name',
            validators: [FieldData.requiredValidator],
            initialData: '',
          ),
          FieldData(
            id: 'currency',
            label: 'Currency Sign',
            initialData: newGroup.currencySign,
            validators: [FieldData.requiredValidator],
            formatters: [SingleCharacterTextInputFormatter()],
            isAdvanced: true,
          ),
          FieldData<double>(
            id: 'debt_threshold',
            label: 'Debt Threshold',
            initialData: newGroup.debtThreshold,
            validators: [FieldData.requiredValidator],
            formatters: [FilteringTextInputFormatter.deny(RegExp('-'))],
            isAdvanced: true,
          ),
        ],
        onSubmit: (values) async {
          newGroup.name = values['name']!;
          newGroup.currencySign = values['currency']!;
          newGroup.debtThreshold = values['debt_threshold']!;

          groupsCubit.addGroup(newGroup, authBloc.uid);
        },
      ),
    );
  }
}
