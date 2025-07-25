import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/data/models/custom_user.dart';
import 'package:statera/data/models/group.dart';
import 'package:statera/ui/group/settings/leave_group_setting.dart';
import 'package:statera/ui/widgets/buttons/danger_button.dart';

import '../../helpers.dart';

class GroupCubitMock extends Mock implements GroupCubit {}

class AuthBlocMock extends Mock implements AuthBloc {}

void main() {
  group('Leave Group Setting', () {
    late CustomUser currentUser;
    late CustomUser adminUser;
    late CustomUser otherUser;
    late Group testGroup;

    setUp(() {
      currentUser = CustomUser(uid: defaultCurrentUserId, name: 'Test User');
      adminUser = CustomUser(uid: 'admin_user', name: 'Admin User');
      otherUser = CustomUser(uid: 'other_user', name: 'Other User');
      testGroup = Group(
        id: 'test_group',
        name: 'Test Group',
        members: [currentUser, adminUser, otherUser],
        adminId: adminUser.uid, // Set a different user as admin
      );
    });

    Future<void> pumpLeaveGroupSetting(
      WidgetTester tester, {
      bool isAdmin = false,
      bool hasOutstandingBalance = false,
    }) async {
      if (hasOutstandingBalance) {
        testGroup.balance = {
          currentUser.uid: {
            otherUser.uid: 10.0,
            adminUser.uid: 0.0,
          },
          otherUser.uid: {
            currentUser.uid: -10.0,
            adminUser.uid: 0.0,
          },
          adminUser.uid: {
            currentUser.uid: 0.0,
            otherUser.uid: 0.0,
          },
        };
      }

      await customPump(
        LeaveGroupSetting(
          isAdmin: isAdmin,
          groupName: testGroup.name,
        ),
        tester,
        currentUserId: currentUser.uid,
        group: testGroup,
      );
      await tester.pumpAndSettle();
    }

    group('disables leave button', () {
      testWidgets('when user is admin', (tester) async {
        await pumpLeaveGroupSetting(tester, isAdmin: true);

        final subtitle =
            find.textContaining('Transfer ownership to another member first');
        expect(subtitle, findsOneWidget);
        final button = find.widgetWithText(DangerButton, 'Leave group');
        expect(tester.widget<DangerButton>(button).onPressed, isNull);
      });

      testWidgets('when user has outstanding balance', (tester) async {
        await pumpLeaveGroupSetting(tester, hasOutstandingBalance: true);

        final subtitle = find.textContaining('Settle all pending debts first');
        expect(subtitle, findsOneWidget);
        final button = find.widgetWithText(DangerButton, 'Leave group');
        expect(tester.widget<DangerButton>(button).onPressed, isNull);
      });
    });

    testWidgets('enables leave button when user can leave', (tester) async {
      await pumpLeaveGroupSetting(tester);

      final button = find.widgetWithText(DangerButton, 'Leave group');
      expect(tester.widget<DangerButton>(button).onPressed, isNotNull);
    });
  });
}
