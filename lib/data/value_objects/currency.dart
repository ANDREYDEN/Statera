import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';

/// A currency identified by its ISO 4217 [code].
///
/// The [sign] is stored alongside the code on every Firestore record so that
/// prices can be rendered without looking anything up.
class Currency extends Equatable {
  final String code;
  final String sign;
  final String name;

  const Currency({required this.code, required this.sign, required this.name});

  static const usd = Currency(code: 'USD', sign: '\$', name: 'US Dollar');

  /// Currencies supported by the exchange rate source (freecurrencyapi.com).
  static const List<Currency> all = [
    usd,
    Currency(code: 'EUR', sign: '€', name: 'Euro'),
    Currency(code: 'GBP', sign: '£', name: 'British Pound'),
    Currency(code: 'CAD', sign: 'CA\$', name: 'Canadian Dollar'),
    Currency(code: 'AUD', sign: 'A\$', name: 'Australian Dollar'),
    Currency(code: 'NZD', sign: 'NZ\$', name: 'New Zealand Dollar'),
    Currency(code: 'JPY', sign: '¥', name: 'Japanese Yen'),
    Currency(code: 'CNY', sign: 'CN¥', name: 'Chinese Yuan'),
    Currency(code: 'HKD', sign: 'HK\$', name: 'Hong Kong Dollar'),
    Currency(code: 'SGD', sign: 'S\$', name: 'Singapore Dollar'),
    Currency(code: 'KRW', sign: '₩', name: 'South Korean Won'),
    Currency(code: 'INR', sign: '₹', name: 'Indian Rupee'),
    Currency(code: 'IDR', sign: 'Rp', name: 'Indonesian Rupiah'),
    Currency(code: 'MYR', sign: 'RM', name: 'Malaysian Ringgit'),
    Currency(code: 'PHP', sign: '₱', name: 'Philippine Peso'),
    Currency(code: 'THB', sign: '฿', name: 'Thai Baht'),
    Currency(code: 'ILS', sign: '₪', name: 'Israeli New Shekel'),
    Currency(code: 'TRY', sign: '₺', name: 'Turkish Lira'),
    Currency(code: 'RUB', sign: '₽', name: 'Russian Ruble'),
    Currency(code: 'PLN', sign: 'zł', name: 'Polish Zloty'),
    Currency(code: 'CZK', sign: 'Kč', name: 'Czech Koruna'),
    Currency(code: 'HUF', sign: 'Ft', name: 'Hungarian Forint'),
    Currency(code: 'RON', sign: 'lei', name: 'Romanian Leu'),
    Currency(code: 'BGN', sign: 'лв', name: 'Bulgarian Lev'),
    Currency(code: 'CHF', sign: 'CHF', name: 'Swiss Franc'),
    Currency(code: 'SEK', sign: 'kr', name: 'Swedish Krona'),
    Currency(code: 'NOK', sign: 'kr', name: 'Norwegian Krone'),
    Currency(code: 'DKK', sign: 'kr', name: 'Danish Krone'),
    Currency(code: 'ISK', sign: 'kr', name: 'Icelandic Krona'),
    Currency(code: 'BRL', sign: 'R\$', name: 'Brazilian Real'),
    Currency(code: 'MXN', sign: 'MX\$', name: 'Mexican Peso'),
    Currency(code: 'ZAR', sign: 'R', name: 'South African Rand'),
  ];

  /// Finds a supported currency by its ISO [code], defaulting to [usd].
  static Currency fromCode(String? code) {
    return all.firstWhereOrNull((currency) => currency.code == code) ?? usd;
  }

  /// Best-effort mapping of a legacy, free-text currency sign to a currency.
  static Currency fromSign(String? sign) {
    return all.firstWhereOrNull((currency) => currency.sign == sign) ?? usd;
  }

  /// Restores a currency from the `currencyCode` and `currencySign` fields of
  /// a Firestore record.
  ///
  /// Records created before currency codes were introduced only have a sign.
  /// In that case the code is inferred from the sign, while the original sign
  /// is kept for display.
  static Currency fromFirestore({String? code, String? sign}) {
    final hasCode = code != null;
    final currency = hasCode ? fromCode(code) : fromSign(sign);
    final resolvedCode = code ?? currency.code;

    return Currency(
      code: resolvedCode,
      sign: sign ?? currency.sign,
      name: currency.name,
    );
  }

  String render(double value) => '$sign${value.toStringAsFixed(2)}';

  @override
  List<Object?> get props => [code, sign];

  @override
  String toString() => '$code ($sign)';
}
