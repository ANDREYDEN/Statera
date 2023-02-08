import 'package:flutter_test/flutter_test.dart';
import 'package:statera/data/models/models.dart';

void main() {
  group('Large expense', () {
    var expense = Expense(
      name: 'Big',
      authorUid: 'foo',
      settings: ExpenseSettings(tax: 0.13),
    );

    var assigneeUids = ['1', '2', '3'];
    for (var uid in assigneeUids) {
      expense.assigneeUids.add(uid);
    }

    var item1 = Item(
      name: 'Blaster',
      value: 12.97,
      isTaxable: true,
      partition: 3,
    );
    expense.addItem(item1);
    // no decision for assignee 1
    item1.setAssigneeDecision('2', 1);
    item1.setAssigneeDecision('3', 2);

    var item2 = Item(name: 'Kinder', value: 0.86, isTaxable: true);
    expense.addItem(item2);
    item2.setAssigneeDecision('1', 1);
    item2.setAssigneeDecision('2', 1);
    item2.setAssigneeDecision('3', 1);

    var item3 = Item(name: 'Kinder', value: 0.86, isTaxable: true);
    expense.addItem(item3);
    item3.setAssigneeDecision('1', 0);
    // no decision for assignee 2
    item3.setAssigneeDecision('3', 1);

    var item4 = Item(name: 'Potatoes', value: 3.97);
    expense.addItem(item4);
    // no decisions made

    var item5 = Item(name: 'Tomatoes', value: 3.97);
    expense.addItem(item5);
    item5.setAssigneeDecision('1', 1);
    item5.setAssigneeDecision('2', 1);
    item5.setAssigneeDecision('3', 1);

    var item6 = Item(name: 'Avocados', value: 4.97, partition: 5);
    expense.addItem(item6);
    item6.setAssigneeDecision('1', 0);
    item6.setAssigneeDecision('2', 1);
    item6.setAssigneeDecision('3', 4);

    var item7 = Item(name: 'Cucumbers', value: 1.97);
    expense.addItem(item7);
    item7.setAssigneeDecision('1', 1);
    item7.setAssigneeDecision('2', 1);
    // no decision for assignee 3

    test('can calculate its total', () {
      expect(expense.total, closeTo(31.48, 0.01));
    });

    test('can calculate totals and assignee split', () {
      expect(expense.getConfirmedSubTotalForUser('1'), closeTo(2.6, 0.01));
      expect(expense.getConfirmedTaxForUser('1'), closeTo(0.03, 0.01));
      expect(expense.getConfirmedTotalForUser('1'), closeTo(2.63, 0.01));

      expect(expense.getConfirmedSubTotalForUser('2'), closeTo(7.91, 0.01));
      expect(expense.getConfirmedTaxForUser('2'), closeTo(0.6, 0.01));
      expect(expense.getConfirmedTotalForUser('2'), closeTo(8.51, 0.01));

      expect(expense.getConfirmedSubTotalForUser('3'), closeTo(15.09, 0.01));
      expect(expense.getConfirmedTaxForUser('3'), closeTo(1.27, 0.01));
      expect(expense.getConfirmedTotalForUser('3'), closeTo(16.36, 0.01));
    });
  });
}
