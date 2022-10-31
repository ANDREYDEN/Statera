import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/groups/groups_cubit.dart';
import 'package:statera/data/models/group.dart';
import 'package:statera/ui/groups/group_list_item.dart';
import 'package:statera/settings/settings.dart';
import 'package:statera/ui/support/support.dart';
import 'package:statera/ui/widgets/dialogs/crud_dialog/crud_dialog.dart';
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
  void initState() {
    super.initState();
  }

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
          : () => createGroup(groupsCubit, authBloc.user),
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
                            ? ListEmpty(text: 'Join or create a group!')
                            : ListView.builder(
                                itemCount: groups.length,
                                itemBuilder: (context, index) {
                                  var group = groups[index];
                                  return GroupListItem(group: group);
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

  createGroup(GroupsCubit groupsCubit, User creator) {
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
          FieldData(
            id: 'debt_threshold',
            label: 'Debt Threshold',
            initialData: newGroup.debtThreshold,
            validators: [
              FieldData.requiredValidator,
              FieldData.doubleValidator
            ],
            formatters: [FilteringTextInputFormatter.deny(RegExp('-'))],
            isAdvanced: true,
          ),
        ],
        onSubmit: (values) async {
          newGroup.name = values['name']!;
          newGroup.currencySign = values['currency']!;
          newGroup.debtThreshold = double.parse(values['debt_threshold']!);

          groupsCubit.addGroup(newGroup, creator);
        },
      ),
    );
  }
}
