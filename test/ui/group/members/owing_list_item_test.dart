import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/owing/owing_cubit.dart';
import 'package:statera/business_logic/payments/new_payments_cubit.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/group_repository.mocks.dart';
import 'package:statera/data/services/payment_service.mocks.dart';
import 'package:statera/ui/group/members/owing_list_item.dart';

import '../../../helpers.dart';

class MockGroupCubit extends Mock implements GroupCubit {}

void main() {
  group('Owing list Item', () {
    final mockPaymentService = MockPaymentService();
    final mockGroupService = MockGroupRepository();

    late CustomUser currentUser;
    late CustomUser memberUser;
    late Group group;
    late OwingListItem owingListItem;

    setUp(() {
      currentUser = CustomUser(uid: defaultCurrentUserId, name: 'Current User');
      memberUser = CustomUser.fake();
      group = Group(
        id: 'test_group',
        name: 'Test Group',
        members: [currentUser, memberUser],
        adminId: defaultCurrentUserId,
      );
      owingListItem = OwingListItem(member: memberUser, owing: 10);
    });

    when(mockGroupService.groupStream(any))
        .thenAnswer((_) => Stream.fromIterable([group]));

    when(mockPaymentService.paymentsStream(
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

    Future<void> pumpOwingListItem(WidgetTester tester) async {
      await customPump(owingListItem, tester,
          currentUserId: defaultCurrentUserId,
          group: group,
          extraProviders: [
            Provider<OwingCubit>(
              create: (context) => OwingCubit(),
            ),
            Provider<NewPaymentsCubit>(
                create: (context) => NewPaymentsCubit(mockPaymentService)
                  ..load(groupId: group.id, uid: currentUser.uid)),
          ],
          groupService: mockGroupService);
      await tester.pump();
    }

    testWidgets('shows options for admins', (WidgetTester tester) async {
      await pumpOwingListItem(tester);
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
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

    testWidgets('shows kick member confirmation dialog',
        (WidgetTester tester) async {
      await pumpOwingListItem(tester);

      final icon = find.byIcon(Icons.more_vert);
      await tester.tap(icon);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Kick Member'));
      await tester.pumpAndSettle();

      expect(
        find.text('You are about to KICK member "${memberUser.name}"'),
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

    testWidgets('shows transfer ownership confirmation dialog',
        (WidgetTester tester) async {
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

    testWidgets('doesnt show options to non admins',
        (WidgetTester tester) async {
      group = Group(
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
