import 'package:flutter_test/flutter_test.dart';
import 'package:statera/data/value_objects/exchange_rates.dart';

const rates = ExchangeRates(base: 'USD', rates: {'EUR': 0.5, 'GBP': 0.25});

void main() {
  group('ExchangeRates', () {
    test('converts from the base currency', () {
      expect(rates.convert(10, from: 'USD', to: 'EUR'), 5);
    });

    test('converts to the base currency', () {
      expect(rates.convert(10, from: 'EUR', to: 'USD'), 20);
    });

    test('converts between two non-base currencies', () {
      expect(rates.convert(10, from: 'EUR', to: 'GBP'), 5);
    });

    test('does not change the value for the same currency', () {
      expect(rates.convert(10, from: 'JPY', to: 'JPY'), 10);
    });

    test('throws when a rate is missing', () {
      expect(
        () => rates.convert(10, from: 'JPY', to: 'USD'),
        throwsArgumentError,
      );
    });

    test('parses integer rates from Firestore', () {
      final parsed = ExchangeRates.fromFirestore({
        'base': 'USD',
        'rates': {'JPY': 150, 'EUR': 0.9},
      });

      expect(parsed.rates, {'JPY': 150.0, 'EUR': 0.9});
    });
  });
}
