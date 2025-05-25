import 'package:flutter_test/flutter_test.dart';
import 'package:statera/data/models/models.dart';

void main() {
  group('Item', () {
    late Item item = SimpleItem(name: 'foo', value: 145.0);

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
      var item = SimpleItem(name: 'foo', value: 145.0);
      var itemWithTax = SimpleItem(name: 'foo', value: 145.0, isTaxable: true);
      var partitionedItem = SimpleItem(name: 'foo', value: 145.0, partition: 3);
      var partitionedItemWithTax = SimpleItem(
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
            final subTotal = item.getConfirmedSubtotalForUser(i.toString());
            final taxValue = item.getConfirmedTaxFor(i.toString(), tax: tax);
            expect(
              subTotal + taxValue,
              closeTo(expectedValues[i], 0.01),
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
          expectedValues: [item.total / 2, 0.0, item.total / 2],
        );

        createSharedValueTest(
          item,
          condition: 'someone accepted and everyone else did not mark',
          partsList: [1, null, null],
          expectedValues: [item.total, 0.0, 0.0],
        );

        createSharedValueTest(
          item,
          condition: 'someone accepted more than 1 part',
          partsList: [2, 1, null],
          expectedValues: [item.total / 2, item.total / 2, 0.0],
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
            item.total * (1 + 0.1) / 2,
            item.total * (1 + 0.1) / 2,
            0.0
          ],
        );
      });

      group('when partitioned', () {
        var item = SimpleItem(name: 'foo', value: 145.0, partition: 3);

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
              List<double>.generate(3, (_) => item.total / item.partition),
        );

        createSharedValueTest(
          partitionedItem,
          condition: 'someone accepted 2 parts and everyone else did not mark',
          partsList: [2, null, null],
          expectedValues: [item.total * 2 / item.partition, 0.0, 0.0],
        );

        createSharedValueTest(
          partitionedItem,
          condition: 'someone accepted all parts and everyone else denied',
          partsList: [3, 0, 0],
          expectedValues: [item.total, 0.0, 0.0],
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
            item.total * (1 + 0.1) / item.partition,
            item.total * (1 + 0.1) * 2 / item.partition,
            0.0
          ],
        );
      });
    });

    test('can be converted to and from a firestore object', () {
      var item = SimpleItem(
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
      var item =
          SimpleItem(name: 'foo', value: 145.0, assigneeUids: ['1', '2', '3']);

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
      var item = SimpleItem(name: 'foo', value: 145.0, partition: 3);

      var originalParts = 1;
      var assignee = AssigneeDecision(uid: '1', parts: originalParts);
      item.assignees = [assignee];

      item.setAssigneeDecision(assignee.uid, 4);

      expect(assignee.parts, originalParts);
    });
  });
}
