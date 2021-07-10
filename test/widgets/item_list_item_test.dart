import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:statera/models/item.dart';
import 'package:statera/viewModels/authentication_vm.dart';
import 'package:statera/widgets/listItems/item_list_item.dart';

import 'item_list_item_test.mocks.dart';

@GenerateMocks([AuthenticationViewModel])
void main() {
  group("Item List Item", () {
    late bool wasConfirmed;
    late bool wasDenied;
    var mockAuthVm = MockAuthenticationViewModel();
    late Item item;

    setUp(() {
      wasConfirmed = false;
      wasDenied = false;
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
                onConfirm: () => wasConfirmed = true,
                onDeny: () => wasDenied = true,
              ),
            ),
          ),
        ),
      );
    }

    testWidgets("can mark an item as accepted", (WidgetTester tester) async {
      await buildItemListItem(tester);

      var checkButton = find.byIcon(Icons.check);
      await tester.tap(checkButton);

      expect(wasConfirmed, isTrue);
      expect(wasDenied, isFalse);
    });

    testWidgets("can mark an item as denied", (WidgetTester tester) async {
      await buildItemListItem(tester);

      var checkButton = find.byIcon(Icons.close);
      await tester.tap(checkButton);

      expect(wasConfirmed, isFalse);
      expect(wasDenied, isTrue);
    });
  });
}
