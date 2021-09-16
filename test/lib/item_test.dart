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

    group('not partitioned', () {
      [
        {
          "decisions": [
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
          ],
          "value": 145.0,
          "expected": 72.5
        },
        {
          "decisions": [
            AssigneeDecision(
              uid: '1',
              decision: ProductDecision.Confirmed,
              parts: 1,
            ),
            AssigneeDecision(
              uid: '2',
              decision: ProductDecision.Undefined,
              parts: 0,
            ),
            AssigneeDecision(
              uid: '3',
              decision: ProductDecision.Undefined,
              parts: 1,
            ),
          ],
          "value": 145.0,
          "expected": 145.0,
        },
        {
          "decisions": [
            AssigneeDecision(
              uid: '1',
              decision: ProductDecision.Denied,
              parts: 0,
            ),
            AssigneeDecision(
              uid: '2',
              decision: ProductDecision.Denied,
              parts: 0,
            ),
            AssigneeDecision(
              uid: '3',
              decision: ProductDecision.Denied,
              parts: 0,
            ),
          ],
          "value": 145.0,
          "expected": 0.0,
        },
        {
          "decisions": [
            AssigneeDecision(
              uid: '1',
              decision: ProductDecision.Undefined,
              parts: 123,
            ),
            AssigneeDecision(
              uid: '2',
              decision: ProductDecision.Denied,
              parts: 0,
            ),
            AssigneeDecision(
              uid: '3',
              decision: ProductDecision.Denied,
              parts: 0,
            ),
          ],
          "value": 145.0,
          "expected": 0.0,
        }
      ].forEach((testData) {
        test('gets the shared value', () {
          var item = Item(name: "foo", value: testData["value"] as double);

          item.assignees = testData["decisions"] as List<AssigneeDecision>;

          expect(item.getSharedValueFor('1'), testData["expected"] as double);
        });
      });
    });

    group('partitioned', () {
      [
        {
          "decisions": [
            AssigneeDecision(
              uid: '1',
              decision: ProductDecision.Confirmed,
              parts: 1,
            ),
            AssigneeDecision(
              uid: '2',
              decision: ProductDecision.Confirmed,
              parts: 1,
            ),
            AssigneeDecision(
              uid: '3',
              decision: ProductDecision.Confirmed,
              parts: 1,
            ),
          ],
          "value": 145.0,
          "expected": 145.0 / 3
        },
        {
          "decisions": [
            AssigneeDecision(
              uid: '1',
              decision: ProductDecision.Confirmed,
              parts: 2,
            ),
            AssigneeDecision(
              uid: '2',
              decision: ProductDecision.Undefined,
              parts: 0,
            ),
            AssigneeDecision(
              uid: '3',
              decision: ProductDecision.Undefined,
              parts: 0,
            ),
          ],
          "value": 145.0,
          "expected": 145.0 * 2 / 3,
        },
        {
          "decisions": [
            AssigneeDecision(
              uid: '1',
              decision: ProductDecision.Confirmed,
              parts: 3,
            ),
            AssigneeDecision(
              uid: '2',
              decision: ProductDecision.Denied,
              parts: 0,
            ),
            AssigneeDecision(
              uid: '3',
              decision: ProductDecision.Denied,
              parts: 0,
            ),
          ],
          "value": 145.0,
          "expected": 145.0,
        },
        {
          "decisions": [
            AssigneeDecision(
              uid: '1',
              decision: ProductDecision.Denied,
              parts: 0,
            ),
            AssigneeDecision(
              uid: '2',
              decision: ProductDecision.Denied,
              parts: 0,
            ),
            AssigneeDecision(
              uid: '3',
              decision: ProductDecision.Denied,
              parts: 0,
            ),
          ],
          "value": 145.0,
          "expected": 0.0,
        },
        {
          "decisions": [
            AssigneeDecision(
              uid: '1',
              decision: ProductDecision.Undefined,
              parts: 0,
            ),
            AssigneeDecision(
              uid: '2',
              decision: ProductDecision.Denied,
              parts: 0,
            ),
            AssigneeDecision(
              uid: '3',
              decision: ProductDecision.Confirmed,
              parts: 2,
            ),
          ],
          "value": 145.0,
          "expected": 0.0,
        }
      ].forEach((testData) {
        test('gets the shared value', () {
          var item = Item(
            name: "foo",
            value: testData["value"] as double,
            partition: 3,
          );

          item.assignees = testData["decisions"] as List<AssigneeDecision>;

          expect(item.getSharedValueFor('1'), testData["expected"] as double);
        });
      });
    });
  });
}
