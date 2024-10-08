import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/data/models/custom_user.dart';
import 'package:statera/data/models/group.dart';
import 'package:statera/data/models/payment/payment.dart';
import 'package:statera/data/models/payment/payment_expense_info.dart';
import 'package:statera/data/models/payment/payment_redirect_info.dart';
import 'package:statera/data/services/auth_service.mocks.dart';
import 'package:statera/data/services/expense_service.mocks.dart';
import 'package:statera/data/services/group_repository.mocks.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/data/services/user_repository.mocks.dart';
import 'package:statera/ui/payments/payment_list_item.dart';
import 'package:statera/utils/preview_helpers.dart';

class MockUser extends Mock implements User {
  String get uid =>
      super.noSuchMethod(Invocation.getter(#uid), returnValue: 'foo');
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

    final authService = MockAuthService();
    final user = MockUser();
    when(user.uid).thenReturn('a');
    when(authService.currentUser).thenReturn(user);

    return Preview(
      providers: [
        BlocProvider(
          create: (_) => GroupCubit(
            MockGroupRepository(),
            MockExpenseService(),
            MockUserRepository(),
          )..loadGroup(Group(
              name: 'Example',
              members: [user1, user2],
            )),
        ),
        BlocProvider(
          create: (_) => AuthBloc(authService),
        ),
        Provider.value(value: PreferencesService()),
      ],
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
          ),
          PaymentListItem(
            payment: Payment(
              groupId: 'asd',
              payerId: 'a',
              receiverId: 'b',
              value: 123,
              timeCreated: DateTime.now(),
              newFor: ['a', 'b'],
            ),
          ),
          PaymentListItem(
            payment: Payment(
              groupId: 'asd',
              payerId: 'a',
              receiverId: 'b',
              value: 123,
              timeCreated: DateTime.now(),
              redirectInfo: PaymentRedirectInfo(authorUid: 'a'),
            ),
          ),
          PaymentListItem(
            payment: Payment(
              groupId: 'asd',
              payerId: 'b',
              receiverId: 'a',
              value: 123,
              timeCreated: DateTime.now(),
              redirectInfo: PaymentRedirectInfo(authorUid: 'b'),
            ),
          ),
          PaymentListItem(
            payment: Payment(
              groupId: 'asd',
              payerId: 'b',
              receiverId: 'a',
              value: 123,
              timeCreated: DateTime.now(),
              reason: 'Custom payment reason',
            ),
          ),
        ],
      ),
    );
  }
}
