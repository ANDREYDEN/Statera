import 'package:flutter_test/flutter_test.dart';
import 'package:statera/data/models/assignee.dart';
import 'package:statera/data/models/expense.dart';
import 'package:statera/data/models/item.dart';

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

      var item = Item(name: 'asd', value: 123);
      expense.addItem(item);

      item.setAssigneeDecision(firstAssigneeUid, 1);
      item.setAssigneeDecision(secondAssigneeUid, 0);

      expect(expense.completed, isTrue);
    });

    test('is marked by an assignee if all products are marked', () {
      expense.assigneeUids = [assigneeUid];

      var item1 = Item(name: 'asd', value: 123);
      var item2 = Item(name: 'asd', value: 123);
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

    group('calculating totals', () {
      group('gets the total of its items', () {
        test('when no items have tax', () {
          var item1 = Item(name: 'big', value: 124);
          var item2 = Item(name: 'small', value: 42);
          expense.addItem(item1);
          expense.addItem(item2);

          expect(expense.total, item1.value + item2.value);
        });

        test('when some items have tax', () {
          var tax = 0.1;
          expense.settings.tax = tax;
          var item1 = Item(name: 'big', value: 124);
          var item2 = Item(name: 'small', value: 42, isTaxable: true);
          expense.addItem(item1);
          expense.addItem(item2);

          expect(expense.total, item1.value + item2.value * (1 + tax));
        });

        test('when all items have tax', () {
          var tax = 0.1;
          expense.settings.tax = tax;
          var item1 = Item(name: 'big', value: 124, isTaxable: true);
          var item2 = Item(name: 'small', value: 42, isTaxable: true);
          expense.addItem(item1);
          expense.addItem(item2);

          expect(expense.total, (item1.value + item2.value) * (1 + tax));
        });
      });

      group('gets confirmed total for assignees', () {
        var firstAssigneeUid = 'first';
        var secondAssigneeUid = 'second';
        var item1 = Item(name: 'big', value: 124);
        var item2 = Item(name: 'small', value: 42, partition: 3);
        setUp(() {
          expense.assigneeUids = [firstAssigneeUid, secondAssigneeUid];

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
      });

      group('gets confirmed subtotal for assignees', () {
        var firstAssigneeUid = 'first';
        var secondAssigneeUid = 'second';
        var item1 = Item(name: 'big', value: 124);
        var item2 = Item(name: 'small', value: 42, partition: 3);
        setUp(() {
          expense.assigneeUids = [firstAssigneeUid, secondAssigneeUid];

          expense.addItem(item1);
          expense.addItem(item2);
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
      test('expense can be converted to Firestore object', () {
        var expense = Expense(
          name: 'foo',
          authorUid: authorUid,
          groupId: '123',
        );

        var firestoreData = expense.toFirestore();

        expect(firestoreData['name'], expense.name);
        expect(firestoreData['authorUid'], expense.authorUid);
        expect(
          expense.date!.difference(firestoreData['date']),
          lessThan(Duration(seconds: 1)),
        );
      });
    });
  });
}
