import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/error_service_mock.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/data/value_objects/currency.dart';
import 'package:statera/ui/contact/contact_page.dart';

import '../../helpers.dart';

const currentUid = 'me';
const contactUid = 'contact';
final eur = Currency.fromCode('EUR');

void main() {
  group('ContactPage', () {
    late FakeFirebaseFirestore firestore;

    setUp(() {
      firestore = FakeFirebaseFirestore();
    });

    group('total debt', () {
      testWidgets('sums debt that is in a single currency', (tester) async {
        await seedUsers(firestore);
        await seedGroup(firestore, 'owing', owedToContact: 30);
        await seedGroup(firestore, 'owed', owedToContact: -20);
        await pumpContactPage(tester, firestore);

        expect(find.text('\$10.00'), findsOneWidget);
      });

      testWidgets('converts debt into the most common currency', (
        tester,
      ) async {
        await seedUsers(firestore);
        await seedLatestRates(firestore, {'EUR': 0.5});
        await seedGroup(firestore, 'eur1', owedToContact: 10, currency: eur);
        await seedGroup(firestore, 'eur2', owedToContact: 10, currency: eur);
        await seedGroup(firestore, 'usd', owedToContact: 10);
        await pumpContactPage(tester, firestore);

        expect(find.text('≈€25.00'), findsOneWidget);
      });

      testWidgets('converts debt into the preferred currency', (tester) async {
        await seedUsers(firestore, preferredCurrencyCode: 'USD');
        await seedLatestRates(firestore, {'EUR': 0.5});
        await seedGroup(firestore, 'eur', owedToContact: 10, currency: eur);
        await pumpContactPage(tester, firestore);

        expect(find.text('≈\$20.00'), findsOneWidget);
      });

      testWidgets('shows an error when exchange rates are unavailable', (
        tester,
      ) async {
        await seedUsers(firestore);
        await seedGroup(firestore, 'eur', owedToContact: 10, currency: eur);
        await seedGroup(firestore, 'usd', owedToContact: 10);
        await pumpContactPage(tester, firestore);

        expect(find.text('Unable to convert currencies'), findsOneWidget);
      });
    });

    group('settling debt', () {
      testWidgets('creates a payment in every group with a non-zero balance', (
        tester,
      ) async {
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
      });

      testWidgets('zeroes out the balance in every shared group', (
        tester,
      ) async {
        await seedUsers(firestore);
        await seedGroup(firestore, 'owing', owedToContact: 30);
        await seedGroup(firestore, 'owed', owedToContact: -20);
        await pumpContactPage(tester, firestore);

        await settleDebt(tester);

        expect(await getBalance(firestore, groupId: 'owing'), 0);
        expect(await getBalance(firestore, groupId: 'owed'), 0);
      });

      testWidgets('creates each payment in the currency of its group', (
        tester,
      ) async {
        await seedUsers(firestore);
        await seedLatestRates(firestore, {'EUR': 0.5});
        await seedGroup(firestore, 'usd', owedToContact: 30);
        await seedGroup(firestore, 'eur', owedToContact: 10, currency: eur);
        await pumpContactPage(tester, firestore);

        await settleDebt(tester);

        final payments = await getPayments(firestore);
        final eurPayment = payments.singleWhere(
          (payment) => payment['groupId'] == 'eur',
        );
        expect(eurPayment['currencyCode'], 'EUR');
        expect(eurPayment['value'], 10);
        final usdPayment = payments.singleWhere(
          (payment) => payment['groupId'] == 'usd',
        );
        expect(usdPayment['currencyCode'], 'USD');
        expect(usdPayment['value'], 30);
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

Future<void> seedUsers(
  FakeFirebaseFirestore firestore, {
  String? preferredCurrencyCode,
}) async {
  await firestore.collection('users').doc(currentUid).set({
    'name': 'Me',
    if (preferredCurrencyCode != null)
      'preferredCurrencyCode': preferredCurrencyCode,
  });
  await firestore.collection('users').doc(contactUid).set({'name': 'Contact'});
}

Future<void> seedGroup(
  FakeFirebaseFirestore firestore,
  String id, {
  required double owedToContact,
  Currency? currency,
}) async {
  final group = Group(
    currency: currency,
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

Future<void> seedLatestRates(
  FakeFirebaseFirestore firestore,
  Map<String, double> rates,
) async {
  await firestore.collection('currencies').doc('latest').set({
    'base': 'USD',
    'date': '2026-11-25',
    'rates': rates,
  });
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
      Provider<CurrencyService>(create: (_) => CurrencyService(firestore)),
      Provider<ErrorService>(create: (_) => MockErrorService()),
    ],
  );
  await tester.pumpAndSettle();
  // let the payment list mark the loaded payments as viewed
  await tester.pump(const Duration(seconds: 1));
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
