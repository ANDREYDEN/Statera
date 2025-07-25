import 'package:flutter_test/flutter_test.dart';
import 'package:statera/data/models/models.dart';

void main() {
  group('Large expense', () {
    var expense = Expense(
      name: 'Big',
      authorUid: 'foo',
      settings: ExpenseSettings(tax: 0.13, tip: 0.15),
    );

    var assigneeUids = ['1', '2', '3'];
    for (var uid in assigneeUids) {
      expense.assigneeUids.add(uid);
    }

    var item1 = SimpleItem(
      name: 'Blaster',
      value: 12.97,
      isTaxable: true,
      partition: 3,
    );
    expense.addItem(item1);
    // no decision for assignee 1
    item1.setAssigneeDecision('2', 1);
    item1.setAssigneeDecision('3', 2);

    var item2 = SimpleItem(name: 'Kinder', value: 0.86, isTaxable: true);
    expense.addItem(item2);
    item2.setAssigneeDecision('1', 1);
    item2.setAssigneeDecision('2', 1);
    item2.setAssigneeDecision('3', 1);

    var item3 = SimpleItem(name: 'Kinder', value: 0.86, isTaxable: true);
    expense.addItem(item3);
    item3.setAssigneeDecision('1', 0);
    // no decision for assignee 2
    item3.setAssigneeDecision('3', 1);

    var item4 = SimpleItem(name: 'Potatoes', value: 3.97);
    expense.addItem(item4);
    // no decisions made

    var item5 = SimpleItem(name: 'Tomatoes', value: 3.97);
    expense.addItem(item5);
    item5.setAssigneeDecision('1', 1);
    item5.setAssigneeDecision('2', 1);
    item5.setAssigneeDecision('3', 1);

    var item6 = SimpleItem(name: 'Avocados', value: 4.97, partition: 5);
    expense.addItem(item6);
    item6.setAssigneeDecision('1', 0);
    item6.setAssigneeDecision('2', 1);
    item6.setAssigneeDecision('3', 4);

    var item7 = SimpleItem(name: 'Cucumbers', value: 1.97);
    expense.addItem(item7);
    item7.setAssigneeDecision('1', 1);
    item7.setAssigneeDecision('2', 1);
    // no decision for assignee 3

    test('can calculate its total', () {
      final expectedSubtotal = 29.57;
      final expectedTip = 4.4355;
      final expectedTax = 1.9097;
      expect(expense.total,
          closeTo(expectedSubtotal + expectedTip + expectedTax, 0.01));
    });

    test('can calculate totals and assignee split', () {
      expect(expense.getConfirmedSubtotalForUser('1'), closeTo(2.6, 0.01));
      expect(expense.getConfirmedTaxForUser('1'), closeTo(0.03, 0.01));
      expect(expense.getConfirmedTipForUser('1'), closeTo(0.39, 0.01));
      expect(expense.getConfirmedTotalForUser('1'), closeTo(3.02, 0.01));

      expect(expense.getConfirmedSubtotalForUser('2'), closeTo(7.91, 0.01));
      expect(expense.getConfirmedTaxForUser('2'), closeTo(0.6, 0.01));
      expect(expense.getConfirmedTipForUser('2'), closeTo(1.1865, 0.01));
      expect(expense.getConfirmedTotalForUser('2'), closeTo(9.6965, 0.01));

      expect(expense.getConfirmedSubtotalForUser('3'), closeTo(15.09, 0.01));
      expect(expense.getConfirmedTaxForUser('3'), closeTo(1.27, 0.01));
      expect(expense.getConfirmedTipForUser('3'), closeTo(2.2635, 0.01));
      expect(expense.getConfirmedTotalForUser('3'), closeTo(18.6235, 0.01));
    });
  });
}
