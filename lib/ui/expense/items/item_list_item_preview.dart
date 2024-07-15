import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/auth_service.mocks.dart';
import 'package:statera/data/services/expense_service.mocks.dart';
import 'package:statera/data/services/group_repository.mocks.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/data/services/user_repository.mocks.dart';
import 'package:statera/ui/expense/items/gas_item_list_item.dart';
import 'package:statera/ui/expense/items/item_list_item.dart';
import 'package:statera/utils/preview_helpers.dart';
import 'package:uuid/uuid.dart';

class MockUser extends Mock implements User {
  String get uid =>
      super.noSuchMethod(Invocation.getter(#uid), returnValue: 'foo');
}

main() {
  runApp(ItemListItemPreview());
}

class ItemListItemPreview extends StatelessWidget {
  final me = CustomUser(uid: 'a', name: 'John Doe');
  final other = CustomUser(uid: 'b', name: 'Adam Smith');
  final another = CustomUser(uid: 'c', name: 'Kate Smith');

  ItemListItemPreview({Key? key}) : super(key: key);

  SimpleItem getSimpleItem() {
    return SimpleItem(
      name: 'Pizza',
      value: 23.33,
      assigneeUids: [me.uid, other.uid, another.uid],
    );
  }

  @override
  Widget build(BuildContext context) {
    final tenUsers = List.generate(
      10,
      (index) => CustomUser(
        uid: Uuid().v1(),
        name: 'User $index',
      ),
    );

    final authService = MockAuthService();
    final user = MockUser();
    when(user.uid).thenReturn(me.uid);
    when(authService.currentUser).thenReturn(user);

    final partitionedItem = SimpleItem(
      name: 'Pizza',
      value: 23.33,
      partition: 5,
      assigneeUids: [me.uid, other.uid, another.uid],
    );
    final simpleItemWithTenUsers = SimpleItem(
      name: 'A lot of users and a very long name',
      value: 23.33,
      assigneeUids: tenUsers.map((u) => u.uid).toList(),
    );
    for (final user in tenUsers) {
      simpleItemWithTenUsers.setAssigneeDecision(user.uid, 1);
    }

    final gasItem = GasItem(
      name: 'Gas',
      distance: 184,
      gasPrice: 1.7,
      consumption: 7.5,
      assigneeUids: [me.uid, other.uid, another.uid],
    );

    final gasItemWithTenUsers = GasItem(
      name: 'Some very long and boring gas name',
      distance: 200,
      gasPrice: 1.7,
      consumption: 7,
      assigneeUids: tenUsers.map((u) => u.uid).toList(),
    );

    for (final user in tenUsers) {
      gasItemWithTenUsers.setAssigneeDecision(user.uid, 1);
    }

    return Preview(
      providers: [
        BlocProvider(
          create: (_) => GroupCubit(
            MockGroupRepository(),
            MockExpenseService(),
            MockUserRepository(),
          )..loadGroup(Group(
              name: 'Example',
              members: [me, other, another, ...tenUsers],
            )),
        ),
        BlocProvider(create: (_) => AuthBloc(authService)),
        Provider.value(value: PreferencesService()),
      ],
      body: ListView(
        children: [
          ItemListItem(
            item: getSimpleItem(),
            onChangePartition: (_) {},
          ),
          ItemListItem(
            item: getSimpleItem()
              ..setAssigneeDecision(me.uid, 0)
              ..setAssigneeDecision(other.uid, 1),
            onChangePartition: (_) {},
          ),
          ItemListItem(
            item: getSimpleItem()
              ..setAssigneeDecision(me.uid, 1)
              ..setAssigneeDecision(other.uid, 1),
            onChangePartition: (_) {},
          ),
          ItemListItem(
            item: getSimpleItem()
              ..setAssigneeDecision(me.uid, 0)
              ..setAssigneeDecision(other.uid, 0)
              ..setAssigneeDecision(another.uid, 0),
            onChangePartition: (_) {},
          ),
          ItemListItem(
            item: getSimpleItem()
              ..setAssigneeDecision(me.uid, 1)
              ..setAssigneeDecision(other.uid, 1)
              ..setAssigneeDecision(another.uid, 1),
            onChangePartition: (_) {},
            showDecisions: true,
          ),
          ItemListItem(
            item: partitionedItem
              ..setAssigneeDecision(me.uid, 2)
              ..setAssigneeDecision(other.uid, 1)
              ..setAssigneeDecision(another.uid, 2),
            onChangePartition: (_) {},
            showDecisions: true,
          ),
          ItemListItem(
            item: simpleItemWithTenUsers,
            onChangePartition: (_) {},
            showDecisions: true,
          ),
          GasItemListItem(
            item: gasItem
              ..setAssigneeDecision(me.uid, 1)
              ..setAssigneeDecision(another.uid, 1),
            onChangePartition: (_) {},
            showDecisions: true,
          ),
          GasItemListItem(
            item: gasItemWithTenUsers,
            onChangePartition: (_) {},
            showDecisions: true,
          ),
        ],
      ),
    );
  }
}
