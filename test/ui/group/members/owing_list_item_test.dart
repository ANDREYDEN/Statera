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
    testWidgets('shows options for admins', (WidgetTester tester) async {
      final currentUser =
          CustomUser(uid: defaultCurrentUserId, name: 'Current User');
      final memberUser = CustomUser.fake();

      // Create a group where the current user is an admin
      final testGroup = Group(
        id: 'test_group',
        name: 'Test Group',
        members: [currentUser, memberUser],
        adminId: defaultCurrentUserId,
      );

      final owingListItem = OwingListItem(member: memberUser, owing: 10);

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
        group: testGroup,
      );

      await tester.pump();

      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });
  });
}
