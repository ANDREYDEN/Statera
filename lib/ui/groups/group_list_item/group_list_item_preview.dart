import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/groups/groups_cubit.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/auth_service.mocks.dart';
import 'package:statera/data/services/group_repository.mocks.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/data/services/user_group_repository.mocks.dart';
import 'package:statera/data/services/user_repository.mocks.dart';
import 'package:statera/ui/groups/group_list_item/group_list_item.dart';
import 'package:statera/utils/preview_helpers.dart';

class MockUser extends Mock implements User {
  String get uid =>
      super.noSuchMethod(Invocation.getter(#uid), returnValue: 'foo');
}

void main() {
  runApp(GroupListItemPreview());
}

class GroupListItemPreview extends StatelessWidget {
  final me = CustomUser(uid: 'me', name: 'John Doe');

  GroupListItemPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final _authService = MockAuthService();
    final user = MockUser();
    when(user.uid).thenReturn(me.uid);
    when(_authService.currentUser).thenReturn(user);

    final groupId = 'group-id';
    final simpleUserGroup = UserGroup(groupId: groupId, name: 'Simple');
    final userGroupWithDebt = UserGroup(
      groupId: groupId,
      name: 'With Debt',
      balance: {
        'me': {'other': 5},
        'other': {'me': 5}
      },
    );

    final _groupRepository = MockGroupRepository();
    final _userRepository = MockUserRepository();
    final _userGroupRepository = MockUserGroupRepository();

    return Preview(
      providers: [
        Provider.value(
            value: GroupsCubit(
                _groupRepository, _userRepository, _userGroupRepository)),
        Provider.value(value: AuthBloc(_authService)),
        Provider.value(value: PreferencesService())
      ],
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width / 3,
        ),
        child: Column(
          children: [
            GroupListItem(userGroup: simpleUserGroup),
            GroupListItem(userGroup: userGroupWithDebt),
          ],
        ),
      ),
    );
  }
}
