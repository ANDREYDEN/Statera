import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/data/value_objects/aggregated_debt.dart';
import 'package:statera/data/value_objects/currency.dart';
import 'package:statera/data/value_objects/exchange_rates.dart';

/// Sums debt [parts] from several groups into a single currency.
///
/// Exchange rates are only read when the parts are in different currencies.
/// The [builder] receives null while [parts] or the rates are loading.
/// [errorBuilder] is used when the debt can't be converted.
class AggregatedDebtBuilder extends StatelessWidget {
  final List<DebtPart>? parts;
  final String? preferredCurrencyCode;
  final Widget Function(BuildContext context, AggregatedDebt? debt) builder;
  final WidgetBuilder errorBuilder;

  const AggregatedDebtBuilder({
    super.key,
    required this.parts,
    required this.builder,
    required this.errorBuilder,
    this.preferredCurrencyCode,
  });

  @override
  Widget build(BuildContext context) {
    final parts = this.parts;
    if (parts == null) return builder(context, null);

    final currency = AggregatedDebt.resolveCurrency(
      parts,
      preferredCurrencyCode: preferredCurrencyCode,
    );
    if (!AggregatedDebt.needsConversion(parts, currency)) {
      return builder(context, AggregatedDebt.from(parts, currency: currency));
    }

    return FutureBuilder<ExchangeRates>(
      future: context.read<CurrencyService>().getLatestRates(),
      builder: (context, snap) {
        final rates = snap.data;
        if (snap.hasError) return _buildError(context, snap.error!);
        if (rates == null) return builder(context, null);

        return _buildConverted(context, parts, currency, rates);
      },
    );
  }

  Widget _buildConverted(
    BuildContext context,
    List<DebtPart> parts,
    Currency currency,
    ExchangeRates rates,
  ) {
    try {
      final debt = AggregatedDebt.from(
        parts,
        currency: currency,
        rates: rates,
      );
      return builder(context, debt);
    } on ArgumentError catch (error) {
      return _buildError(context, error);
    }
  }

  Widget _buildError(BuildContext context, Object error) {
    context.read<ErrorService>().recordError(
      error,
      reason: 'Failed to convert aggregated debt',
    );
    return errorBuilder(context);
  }
}
