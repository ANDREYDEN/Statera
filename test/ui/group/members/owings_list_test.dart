import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/owing/owing_cubit.dart';
import 'package:statera/business_logic/payments/new_payments_cubit.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/error_service_mock.dart';
import 'package:statera/data/services/expense_service.mocks.dart';
import 'package:statera/data/services/group_repository.mocks.dart';
import 'package:statera/data/services/payment_service.mocks.dart';
import 'package:statera/ui/group/members/owings_list.dart';
import 'package:statera/ui/widgets/user_avatar.dart';

import '../../../helpers.dart';

void main() {
  group('OwingsList', () {
    final mockPaymentService = MockPaymentService();
    final mockGroupService = MockGroupRepository();
    final mockExpenseService = MockExpenseService();

    late CustomUser currentUser;
    final groupId = 'test_group';

    final memberA = CustomUser(uid: 'uid_a', name: 'Alice');
    final memberZ = CustomUser(uid: 'uid_z', name: 'Zoe');
    final memberB = CustomUser(uid: 'uid_b', name: 'Bob');

    setUp(() {
      currentUser = CustomUser(uid: defaultCurrentUserId, name: 'Current User');
    });

    Future<void> pumpOwingsList(
      WidgetTester tester, {
      required List<Payment> payments,
      required Map<String, Map<String, double>> balance,
    }) async {
      final testGroup = Group(
        id: groupId,
        name: 'Test Group',
        members: [currentUser, memberA, memberZ, memberB],
        balance: balance,
        adminId: defaultCurrentUserId,
      );

      when(
        mockGroupService.groupStream(any),
      ).thenAnswer((_) => Stream.fromIterable([testGroup]));

      when(
        mockPaymentService.paymentsStream(
          groupId: testGroup.id,
          userId1: currentUser.uid,
          newFor: currentUser.uid,
        ),
      ).thenAnswer((_) => Stream.fromIterable([payments]));

      await customPump(
        OwingsList(),
        tester,
        currentUserId: defaultCurrentUserId,
        group: testGroup,
        extraProviders: [
          Provider<OwingCubit>(create: (context) => OwingCubit()),
          Provider<NewPaymentsCubit>(
            create: (context) =>
                NewPaymentsCubit(mockPaymentService, MockErrorService())
                  ..load(groupId: testGroup.id, uid: currentUser.uid),
          ),
        ],
        groupService: mockGroupService,
        expenseService: mockExpenseService,
      );
      await tester.pumpAndSettle();
    }

    testWidgets('orders members by debt then name when no recent payments', (
      WidgetTester tester,
    ) async {
      await pumpOwingsList(
        tester,
        payments: [],
        balance: {
          currentUser.uid: {memberA.uid: 0, memberB.uid: 10, memberZ.uid: 0},
          memberA.uid: {currentUser.uid: 0},
          memberB.uid: {currentUser.uid: -10.0},
          memberZ.uid: {currentUser.uid: 0},
        },
      );

      final memberNames = tester
          .widgetList<Text>(
            find.descendant(
              of: find.byType(UserAvatarName),
              matching: find.byType(Text),
            ),
          )
          .map((t) => t.data);

      expect(
        memberNames,
        orderedEquals([memberB.name, memberA.name, memberZ.name]),
      );
    });

    testWidgets('puts members with recent unseen payments first', (
      WidgetTester tester,
    ) async {
      final earlierTime = DateTime(2024, 1, 1);
      final laterTime = DateTime(2024, 1, 2);

      final payments = [
        Payment(
          groupId: groupId,
          payerId: currentUser.uid,
          receiverId: memberA.uid,
          value: 100,
          timeCreated: earlierTime,
        ),
        Payment(
          groupId: groupId,
          payerId: currentUser.uid,
          receiverId: memberB.uid,
          value: 50,
          timeCreated: laterTime,
        ),
      ];

      await pumpOwingsList(
        tester,
        payments: payments,
        balance: {
          currentUser.uid: {memberA.uid: 100, memberB.uid: 50, memberZ.uid: 0},
          memberA.uid: {currentUser.uid: 100.0},
          memberB.uid: {currentUser.uid: 50.0},
          memberZ.uid: {currentUser.uid: 0.0},
        },
      );

      final memberNames = tester
          .widgetList<Text>(
            find.descendant(
              of: find.byType(UserAvatarName),
              matching: find.byType(Text),
            ),
          )
          .map((t) => t.data);

      expect(
        memberNames,
        orderedEquals([memberB.name, memberA.name, memberZ.name]),
      );
    });

    testWidgets('orders by debt when payments have same date', (
      WidgetTester tester,
    ) async {
      final sameTime = DateTime(2024, 1, 1);

      final payments = [
        Payment(
          groupId: groupId,
          payerId: currentUser.uid,
          receiverId: memberA.uid,
          value: 50,
          timeCreated: sameTime,
        ),
        Payment(
          groupId: groupId,
          payerId: currentUser.uid,
          receiverId: memberB.uid,
          value: 100,
          timeCreated: sameTime,
        ),
      ];

      await pumpOwingsList(
        tester,
        payments: payments,
        balance: {
          currentUser.uid: {memberA.uid: 50, memberB.uid: 100, memberZ.uid: 0},
          memberA.uid: {currentUser.uid: 50.0},
          memberB.uid: {currentUser.uid: 100.0},
          memberZ.uid: {currentUser.uid: 0.0},
        },
      );

      final memberNames = tester
          .widgetList<Text>(
            find.descendant(
              of: find.byType(UserAvatarName),
              matching: find.byType(Text),
            ),
          )
          .map((t) => t.data);

      expect(
        memberNames,
        orderedEquals([memberB.name, memberA.name, memberZ.name]),
      );
    });
  });
}
