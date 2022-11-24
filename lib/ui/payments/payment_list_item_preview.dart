import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/business_logic/layout/layout_state.dart';
import 'package:statera/data/models/custom_user.dart';
import 'package:statera/data/models/group.dart';
import 'package:statera/data/models/payment.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/ui/payments/payment_list_item.dart';
import 'package:statera/utils/theme.dart';

class GroupServiceMock extends Mock implements GroupService {}

class ExpenseServiceMock extends Mock implements ExpenseService {}

class UserRepositoryMock extends Mock implements UserRepository {}

main() {
  runApp(ListCover());
}

class ListCover extends StatelessWidget {
  const ListCover({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user1 = CustomUser(uid: 'a', name: 'John Doe');
    final user2 = CustomUser(uid: 'b', name: 'Adam Smith');

    return MaterialApp(
      theme: theme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      home: LayoutBuilder(
        builder: (context, constraints) => Provider<LayoutState>.value(
          value: LayoutState(constraints),
          child: BlocProvider<GroupCubit>(
            create: (_) => GroupCubit(
              GroupServiceMock(),
              ExpenseServiceMock(),
              UserRepositoryMock(),
            )..loadGroup(Group(
                name: 'Example',
                members: [user1, user2],
              )),
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
                    receiverUid: 'a',
                  ),
                  PaymentListItem(
                    payment: Payment(
                      groupId: 'asd',
                      payerId: 'a',
                      receiverId: 'b',
                      value: 123,
                    ),
                    receiverUid: 'b',
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
                    receiverUid: 'b',
                  ),
                  PaymentListItem(
                    payment: Payment(
                      groupId: 'asd',
                      payerId: 'a',
                      receiverId: 'b',
                      value: 123,
                      reason: 'There was a malfunction in the system',
                    ),
                    receiverUid: 'a',
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
                    receiverUid: 'b',
                  ),
                  PaymentListItem(
                    payment: Payment(
                      groupId: 'asd',
                      payerId: 'a',
                      receiverId: 'b',
                      value: 123,
                      oldPayerBalance: 33,
                    ),
                    receiverUid: 'b',
                  ),
                  PaymentListItem(
                    payment: Payment(
                      groupId: 'asd',
                      payerId: 'a',
                      receiverId: 'b',
                      value: 50,
                      oldPayerBalance: 10,
                    ),
                    receiverUid: 'b',
                  ),
                  PaymentListItem(
                    payment: Payment(
                      groupId: 'asd',
                      payerId: 'b',
                      receiverId: 'a',
                      value: 30,
                      oldPayerBalance: -40,
                    ),
                    receiverUid: 'b',
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
