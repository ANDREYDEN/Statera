import 'package:flutter_test/flutter_test.dart';
import 'package:statera/data/models/models.dart';

void main() {
  group('Expense', () {
    late Expense expense;
    String authorUid = 'bar';
    String assigneeUid = 'qwe';

    setUp(() {
      expense = Expense(
        authorUid: authorUid,
        name: 'baz',
        groupId: 'que',
      );
    });

    group('assignee CRUD', () {
      test('adds the author to the assignees by default', () {
        expect(expense.assigneeUids, hasLength(1));
        expect(expense.assigneeUids.first, authorUid);
        expect(expense.isAuthoredBy(authorUid), isTrue);
      });

      group('updating assignees', () {
        test("updates and preserves the old assignees' product decisions", () {
          var item = Item.fake();
          expense.addItem(item);
          expense.addAssignee(assigneeUid);
          var initialParts = 1;
          item.setAssigneeDecision(assigneeUid, initialParts);
          var newAssigneeIds = [assigneeUid, '2', '3'];

          expense.updateAssignees(newAssigneeIds);

          expect(item.assignees, hasLength(newAssigneeIds.length));
          expect(item.isMarkedBy('2'), isFalse);
          expect(item.getAssigneeParts(assigneeUid), initialParts);
        });

        test('restricts updating with an empty list', () {
          expect(() => expense.updateAssignees([]), throwsException);
        });
      });

      group('adding assignees', () {
        test('can be performed', () {
          expense.assigneeUids = [assigneeUid];

          var item = Item.fake();
          expense.addItem(item);
          var firstAssigneeParts = 1;
          item.setAssigneeDecision(assigneeUid, firstAssigneeParts);

          var newAssigneeUid = 'bla';
          expense.addAssignee(newAssigneeUid);

          expect(expense.assigneeUids, hasLength(2));
          expect(expense.assigneeUids[1], newAssigneeUid);
          expect(
            item.getAssigneeParts(assigneeUid),
            firstAssigneeParts,
            reason: 'First assignee decision was removed',
          );
          expect(item.isMarkedBy(newAssigneeUid), isFalse);
        });

        test("can be performed if there's noone but the author assigned", () {
          expense.addItem(Item.fake());
          expense.assigneeUids = [authorUid];
          expense.items.first.setAssigneeDecision(authorUid, 1);

          expect(expense.canReceiveAssignees, isTrue);
        });

        test('can be performed even if all assignees have made their decisions',
            () {
          expense.addItem(Item.fake());
          expense.assigneeUids = [assigneeUid];
          expense.items.first.setAssigneeDecision(authorUid, 1);

          expect(expense.canReceiveAssignees, isTrue);
        });

        test("can't be performed if the expense is finalized", () {
          expense.addItem(Item.fake());
          expense.assigneeUids = [assigneeUid];
          expense.items.first.setAssigneeDecision(authorUid, 1);
          expense.finalizedDate = DateTime.now();

          expect(expense.canReceiveAssignees, isFalse);
        });

        test('can add assignee decisions to existing items', () {
          expense.assigneeUids = [assigneeUid];

          var item = Item.fake();
          expense.addItem(item);

          var itemAssigneeIds = item.assignees
              .map((assigneeDecision) => assigneeDecision.uid)
              .toList();
          var expenseAssigneeIds =
              expense.assigneeUids.map((assignee) => assigneeUid).toList();
          expect(itemAssigneeIds, containsAll(expenseAssigneeIds));
        });
      });
    });

    test('is completed when all assignees have completed their markings', () {
      var firstAssigneeUid = 'first';
      var secondAssigneeUid = 'second';
      expense.assigneeUids = [firstAssigneeUid, secondAssigneeUid];

      var item = SimpleItem(name: 'asd', value: 123);
      expense.addItem(item);

      item.setAssigneeDecision(firstAssigneeUid, 1);
      item.setAssigneeDecision(secondAssigneeUid, 0);

      expect(expense.completed, isTrue);
    });

    test('is marked by an assignee if all products are marked', () {
      expense.assigneeUids = [assigneeUid];

      var item1 = SimpleItem(name: 'asd', value: 123);
      var item2 = SimpleItem(name: 'asd', value: 123);
      expense.addItem(item1);
      expense.addItem(item2);

      item1.setAssigneeDecision(assigneeUid, 1);

      expect(expense.isMarkedBy(assigneeUid), isFalse);

      item2.setAssigneeDecision(assigneeUid, 0);

      expect(expense.isMarkedBy(assigneeUid), isTrue);
    });

    test('can return the number of assignees that have marked all items', () {
      var firstAssigneeUid = '1';
      var secondAssigneeUid = '2';
      var thirdAssigneeUid = '3';
      expense.assigneeUids = [
        firstAssigneeUid,
        secondAssigneeUid,
        thirdAssigneeUid
      ];

      var item1 = Item.fake();
      var item2 = Item.fake();
      expense.addItem(item1);
      expense.addItem(item2);

      expect(expense.definedAssignees, 0);

      item1.setAssigneeDecision(firstAssigneeUid, 1);
      item2.setAssigneeDecision(firstAssigneeUid, 0);

      expect(expense.definedAssignees, 1);

      item2.setAssigneeDecision(secondAssigneeUid, 0);

      expect(expense.definedAssignees, 1);
    });

    test('has tax when tax setting is set', () {
      expect(expense.hasTax, isFalse);

      expense.settings.tax = 0.1;

      expect(expense.hasTax, isTrue);
    });

    group('calculating totals', () {
      group('gets the total of its items', () {
        test('when no items have tax', () {
          var item1 = SimpleItem(name: 'big', value: 124);
          var item2 = SimpleItem(name: 'small', value: 42);
          expense.addItem(item1);
          expense.addItem(item2);

          expect(expense.total, item1.total + item2.total);
        });

        test('when some items have tax', () {
          var tax = 0.1;
          expense.settings.tax = tax;
          var item1 = SimpleItem(name: 'big', value: 124);
          var item2 = SimpleItem(name: 'small', value: 42, isTaxable: true);
          expense.addItem(item1);
          expense.addItem(item2);

          expect(expense.total, item1.total + item2.total * (1 + tax));
        });

        test('when all items have tax', () {
          var tax = 0.1;
          expense.settings.tax = tax;
          var item1 = SimpleItem(name: 'big', value: 124, isTaxable: true);
          var item2 = SimpleItem(name: 'small', value: 42, isTaxable: true);
          expense.addItem(item1);
          expense.addItem(item2);

          expect(expense.total, closeTo(182.6, 0.01));
        });

        test('when some items have tax and expense has a tip', () {
          var tax = 0.1;
          expense.settings.tax = tax;
          expense.settings.tip = 0.2;
          var item1 = SimpleItem(name: 'big', value: 124, isTaxable: true);
          var item2 = SimpleItem(name: 'small', value: 42, isTaxable: false);
          expense.addItem(item1);
          expense.addItem(item2);

          expect(expense.total, closeTo(211.6, 0.01));
        });
      });

      group('gets confirmed totals for assignees', () {
        var firstAssigneeUid = 'first';
        var secondAssigneeUid = 'second';
        late SimpleItem item1;
        late SimpleItem item2;

        setUp(() {
          expense.assigneeUids = [firstAssigneeUid, secondAssigneeUid];

          item1 = SimpleItem(name: 'big', value: 124);
          item2 = SimpleItem(name: 'small', value: 42, partition: 3);
          expense.addItem(item1);
          expense.addItem(item2);
        });

        test('when everything is not marked yet', () {
          expect(expense.getConfirmedTotalForUser(firstAssigneeUid), 0);
          expect(expense.getConfirmedTotalForUser(secondAssigneeUid), 0);
        });

        test("when someone didn't mark the items", () {
          item1.setAssigneeDecision(firstAssigneeUid, 1);
          item2.setAssigneeDecision(firstAssigneeUid, 2);

          expect(expense.getConfirmedTotalForUser(firstAssigneeUid), 152);
          expect(expense.getConfirmedTotalForUser(secondAssigneeUid), 0);
        });

        test('when everyone marked the items', () {
          item1.setAssigneeDecision(firstAssigneeUid, 1);
          item2.setAssigneeDecision(firstAssigneeUid, 2);

          item1.setAssigneeDecision(secondAssigneeUid, 1);
          item2.setAssigneeDecision(secondAssigneeUid, 1);

          expect(expense.getConfirmedTotalForUser(firstAssigneeUid), 90);
          expect(expense.getConfirmedTotalForUser(secondAssigneeUid), 76);
        });

        test('when there are denials', () {
          item1.setAssigneeDecision(firstAssigneeUid, 1);
          item2.setAssigneeDecision(firstAssigneeUid, 0);

          item1.setAssigneeDecision(secondAssigneeUid, 0);
          item2.setAssigneeDecision(secondAssigneeUid, 1);

          expect(expense.getConfirmedTotalForUser(firstAssigneeUid), 124);
          expect(expense.getConfirmedTotalForUser(secondAssigneeUid), 14);
        });

        test('when everything was denied', () {
          item1.setAssigneeDecision(firstAssigneeUid, 0);
          item2.setAssigneeDecision(firstAssigneeUid, 0);

          item1.setAssigneeDecision(secondAssigneeUid, 0);
          item2.setAssigneeDecision(secondAssigneeUid, 0);

          expect(expense.getConfirmedTotalForUser(firstAssigneeUid), 0);
          expect(expense.getConfirmedTotalForUser(secondAssigneeUid), 0);
        });

        test('when items were denied and not marked', () {
          item1.setAssigneeDecision(firstAssigneeUid, 0);

          item2.setAssigneeDecision(secondAssigneeUid, 0);

          expect(expense.getConfirmedTotalForUser(firstAssigneeUid), 0);
          expect(expense.getConfirmedTotalForUser(secondAssigneeUid), 0);
        });

        test('when expense has tax and no items are taxable', () {
          var tax = 0.1;
          expense.settings.tax = tax;

          item1.setAssigneeDecision(firstAssigneeUid, 0);
          item2.setAssigneeDecision(firstAssigneeUid, 1);

          item2.setAssigneeDecision(secondAssigneeUid, 2);

          expect(expense.getConfirmedTotalForUser(firstAssigneeUid), 14);
          expect(expense.getConfirmedSubtotalForUser(firstAssigneeUid), 14);
          expect(expense.getConfirmedTaxForUser(firstAssigneeUid), 0);
          expect(expense.getConfirmedTotalForUser(secondAssigneeUid), 28);
          expect(expense.getConfirmedSubtotalForUser(secondAssigneeUid), 28);
          expect(expense.getConfirmedTaxForUser(secondAssigneeUid), 0);
        });

        test('when expense has tax and some items are taxable', () {
          var tax = 0.1;
          expense.settings.tax = tax;
          item1.isTaxable = true;

          item1.setAssigneeDecision(firstAssigneeUid, 0);
          item2.setAssigneeDecision(firstAssigneeUid, 1);

          item1.setAssigneeDecision(secondAssigneeUid, 1);

          expect(expense.getConfirmedTotalForUser(firstAssigneeUid), 14);
          expect(expense.getConfirmedSubtotalForUser(firstAssigneeUid), 14);
          expect(expense.getConfirmedTaxForUser(firstAssigneeUid), 0);
          expect(expense.getConfirmedTotalForUser(secondAssigneeUid), 136.4);
          expect(expense.getConfirmedSubtotalForUser(secondAssigneeUid), 124);
          expect(expense.getConfirmedTaxForUser(secondAssigneeUid), 12.4);
        });

        test('when expense has tax and all items are taxable', () {
          var tax = 0.1;
          expense.settings.tax = tax;
          item1.isTaxable = true;
          item2.isTaxable = true;

          item1.setAssigneeDecision(firstAssigneeUid, 1);
          item2.setAssigneeDecision(firstAssigneeUid, 1);

          item2.setAssigneeDecision(secondAssigneeUid, 2);

          expect(expense.getConfirmedTotalForUser(firstAssigneeUid), 151.8);
          expect(expense.getConfirmedSubtotalForUser(firstAssigneeUid), 138);
          expect(expense.getConfirmedTaxForUser(firstAssigneeUid), 13.8);
          expect(expense.getConfirmedTotalForUser(secondAssigneeUid), 30.8);
          expect(expense.getConfirmedSubtotalForUser(secondAssigneeUid), 28);
          expect(expense.getConfirmedTaxForUser(secondAssigneeUid),
              closeTo(2.8, 0.01));
        });

        test('when expense has tax & tip and some items are taxable', () {
          expense.settings.tax = 0.1;
          expense.settings.tip = 0.2;
          item1.isTaxable = true;

          item1.setAssigneeDecision(firstAssigneeUid, 0);
          item2.setAssigneeDecision(firstAssigneeUid, 1);

          item1.setAssigneeDecision(secondAssigneeUid, 1);

          expect(expense.getConfirmedSubtotalForUser(firstAssigneeUid), 14);
          expect(expense.getConfirmedTaxForUser(firstAssigneeUid), 0);
          expect(
            expense.getConfirmedTipForUser(firstAssigneeUid),
            closeTo(2.8, 0.01),
          );
          expect(
            expense.getConfirmedTotalForUser(firstAssigneeUid),
            closeTo(16.8, 0.01),
          );

          expect(expense.getConfirmedSubtotalForUser(secondAssigneeUid), 124);
          expect(expense.getConfirmedTaxForUser(secondAssigneeUid), 12.4);
          expect(expense.getConfirmedTipForUser(secondAssigneeUid), 24.8);
          expect(
            expense.getConfirmedTotalForUser(secondAssigneeUid),
            closeTo(161.2, 0.01),
          );
        });
      });
    });

    test('can only be updated by the author if not finalized', () {
      var item = Item.fake();
      expense.addItem(item);
      var somebodyElseUid = 'other';
      expense.addAssignee(somebodyElseUid);

      expect(expense.canBeUpdatedBy(authorUid), isTrue);
      expect(expense.canBeUpdatedBy(somebodyElseUid), isFalse);

      item.setAssigneeDecision(authorUid, 1);
      item.setAssigneeDecision(somebodyElseUid, 0);

      expect(expense.canBeUpdatedBy(authorUid), isTrue);

      expense.finalizedDate = DateTime.now();

      expect(expense.canBeUpdatedBy(authorUid), isFalse);
    });

    test("can't be marked by anyone if the expense is finalized", () {
      var item = Item.fake();
      expense.addItem(item);
      var anotherAssigneeUid = 'another';
      var outsiderUid = 'outsider';
      expense.addAssignee(assigneeUid);
      expense.addAssignee(anotherAssigneeUid);

      item.setAssigneeDecision(authorUid, 0);
      item.setAssigneeDecision(assigneeUid, 1);
      item.setAssigneeDecision(anotherAssigneeUid, 0);

      [authorUid, assigneeUid, anotherAssigneeUid].forEach((uid) {
        expect(expense.canBeMarkedBy(uid), isTrue);
      });

      expense.finalizedDate = DateTime.now();

      [authorUid, assigneeUid, anotherAssigneeUid, outsiderUid].forEach((uid) {
        expect(expense.canBeMarkedBy(uid), isFalse);
      });
    });

    test("can't be marked by someone outside of the expense", () {
      var item = Item.fake();
      expense.addItem(item);
      var outsider = Assignee.fake();

      expect(expense.canBeMarkedBy(outsider.uid), isFalse);
    });

    test('can be marked by any assignee', () {
      var item = Item.fake();
      expense.addItem(item);
      var anotherAssigneeUid = 'another';
      expense.addAssignee(assigneeUid);
      expense.addAssignee(anotherAssigneeUid);

      [authorUid, assigneeUid, anotherAssigneeUid].forEach((uid) {
        expect(expense.canBeMarkedBy(uid), isTrue);
      });
    });

    group('conversion', () {
      test('expense can be converted to an from a Firestore object', () {
        var expense = Expense(
          name: 'foo',
          authorUid: authorUid,
          groupId: '123',
        );
        expense.date = null;

        var firestoreExpense = Expense.fromFirestore(
          expense.toFirestore(),
          expense.id,
        );
        expect(expense, firestoreExpense);
        expect(expense == firestoreExpense, isTrue);
      });
    });
  });
}
