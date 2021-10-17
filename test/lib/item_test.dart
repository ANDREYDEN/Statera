import 'package:flutter_test/flutter_test.dart';
import 'package:statera/data/models/assignee_decision.dart';
import 'package:statera/data/models/item.dart';

void main() {
  group('Item', () {
    late Item item = Item(name: "foo", value: 145.0);

    test('gets the number of assignees that confirmed the item', () {
      var assignee1 = AssigneeDecision(uid: '1');
      var assignee2 = AssigneeDecision(uid: '2', parts: 1);

      item.assignees = [assignee1, assignee2];

      expect(item.confirmedCount, 1);
    });

    test("is incomplete when at leat one assignee hasn't made a decision", () {
      var assignee1 = AssigneeDecision(uid: '1', parts: 1);
      var assignee2 = AssigneeDecision(uid: '2');

      item.assignees = [assignee1, assignee2];

      expect(item.completed, isFalse);
    });

    test('is completed when all assignees made a decision', () {
      var assignee1 = AssigneeDecision(uid: '1', parts: 1);
      var assignee2 = AssigneeDecision(uid: '2', parts: 0);

      item.assignees = [assignee1, assignee2];

      expect(item.completed, isTrue);
    });

    group('calculates the shared value for not partitioned item', () {
      var item = Item(name: "foo", value: 145.0);

      createSimpleSharedValueTest(
          {condition, partsList, value, expectedValue}) {
        createSharedValueTest(
          item,
          condition: condition,
          partsList: partsList,
          value: value,
          expectedValue: expectedValue,
        );
      }

      createSimpleSharedValueTest(
        condition: "accepted together with someone else",
        partsList: [1, 0, 1],
        value: item.value,
        expectedValue: item.value / 2,
      );

      createSimpleSharedValueTest(
        condition: "accepted and everyone else is undefined",
        partsList: [1, null, null],
        value: item.value,
        expectedValue: item.value,
      );

      createSimpleSharedValueTest(
        condition: "everybody denied",
        partsList: [0, 0, 0],
        value: item.value,
        expectedValue: 0.0,
      );

      createSimpleSharedValueTest(
        condition: "undefined and everybody else denied",
        partsList: [null, 0, 0],
        value: item.value,
        expectedValue: 0.0,
      );

      createSimpleSharedValueTest(
        condition: "denied but others did something else",
        partsList: [0, 0, 0],
        value: item.value,
        expectedValue: 0.0,
      );
    });

    group('calculates the shared value for partitioned item', () {
      var item = Item(name: "foo", value: 145.0, partition: 3);

      createPartitionedSharedValueTest(
          {condition, partsList, value, expectedValue}) {
        createSharedValueTest(
          item,
          condition: condition,
          partsList: partsList,
          value: value,
          expectedValue: expectedValue,
        );
      }

      createPartitionedSharedValueTest(
        condition: "everybody accepted 1 part",
        partsList: [1, 1, 1],
        value: item.value,
        expectedValue: item.value / 3,
      );

      createPartitionedSharedValueTest(
        condition: "accepted 2 and everyone else undefined",
        partsList: [2, null, null],
        value: item.value,
        expectedValue: item.value * 2 / 3,
      );

      createPartitionedSharedValueTest(
        condition: "accepted all and everyone else denied",
        partsList: [3, 0, 0],
        value: item.value,
        expectedValue: item.value,
      );

      createPartitionedSharedValueTest(
        condition: "everyone denied",
        partsList: [0, 0, 0],
        value: item.value,
        expectedValue: 0.0,
      );

      createPartitionedSharedValueTest(
        condition: "undefined and everybody else did something else",
        partsList: [null, 0, 2],
        value: item.value,
        expectedValue: 0.0,
      );
    });
  });
}

createSharedValueTest(
  Item item, {
  required String condition,
  required List<int?> partsList,
  required double value,
  required double expectedValue,
}) {
  test('when $condition', () {
    item.assignees = partsList
        .map((parts) => AssigneeDecision(
              uid: partsList.indexOf(parts).toString(),
              parts: parts,
            ))
        .toList();

    expect(item.getSharedValueFor('0'), expectedValue);
  });
}
