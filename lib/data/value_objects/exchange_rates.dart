/// Exchange rates relative to a [base] currency, as stored in
/// `currencies/latest` by the `updateCurrencies` Firebase Function.
class ExchangeRates {
  final String base;

  /// Amount of each currency that equals one unit of [base].
  final Map<String, double> rates;

  const ExchangeRates({required this.base, required this.rates});

  /// Converts [value] between two currencies via the [base] currency.
  ///
  /// Throws an [ArgumentError] if a rate for either currency is missing.
  double convert(double value, {required String from, required String to}) {
    if (from == to) return value;

    return value / _getRate(from) * _getRate(to);
  }

  double _getRate(String code) {
    if (code == base) return 1;

    final rate = rates[code];
    if (rate == null) throw ArgumentError('No exchange rate for $code');

    return rate;
  }

  static ExchangeRates fromFirestore(Map<String, dynamic> data) {
    final rates = Map<String, dynamic>.from(data['rates'] ?? {});

    return ExchangeRates(
      base: data['base'] ?? 'USD',
      rates: rates.map((code, rate) => MapEntry(code, (rate as num).toDouble())),
    );
  }
}
