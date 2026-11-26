import 'package:flutter_test/flutter_test.dart';
import 'package:statera/data/value_objects/aggregated_debt.dart';
import 'package:statera/data/value_objects/currency.dart';
import 'package:statera/data/value_objects/exchange_rates.dart';

final eur = Currency.fromCode('EUR');
const rates = ExchangeRates(base: 'USD', rates: {'EUR': 0.5});

void main() {
  group('AggregatedDebt', () {
    group('resolveCurrency', () {
      test('uses the preferred currency if there is one', () {
        final currency = AggregatedDebt.resolveCurrency([
          (currency: Currency.usd, amount: 10),
        ], preferredCurrencyCode: 'EUR');

        expect(currency, eur);
      });

      test('uses the most common currency otherwise', () {
        final currency = AggregatedDebt.resolveCurrency([
          (currency: Currency.usd, amount: 10),
          (currency: eur, amount: 10),
          (currency: eur, amount: 10),
        ]);

        expect(currency, eur);
      });

      test('defaults to USD without any debt', () {
        expect(AggregatedDebt.resolveCurrency([]), Currency.usd);
      });
    });

    group('needsConversion', () {
      test('is false when all debt is in the target currency', () {
        final parts = [(currency: eur, amount: 10.0)];

        expect(AggregatedDebt.needsConversion(parts, eur), isFalse);
      });

      test('ignores settled debt in other currencies', () {
        final parts = [
          (currency: eur, amount: 10.0),
          (currency: Currency.usd, amount: 0.0),
        ];

        expect(AggregatedDebt.needsConversion(parts, eur), isFalse);
      });

      test('is true when some debt is in another currency', () {
        final parts = [
          (currency: eur, amount: 10.0),
          (currency: Currency.usd, amount: 5.0),
        ];

        expect(AggregatedDebt.needsConversion(parts, eur), isTrue);
      });
    });

    group('from', () {
      test('sums debt in a single currency without rates', () {
        final debt = AggregatedDebt.from([
          (currency: eur, amount: 10),
          (currency: eur, amount: -4),
        ], currency: eur);

        expect(debt.amount, 6);
        expect(debt.isConverted, isFalse);
        expect(debt.render(), '€6.00');
      });

      test('converts debt in other currencies', () {
        final debt = AggregatedDebt.from(
          [
            (currency: eur, amount: 10),
            (currency: Currency.usd, amount: 10),
          ],
          currency: eur,
          rates: rates,
        );

        expect(debt.amount, 15);
        expect(debt.isConverted, isTrue);
        expect(debt.render(), '≈€15.00');
      });

      test('requires rates to convert debt', () {
        expect(
          () => AggregatedDebt.from([
            (currency: Currency.usd, amount: 10),
          ], currency: eur),
          throwsArgumentError,
        );
      });

      test('renders the absolute amount', () {
        final debt = AggregatedDebt.from([
          (currency: eur, amount: -3),
        ], currency: eur);

        expect(debt.render(absolute: true), '€3.00');
      });
    });
  });
}
