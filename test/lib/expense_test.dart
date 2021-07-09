import 'package:flutter_test/flutter_test.dart';
import 'package:statera/models/assignee.dart';
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

    test('it adds the author to the assignees by default', () {
      expect(expense.assignees, hasLength(1));
      expect(expense.assignees.first.uid, author.uid);
    });

    group('adding assignees', () {
      test('adds an assignee', () {
        expense.setAssignees([assignee]);

        expect(expense.assignees, hasLength(1));
        expect(expense.assignees.first.uid, assignee.uid);
      });

      test('adds assignee decisions to existing items', () {
        var item = Item(name: 'asd', value: 123);
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

    test(
      'it can indicate that it is ready to be paid for',
      () {},
      skip: "TODO",
    );
  });
}
