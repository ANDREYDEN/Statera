part of 'expense_details.dart';

class FooterEntry extends StatelessWidget {
  final String label;
  final double value;
  final bool bold;

  const FooterEntry({
    Key? key,
    required this.label,
    required this.value,
    this.bold = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.titleSmall!.copyWith(
          fontWeight: bold ? FontWeight.bold : null,
        );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: textStyle),
          PriceText(value: value, textStyle: textStyle),
        ],
      ),
    );
  }
}
