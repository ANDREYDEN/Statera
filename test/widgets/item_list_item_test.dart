import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/data/models/item.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/business_logic/group/group_state.dart';
import 'package:statera/ui/viewModels/authentication_vm.dart';
import 'package:statera/ui/widgets/listItems/item_list_item.dart';

class MockAuthenticationViewModel extends Mock implements AuthenticationViewModel {}

class MockGroupCubit extends MockCubit<GroupState> implements GroupCubit {}

class FakeGroupLoadedState extends Fake implements GroupLoadedState {}

void main() {
  group("Item List Item", () {
    late int parts;
    var mockAuthVm = MockAuthenticationViewModel();
    late Item item;
    late MockGroupCubit groupCubit;

    setUpAll(() {
      registerFallbackValue(FakeGroupLoadedState());
    });

    setUp(() {
      parts = 0;
      item = Item(name: "foo", value: 145);
      groupCubit = MockGroupCubit();
      when(() => mockAuthVm.hasConfirmed(item)).thenReturn(false);
      when(() => mockAuthVm.hasDenied(item)).thenReturn(false);
      when(() => mockAuthVm.hasDecidedOn(item)).thenReturn(false);
      when(() => mockAuthVm.getItemParts(item)).thenReturn(parts);
      when(() => groupCubit.state).thenReturn(GroupLoadedState(group: Group.fake()));
    });

    Future<void> buildItemListItem(tester) {
      return tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiProvider(
              providers: [
                Provider<AuthenticationViewModel>(
                  create: (context) => mockAuthVm,
                ),
                BlocProvider<GroupCubit>(create: (_) => groupCubit)
              ],
              child: ItemListItem(
                item: item,
                onChangePartition: (newParts) => parts = newParts,
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

      expect(parts, 1);
    });

    testWidgets("can mark an item as denied", (WidgetTester tester) async {
      await buildItemListItem(tester);

      var checkButton = find.byIcon(Icons.close);
      await tester.tap(checkButton);

      expect(parts, -1);
    });
  });
}
