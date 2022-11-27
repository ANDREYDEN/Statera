import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/expense_service.mocks.dart';
import 'package:statera/data/services/group_service.mocks.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/data/services/user_repository.mocks.dart';
import 'package:statera/ui/expense/items/item_list_item.dart';

class MockUser extends Mock implements User {
  String get uid =>
      super.noSuchMethod(Invocation.getter(#uid), returnValue: 'foo');
}

class AuthServiceMock extends Mock implements AuthService {
  User? get currentUser => super
      .noSuchMethod(Invocation.getter(#currentUser), returnValue: MockUser());

  @override
  Stream<User?> currentUserStream() => super.noSuchMethod(
        Invocation.method(#currentUserStream, []),
        returnValue: Stream<User?>.empty(),
        returnValueForMissingStub: Stream<User?>.empty(),
      ) as Stream<User?>;
}

void main() {
  group('Item List Item', () {
    late Item item;
    int parts = 0;
    final user1 = CustomUser(uid: 'a', name: 'John Doe');
    final user2 = CustomUser(uid: 'b', name: 'Adam Smith');
    final authService = AuthServiceMock();

    setUp(() {
      item = Item(name: 'foo', value: 145);
      final user = MockUser();
      when(user.uid).thenReturn('a');
      when(authService.currentUser).thenReturn(user);
    });

    Future<void> buildItemListItem(tester) {
      return tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiProvider(
              providers: [
                BlocProvider<AuthBloc>(
                  create: (_) => AuthBloc(
                    authService,
                    MockUserRepository(),
                  ),
                ),
                BlocProvider<GroupCubit>(
                  create: (_) => GroupCubit(
                    MockGroupService(),
                    MockExpenseService(),
                    MockUserRepository(),
                  )..loadGroup(Group(
                      name: 'Example',
                      members: [user1, user2],
                    )),
                )
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

    testWidgets('can mark an item as accepted', (WidgetTester tester) async {
      await buildItemListItem(tester);

      var checkButton = find.byIcon(Icons.check_rounded);
      await tester.tap(checkButton);

      expect(parts, 1);
    });

    testWidgets('can mark an item as denied', (WidgetTester tester) async {
      await buildItemListItem(tester);

      var checkButton = find.byIcon(Icons.close_rounded);
      await tester.tap(checkButton);

      expect(parts, -1);
    });
  });
}
