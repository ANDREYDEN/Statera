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
import 'package:statera/data/services/auth_service.mocks.dart';
import 'package:statera/data/services/expense_service.mocks.dart';
import 'package:statera/data/services/group_service.mocks.dart';
import 'package:statera/data/services/user_repository.mocks.dart';
import 'package:statera/ui/group/expenses/expense_list.dart';

class MockUser extends Mock implements User {
  String get uid =>
      super.noSuchMethod(Invocation.getter(#uid), returnValue: 'foo');
}

void main() {
  group('Expense List', () {
    final groupService = MockGroupService();
    final expenseService = MockExpenseService();
    final userRepository = MockUserRepository();
    final authService = MockAuthService();
    final currentUser = MockUser();
    final currentUserId = 'foo';
    final otherUserId = 'bar';
    final groupId = 'group_foo';
    final testGroup = Group(
      id: groupId,
      name: 'Group Foo',
      members: [
        CustomUser(uid: currentUserId, name: 'Foo'),
        CustomUser(uid: otherUserId, name: 'Bar')
      ],
    );

    final expenses = [
      Expense(name: 'E1', authorUid: currentUserId),
      Expense(name: 'E2', authorUid: otherUserId)
    ];

    when(expenseService.listenForRelatedExpenses(any, any))
        .thenAnswer((_) => Stream.fromIterable([expenses]));
    when(groupService.groupStream(any))
        .thenAnswer((_) => Stream.fromIterable([testGroup]));
    when(currentUser.uid).thenReturn(currentUserId);
    when(authService.currentUser).thenAnswer((_) => currentUser);

    testWidgets('shows all group expenses', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<LayoutState>(create: (_) => LayoutState.narrow()),
            BlocProvider(create: (context) => ExpenseBloc(expenseService)),
            BlocProvider(
                create: (context) =>
                    GroupCubit(groupService, expenseService, userRepository)
                      ..load(groupId)),
            BlocProvider(
              create: (context) => ExpensesCubit(expenseService, groupService)
                ..load(currentUserId, groupId),
            ),
            BlocProvider(create: (context) => AuthBloc(authService))
          ],
          child: MaterialApp(home: Scaffold(body: ExpenseList())),
        ),
      );
      await tester.pumpAndSettle();

      for (var expense in expenses) {
        expect(find.text(expense.name), findsOneWidget);
      }
    });

    group('filtering', () {
      final finalizedExpense =
          Expense(name: 'finalized', authorUid: currentUserId);
      finalizedExpense.finalizedDate = DateTime.now();

      final pendingExpense = Expense(name: 'pending', authorUid: currentUserId);
      final completeItem = Item(name: 'Banana', value: 0.5);
      completeItem.assignees
          .add(AssigneeDecision(uid: currentUserId, parts: 1));
      pendingExpense.items.add(completeItem);

      final notMarkedExpense =
          Expense(name: 'not_marked', authorUid: currentUserId);
      final incompleteItem = Item(name: 'Apple', value: 0.5);
      incompleteItem.assignees.add(AssigneeDecision(uid: currentUserId));
      notMarkedExpense.items.add(incompleteItem);

      final expenses = [finalizedExpense, pendingExpense, notMarkedExpense];
      when(expenseService.listenForRelatedExpenses(any, any))
          .thenAnswer((_) => Stream.fromIterable([expenses]));

      testWidgets('can select finalized expenses', (WidgetTester tester) async {
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              Provider<LayoutState>(create: (_) => LayoutState.narrow()),
              BlocProvider(create: (context) => ExpenseBloc(expenseService)),
              BlocProvider(
                  create: (context) =>
                      GroupCubit(groupService, expenseService, userRepository)
                        ..load(groupId)),
              BlocProvider(
                create: (context) => ExpensesCubit(expenseService, groupService)
                  ..load(currentUserId, groupId),
              ),
              BlocProvider(create: (context) => AuthBloc(authService))
            ],
            child: MaterialApp(home: Scaffold(body: ExpenseList())),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Finalized'));
        await tester.pumpAndSettle();

        expect(find.text(finalizedExpense.name), findsNothing);
        expect(find.text(pendingExpense.name), findsOneWidget);
        expect(find.text(notMarkedExpense.name), findsOneWidget);

        await tester.tap(find.text('Finalized'));
        await tester.pumpAndSettle();

        expect(find.text(finalizedExpense.name), findsOneWidget);
        expect(find.text(pendingExpense.name), findsOneWidget);
        expect(find.text(notMarkedExpense.name), findsOneWidget);
      });

      testWidgets(
        'can select pending expenses',
        (WidgetTester tester) async {
          expect(notMarkedExpense.isIn(Expense.expenseStages(currentUserId)[0]),
              true);
          expect(pendingExpense.isIn(Expense.expenseStages(currentUserId)[1]),
              true);
          expect(finalizedExpense.isIn(Expense.expenseStages(currentUserId)[2]),
              true);
          await tester.pumpWidget(
            MultiProvider(
              providers: [
                Provider<LayoutState>(create: (_) => LayoutState.narrow()),
                BlocProvider(create: (context) => ExpenseBloc(expenseService)),
                BlocProvider(
                    create: (context) =>
                        GroupCubit(groupService, expenseService, userRepository)
                          ..load(groupId)),
                BlocProvider(
                  create: (context) =>
                      ExpensesCubit(expenseService, groupService)
                        ..load(currentUserId, groupId),
                ),
                BlocProvider(create: (context) => AuthBloc(authService))
              ],
              child: MaterialApp(home: Scaffold(body: ExpenseList())),
            ),
          );
          await tester.pumpAndSettle();

          await tester.tap(find.text('Pending'));
          await tester.pumpAndSettle();

          expect(find.text(finalizedExpense.name), findsOneWidget);
          expect(find.text(pendingExpense.name), findsNothing);
          expect(find.text(notMarkedExpense.name), findsOneWidget);

          await tester.tap(find.text('Pending'));
          await tester.pumpAndSettle();

          expect(find.text(finalizedExpense.name), findsOneWidget);
          expect(find.text(pendingExpense.name), findsOneWidget);
          expect(find.text(notMarkedExpense.name), findsOneWidget);
        },
      );

      testWidgets(
        'can select not marked expenses',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            MultiProvider(
              providers: [
                Provider<LayoutState>(create: (_) => LayoutState.narrow()),
                BlocProvider(create: (context) => ExpenseBloc(expenseService)),
                BlocProvider(
                    create: (context) =>
                        GroupCubit(groupService, expenseService, userRepository)
                          ..load(groupId)),
                BlocProvider(
                  create: (context) =>
                      ExpensesCubit(expenseService, groupService)
                        ..load(currentUserId, groupId),
                ),
                BlocProvider(create: (context) => AuthBloc(authService))
              ],
              child: MaterialApp(home: Scaffold(body: ExpenseList())),
            ),
          );
          await tester.pumpAndSettle();

          await tester.tap(find.text('Not Marked'));
          await tester.pumpAndSettle();

          expect(find.text(finalizedExpense.name), findsOneWidget);
          expect(find.text(pendingExpense.name), findsOneWidget);
          expect(find.text(notMarkedExpense.name), findsNothing);

          await tester.tap(find.text('Not Marked'));
          await tester.pumpAndSettle();

          expect(find.text(finalizedExpense.name), findsOneWidget);
          expect(find.text(pendingExpense.name), findsOneWidget);
          expect(find.text(notMarkedExpense.name), findsOneWidget);
        },
      );
    });
  });
}
