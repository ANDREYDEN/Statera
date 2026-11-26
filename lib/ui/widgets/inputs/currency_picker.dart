import 'package:flutter/material.dart';
import 'package:statera/data/value_objects/currency.dart';

/// Result of [showCurrencyPicker]. A null [currency] means the user picked
/// the "automatic" option.
typedef CurrencySelection = ({Currency? currency});

/// A list tile that shows the [selected] currency and lets the user pick a
/// different one.
///
/// When [automaticLabel] is provided, the picker offers an extra option that
/// clears the selection.
class CurrencyPicker extends StatelessWidget {
  final String label;
  final Currency? selected;
  final String? automaticLabel;
  final ValueChanged<Currency?> onChanged;

  const CurrencyPicker({
    super.key,
    required this.label,
    required this.selected,
    required this.onChanged,
    this.automaticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final selectedCurrency = selected;
    final selectionText = selectedCurrency == null
        ? automaticLabel ?? ''
        : '${selectedCurrency.code} (${selectedCurrency.sign})';

    return ListTile(
      title: Text(label),
      trailing: Text(selectionText),
      onTap: () async {
        final selection = await showCurrencyPicker(
          context,
          selected: selected,
          automaticLabel: automaticLabel,
        );
        if (selection == null) return;

        onChanged(selection.currency);
      },
    );
  }
}

/// Shows a dialog with all supported currencies.
///
/// Returns null if the dialog was dismissed.
Future<CurrencySelection?> showCurrencyPicker(
  BuildContext context, {
  Currency? selected,
  String? automaticLabel,
}) {
  return showDialog<CurrencySelection>(
    context: context,
    builder: (context) => SimpleDialog(
      title: Text('Pick a currency'),
      children: [
        if (automaticLabel != null)
          _CurrencyOption(
            title: automaticLabel,
            isSelected: selected == null,
            onTap: () => Navigator.of(context).pop((currency: null)),
          ),
        for (final currency in Currency.all)
          _CurrencyOption(
            title: '${currency.code} - ${currency.name}',
            trailing: currency.sign,
            isSelected: currency.code == selected?.code,
            onTap: () => Navigator.of(context).pop((currency: currency)),
          ),
      ],
    ),
  );
}

class _CurrencyOption extends StatelessWidget {
  final String title;
  final String? trailing;
  final bool isSelected;
  final VoidCallback onTap;

  const _CurrencyOption({
    required this.title,
    required this.isSelected,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final trailingText = trailing;

    return ListTile(
      title: Text(title),
      trailing: trailingText == null ? null : Text(trailingText),
      selected: isSelected,
      onTap: onTap,
    );
  }
}
