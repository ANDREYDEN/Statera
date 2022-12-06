import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/auth_service.dart';
import 'package:statera/data/services/expense_service.mocks.dart';
import 'package:statera/data/services/group_service.mocks.dart';
import 'package:statera/data/services/user_repository.mocks.dart';
import 'package:statera/ui/expense/items/item_list_item.dart';
import 'package:statera/utils/theme.dart';

class MockUser extends Mock implements User {
  String get uid =>
      super.noSuchMethod(Invocation.getter(#uid), returnValue: 'foo');
}

class AuthServiceMock extends Mock implements AuthService {
  User? get currentUser => super
      .noSuchMethod(Invocation.getter(#currentUser), returnValue: MockUser());

  @override
  Stream<User?> currentUserStream() => super.noSuchMethod(
        Invocation.method(#currentUserStream, []),
        returnValue: Stream<User?>.empty(),
        returnValueForMissingStub: Stream<User?>.empty(),
      ) as Stream<User?>;
}

main() {
  runApp(ItemListItemPreview());
}

class ItemListItemPreview extends StatelessWidget {
  const ItemListItemPreview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final me = CustomUser(uid: 'a', name: 'John Doe');
    final other = CustomUser(uid: 'b', name: 'Adam Smith');
    final another = CustomUser(uid: 'c', name: 'Kate Smith');

    final authService = AuthServiceMock();
    final user = MockUser();
    when(user.uid).thenReturn(me.uid);
    when(authService.currentUser).thenReturn(user);

    final simpleItem = Item(
      name: 'Pizza',
      value: 23.33,
      assigneeUids: [me.uid, other.uid, another.uid],
    );
    final partitionedItem = Item(
      name: 'Pizza',
      value: 23.33,
      partition: 5,
      assigneeUids: [me.uid, other.uid, another.uid],
    );

    return MaterialApp(
      theme: theme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.light,
      home: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => GroupCubit(
              MockGroupService(),
              MockExpenseService(),
              MockUserRepository(),
            )..loadGroup(Group(
                name: 'Example',
                members: [me, other, another],
              )),
          ),
          BlocProvider(
            create: (_) => AuthBloc(authService),
          )
        ],
        child: Scaffold(
          body: ListView(
            children: [
              ItemListItem(
                item: simpleItem,
                onChangePartition: (_) {},
              ),
              ItemListItem(
                item: simpleItem
                  ..setAssigneeDecision(me.uid, 0)
                  ..setAssigneeDecision(other.uid, 1),
                onChangePartition: (_) {},
              ),
              ItemListItem(
                item: simpleItem
                  ..setAssigneeDecision(me.uid, 1)
                  ..setAssigneeDecision(other.uid, 1),
                onChangePartition: (_) {},
              ),
              ItemListItem(
                item: simpleItem
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
              )
            ],
          ),
        ),
      ),
    );
  }
}
