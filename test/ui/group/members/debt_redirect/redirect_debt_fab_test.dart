import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:statera/business_logic/debt_redirection/debt_redirection_cubit.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/group/members/debt_redirect/redirect_debt_fab.dart';

import '../../../../helpers.dart';

void main() {
  group('Redirect Debt FAB', () {
    testWidgets('can redirect debt', (WidgetTester tester) async {
      const uid = 'foo';
      final group = Group(
        id: 'group_foo',
        name: 'Group Foo',
        members: [
          CustomUser(uid: uid, name: 'Foo'),
        ],
        balance: {
          'ower': {uid: 3.0, 'receiver': 0.0},
          uid: {'ower': -3.0, 'receiver': 5.0},
          'receiver': {uid: -5.0, 'ower': 0.0}
        },
        supportsDebtRedirection: true,
      );
      await customPump(
        BlocProvider.value(
          value: DebtRedirectionCubit(defaultPaymentService)..init(uid, group),
          child: RedirectDebtFAB(
            popOnSuccess: false,
            loadingLabel: Text('Loading...'),
          ),
        ),
        tester,
        currentUserId: uid,
        group: group,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      final savedGroups =
          verify(defaultGroupService.saveGroup(captureAny)).captured;
      expect(savedGroups.length, 1);
      final savedGroup = savedGroups.first as Group;
      expect(savedGroup, isNotNull);
      final hasCorrectBalance = predicate<Group>((group) {
        return group.balance['ower']![uid] == 0.0 &&
            group.balance[uid]!['receiver'] == 2.0 &&
            group.balance['ower']!['receiver'] == 3.0;
      });
      expect(savedGroup, hasCorrectBalance);
      verify(defaultPaymentService.addPayment(any)).called(3);

      expect(find.text('Debt successfuly redirected'), findsOneWidget);
    });
  });
}
