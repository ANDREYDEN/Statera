import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:statera/models/assignee_decision.dart';
import 'package:statera/models/item.dart';
import 'package:statera/viewModels/authentication_vm.dart';
import 'package:statera/widgets/listItems/item_list_item.dart';

import 'item_list_item_test.mocks.dart';

@GenerateMocks([AuthenticationViewModel])
void main() {
  group("Item List Item", () {
    late ProductDecision decision = ProductDecision.Undefined;
    var mockAuthVm = MockAuthenticationViewModel();
    late Item item;

    setUp(() {
      item = Item(name: "foo", value: 145);
      when(mockAuthVm.hasConfirmed(item)).thenReturn(false);
      when(mockAuthVm.hasDenied(item)).thenReturn(false);
    });

    Future<void> buildItemListItem(tester) {
      return tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Provider<AuthenticationViewModel>(
              create: (context) => mockAuthVm,
              child: ItemListItem(
                  item: item,
                  onChangePartition: (newDecision) => decision = newDecision),
            ),
          ),
        ),
      );
    }

    testWidgets("can mark an item as accepted", (WidgetTester tester) async {
      await buildItemListItem(tester);

      var checkButton = find.byIcon(Icons.check);
      await tester.tap(checkButton);

      expect(decision, ProductDecision.Confirmed);
    });

    testWidgets("can mark an item as denied", (WidgetTester tester) async {
      await buildItemListItem(tester);

      var checkButton = find.byIcon(Icons.close);
      await tester.tap(checkButton);

      expect(decision, ProductDecision.Denied);
    });
  });
}
