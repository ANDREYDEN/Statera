import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/expense/expense_details.dart';
import 'package:statera/ui/expense/expense_page.dart';

import '../../helpers.dart';

void main() {
  group('ExpensePage', () {
    testWidgets('shows the expense title and item names when loaded', (
      tester,
    ) async {
      final expense = Expense(
        name: 'Grocery Run',
        authorUid: defaultCurrentUserId,
      );
      expense.items.add(SimpleItem(name: 'Milk', value: 2.0));
      expense.items.add(SimpleItem(name: 'Eggs', value: 3.0));

      await pumpExpensePage(tester, expense: expense);
      await tester.pumpAndSettle();

      expect(find.text('Grocery Run'), findsOneWidget);
      expect(find.text('Milk'), findsOneWidget);
      expect(find.text('Eggs'), findsOneWidget);
    });

    group('Expense Actions', () {
      group('Add tax to all items', () {
        testWidgets('applies tax to all items', (tester) async {
          final expense = Expense(
            name: 'Grocery Run',
            authorUid: defaultCurrentUserId,
          );
          expense.settings.tax = 0.13;
          final item1 = SimpleItem(
            name: 'Milk',
            value: 10.0,
            assigneeUids: [defaultCurrentUserId],
          );
          item1.setAssigneeDecision(defaultCurrentUserId, 1);
          final item2 = SimpleItem(
            name: 'Eggs',
            value: 5.0,
            assigneeUids: [defaultCurrentUserId],
          );
          item2.setAssigneeDecision(defaultCurrentUserId, 1);
          expense.items.add(item1);
          expense.items.add(item2);

          await pumpExpensePage(tester, expense: expense);
          await tester.pumpAndSettle();

          expectExepenseTotalIs('\$15.00');

          await tester.tap(find.byIcon(Icons.more_vert));
          await tester.pumpAndSettle();

          await tester.tap(find.text('Add tax to all items'));
          await tester.pumpAndSettle();

          await tester.tap(find.text('Yes'));
          await tester.pumpAndSettle();

          expect(find.textContaining('+ tax'), findsExactly(2));
          expect(find.textContaining('Tax ('), findsOneWidget);
          expectExepenseTotalIs('\$16.95');
        });
      });
    });
  });
}

Future<void> pumpExpensePage(
  WidgetTester tester, {
  required Expense expense,
}) async {
  when(
    defaultExpenseService.expenseStream(any),
  ).thenAnswer((_) => Stream.value(expense));

  await customPump(
    ExpensePage(),
    tester,
    group: defaultGroup,
    selectedExpense: expense,
  );
}

void expectExepenseTotalIs(String expectedTotal) {
  final totalWidget = find.ancestor(
    of: find.text('Your Total'),
    matching: find.byType(FooterEntry),
  );

  final totalTextWidget = find.descendant(
    of: totalWidget,
    matching: find.text(expectedTotal),
  );
  expect(totalTextWidget, findsOneWidget);
}
