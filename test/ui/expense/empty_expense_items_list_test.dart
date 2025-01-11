import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/expense/buttons/new_item_button.dart';
import 'package:statera/ui/expense/buttons/receipt_scan_button.dart';
import 'package:statera/ui/expense/empty_expense_items_list.dart';
import 'package:statera/ui/platform_context.mocks.dart';

import '../../helpers.dart';

void main() {
  group('EmptyExpenseItemsList', () {
    final author = CustomUser.fake();
    final member = CustomUser.fake();
    final expense = Expense(name: 'Test', authorUid: author.uid);

    testWidgets('does not show action buttons to regular members',
        (WidgetTester tester) async {
      await customPump(
        EmptyExpenseItemsList(expense: expense),
        tester,
        currentUserId: member.uid,
      );
      await tester.pumpAndSettle();

      expect(
        find.text('There are no items in this expense yet'),
        findsOneWidget,
      );

      expect(find.byType(NewItemButton), findsNothing);
      expect(find.byType(ReceiptScanButton), findsNothing);
    });

    testWidgets('shows action buttons to admins', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(Size(900, 1200));

      final platformContext = MockPlatformContext();
      when(platformContext.isWeb).thenReturn(true);

      await customPump(
        EmptyExpenseItemsList(expense: expense),
        tester,
        currentUserId: author.uid,
        platformContext: platformContext,
      );
      await tester.pumpAndSettle();

      expect(find.text('Add items to this expense'), findsOneWidget);
      expect(find.byType(NewItemButton), findsOneWidget);
      expect(find.byType(ReceiptScanButton), findsOneWidget);
    });

    testWidgets('does not show receipt scanner button on MacOS (native)',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(Size(900, 1200));

      final platformContext = MockPlatformContext();
      when(platformContext.isWeb).thenReturn(false);
      when(platformContext.isMacOS).thenReturn(true);

      await customPump(
        EmptyExpenseItemsList(expense: expense),
        tester,
        currentUserId: author.uid,
        platformContext: platformContext,
      );
      await tester.pumpAndSettle();

      expect(find.text('Add items to this expense'), findsOneWidget);
      expect(find.byType(NewItemButton), findsOneWidget);
      expect(find.byType(ReceiptScanButton), findsNothing);
    });
  });
}
