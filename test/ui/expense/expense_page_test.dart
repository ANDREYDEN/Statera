import 'package:flutter_test/flutter_test.dart';
import 'package:statera/data/models/models.dart';
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
  });
}

Future<void> pumpExpensePage(
  WidgetTester tester, {
  required Expense expense,
}) async {
  await customPump(
    ExpensePage(),
    tester,
    group: defaultGroup,
    selectedExpense: expense,
  );
}
