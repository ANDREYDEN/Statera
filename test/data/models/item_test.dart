import 'package:flutter_test/flutter_test.dart';
import 'package:statera/data/models/assignee_decision.dart';
import 'package:statera/data/models/item.dart';

void main() {
  group('Item', () {
    late Item item = Item(name: 'foo', value: 145.0);

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
    group('calculates the shared value', () {
      group('when not partitioned', () {
        var item = Item(name: 'foo', value: 145.0);

        createSimpleSharedValueTest({condition, partsList, expectedValues}) {
          createSharedValueTest(
            item,
            condition: condition,
            partsList: partsList,
            expectedValues: expectedValues,
          );
        }

        createSimpleSharedValueTest(
          condition: 'noone marked',
          partsList: [null, null, null],
          expectedValues: [0.0, 0.0, 0.0],
        );

        createSimpleSharedValueTest(
          condition: '2 peope accepted and 1 denied',
          partsList: [1, 0, 1],
          expectedValues: [item.value / 2, 0.0, item.value / 2],
        );

        createSimpleSharedValueTest(
          condition: 'someone accepted and everyone else did not mark',
          partsList: [1, null, null],
          expectedValues: [item.value, 0.0, 0.0],
        );

        createSimpleSharedValueTest(
          condition: 'everybody denied',
          partsList: [0, 0, 0],
          expectedValues: [0.0, 0.0, 0.0],
        );
      });

      group('partitioned', () {
        var item = Item(name: 'foo', value: 145.0, partition: 3);

        createPartitionedSharedValueTest(
            {condition, partsList, expectedValues}) {
          createSharedValueTest(
            item,
            condition: condition,
            partsList: partsList,
            expectedValues: expectedValues,
          );
        }

        createPartitionedSharedValueTest(
          condition: 'noone marked',
          partsList: [null, null, null],
          expectedValues: [0.0, 0.0, 0.0],
        );

        createPartitionedSharedValueTest(
          condition: 'everybody accepted 1 part',
          partsList: [1, 1, 1],
          expectedValues:
              List<double>.generate(3, (_) => item.value / item.partition),
        );

        createPartitionedSharedValueTest(
          condition: 'someone accepted 2 parts and everyone else did not mark',
          partsList: [2, null, null],
          expectedValues: [item.value * 2 / item.partition, 0.0, 0.0],
        );

        createPartitionedSharedValueTest(
          condition: 'someone accepted all parts and everyone else denied',
          partsList: [3, 0, 0],
          expectedValues: [item.value, 0.0, 0.0],
        );

        createPartitionedSharedValueTest(
          condition: 'everyone denied',
          partsList: [0, 0, 0],
          expectedValues: [0.0, 0.0, 0.0],
        );
      });
    });
  });
}

createSharedValueTest(
  Item item, {
  required String condition,
  required List<int?> partsList,
  required List<double> expectedValues,
}) {
  test('when $condition', () {
    item.assignees = [];
    for (var i = 0; i < partsList.length; i++) {
      item.assignees.add(AssigneeDecision(
        uid: i.toString(),
        parts: partsList[i],
      ));
    }

    for (var i = 0; i < partsList.length; i++) {
      expect(item.getConfirmedValueFor(uid: i.toString()), expectedValues[i]);
    }
  });
}
