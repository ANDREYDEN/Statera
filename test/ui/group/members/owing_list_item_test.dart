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
import 'package:statera/ui/group/members/kick_member/kick_member_info_section.dart';
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
    late Expense pendingExpense;
    late Expense pendingAuthoredExpense;

    setUp(() {
      currentUser = CustomUser(uid: defaultCurrentUserId, name: 'Current User');
      memberUser = CustomUser.fake();
      testGroup = Group(
        id: 'test_group',
        name: 'Test Group',
        members: [currentUser, memberUser],
        balance: {
          currentUser.uid: {memberUser.uid: -10.0},
          memberUser.uid: {currentUser.uid: 10.0},
        },
        adminId: defaultCurrentUserId,
      );

      owingListItem = OwingListItem(member: memberUser, owing: 10);
      pendingExpense = Expense(
        authorUid: defaultCurrentUserId,
        name: 'test expense',
        groupId: testGroup.id,
      )..addAssignee(memberUser.uid);
      pendingAuthoredExpense = Expense(
        authorUid: memberUser.uid,
        name: 'test authored expense',
        groupId: testGroup.id,
      );

      when(mockGroupService.groupStream(any))
          .thenAnswer((_) => Stream.fromIterable([testGroup]));

      when(mockExpenseService.getPendingExpenses(testGroup.id!, memberUser.uid))
          .thenAnswer((_) => Future.value([pendingExpense]));
      when(mockExpenseService.getPendingAuthoredExpenses(
              testGroup.id!, memberUser.uid))
          .thenAnswer((_) => Future.value([pendingAuthoredExpense]));

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

    group('when kicking member', () {
      testWidgets('can kick member', (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(Size(700, 1000));
        testGroup.balance = {
          '${currentUser.uid}': {'${memberUser.uid}': -10},
          '${memberUser.uid}': {'${currentUser.uid}': 10}
        };

        await pumpOwingListItem(tester);

        await openOptionsMenu(tester);
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
          of: find.text('Confirm'),
          matching: find.byType(FilledButton),
        );
        expect(tester.widget<FilledButton>(confirmButton).enabled, isTrue);
        await tester.tap(confirmButton);

        verify(mockGroupService.saveGroup(any)).called(1);
      });

      testWidgets('shows outstanding balance', (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(Size(700, 1000));
        await pumpOwingListItem(tester);

        await openOptionsMenu(tester);
        await tester.tap(find.text('Kick Member'));
        await tester.pumpAndSettle();

        final sectionTitle = find.text('Outstanding Balance');
        final section = find.ancestor(
          of: sectionTitle,
          matching: find.byType(KickMemberInfoSection),
        );
        final memberWithPendingBalanceName =
            find.descendant(of: section, matching: find.text(currentUser.name));
        expect(memberWithPendingBalanceName, findsOneWidget);
      });

      testWidgets('shows outstanding expenses', (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(Size(700, 1000));
        await pumpOwingListItem(tester);

        await openOptionsMenu(tester);
        await tester.tap(find.text('Kick Member'));
        await tester.pumpAndSettle();

        final sectionTitle = find.text('Pending Expenses');
        final section = find.ancestor(
          of: sectionTitle,
          matching: find.byType(KickMemberInfoSection),
        );
        final pendingExpenseName = find.descendant(
          of: section,
          matching: find.text(pendingExpense.name),
        );
        expect(pendingExpenseName, findsOneWidget);
      });

      testWidgets('shows outstanding authored expenses',
          (WidgetTester tester) async {
        await pumpOwingListItem(tester);

        await openOptionsMenu(tester);
        await tester.tap(find.text('Kick Member'));
        await tester.pumpAndSettle();

        final sectionTitle = find.text('Pending Authored Expenses');
        final section = find.ancestor(
          of: sectionTitle,
          matching: find.byType(KickMemberInfoSection),
        );
        final pendingAuthoredExpenseName = find.descendant(
          of: section,
          matching: find.text(pendingAuthoredExpense.name),
        );
        expect(pendingAuthoredExpenseName, findsOneWidget);
      });
    });

    testWidgets('can transfer ownership', (WidgetTester tester) async {
      await pumpOwingListItem(tester);

      await openOptionsMenu(tester);

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
        of: find.text('Confirm'),
        matching: find.byType(FilledButton),
      );
      expect(tester.widget<FilledButton>(confirmButton).enabled, isTrue);
      await tester.tap(confirmButton);

      verify(mockGroupService.saveGroup(any)).called(1);
    });

    testWidgets('shows kick member and transfer ownership option in menu',
        (WidgetTester tester) async {
      await pumpOwingListItem(tester);

      await openOptionsMenu(tester);

      expect(find.text('Kick Member'), findsOneWidget);
      expect(find.text('Transfer Ownership'), findsOneWidget);
    });

    testWidgets('shows options for admins', (WidgetTester tester) async {
      await pumpOwingListItem(tester);
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    testWidgets('does not show options to non admins',
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

Future<void> openOptionsMenu(WidgetTester tester) async {
  final icon = find.byIcon(Icons.more_vert);
  await tester.tap(icon);
  await tester.pumpAndSettle();
}
