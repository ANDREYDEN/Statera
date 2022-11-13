import 'package:flutter_test/flutter_test.dart';
import 'package:statera/data/models/assignee.dart';
import 'package:statera/data/models/author.dart';
import 'package:statera/data/models/expense.dart';
import 'package:statera/data/models/item.dart';

void main() {
  group('Expense', () {
    late Expense expense;
    CustomUser author = CustomUser(name: 'foo', uid: 'bar');
    Assignee assignee = Assignee(uid: 'qwe');

    setUp(() {
      expense = Expense(
        author: author,
        name: 'baz',
        groupId: 'que',
      );
    });

    group('assignee CRUD', () {
      test('adds the author to the assignees by default', () {
        expect(expense.assignees, hasLength(1));
        expect(expense.assignees.first.uid, author.uid);
        expect(expense.isAuthoredBy(author.uid), isTrue);
      });

      group('updating assignees', () {
        test("updates and preserves the old assignees' product decisions", () {
          var item = Item.fake();
          expense.addItem(item);
          expense.addAssignee(assignee);
          var initialParts = 1;
          item.setAssigneeDecision(assignee.uid, initialParts);
          var newAssigneeIds = [assignee.uid, '2', '3'];

          expense.updateAssignees(newAssigneeIds);

          expect(item.assignees, hasLength(newAssigneeIds.length));
          expect(item.isMarkedBy('2'), isFalse);
          expect(item.getAssigneeParts(assignee.uid), initialParts);
        });

        test('restricts updating with an empty list', () {
          expect(() => expense.updateAssignees([]), throwsException);
        });
      });

      group('adding assignees', () {
        test('can be performed', () {
          expense.assignees = [assignee];

          var item = Item.fake();
          expense.addItem(item);
          var firstAssigneeParts = 1;
          item.setAssigneeDecision(assignee.uid, firstAssigneeParts);

          var newAssignee = Assignee.fake();
          expense.addAssignee(newAssignee);

          expect(expense.assignees, hasLength(2));
          expect(expense.assignees[1].uid, newAssignee.uid);
          expect(
            item.getAssigneeParts(assignee.uid),
            firstAssigneeParts,
            reason: 'First assignee decision was removed',
          );
          expect(item.isMarkedBy(newAssignee.uid), isFalse);
        });

        test("can be performed if there's noone but the author assigned", () {
          expense.addItem(Item.fake());
          expense.assignees = [Assignee(uid: author.uid)];
          expense.items.first.setAssigneeDecision(author.uid, 1);

          expect(expense.canReceiveAssignees, isTrue);
        });

        test('can be performed even if all assignees have made their decisions',
            () {
          expense.addItem(Item.fake());
          expense.assignees = [assignee];
          expense.items.first.setAssigneeDecision(author.uid, 1);

          expect(expense.canReceiveAssignees, isTrue);
        });

        test("can't be performed if the expense is finalized", () {
          expense.addItem(Item.fake());
          expense.assignees = [assignee];
          expense.items.first.setAssigneeDecision(author.uid, 1);
          expense.finalizedDate = DateTime.now();

          expect(expense.canReceiveAssignees, isFalse);
        });

        test('can add assignee decisions to existing items', () {
          expense.assignees = [assignee];

          var item = Item.fake();
          expense.addItem(item);

          var itemAssigneeIds = item.assignees
              .map((assigneeDecision) => assigneeDecision.uid)
              .toList();
          var expenseAssigneeIds =
              expense.assignees.map((assignee) => assignee.uid).toList();
          expect(itemAssigneeIds, containsAll(expenseAssigneeIds));
        });
      });
    });

    test(
      'is completed when all assignees have completed their markings',
      () {
        var firstAssignee = Assignee(uid: 'first');
        var secondAssignee = Assignee(uid: 'second');
        expense.assignees = [firstAssignee, secondAssignee];

        var item = Item(name: 'asd', value: 123);
        expense.addItem(item);

        item.setAssigneeDecision(firstAssignee.uid, 1);
        item.setAssigneeDecision(secondAssignee.uid, 0);

        expect(expense.completed, isTrue);
      },
    );

    test('is marked by an assignee if all products are marked', () {
      expense.assignees = [assignee];

      var item1 = Item(name: 'asd', value: 123);
      var item2 = Item(name: 'asd', value: 123);
      expense.addItem(item1);
      expense.addItem(item2);

      item1.setAssigneeDecision(assignee.uid, 1);

      expect(expense.isMarkedBy(assignee.uid), isFalse);

      item2.setAssigneeDecision(assignee.uid, 0);

      expect(expense.isMarkedBy(assignee.uid), isTrue);
    });

    test('can return the number of assignees that have marked all items', () {
      var firstAssignee = Assignee.fake(uid: '1');
      var secondAssignee = Assignee.fake(uid: '2');
      var thirdAssignee = Assignee.fake(uid: '3');
      expense.assignees = [firstAssignee, secondAssignee, thirdAssignee];

      var item1 = Item.fake();
      var item2 = Item.fake();
      expense.addItem(item1);
      expense.addItem(item2);

      expect(expense.definedAssignees, 0);

      item1.setAssigneeDecision(firstAssignee.uid, 1);
      item2.setAssigneeDecision(firstAssignee.uid, 0);

      expect(expense.definedAssignees, 1);

      item2.setAssigneeDecision(secondAssignee.uid, 0);

      expect(expense.definedAssignees, 1);
    });

    group('calculating totals', () {
      test('gets the total of its items', () {
        var item1 = Item(name: 'big', value: 124);
        var item2 = Item(name: 'small', value: 42);
        expense.addItem(item1);
        expense.addItem(item2);

        expect(expense.total, item1.value + item2.value);
      });

      group('gets confirmed total for assignees', () {
        var firstAssignee = Assignee(uid: 'first');
        var secondAssignee = Assignee(uid: 'second');
        var item1 = Item(name: 'big', value: 124);
        var item2 = Item(name: 'small', value: 42, partition: 3);
        setUp(() {
          expense.assignees = [firstAssignee, secondAssignee];

          expense.addItem(item1);
          expense.addItem(item2);
        });

        test('when everything is not marked yet', () {
          expect(expense.getConfirmedTotalForUser(firstAssignee.uid), 0);
          expect(expense.getConfirmedTotalForUser(secondAssignee.uid), 0);
        });

        test("when someone didn't mark the items", () {
          item1.setAssigneeDecision(firstAssignee.uid, 1);
          item2.setAssigneeDecision(firstAssignee.uid, 2);

          expect(expense.getConfirmedTotalForUser(firstAssignee.uid), 152);
          expect(expense.getConfirmedTotalForUser(secondAssignee.uid), 0);
        });

        test('when everyone marked the items', () {
          item1.setAssigneeDecision(firstAssignee.uid, 1);
          item2.setAssigneeDecision(firstAssignee.uid, 2);

          item1.setAssigneeDecision(secondAssignee.uid, 1);
          item2.setAssigneeDecision(secondAssignee.uid, 1);

          expect(expense.getConfirmedTotalForUser(firstAssignee.uid), 90);
          expect(expense.getConfirmedTotalForUser(secondAssignee.uid), 76);
        });

        test('when there are denials', () {
          item1.setAssigneeDecision(firstAssignee.uid, 1);
          item2.setAssigneeDecision(firstAssignee.uid, 0);

          item1.setAssigneeDecision(secondAssignee.uid, 0);
          item2.setAssigneeDecision(secondAssignee.uid, 1);

          expect(expense.getConfirmedTotalForUser(firstAssignee.uid), 124);
          expect(expense.getConfirmedTotalForUser(secondAssignee.uid), 14);
        });

        test('when everything was denied', () {
          item1.setAssigneeDecision(firstAssignee.uid, 0);
          item2.setAssigneeDecision(firstAssignee.uid, 0);

          item1.setAssigneeDecision(secondAssignee.uid, 0);
          item2.setAssigneeDecision(secondAssignee.uid, 0);

          expect(expense.getConfirmedTotalForUser(firstAssignee.uid), 0);
          expect(expense.getConfirmedTotalForUser(secondAssignee.uid), 0);
        });

        test('when items were denied and not marked', () {
          item1.setAssigneeDecision(firstAssignee.uid, 0);

          item2.setAssigneeDecision(secondAssignee.uid, 0);

          expect(expense.getConfirmedTotalForUser(firstAssignee.uid), 0);
          expect(expense.getConfirmedTotalForUser(secondAssignee.uid), 0);
        });
      });
    });

    test('can only be updated by the author if not finalized', () {
      var item = Item.fake();
      expense.addItem(item);
      var somebodyElse = Assignee.fake(uid: 'other');
      expense.addAssignee(somebodyElse);

      expect(expense.canBeUpdatedBy(author.uid), isTrue);
      expect(expense.canBeUpdatedBy(somebodyElse.uid), isFalse);

      item.setAssigneeDecision(author.uid, 1);
      item.setAssigneeDecision(somebodyElse.uid, 0);

      expect(expense.canBeUpdatedBy(author.uid), isTrue);

      expense.finalizedDate = DateTime.now();

      expect(expense.canBeUpdatedBy(author.uid), isFalse);
    });

    test("can't be marked by anyone if the expense is finalized", () {
      var item = Item.fake();
      expense.addItem(item);
      var anotherAssignee = Assignee.fake();
      var outsider = Assignee.fake();
      expense.addAssignee(assignee);
      expense.addAssignee(anotherAssignee);

      item.setAssigneeDecision(author.uid, 0);
      item.setAssigneeDecision(assignee.uid, 1);
      item.setAssigneeDecision(anotherAssignee.uid, 0);

      [author.uid, assignee.uid, anotherAssignee.uid, outsider.uid]
          .forEach((uid) {
        expect(expense.canBeMarkedBy(uid), isTrue);
      });

      expense.finalizedDate = DateTime.now();

      [author.uid, assignee.uid, anotherAssignee.uid, outsider.uid]
          .forEach((uid) {
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
      var anotherAssignee = Assignee.fake();
      expense.addAssignee(assignee);
      expense.addAssignee(anotherAssignee);

      [author.uid, assignee.uid, anotherAssignee.uid].forEach((uid) {
        expect(expense.canBeMarkedBy(uid), isTrue);
      });
    });

    group('conversion', () {
      test('expense can be converted to Firestore object', () {
        var expense = Expense(name: 'foo', author: author, groupId: '123');

        var firestoreData = expense.toFirestore();

        expect(firestoreData['name'], expense.name);
        expect(
          CustomUser.fromFirestore(firestoreData['author']).uid,
          expense.author.uid,
        );
        expect(
          expense.date!.difference(firestoreData['date']),
          lessThan(Duration(seconds: 1)),
        );
      });
    });
  });
}
