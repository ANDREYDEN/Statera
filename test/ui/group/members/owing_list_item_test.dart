import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/owing/owing_cubit.dart';
import 'package:statera/business_logic/payments/new_payments_cubit.dart';
import 'package:statera/data/models/custom_user.dart';
import 'package:statera/data/models/group.dart';
import 'package:statera/ui/group/members/owing_list_item.dart';

import '../../../helpers.dart';

void main() {
  group('Owing list Item', () {
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

    Future<void> pumpOwingListItem(WidgetTester tester) async {
      await customPump(
        MultiProvider(
          providers: [
            Provider<OwingCubit>(
              create: (context) => OwingCubit(),
            ),
            Provider<NewPaymentsCubit>(
              create: (context) => NewPaymentsCubit(defaultPaymentService),
            ),
          ],
          child: owingListItem,
        ),
        tester,
        currentUserId: defaultCurrentUserId,
        group: group,
      );

      await tester.pump();
    }

    testWidgets('shows options for admins', (WidgetTester tester) async {
      await pumpOwingListItem(tester);
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    testWidgets('shows kick member and transfer ownership option in menu',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(Size(600, 1200));
      await pumpOwingListItem(tester);

      final icon = find.byIcon(Icons.more_vert);
      await tester.tap(icon);
      await tester.pump();

      expect(find.text('Kick Member'), findsOneWidget);
      expect(find.text('Transfer Ownership'), findsOneWidget);
    });

    testWidgets('doesnt show options to non admins',
        (WidgetTester tester) async {
      group = Group(
        id: 'test_group',
        name: 'Test Group',
        members: [currentUser, memberUser],
        adminId: memberUser.uid, // Make the member user the admin instead
      );

      await pumpOwingListItem(tester);

      expect(find.byIcon(Icons.more_vert), findsNothing);
    });
  });
}
