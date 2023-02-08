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
      var item = Item(name: 'foo', value: 145.0);
      var itemWithTax = Item(name: 'foo', value: 145.0, isTaxable: true);
      var partitionedItem = Item(name: 'foo', value: 145.0, partition: 3);
      var partitionedItemWithTax = Item(
        name: 'foo',
        value: 145.0,
        partition: 3,
        isTaxable: true,
      );

      createSharedValueTest(
        Item item, {
        required String condition,
        required List<int?> partsList,
        required List<double> expectedValues,
        double? tax,
        bool taxOnly = false,
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
            expect(
              item.getConfirmedValueFor(
                uid: i.toString(),
                tax: tax,
                taxOnly: taxOnly,
              ),
              expectedValues[i],
            );
          }
        });
      }

      group('when not partitioned', () {
        createSharedValueTest(
          item,
          condition: 'noone marked',
          partsList: [null, null, null],
          expectedValues: [0.0, 0.0, 0.0],
        );

        createSharedValueTest(
          item,
          condition: '2 peope accepted and 1 denied',
          partsList: [1, 0, 1],
          expectedValues: [item.value / 2, 0.0, item.value / 2],
        );

        createSharedValueTest(
          item,
          condition: 'someone accepted and everyone else did not mark',
          partsList: [1, null, null],
          expectedValues: [item.value, 0.0, 0.0],
        );

        createSharedValueTest(
          item,
          condition: 'someone accepted more than 1 part',
          partsList: [2, 1, null],
          expectedValues: [item.value / 2, item.value / 2, 0.0],
        );

        createSharedValueTest(
          item,
          condition: 'everybody denied',
          partsList: [0, 0, 0],
          expectedValues: [0.0, 0.0, 0.0],
        );

        createSharedValueTest(
          itemWithTax,
          condition: 'item has tax',
          tax: 0.1,
          partsList: [1, 1, 0],
          expectedValues: [
            item.value * (1 + 0.1) / 2,
            item.value * (1 + 0.1) / 2,
            0.0
          ],
        );

        createSharedValueTest(
          itemWithTax,
          condition: 'item has tax and calculating only tax',
          tax: 0.1,
          taxOnly: true,
          partsList: [1, 1, 0],
          expectedValues: [
            item.value * 0.1 / 2,
            item.value * 0.1 / 2,
            0.0
          ],
        );
      });

      group('when partitioned', () {
        var item = Item(name: 'foo', value: 145.0, partition: 3);

        createSharedValueTest(
          partitionedItem,
          condition: 'noone marked',
          partsList: [null, null, null],
          expectedValues: [0.0, 0.0, 0.0],
        );

        createSharedValueTest(
          partitionedItem,
          condition: 'everybody accepted 1 part',
          partsList: [1, 1, 1],
          expectedValues:
              List<double>.generate(3, (_) => item.value / item.partition),
        );

        createSharedValueTest(
          partitionedItem,
          condition: 'someone accepted 2 parts and everyone else did not mark',
          partsList: [2, null, null],
          expectedValues: [item.value * 2 / item.partition, 0.0, 0.0],
        );

        createSharedValueTest(
          partitionedItem,
          condition: 'someone accepted all parts and everyone else denied',
          partsList: [3, 0, 0],
          expectedValues: [item.value, 0.0, 0.0],
        );

        createSharedValueTest(
          partitionedItem,
          condition: 'everyone denied',
          partsList: [0, 0, 0],
          expectedValues: [0.0, 0.0, 0.0],
        );

        createSharedValueTest(
          partitionedItemWithTax,
          condition: 'item has tax',
          tax: 0.1,
          partsList: [1, 2, 0],
          expectedValues: [
            item.value * (1 + 0.1) / item.partition,
            item.value * (1 + 0.1) * 2 / item.partition,
            0.0
          ],
        );

        createSharedValueTest(
          partitionedItemWithTax,
          condition: 'item has tax and calculating only tax',
          tax: 0.1,
          taxOnly: true,
          partsList: [1, 2, 0],
          expectedValues: [
            item.value * 0.1 / item.partition,
            item.value * 0.1 * 2 / item.partition,
            0.0
          ],
        );
      });
    });

    test('can be converted to and from a firestore object', () {
      var item = Item(
        name: 'foo',
        value: 145.0,
        partition: 3,
        isTaxable: true,
        assigneeUids: ['1', '2', '3'],
      );

      var firestoreItem = Item.fromFirestore(item.toFirestore());

      expect(firestoreItem, item);
      expect(firestoreItem == item, true);
    });

    test('can reset its assignee desicions', () {
      var item = Item(name: 'foo', value: 145.0, assigneeUids: ['1', '2', '3']);

      item.assignees = [
        AssigneeDecision(uid: '1', parts: 1),
        AssigneeDecision(uid: '2', parts: 2),
        AssigneeDecision(uid: '3', parts: 0),
      ];

      item.resetAssigneeDecisions();

      for (var assignee in item.assignees) {
        expect(assignee.parts, isNull);
      }
    });

    test('can not set assignee decision higher than remaining partition', () {
      var item = Item(name: 'foo', value: 145.0, partition: 3);

      var originalParts = 1;
      var assignee = AssigneeDecision(uid: '1', parts: originalParts);
      item.assignees = [assignee];

      item.setAssigneeDecision(assignee.uid, 4);

      expect(assignee.parts, originalParts);
    });
  });
}
