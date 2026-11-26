import 'package:flutter_test/flutter_test.dart';
import 'package:statera/data/value_objects/currency.dart';

void main() {
  group('Currency', () {
    test('finds a currency by code', () {
      expect(Currency.fromCode('EUR').sign, '€');
    });

    test('defaults to USD for unknown or missing codes', () {
      expect(Currency.fromCode('XXX'), Currency.usd);
      expect(Currency.fromCode(null), Currency.usd);
    });

    test('maps legacy signs to currencies', () {
      expect(Currency.fromSign('£').code, 'GBP');
      expect(Currency.fromSign('\$').code, 'USD');
      expect(Currency.fromSign('?').code, 'USD');
    });

    test('restores a currency from a record with a code and a sign', () {
      final currency = Currency.fromFirestore(code: 'EUR', sign: '€');

      expect(currency.code, 'EUR');
      expect(currency.sign, '€');
      expect(currency.name, 'Euro');
    });

    test('restores a legacy record that only has a sign', () {
      final currency = Currency.fromFirestore(sign: '€');

      expect(currency.code, 'EUR');
      expect(currency.sign, '€');
    });

    test('keeps a custom legacy sign for display', () {
      final currency = Currency.fromFirestore(sign: 'X');

      expect(currency.code, 'USD');
      expect(currency.sign, 'X');
    });

    test('defaults to USD for records without currency info', () {
      expect(Currency.fromFirestore(), Currency.usd);
    });

    test('renders a price', () {
      expect(Currency.fromCode('EUR').render(3.5), '€3.50');
    });
  });
}
