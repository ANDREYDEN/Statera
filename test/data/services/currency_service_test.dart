import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:statera/data/exceptions/exceptions.dart';
import 'package:statera/data/services/services.dart';

main() {
  group('CurrencyService', () {
    group('getLatestRates', () {
      test('reads the latest exchange rates', () async {
        final firestore = FakeFirebaseFirestore();
        await seedLatestRates(firestore, {'EUR': 0.5});

        final rates = await CurrencyService(firestore).getLatestRates();

        expect(rates.base, 'USD');
        expect(rates.rates, {'EUR': 0.5});
      });

      test('reuses the rates that were already read', () async {
        final firestore = FakeFirebaseFirestore();
        await seedLatestRates(firestore, {'EUR': 0.5});
        final currencyService = CurrencyService(firestore);
        await currencyService.getLatestRates();
        await seedLatestRates(firestore, {'EUR': 0.9});

        final rates = await currencyService.getLatestRates();

        expect(rates.rates, {'EUR': 0.5});
      });

      test('retries after rates were not found', () async {
        final firestore = FakeFirebaseFirestore();
        final currencyService = CurrencyService(firestore);
        await expectLater(
          currencyService.getLatestRates(),
          throwsA(isA<EntityNotFoundException>()),
        );
        await seedLatestRates(firestore, {'EUR': 0.5});

        final rates = await currencyService.getLatestRates();

        expect(rates.rates, {'EUR': 0.5});
      });
    });
  });
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
