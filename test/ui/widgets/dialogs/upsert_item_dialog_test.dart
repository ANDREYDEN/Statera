import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/widgets/dialogs/upsert_item_dialog.dart';

import '../../../helpers.dart';
import '../../../widget_tester_extensions.dart';

void main() {
  group('UpsertItemDialog', () {
    testWidgets(
      'saves assignee decisions made on behalf of others when creating a new item',
      (tester) async {
        await tester.binding.setSurfaceSize(Size(600, 1200));

        final author = CustomUser.fake(name: 'Author');
        final other = CustomUser.fake(name: 'Other');
        final group = Group(
          name: 'Test group',
          members: [author, other],
          allowAuthorsToMarkOnBehalfOfOthers: true,
        );
        final expense = Expense(
          name: 'Test Expense',
          authorUid: author.uid,
          assigneeUids: [author.uid, other.uid],
        );

        Item? submittedItem;

        await pumpUpsertItemDialog(
          tester,
          group: group,
          expense: expense,
          currentUserId: author.uid,
          onSubmit: (item) => submittedItem = item,
        );

        await tester.pump();
        await tester.tap(find.text('Advanced'));
        await tester.pumpAndSettle();

        await tester.enterTextByLabel('Item Name', 'Pizza');
        await tester.enterTextByLabel('Item Value', '10');

        final otherTile = find.ancestor(
          of: find.text(other.name),
          matching: find.byType(ListTile),
        );
        await tester.tap(
          find.descendant(
            of: otherTile,
            matching: find.byIcon(Icons.check_rounded),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        expect(submittedItem, isNotNull);
        expect(submittedItem!.getAssigneeParts(other.uid), 1);
      },
    );

    testWidgets(
      'clamps assignee decisions made on behalf of others when the item partition shrinks afterwards',
      (tester) async {
        await tester.binding.setSurfaceSize(Size(600, 1200));

        final author = CustomUser.fake(name: 'Author');
        final other = CustomUser.fake(name: 'Other');
        final group = Group(
          name: 'Test group',
          members: [author, other],
          allowAuthorsToMarkOnBehalfOfOthers: true,
        );
        final expense = Expense(
          name: 'Test Expense',
          authorUid: author.uid,
          assigneeUids: [author.uid, other.uid],
        );

        Item? submittedItem;

        await pumpUpsertItemDialog(
          tester,
          group: group,
          expense: expense,
          currentUserId: author.uid,
          onSubmit: (item) => submittedItem = item,
        );

        await tester.pump();
        await tester.tap(find.text('Advanced'));
        await tester.pumpAndSettle();

        await tester.enterTextByLabel('Item Name', 'Pizza');
        await tester.enterTextByLabel('Item Value', '10');

        await tester.enterTextByLabel('Item Parts', '5');
        await tester.pumpAndSettle();

        final otherTile = find.ancestor(
          of: find.text(other.name),
          matching: find.byType(ListTile),
        );
        final otherAcceptButton = find
            .descendant(of: otherTile, matching: find.byType(IconButton))
            .at(1);

        final otherAssigneeItemParts = 3;
        for (var i = 0; i < otherAssigneeItemParts; i++) {
          await tester.tap(otherAcceptButton);
          await tester.pumpAndSettle();
        }

        await tester.enterTextByLabel('Item Parts', '2');
        await tester.pumpAndSettle();

        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        expect(submittedItem, isNotNull);
        expect(submittedItem!.partition, 2);
        expect(submittedItem!.getAssigneeParts(other.uid), 2);
      },
    );
  });
}

Future<void> pumpUpsertItemDialog(
  WidgetTester tester, {
  required Group group,
  required Expense expense,
  required String currentUserId,
  required void Function(Item) onSubmit,
}) {
  return customPump(
    UpsertItemDialog(onSubmit: onSubmit),
    tester,
    group: group,
    selectedExpense: expense,
    currentUserId: currentUserId,
  );
}
