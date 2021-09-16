import 'package:flutter_test/flutter_test.dart';
import 'package:statera/models/assignee_decision.dart';
import 'package:statera/models/item.dart';

void main() {
  group('Item', () {
    test('gets the number of assignees that confirmed the item', () {
      var item = Item(name: "foo", value: 145);
      var assignee1 =
          AssigneeDecision(uid: '1', decision: ProductDecision.Confirmed);
      var assignee2 =
          AssigneeDecision(uid: '2', decision: ProductDecision.Denied);

      item.assignees = [assignee1, assignee2];

      expect(item.confirmedCount, 1);
    });

    test("is incomplete when at leat one assignee hasn't made a decision", () {
      var item = Item(name: "foo", value: 145);
      var assignee1 =
          AssigneeDecision(uid: '1', decision: ProductDecision.Confirmed);
      var assignee2 =
          AssigneeDecision(uid: '2', decision: ProductDecision.Undefined);

      item.assignees = [assignee1, assignee2];

      expect(item.completed, isFalse);
    });

    test('is completed when all assignees made a decision', () {
      var item = Item(name: "foo", value: 145);
      var assignee1 =
          AssigneeDecision(uid: '1', decision: ProductDecision.Confirmed);
      var assignee2 =
          AssigneeDecision(uid: '2', decision: ProductDecision.Denied);

      item.assignees = [assignee1, assignee2];

      expect(item.completed, isTrue);
    });

    test('gets the shared value', () {
      var item = Item(name: "foo", value: 145);

      item.assignees = [
        AssigneeDecision(
          uid: '1',
          decision: ProductDecision.Confirmed,
          parts: 1,
        ),
        AssigneeDecision(
          uid: '2',
          decision: ProductDecision.Denied,
          parts: 0,
        ),
        AssigneeDecision(
          uid: '3',
          decision: ProductDecision.Confirmed,
          parts: 1,
        ),
      ];

      expect(item.getSharedValueFor('3'), 145 / 2);
    });
  });
}
