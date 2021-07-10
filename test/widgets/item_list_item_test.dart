import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:statera/models/item.dart';
import 'package:statera/viewModels/authentication_vm.dart';
import 'package:statera/widgets/listItems/item_list_item.dart';

// class MockAuthenticationViewModel extends Mock
//     implements AuthenticationViewModel {
//   @override
//   bool hasConfirmed(Item item) {
//     return false;
//   }

//   @override
//   bool hasDenied(Item item) {
//     return false;
//   }
// }

@GenerateMocks([AuthenticationViewModel])
void main() {
  group("Item List Item", () {
    testWidgets("can mark an item as accepted", (WidgetTester tester) async {
      var item = Item(name: "foo", value: 145);
      var wasConfirmed = false;
      var wasDenied = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Provider<AuthenticationViewModel>(
              create: (context) => MockAuthenticationViewModel(),
              child: ItemListItem(
                item: item,
                onConfirm: () => wasConfirmed = true,
                onDeny: () => wasDenied = true,
              ),
            ),
          ),
        ),
      );

      var checkButton = find.byIcon(Icons.check);
      await tester.tap(checkButton);

      expect(wasConfirmed, isTrue);
      expect(wasDenied, isFalse);
    });

    testWidgets("can mark an item as denied", (WidgetTester tester) async {
      var item = Item(name: "foo", value: 145);
      var wasConfirmed = false;
      var wasDenied = false;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Provider<AuthenticationViewModel>(
            create: (context) => MockAuthenticationViewModel(),
            child: ItemListItem(
              item: item,
              onConfirm: () => wasConfirmed = true,
              onDeny: () => wasDenied = true,
            ),
          ),
        ),
      ));

      var checkButton = find.byIcon(Icons.close);
      await tester.tap(checkButton);

      expect(wasConfirmed, isFalse);
      expect(wasDenied, isTrue);
    });
  });
}
