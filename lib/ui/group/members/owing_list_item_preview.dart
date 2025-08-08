import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/business_logic/owing/owing_cubit.dart';
import 'package:statera/business_logic/payments/new_payments_cubit.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/auth_service.mocks.dart';
import 'package:statera/data/services/expense_service.mocks.dart';
import 'package:statera/data/services/group_repository.mocks.dart';
import 'package:statera/data/services/payment_service.mocks.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/data/services/user_repository.mocks.dart';
import 'package:statera/ui/group/members/owing_list_item.dart';
import 'package:statera/utils/preview_helpers.dart';

void main() {
  runApp(OwingListItemExamples());
}

class MockUser extends Mock implements User {
  String get uid =>
      super.noSuchMethod(Invocation.getter(#uid), returnValue: 'foo');
}

class OwingListItemExamples extends StatelessWidget {
  const OwingListItemExamples({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    late CustomUser currentUser;
    late CustomUser memberUser;
    late CustomUser memberUser2;
    late CustomUser memberUser3;

    currentUser = CustomUser(uid: 'foo', name: 'Current User');
    memberUser = CustomUser.fake(name: 'Agent Smith');
    memberUser2 = CustomUser.fake(name: 'John Doe');
    memberUser3 = CustomUser.fake(name: 'Jane Doe');
    final group = Group(
        id: 'test_group',
        name: 'Test Group',
        members: [currentUser, memberUser, memberUser2, memberUser3],
        adminId: currentUser.uid,
        balance: {
          '${currentUser.uid}': {
            '${memberUser.uid}': -10,
            '${memberUser2.uid}': -10,
            '${memberUser3.uid}': -10
          },
          '${memberUser.uid}': {
            '${currentUser.uid}': 10,
            '${memberUser2.uid}': 10,
            '${memberUser3.uid}': 10
          },
          '${memberUser2.uid}': {
            '${currentUser.uid}': 10,
            '${memberUser.uid}': -10,
            '${memberUser3.uid}': -10
          },
          '${memberUser3.uid}': {
            '${currentUser.uid}': 10,
            '${memberUser.uid}': -10,
            '${memberUser3.uid}': -10
          }
        });

    final expense = Expense(
        authorUid: currentUser.uid, name: 'test expense', groupId: group.id);

    final defaultAuthService = MockAuthService();
    final authCurrentUser = MockUser();
    when(authCurrentUser.uid).thenReturn(currentUser.uid);
    when(defaultAuthService.currentUser).thenAnswer((_) => authCurrentUser);

    final defaultGroupService = MockGroupRepository();
    when(defaultGroupService.groupStream(any))
        .thenAnswer((_) => Stream.fromIterable([group]));

    final mockExpenseService = MockExpenseService();
    when(mockExpenseService.getPendingExpenses(group.id, memberUser.uid))
        .thenAnswer((_) => Future.value([expense]));
    when(mockExpenseService.getPendingAuthoredExpenses(
            group.id, memberUser.uid))
        .thenAnswer((_) => Future.value([expense]));

    final defaultPaymentService = MockPaymentService();
    when(defaultPaymentService.paymentsStream(
      groupId: group.id,
      userId1: currentUser.uid,
      newFor: currentUser.uid,
    )).thenAnswer((_) => Stream.fromIterable([
          [
            Payment(
              groupId: group.id,
              payerId: currentUser.uid,
              receiverId: memberUser.uid,
              value: 145,
            )
          ]
        ]));
    return CustomPreview(
      providers: [
        Provider<ExpenseService>.value(value: mockExpenseService),
        Provider.value(value: PreferencesService()),
        Provider<OwingCubit>(
          create: (context) => OwingCubit(),
        ),
        Provider<NewPaymentsCubit>(
            create: (context) => NewPaymentsCubit(defaultPaymentService)
              ..load(groupId: group.id, uid: currentUser.uid)),
        BlocProvider(create: (context) => AuthBloc(defaultAuthService)),
        BlocProvider(
          create: (context) => GroupCubit(
            defaultGroupService,
            mockExpenseService,
            MockUserRepository(),
          )..load((group).id),
        ),
      ],
      body: Column(
        children: [
          OwingListItem(member: memberUser, owing: 10),
          OwingListItem(member: memberUser2, owing: 12),
          OwingListItem(member: memberUser3, owing: 13),
        ],
      ),
    );
  }
}
