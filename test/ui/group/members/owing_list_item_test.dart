import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/owing/owing_cubit.dart';
import 'package:statera/business_logic/payments/new_payments_cubit.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/expense_service.mocks.dart';
import 'package:statera/data/services/group_repository.mocks.dart';
import 'package:statera/data/services/payment_service.mocks.dart';
import 'package:statera/ui/group/members/owing_list_item.dart';

import '../../../helpers.dart';

class MockGroupCubit extends Mock implements GroupCubit {}

void main() {
  group('Owing list Item', () {
    final mockPaymentService = MockPaymentService();
    final mockGroupService = MockGroupRepository();
    final mockExpenseService = MockExpenseService();

    late CustomUser currentUser;
    late CustomUser memberUser;
    late Group testGroup;
    late OwingListItem owingListItem;
    late Expense expense;

    setUp(() {
      currentUser = CustomUser(uid: defaultCurrentUserId, name: 'Current User');
      memberUser = CustomUser.fake();
      testGroup = Group(
        id: 'test_group',
        name: 'Test Group',
        members: [currentUser, memberUser],
        adminId: defaultCurrentUserId,
      );

      owingListItem = OwingListItem(member: memberUser, owing: 10);
      expense = Expense(
          authorUid: defaultCurrentUserId,
          name: 'test expense',
          groupId: testGroup.id);

      when(mockGroupService.groupStream(any))
          .thenAnswer((_) => Stream.fromIterable([testGroup]));

      when(mockPaymentService.paymentsStream(
        groupId: testGroup.id,
        userId1: currentUser.uid,
        newFor: currentUser.uid,
      )).thenAnswer((_) => Stream.fromIterable([
            [
              Payment(
                groupId: testGroup.id,
                payerId: currentUser.uid,
                receiverId: memberUser.uid,
                value: 145,
              )
            ]
          ]));
    });

    Future<void> pumpOwingListItem(WidgetTester tester) async {
      await customPump(
        owingListItem,
        tester,
        currentUserId: defaultCurrentUserId,
        group: testGroup,
        extraProviders: [
          Provider<OwingCubit>(
            create: (context) => OwingCubit(),
          ),
          Provider<NewPaymentsCubit>(
              create: (context) => NewPaymentsCubit(mockPaymentService)
                ..load(groupId: testGroup.id, uid: currentUser.uid)),
        ],
        groupService: mockGroupService,
        expenseService: mockExpenseService,
      );
      await tester.pump();
    }

    group('shows kick member confirmation dialog', () {
      testWidgets('member has outstanding balance',
          (WidgetTester tester) async {
        testGroup.balance = {
          '${currentUser.uid}': {'${memberUser.uid}': -10},
          '${memberUser.uid}': {'${currentUser.uid}': 10}
        };

        await pumpOwingListItem(tester);

        final icon = find.byIcon(Icons.more_vert);
        await tester.tap(icon);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Kick Member'));
        await tester.pumpAndSettle();

        expect(
          find.textContaining(
              'You are about to KICK member "${memberUser.name}"'),
          findsOneWidget,
        );

        await tester.enterText(find.byType(TextField), memberUser.name);
        await tester.pumpAndSettle();

        final confirmButton = find.ancestor(
            of: find.text('Confirm'), matching: find.byType(FilledButton));
        expect(tester.widget<FilledButton>(confirmButton).enabled, isTrue);
        await tester.tap(confirmButton);

        verify(mockGroupService.saveGroup(any)).called(1);
      });

      testWidgets('member is author of outstanding expenses',
          (WidgetTester tester) async {
        await pumpOwingListItem(tester);

        when(mockExpenseService.getPendingAuthoredExpenses(
                testGroup.id!, memberUser.uid))
            .thenAnswer((_) => Future.value([expense]));

        final icon = find.byIcon(Icons.more_vert);
        await tester.tap(icon);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Kick Member'));
        await tester.pumpAndSettle();

        expect(
          find.textContaining(
              'User is the author of unresolved expenses: ${expense.name}'),
          findsOneWidget,
        );
      });

      testWidgets('member is an assignee in any outstanding expenses',
          (WidgetTester tester) async {
        await pumpOwingListItem(tester);

        when(mockExpenseService.getPendingExpenses(
                testGroup.id!, memberUser.uid))
            .thenAnswer((_) => Future.value([expense]));

        final icon = find.byIcon(Icons.more_vert);
        await tester.tap(icon);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Kick Member'));
        await tester.pumpAndSettle();

        expect(
          find.textContaining(
              'Pending expenses where user is involved: ${expense.name}'),
          findsOneWidget,
        );
      });
    });

    group('shows transfer ownership confirmation dialog', () {
      testWidgets('able to transefer ownership', (WidgetTester tester) async {
        await pumpOwingListItem(tester);

        await tester.tap(find.byIcon(Icons.more_vert));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Transfer Ownership'));
        await tester.pumpAndSettle();

        expect(
          find.text(
              'You are about to Transfer Ownership to "${memberUser.name}"'),
          findsOneWidget,
        );

        final test = find.byType(TextField);
        expect(test, findsOneWidget);
        await tester.enterText(find.byType(TextField), memberUser.name);
        await tester.pumpAndSettle();

        final confirmButton = find.ancestor(
            of: find.text('Confirm'), matching: find.byType(FilledButton));
        expect(tester.widget<FilledButton>(confirmButton).enabled, isTrue);
        await tester.tap(confirmButton);

        verify(mockGroupService.saveGroup(any)).called(1);
      });
    });

    testWidgets('shows kick member and transfer ownership option in menu',
        (WidgetTester tester) async {
      await pumpOwingListItem(tester);

      final icon = find.byIcon(Icons.more_vert);
      await tester.tap(icon);
      await tester.pump();

      expect(find.text('Kick Member'), findsOneWidget);
      expect(find.text('Transfer Ownership'), findsOneWidget);
    });

    testWidgets('shows options for admins', (WidgetTester tester) async {
      await pumpOwingListItem(tester);
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    testWidgets('doesnt show options to non admins',
        (WidgetTester tester) async {
      testGroup = Group(
        id: 'test_group',
        name: 'Test Group',
        members: [currentUser, memberUser],
        adminId: memberUser.uid,
      );

      await pumpOwingListItem(tester);

      expect(find.byIcon(Icons.more_vert), findsNothing);
    });
  });
}
