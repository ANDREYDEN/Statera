import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/user_expense_repository.mocks.dart';
import 'package:statera/ui/group/expenses/expense_list.dart';

import '../../../helpers.dart';

class MockUser extends Mock implements User {
  String get uid =>
      super.noSuchMethod(Invocation.getter(#uid), returnValue: 'foo');
}

void main() {
  group('Expense List', () {
    final expenses = [
      Expense(name: 'E1', authorUid: defaultCurrentUserId),
      Expense(name: 'E2', authorUid: defaultCurrentUserId)
    ];

    testWidgets('shows all group expenses', (WidgetTester tester) async {
      await customPump(ExpenseList(), tester, expenses: expenses);
      await tester.pumpAndSettle();

      for (var expense in expenses) {
        expect(find.text(expense.name), findsOneWidget);
      }
    });

    group('filtering', () {
      final finalizedExpense = createFinalizedExpense(
        authorUid: defaultCurrentUserId,
      );

      final pendingExpense = createPendingExpense(
        authorUid: defaultCurrentUserId,
      );

      final notMarkedExpense = createNotMarkedExpense(
        authorUid: defaultCurrentUserId,
      );

      testWidgets('can select finalized expenses', (WidgetTester tester) async {
        final userExpenseRepository = MockUserExpenseRepository();
        var responseCount = 0;
        when(userExpenseRepository.listenForRelatedExpenses(
          any,
          any,
          quantity: anyNamed('quantity'),
          stages: anyNamed('stages'),
        )).thenAnswer((_) => [
              Stream.fromIterable([
                [finalizedExpense, pendingExpense, notMarkedExpense]
              ]),
              Stream.fromIterable([
                [pendingExpense, notMarkedExpense]
              ]),
              Stream.fromIterable([
                [finalizedExpense, pendingExpense, notMarkedExpense]
              ]),
            ][responseCount++]);
        await customPump(
          ExpenseList(),
          tester,
          userExpenseRepository: userExpenseRepository,
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Finalized'));
        await tester.pumpAndSettle();

        verify(userExpenseRepository.listenForRelatedExpenses(
          any,
          any,
          quantity: anyNamed('quantity'),
          stages: [0, 1],
        )).called(1);
        expect(find.text(finalizedExpense.name), findsNothing);
        expect(find.text(pendingExpense.name), findsOneWidget);
        expect(find.text(notMarkedExpense.name), findsOneWidget);

        await tester.tap(find.text('Finalized'));
        await tester.pumpAndSettle();

        verify(userExpenseRepository.listenForRelatedExpenses(
          any,
          any,
          quantity: anyNamed('quantity'),
          stages: [0, 1, 2],
        )).called(2);
        expect(find.text(finalizedExpense.name), findsOneWidget);
        expect(find.text(pendingExpense.name), findsOneWidget);
        expect(find.text(notMarkedExpense.name), findsOneWidget);
      });

      testWidgets('can select pending expenses', (WidgetTester tester) async {
        final userExpenseRepository = MockUserExpenseRepository();
        var responseCount = 0;
        when(userExpenseRepository.listenForRelatedExpenses(
          any,
          any,
          quantity: anyNamed('quantity'),
          stages: anyNamed('stages'),
        )).thenAnswer((_) => [
              Stream.fromIterable([
                [finalizedExpense, pendingExpense, notMarkedExpense]
              ]),
              Stream.fromIterable([
                [finalizedExpense, notMarkedExpense]
              ]),
              Stream.fromIterable([
                [finalizedExpense, pendingExpense, notMarkedExpense]
              ]),
            ][responseCount++]);
        await customPump(
          ExpenseList(),
          tester,
          userExpenseRepository: userExpenseRepository,
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Pending'));
        await tester.pumpAndSettle();

        verify(userExpenseRepository.listenForRelatedExpenses(
          any,
          any,
          quantity: anyNamed('quantity'),
          stages: [0, 2],
        )).called(1);
        expect(find.text(finalizedExpense.name), findsOneWidget);
        expect(find.text(pendingExpense.name), findsNothing);
        expect(find.text(notMarkedExpense.name), findsOneWidget);

        await tester.tap(find.text('Pending'));
        await tester.pumpAndSettle();

        verify(userExpenseRepository.listenForRelatedExpenses(
          any,
          any,
          quantity: anyNamed('quantity'),
          stages: [0, 2, 1],
        )).called(1);
        expect(find.text(finalizedExpense.name), findsOneWidget);
        expect(find.text(pendingExpense.name), findsOneWidget);
        expect(find.text(notMarkedExpense.name), findsOneWidget);
      });

      testWidgets('can select not marked expenses',
          (WidgetTester tester) async {
        final userExpenseRepository = MockUserExpenseRepository();
        var responseCount = 0;
        when(userExpenseRepository.listenForRelatedExpenses(
          any,
          any,
          quantity: anyNamed('quantity'),
          stages: anyNamed('stages'),
        )).thenAnswer((_) => [
              Stream.fromIterable([
                [finalizedExpense, pendingExpense, notMarkedExpense]
              ]),
              Stream.fromIterable([
                [finalizedExpense, pendingExpense]
              ]),
              Stream.fromIterable([
                [finalizedExpense, pendingExpense, notMarkedExpense]
              ]),
            ][responseCount++]);
        await customPump(
          ExpenseList(),
          tester,
          userExpenseRepository: userExpenseRepository,
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Not Marked'));
        await tester.pumpAndSettle();

        verify(userExpenseRepository.listenForRelatedExpenses(
          any,
          any,
          quantity: anyNamed('quantity'),
          stages: [1, 2],
        )).called(1);
        expect(find.text(finalizedExpense.name), findsOneWidget);
        expect(find.text(pendingExpense.name), findsOneWidget);
        expect(find.text(notMarkedExpense.name), findsNothing);

        await tester.tap(find.text('Not Marked'));
        await tester.pumpAndSettle();

        verify(userExpenseRepository.listenForRelatedExpenses(
          any,
          any,
          quantity: anyNamed('quantity'),
          stages: [1, 2, 0],
        )).called(1);
        expect(find.text(finalizedExpense.name), findsOneWidget);
        expect(find.text(pendingExpense.name), findsOneWidget);
        expect(find.text(notMarkedExpense.name), findsOneWidget);
      });
    });
  });
}
