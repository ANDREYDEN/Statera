import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/expense_service.mocks.dart';
import 'package:statera/ui/expense/buttons/new_item_button.dart';
import 'package:statera/ui/expense/items/item_list_item.dart';
import 'package:statera/ui/expense/items/items_list.dart';

import '../../../helpers.dart';

void main() {
  group('ItemsList', () {
    final author = CustomUser.fake();
    final member = CustomUser.fake();

    final item1 = SimpleItem(name: 'First Item', value: 15.0);
    final item2 = SimpleItem(name: 'Second Item', value: 25.0);

    testWidgets('shows empty message if expense has no items', (
      WidgetTester tester,
    ) async {
      final expense = Expense(name: 'Test Expense', authorUid: author.uid);

      await _pumpItemsList(tester, currentUserId: member.uid, expense: expense);

      expect(
        find.text('There are no items in this expense yet'),
        findsOneWidget,
      );
    });

    testWidgets(
      'shows empty message and action button if expense has no items and user is expense author',
      (WidgetTester tester) async {
        final expense = Expense(name: 'Test Expense', authorUid: author.uid);

        await _pumpItemsList(
          tester,
          currentUserId: author.uid,
          expense: expense,
        );

        expect(find.text('Add items to this expense'), findsOneWidget);
        expect(find.byType(NewItemButton), findsOneWidget);
      },
    );

    testWidgets(
      'shows info message if user is expense author, but not an assignee',
      (WidgetTester tester) async {
        final expense = Expense(name: 'Test Expense', authorUid: author.uid);
        expense.removeAssignee(author.uid);
        expense.addAssignee(member.uid);
        expense.addItem(item1);

        await _pumpItemsList(
          tester,
          currentUserId: author.uid,
          expense: expense,
        );

        expect(
          find.text(
            'You can\'t mark items in this expense because you are not an assignee.',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets('shows expense items', (WidgetTester tester) async {
      final expense = Expense(name: 'Test Expense', authorUid: author.uid);
      expense.addAssignee(author.uid);
      expense.addItem(item1);
      expense.addItem(item2);

      await _pumpItemsList(tester, currentUserId: author.uid, expense: expense);

      expect(find.byType(ItemListItem), findsNWidgets(2));
      expect(find.text('First Item'), findsOneWidget);
      expect(find.text('Second Item'), findsOneWidget);
    });
  });
}

Future<void> _pumpItemsList(
  WidgetTester tester, {
  required Expense expense,
  String? currentUserId,
}) {
  final mockExpenseService = MockExpenseService();
  when(
    mockExpenseService.expenseStream(any),
  ).thenAnswer((_) => Stream.fromIterable([expense]));

  return customPump(
    ItemsList(),
    tester,
    currentUserId: currentUserId,
    expenseService: mockExpenseService,
    selectedExpense: expense,
  );
}
