import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/expense/expense_bloc.dart';
import 'package:statera/business_logic/expenses/expenses_cubit.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/business_logic/layout/layout_state.dart';
import 'package:statera/data/services/auth_service.mocks.dart';
import 'package:statera/data/services/expense_service.mocks.dart';
import 'package:statera/data/services/group_service.mocks.dart';
import 'package:statera/data/services/user_repository.mocks.dart';
import 'package:statera/data/services/auth_service.dart';
import 'package:statera/data/services/expense_service.dart';
import 'package:statera/data/services/group_service.dart';
import 'package:statera/data/services/user_repository.dart';
import 'package:statera/ui/group/expenses/expense_list.dart';
import 'package:statera/data/models/models.dart';

class MockUser extends Mock implements User {
  String get uid =>
      super.noSuchMethod(Invocation.getter(#uid), returnValue: 'foo');
}

final defaultGroupService = MockGroupService();
final defaultExpenseService = MockExpenseService();
final defaultUserRepository = MockUserRepository();
final defaultAuthService = MockAuthService();
final defaultCurrentUser = MockUser();
final defaultCurrentUserId = 'foo';
final defaultGroup = Group(
      id: 'group_foo',
      name: 'Group Foo',
      members: [
        CustomUser(uid: defaultCurrentUserId, name: 'Foo'),
      ],
    );

Future<void> customPump(
  Widget widget,
  WidgetTester tester, {
  ExpenseService? expenseService,
  GroupService? groupService,
  UserRepository? userRepository,
  AuthService? authService,
  String? currentUserId,
  Group? group,
  List<Expense>? expenses,
}) async {
  when(defaultCurrentUser.uid).thenReturn(defaultCurrentUserId);
  when(defaultAuthService.currentUser).thenAnswer((_) => defaultCurrentUser);

  when(defaultExpenseService.listenForRelatedExpenses(any, any))
      .thenAnswer((_) => Stream.fromIterable([expenses ?? []]));
  when(defaultGroupService.groupStream(any))
      .thenAnswer((_) => Stream.fromIterable([group]));

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<LayoutState>(create: (_) => LayoutState.narrow()),
        BlocProvider(
            create: (context) =>
                ExpenseBloc(expenseService ?? defaultExpenseService)),
        BlocProvider(
            create: (context) => GroupCubit(
                  groupService ?? defaultGroupService,
                  expenseService ?? defaultExpenseService,
                  userRepository ?? defaultUserRepository,
                )..load((group ?? defaultGroup).id)),
        BlocProvider(
          create: (context) => ExpensesCubit(
            expenseService ?? defaultExpenseService,
            groupService ?? defaultGroupService,
          )..load(currentUserId ?? defaultCurrentUserId, (group ?? defaultGroup).id),
        ),
        BlocProvider(
            create: (context) => AuthBloc(authService ?? defaultAuthService))
      ],
      child: MaterialApp(home: Scaffold(body: ExpenseList())),
    ),
  );
}
