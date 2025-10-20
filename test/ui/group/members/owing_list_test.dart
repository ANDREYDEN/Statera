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
  group('OwingList', () {
    final mockPaymentService = MockPaymentService();
    final mockGroupService = MockGroupRepository();
    final mockExpenseService = MockExpenseService();

    late CustomUser currentUser;
    late Group testGroup;

    final memberA = CustomUser(uid: 'uid_a', name: 'Alice');
    final memberZ = CustomUser(uid: 'uid_z', name: 'Zoe');
    final memberB = CustomUser(uid: 'uid_b', name: 'Bob');

    setUp(() {
      currentUser = CustomUser(uid: defaultCurrentUserId, name: 'Current User');

      testGroup = Group(
        id: 'test_group',
        name: 'Test Group',
        members: [currentUser, memberA, memberZ, memberB],
        balance: {
          currentUser.uid: {
            memberA.uid: -5.0,
            memberZ.uid: -15.0,
            memberB.uid: -10.0,
          },
          memberA.uid: {currentUser.uid: 5.0},
          memberZ.uid: {currentUser.uid: 15.0},
          memberB.uid: {currentUser.uid: 10.0},
        },
        adminId: defaultCurrentUserId,
      );

      when(
        mockGroupService.groupStream(any),
      ).thenAnswer((_) => Stream.fromIterable([testGroup]));
    });

    Future<void> pumpOwingList(WidgetTester tester) async {
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

    testWidgets('orders members by name by default', (
      WidgetTester tester,
    ) async {
      when(
        mockPaymentService.paymentsStream(
          groupId: testGroup.id,
          userId1: currentUser.uid,
          newFor: currentUser.uid,
        ),
      ).thenAnswer((_) => Stream.fromIterable([[]]));

      await pumpOwingList(tester);

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
        orderedEquals([memberA.name, memberB.name, memberZ.name]),
      );
    });

    testWidgets('puts members with recent unseen payments first', (
      WidgetTester tester,
    ) async {
      final earlierTime = DateTime(2024, 1, 1);
      final laterTime = DateTime(2024, 1, 2);

      when(
        mockPaymentService.paymentsStream(
          groupId: testGroup.id,
          userId1: currentUser.uid,
          newFor: currentUser.uid,
        ),
      ).thenAnswer(
        (_) => Stream.fromIterable([
          [
            Payment(
              groupId: testGroup.id,
              payerId: currentUser.uid,
              receiverId: memberA.uid,
              value: 50,
              timeCreated: earlierTime,
            ),
            Payment(
              groupId: testGroup.id,
              payerId: currentUser.uid,
              receiverId: memberB.uid,
              value: 100,
              timeCreated: laterTime,
            ),
          ],
        ]),
      );

      await pumpOwingList(tester);

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
