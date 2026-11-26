import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/data/value_objects/currency.dart';
import 'package:statera/ui/group/settings/group_settings.dart';

import '../../../helpers.dart';

const groupId = 'group_id';

void main() {
  group('Group currency setting', () {
    testWidgets('shows the current group currency', (tester) async {
      final firestore = FakeFirebaseFirestore();
      await seedGroup(firestore, currency: Currency.fromCode('GBP'));

      await pumpGroupSettings(tester, firestore);

      expect(find.text('GBP (£)'), findsOneWidget);
    });

    testWidgets('changes the group currency', (tester) async {
      final firestore = FakeFirebaseFirestore();
      await seedGroup(firestore, currency: Currency.usd);
      await pumpGroupSettings(tester, firestore);

      await tester.tap(find.text('Currency'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('EUR - Euro'));
      await tester.pumpAndSettle();

      final groupDoc = await firestore.collection('groups').doc(groupId).get();
      expect(groupDoc.data()!['currencyCode'], 'EUR');
      expect(groupDoc.data()!['currencySign'], '€');
    });
  });
}

Future<void> pumpGroupSettings(
  WidgetTester tester,
  FakeFirebaseFirestore firestore,
) async {
  final groupRepository = GroupRepository(firestore);
  final group = await groupRepository.getGroupById(groupId);

  await customPump(
    GroupSettings(),
    tester,
    groupService: groupRepository,
    group: group,
  );
  await tester.pumpAndSettle();
}

Future<void> seedGroup(
  FakeFirebaseFirestore firestore, {
  required Currency currency,
}) async {
  final admin = CustomUser(uid: defaultCurrentUserId, name: 'Admin');
  final group = Group(
    id: groupId,
    name: 'Group',
    members: [admin],
    adminId: admin.uid,
    currency: currency,
  );
  await firestore.collection('groups').doc(groupId).set(group.toFirestore());
}
