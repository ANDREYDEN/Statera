import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:statera/business_logic/notifications/notifications_cubit.dart';
import 'package:statera/business_logic/notifications/notifications_cubit.mocks.dart';
import 'package:statera/business_logic/user/user_cubit.dart';
import 'package:statera/data/services/error_service_mock.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/ui/color/seed_color_cubit.dart';
import 'package:statera/ui/color/seed_color_cubit.mocks.dart';
import 'package:statera/ui/settings/settings_page.dart';

import '../../helpers.dart';

void main() {
  group('Preferred currency setting', () {
    testWidgets('is automatic by default', (tester) async {
      final firestore = FakeFirebaseFirestore();
      await seedUser(firestore);

      await pumpSettingsPage(tester, firestore);

      expect(find.text('Automatic'), findsOneWidget);
    });

    testWidgets('sets the preferred currency', (tester) async {
      final firestore = FakeFirebaseFirestore();
      await seedUser(firestore);
      await pumpSettingsPage(tester, firestore);

      await tapPreferredCurrency(tester);
      await tester.tap(find.text('EUR - Euro'));
      await tester.pumpAndSettle();

      expect(await getPreferredCurrency(firestore), 'EUR');
      expect(find.text('EUR (€)'), findsOneWidget);
    });

    testWidgets('resets the preferred currency', (tester) async {
      final firestore = FakeFirebaseFirestore();
      await seedUser(firestore, preferredCurrencyCode: 'EUR');
      await pumpSettingsPage(tester, firestore);

      await tapPreferredCurrency(tester);
      await tester.tap(find.text('Automatic'));
      await tester.pumpAndSettle();

      expect(await getPreferredCurrency(firestore), isNull);
    });
  });
}

Future<void> pumpSettingsPage(
  WidgetTester tester,
  FakeFirebaseFirestore firestore,
) async {
  // render the whole settings list, including the General section
  tester.view.physicalSize = const Size(1080, 4000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final userCubit = UserCubit(UserRepository(firestore), MockErrorService())
    ..load(defaultCurrentUserId);
  final seedColorCubit = MockSeedColorCubit();
  when(seedColorCubit.state).thenReturn(Colors.yellow);

  await customPump(
    MultiBlocProvider(
      providers: [
        BlocProvider<UserCubit>.value(value: userCubit),
        BlocProvider<NotificationsCubit>.value(
          value: MockNotificationsCubit(),
        ),
        BlocProvider<SeedColorCubit>.value(value: seedColorCubit),
      ],
      child: SettingsPage(),
    ),
    tester,
  );
  await tester.pumpAndSettle();
}

Future<void> tapPreferredCurrency(WidgetTester tester) async {
  await tester.tap(find.text('Preferred Currency'));
  await tester.pumpAndSettle();
}

Future<void> seedUser(
  FakeFirebaseFirestore firestore, {
  String? preferredCurrencyCode,
}) async {
  await firestore.collection('users').doc(defaultCurrentUserId).set({
    'name': 'Foo',
    'paymentInfo': 'foo@example.com',
    'photoURL': null,
    if (preferredCurrencyCode != null)
      'preferredCurrencyCode': preferredCurrencyCode,
  });
}

Future<String?> getPreferredCurrency(FakeFirebaseFirestore firestore) async {
  final userDoc = await firestore
      .collection('users')
      .doc(defaultCurrentUserId)
      .get();
  return userDoc.data()!['preferredCurrencyCode'];
}
