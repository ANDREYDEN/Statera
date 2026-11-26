import 'package:collection/collection.dart';
import 'package:statera/data/value_objects/currency.dart';
import 'package:statera/data/value_objects/exchange_rates.dart';

/// Debt in a single group, in the currency of that group.
typedef DebtPart = ({Currency currency, double amount});

/// Debt across several groups, expressed in a single [currency].
class AggregatedDebt {
  final Currency currency;
  final double amount;

  /// Whether some of the debt was converted from another currency, which
  /// makes [amount] approximate.
  final bool isConverted;

  const AggregatedDebt({
    required this.currency,
    required this.amount,
    this.isConverted = false,
  });

  /// Uses the [preferredCurrencyCode] if the user has one, otherwise the
  /// currency that most of the [parts] are in.
  static Currency resolveCurrency(
    List<DebtPart> parts, {
    String? preferredCurrencyCode,
  }) {
    if (preferredCurrencyCode != null) {
      return Currency.fromCode(preferredCurrencyCode);
    }
    if (parts.isEmpty) return Currency.usd;

    final partsByCode = groupBy(parts, (DebtPart part) => part.currency.code);
    final mostCommonParts = partsByCode.values.reduce(
      (best, current) => current.length > best.length ? current : best,
    );
    return mostCommonParts.first.currency;
  }

  /// Whether any non-zero part is in a currency other than [currency].
  static bool needsConversion(List<DebtPart> parts, Currency currency) {
    return parts.any(
      (part) => part.amount != 0 && part.currency.code != currency.code,
    );
  }

  /// Sums the [parts] in [currency], converting them with [rates] if needed.
  static AggregatedDebt from(
    List<DebtPart> parts, {
    required Currency currency,
    ExchangeRates? rates,
  }) {
    final isConverted = needsConversion(parts, currency);
    if (isConverted && rates == null) {
      throw ArgumentError('Exchange rates are required to convert the debt');
    }

    final amount = parts.fold(0.0, (total, part) {
      final convertedAmount = isConverted
          ? rates!.convert(
              part.amount,
              from: part.currency.code,
              to: currency.code,
            )
          : part.amount;
      return total + convertedAmount;
    });

    return AggregatedDebt(
      currency: currency,
      amount: amount,
      isConverted: isConverted,
    );
  }

  /// Renders the amount, prefixed with "≈" if it was converted.
  String render({bool absolute = false}) {
    final prefix = isConverted ? '≈' : '';
    final value = absolute ? amount.abs() : amount;
    return '$prefix${currency.render(value)}';
  }
}
