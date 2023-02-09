import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/custom_theme_builder.dart';
import 'package:statera/data/models/custom_user.dart';
import 'package:statera/data/models/group.dart';
import 'package:statera/data/models/payment.dart';
import 'package:statera/data/services/auth_service.dart';
import 'package:statera/data/services/expense_service.mocks.dart';
import 'package:statera/data/services/group_service.mocks.dart';
import 'package:statera/data/services/user_repository.mocks.dart';
import 'package:statera/ui/payments/payment_list_item.dart';

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

main() {
  runApp(ListCover());
}

class ListCover extends StatelessWidget {
  const ListCover({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user1 = CustomUser(uid: 'a', name: 'John Doe');
    final user2 = CustomUser(uid: 'b', name: 'Adam Smith');

    final authService = AuthServiceMock();
    final user = MockUser();
    when(user.uid).thenReturn('a');
    when(authService.currentUser).thenReturn(user);

    return CustomThemeBuilder(
      builder: (lightTheme, darkTheme) {
        return MaterialApp(
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: ThemeMode.system,
          home: MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => GroupCubit(
                  MockGroupService(),
                  MockExpenseService(),
                  MockUserRepository(),
                )..loadGroup(Group(
                    name: 'Example',
                    members: [user1, user2],
                  )),
              ),
              BlocProvider(
                create: (_) => AuthBloc(authService),
              )
            ],
            child: Scaffold(
              body: ListView(
                children: [
                  PaymentListItem(
                    payment: Payment(
                      groupId: 'asd',
                      payerId: 'a',
                      receiverId: 'b',
                      value: 123,
                      timeCreated: DateTime.now(),
                    ),
                  ),
                  PaymentListItem(
                    payment: Payment(
                      groupId: 'asd',
                      payerId: 'a',
                      receiverId: 'b',
                      value: 123,
                      relatedExpense: PaymentExpenseInfo(
                        id: 'dummy_expense',
                        name: 'Some Expense',
                      ),
                    ),
                  ),
                  PaymentListItem(
                    payment: Payment(
                      groupId: 'asd',
                      payerId: 'a',
                      receiverId: 'b',
                      value: 123,
                      reason: 'There was a malfunction in the system',
                    ),
                  ),
                  PaymentListItem(
                    payment: Payment(
                      groupId: 'asd',
                      payerId: 'a',
                      receiverId: 'b',
                      value: 123,
                      reason:
                          'This is a very long and unneeded explanation that there was a malfunction in the system',
                    ),
                  ),
                  PaymentListItem(
                    payment: Payment(
                      groupId: 'asd',
                      payerId: 'a',
                      receiverId: 'b',
                      value: 123,
                      oldPayerBalance: 33,
                    ),
                  ),
                  PaymentListItem(
                    payment: Payment(
                      groupId: 'asd',
                      payerId: 'a',
                      receiverId: 'b',
                      value: 50,
                      oldPayerBalance: 10,
                    ),
                  ),
                  PaymentListItem(
                    payment: Payment(
                      groupId: 'asd',
                      payerId: 'b',
                      receiverId: 'a',
                      value: 30,
                      oldPayerBalance: -40,
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
