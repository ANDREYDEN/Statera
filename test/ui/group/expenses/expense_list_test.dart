import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:statera/data/models/models.dart';
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
      final finalizedExpense = Expense(
        name: 'finalized',
        authorUid: defaultCurrentUserId,
      );
      finalizedExpense.finalizedDate = DateTime.now();

      final pendingExpense = Expense(
        name: 'pending',
        authorUid: defaultCurrentUserId,
      );
      final completeItem = Item(name: 'Banana', value: 0.5);
      completeItem.assignees
          .add(AssigneeDecision(uid: defaultCurrentUserId, parts: 1));
      pendingExpense.items.add(completeItem);

      final notMarkedExpense = Expense(
        name: 'not_marked',
        authorUid: defaultCurrentUserId,
      );
      final incompleteItem = Item(name: 'Apple', value: 0.5);
      incompleteItem.assignees.add(AssigneeDecision(uid: defaultCurrentUserId));
      notMarkedExpense.items.add(incompleteItem);

      final expenses = [finalizedExpense, pendingExpense, notMarkedExpense];

      testWidgets('can select finalized expenses', (WidgetTester tester) async {
        await customPump(ExpenseList(), tester, expenses: expenses);
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
          await customPump(ExpenseList(), tester, expenses: expenses);
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
          await customPump(ExpenseList(), tester, expenses: expenses);
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
