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
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/auth_service.dart';
import 'package:statera/data/services/auth_service.mocks.dart';
import 'package:statera/data/services/expense_service.dart';
import 'package:statera/data/services/expense_service.mocks.dart';
import 'package:statera/data/services/feature_service.dart';
import 'package:statera/data/services/feature_service.mocks.dart';
import 'package:statera/data/services/group_service.dart';
import 'package:statera/data/services/group_service.mocks.dart';
import 'package:statera/data/services/user_repository.dart';
import 'package:statera/data/services/user_repository.mocks.dart';

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
  FeatureService? featureService,
  String? currentUserId,
  Group? group,
  List<Expense>? expenses,
}) async {
  when(defaultCurrentUser.uid).thenReturn(defaultCurrentUserId);
  when(defaultAuthService.currentUser).thenAnswer((_) => defaultCurrentUser);

  when(defaultExpenseService.listenForRelatedExpenses(any, any,
          quantity: anyNamed('quantity')))
      .thenAnswer((_) => Stream.fromIterable([expenses ?? []]));
  when(defaultGroupService.groupStream(any))
      .thenAnswer((_) => Stream.fromIterable([group]));

  final featureServiceMock = MockFeatureService();
  when(featureServiceMock.useDynamicExpenseLoading).thenReturn(true);

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider(create: (_) => LayoutState.narrow()),
        Provider(create: (_) => featureService ?? featureServiceMock),
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
            (group ?? defaultGroup).id,
            expenseService ?? defaultExpenseService,
            groupService ?? defaultGroupService,
          )..load(currentUserId ?? defaultCurrentUserId),
        ),
        BlocProvider(
            create: (context) => AuthBloc(authService ?? defaultAuthService))
      ],
      child: MaterialApp(home: Scaffold(body: widget)),
    ),
  );
}

Expense createFinalizedExpense({
  required String authorUid,
  required String name,
}) {
  final finalizedExpense = Expense(name: name, authorUid: authorUid);
  finalizedExpense.finalizedDate = DateTime.now();
  return finalizedExpense;
}

Expense createPendingExpense({
  required String authorUid,
  required String name,
}) {
  final pendingExpense = Expense(name: 'pending', authorUid: authorUid);
  final completeItem = Item(name: 'Banana', value: 0.5);
  completeItem.assignees.add(AssigneeDecision(uid: authorUid, parts: 1));
  pendingExpense.items.add(completeItem);
  return pendingExpense;
}

Expense createNotMarkedExpense({
  required String authorUid,
  required String name,
}) {
  final notMarkedExpense = Expense(name: name, authorUid: authorUid);
  final incompleteItem = Item(name: 'Apple', value: 0.5);
  incompleteItem.assignees.add(AssigneeDecision(uid: authorUid));
  notMarkedExpense.items.add(incompleteItem);
  return notMarkedExpense;
}
