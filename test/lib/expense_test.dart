import 'package:flutter_test/flutter_test.dart';
import 'package:statera/models/assignee.dart';
import 'package:statera/models/assignee_decision.dart';
import 'package:statera/models/author.dart';
import 'package:statera/models/expense.dart';
import 'package:statera/models/item.dart';

void main() {
  group('Expense', () {
    late Expense expense;
    late Author author;
    late Assignee assignee;

    setUp(() {
      assignee = Assignee(uid: 'qwe');

      author = Author(name: 'foo', uid: 'bar');

      expense = Expense(
        author: author,
        name: 'baz',
        groupId: 'que',
      );
    });

    test('adds the author to the assignees by default', () {
      expect(expense.assignees, hasLength(1));
      expect(expense.assignees.first.uid, author.uid);
    });

    group('adding assignees', () {
      test('sets an assignee', () {
        expense.setAssignees([assignee]);

        expect(expense.assignees, hasLength(1));
        expect(expense.assignees.first.uid, assignee.uid);
      });

      test('adds an assignee', () {
        var item = Item.fake();
        expense.addItem(item);
        expense.setAssignees([assignee]);

        var firstAssigneeDecision = ProductDecision.Confirmed;
        item.setAssigneeDecision(assignee.uid, firstAssigneeDecision);

        var newAssignee = Assignee.fake();
        expense.addAssignee(newAssignee);

        expect(expense.assignees, hasLength(2));
        expect(expense.assignees[1].uid, newAssignee.uid);
        expect(
          item.assigneeDecision(assignee.uid),
          firstAssigneeDecision,
          reason: "First assignee decision was removed",
        );
        expect(
          item.assigneeDecision(newAssignee.uid),
          ProductDecision.Undefined,
        );
      });

      test('adds assignee decisions to existing items', () {
        var item = Item.fake();
        expense.addItem(item);

        expense.setAssignees([assignee]);

        var itemAssigneeIds = item.assignees
            .map((assigneeDecision) => assigneeDecision.uid)
            .toList();
        var expenseAssigneeIds =
            expense.assignees.map((assignee) => assignee.uid).toList();
        expect(itemAssigneeIds, containsAll(expenseAssigneeIds));
      });
    });

    test('can indicate that it is ready to be paid for', () {
      var item = Item(name: 'asd', value: 123);
      expense.addItem(item);

      var firstAssignee = Assignee(uid: 'first');
      var secondAssignee = Assignee(uid: 'second');
      expense.setAssignees([firstAssignee, secondAssignee]);

      item.setAssigneeDecision(firstAssignee.uid, ProductDecision.Confirmed);
      item.setAssigneeDecision(secondAssignee.uid, ProductDecision.Denied);

      expect(expense.isReadyToBePaidFor, isTrue);
    });

    test('is marked by an assignee if all products are marked', () {
      expense.setAssignees([assignee]);

      var item1 = Item(name: 'asd', value: 123);
      var item2 = Item(name: 'asd', value: 123);
      expense.addItem(item1);
      expense.addItem(item2);

      item1.setAssigneeDecision(assignee.uid, ProductDecision.Confirmed);

      expect(expense.isMarkedBy(assignee.uid), isFalse);

      item2.setAssigneeDecision(assignee.uid, ProductDecision.Denied);

      expect(expense.isMarkedBy(assignee.uid), isTrue);
    });

    test('gets confirmed total for assignee', () {
      var firstAssignee = Assignee(uid: 'first');
      var secondAssignee = Assignee(uid: 'second');
      expense.setAssignees([firstAssignee, secondAssignee]);

      var item1 = Item(name: 'big', value: 124);
      var item2 = Item(name: 'small', value: 42);
      expense.addItem(item1);
      expense.addItem(item2);

      item1.setAssigneeDecision(firstAssignee.uid, ProductDecision.Confirmed);
      item2.setAssigneeDecision(firstAssignee.uid, ProductDecision.Denied);

      item1.setAssigneeDecision(secondAssignee.uid, ProductDecision.Confirmed);
      item2.setAssigneeDecision(secondAssignee.uid, ProductDecision.Confirmed);

      expect(expense.getConfirmedTotalForUser(firstAssignee.uid), 62);
      expect(expense.getConfirmedTotalForUser(secondAssignee.uid), 104);
    });

    test('gets unconfirmed extra total for assignee', () {
      var firstAssignee = Assignee(uid: 'first');
      var secondAssignee = Assignee(uid: 'second');
      expense.setAssignees([firstAssignee, secondAssignee]);

      var item1 = Item(name: 'big', value: 124);
      var item2 = Item(name: 'small', value: 42);
      expense.addItem(item1);
      expense.addItem(item2);

      item1.setAssigneeDecision(firstAssignee.uid, ProductDecision.Confirmed);
      item2.setAssigneeDecision(firstAssignee.uid, ProductDecision.Denied);

      item2.setAssigneeDecision(secondAssignee.uid, ProductDecision.Confirmed);

      expect(expense.getPotentialTotalForUser(firstAssignee.uid), 124);
      expect(expense.getPotentialTotalForUser(secondAssignee.uid), 104);
    });
  });
}
