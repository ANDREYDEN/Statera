import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/widgets/listItems/item_list_item.dart';

class MockGroupCubit extends MockCubit<GroupState> implements GroupCubit {}
class FakeGroupLoadedState extends Fake implements GroupLoadedState {}

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}
class FakeAuthState extends Fake implements AuthState {}
class FakeAuthEvent extends Fake implements AuthEvent {}

class MockUser extends Mock implements User {}

void main() {
  group("Item List Item", () {
    late int parts;
    late Item item;
    late MockGroupCubit groupCubit;
    late MockAuthBloc authBloc;

    setUpAll(() {
      registerFallbackValue(FakeGroupLoadedState());
      registerFallbackValue(FakeAuthState());
      registerFallbackValue(FakeAuthEvent());
    });

    setUp(() {
      parts = 0;
      item = Item(name: "foo", value: 145);
      groupCubit = MockGroupCubit();
      when(() => groupCubit.state)
          .thenReturn(GroupLoadedState(group: Group.fake()));
      authBloc = MockAuthBloc();
      final fakeUser = MockUser();
      when(() => fakeUser.uid).thenReturn('');
      when(() => authBloc.state).thenReturn(AuthState.authenticated(fakeUser));
    });

    Future<void> buildItemListItem(tester) {
      return tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiProvider(
              providers: [
                BlocProvider<AuthBloc>(create: (_) => authBloc),
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
