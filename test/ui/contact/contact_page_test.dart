import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/error_service_mock.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/ui/contact/contact_page.dart';

import '../../helpers.dart';

const currentUid = 'me';
const contactUid = 'contact';

void main() {
  group('ContactPage', () {
    late FakeFirebaseFirestore firestore;

    setUp(() {
      firestore = FakeFirebaseFirestore();
    });

    group('settling debt', () {
      testWidgets(
        'creates a payment and settles balance in every group with a non-zero balance',
        (tester) async {
          await seedUsers(firestore);
          await seedGroup(firestore, 'owing', owedToContact: 30);
          await seedGroup(firestore, 'owed', owedToContact: -20);
          await seedGroup(firestore, 'even', owedToContact: 0);
          await pumpContactPage(tester, firestore);

          await settleDebt(tester);

          final payments = await getPayments(firestore);
          expect(payments, hasLength(2));

          final owingPayment = payments.singleWhere(
            (payment) => payment['groupId'] == 'owing',
          );
          expect(owingPayment['payerId'], currentUid);
          expect(owingPayment['receiverId'], contactUid);
          expect(owingPayment['value'], 30);

          final owedPayment = payments.singleWhere(
            (payment) => payment['groupId'] == 'owed',
          );
          expect(owedPayment['payerId'], contactUid);
          expect(owedPayment['receiverId'], currentUid);
          expect(owedPayment['value'], 20);

          expect(await getBalance(firestore, groupId: 'owing'), 0);
          expect(await getBalance(firestore, groupId: 'owed'), 0);
        },
      );

      testWidgets('disables settling when every shared balance is zero', (
        tester,
      ) async {
        await seedUsers(firestore);
        await seedGroup(firestore, 'even', owedToContact: 0);
        await pumpContactPage(tester, firestore);
        await tester.pump(1.seconds);

        final button = tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Settle Debt'),
        );
        expect(button.onPressed, isNull);
      });

      testWidgets('explains when balances across groups cancel out', (
        tester,
      ) async {
        await seedUsers(firestore);
        await seedGroup(firestore, 'owing', owedToContact: 20);
        await seedGroup(firestore, 'owed', owedToContact: -20);
        await pumpContactPage(tester, firestore);

        await tester.tap(find.text('Settle Debt'));
        await tester.pumpAndSettle();

        expect(find.textContaining('No payment is needed'), findsOneWidget);

        await tester.tap(find.text('Confirm'));
        await tester.pumpAndSettle();
        await tester.pumpAndSettle();

        expect(await getPayments(firestore), hasLength(2));
        expect(await getBalance(firestore, groupId: 'owing'), 0);
        expect(await getBalance(firestore, groupId: 'owed'), 0);
      });

      testWidgets('does not create payments when cancelled', (tester) async {
        await seedUsers(firestore);
        await seedGroup(firestore, 'owing', owedToContact: 30);
        await pumpContactPage(tester, firestore);

        await tester.tap(find.text('Settle Debt'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        expect(await getPayments(firestore), isEmpty);
        expect(await getBalance(firestore, groupId: 'owing'), 30);
      });
    });
  });
}

Future<void> seedUsers(FakeFirebaseFirestore firestore) async {
  await firestore.collection('users').doc(currentUid).set({'name': 'Me'});
  await firestore.collection('users').doc(contactUid).set({'name': 'Contact'});
}

Future<void> seedGroup(
  FakeFirebaseFirestore firestore,
  String id, {
  required double owedToContact,
}) async {
  final group = Group(
    id: id,
    name: 'Group $id',
    adminId: currentUid,
    members: [
      CustomUser(uid: currentUid, name: 'Me'),
      CustomUser(uid: contactUid, name: 'Contact'),
    ],
    balance: {
      currentUid: {contactUid: owedToContact},
      contactUid: {currentUid: -owedToContact},
    },
  );
  await firestore.collection('groups').doc(id).set(group.toFirestore());
}

Future<void> pumpContactPage(
  WidgetTester tester,
  FakeFirebaseFirestore firestore,
) async {
  final groupRepository = GroupRepository(firestore);

  await customPump(
    ContactPage.init(contactUid),
    tester,
    currentUserId: currentUid,
    extraProviders: [
      Provider<UserRepository>(create: (_) => UserRepository(firestore)),
      Provider<GroupRepository>(create: (_) => groupRepository),
      Provider<CoordinationRepository>(
        create: (_) => CoordinationRepository(firestore),
      ),
      Provider<PaymentService>(
        create: (_) => PaymentService(groupRepository, firestore),
      ),
      Provider<ErrorService>(create: (_) => MockErrorService()),
    ],
  );
  await tester.pumpAndSettle();
}

Future<void> settleDebt(WidgetTester tester) async {
  await tester.tap(find.text('Settle Debt'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Confirm'));
  await tester.pumpAndSettle();
  // let the payment list mark the new payments as viewed
  await tester.pumpAndSettle();
}

Future<List<Map<String, dynamic>>> getPayments(
  FakeFirebaseFirestore firestore,
) async {
  final snap = await firestore.collection('payments').get();
  return snap.docs.map((doc) => doc.data()).toList();
}

Future<double> getBalance(
  FakeFirebaseFirestore firestore, {
  required String groupId,
}) async {
  final doc = await firestore.collection('groups').doc(groupId).get();
  return Group.fromSnapshot(doc).balance[currentUid]![contactUid]!;
}
