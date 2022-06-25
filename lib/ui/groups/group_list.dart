import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/groups/groups_cubit.dart';
import 'package:statera/data/models/group.dart';
import 'package:statera/ui/settings/settings.dart';
import 'package:statera/ui/groups/group_list_item.dart';
import 'package:statera/ui/support/support.dart';
import 'package:statera/ui/widgets/dialogs/crud_dialog.dart';
import 'package:statera/ui/widgets/list_empty.dart';
import 'package:statera/ui/widgets/loader.dart';
import 'package:statera/ui/widgets/page_scaffold.dart';
import 'package:statera/utils/utils.dart';

class GroupList extends StatefulWidget {
  static const String route = '/groups';

  const GroupList({Key? key}) : super(key: key);

  @override
  _GroupListState createState() => _GroupListState();
}

class _GroupListState extends State<GroupList> {
  AuthBloc get authBloc => context.read<AuthBloc>();
  GroupsCubit get groupsCubit => context.read<GroupsCubit>();

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: kAppName,
      actions: [
        IconButton(
          onPressed: () => Navigator.pushNamed(context, SupportPage.route),
          icon: Icon(Icons.info_outline_rounded),
        ),
        IconButton(
          onPressed: () => Navigator.pushNamed(context, Settings.route),
          icon: Icon(Icons.settings_outlined),
        ),
      ],
      onFabPressed: defaultTargetPlatform == TargetPlatform.windows
          ? null
          : () => updateOrCreateGroup(groupsCubit, authBloc.user),
      child: defaultTargetPlatform == TargetPlatform.windows
          ? Center(
              child:
                  Text('Main app functionality is currently in development...'),
            )
          : BlocBuilder<GroupsCubit, GroupsState>(
              builder: (context, groupsState) {
                if (groupsState is GroupsLoading) {
                  return Center(child: Loader());
                }

                if (groupsState is GroupsError) {
                  developer.log(
                    'Failed loading groups',
                    error: groupsState.error,
                  );

                  return Center(child: Text(groupsState.error.toString()));
                }

                if (groupsState is GroupsLoaded) {
                  final groups = groupsState.groups;
                  final groupsCubit = context.read<GroupsCubit>();

                  return Column(
                    children: [
                      SizedBox.square(
                        dimension: 16,
                        child: Visibility(
                          visible: groupsState is GroupsProcessing,
                          child: Loader(),
                        ),
                      ),
                      Expanded(
                        child: groups.isEmpty
                            ? ListEmpty(text: "Join or create a group!")
                            : ListView.builder(
                                itemCount: groups.length,
                                itemBuilder: (context, index) {
                                  var group = groups[index];
                                  return GestureDetector(
                                    onLongPress: () => updateOrCreateGroup(
                                      groupsCubit,
                                      authBloc.user,
                                      group: group,
                                    ),
                                    child: GroupListItem(group: group),
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                }

                return Container();
              },
            ),
    );
  }

  updateOrCreateGroup(GroupsCubit groupsCubit, User creator, {Group? group}) {
    showDialog(
      context: context,
      builder: (context) => CRUDDialog(
        title: 'New Group',
        fields: [
          FieldData(
            id: 'group_name',
            label: 'Group Name',
            validators: [FieldData.requiredValidator],
            initialData: group?.name,
          ),
          FieldData(
            id: 'group_currency',
            label: 'Group Currency',
            initialData: group?.currencySign ?? Group.kdefaultCurrencySign,
            validators: [FieldData.requiredValidator],
            formatters: [SingleCharacterTextInputFormatter()],
            isAdvanced: true,
          )
        ],
        onSubmit: (values) async {
          var groupToModify = group ?? new Group.fake();
          final wasModified = groupToModify.name != values['group_name']! ||
              groupToModify.currencySign != values['group_currency'];

          if (!wasModified) return;

          groupToModify.name = values['group_name']!;
          groupToModify.currencySign = values['group_currency'];
          if (group == null) {
            groupsCubit.addGroup(groupToModify, creator);
          } else {
            groupsCubit.updateGroup(groupToModify);
          }
        },
      ),
    );
  }
}
