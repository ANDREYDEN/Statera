part of 'expense_details.dart';

class Footer extends StatelessWidget {
  const Footer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveUid = context.watchEffectiveUid();

    return ExpenseBuilder(
      builder: (context, expense) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (expense.hasTax || expense.hasTip) ...[
              Divider(thickness: 3),
              FooterEntry(
                label: 'Subtotal',
                value: expense.getConfirmedSubtotalForUser(effectiveUid),
              ),
            ],
            if (expense.hasTax) ...[
              Divider(),
              FooterEntry(
                label: 'Tax (${(expense.settings.tax ?? 0) * 100}%)',
                value: expense.getConfirmedTaxForUser(effectiveUid),
              ),
            ],
            if (expense.hasTip) ...[
              Divider(),
              FooterEntry(
                label: 'Tip (${(expense.settings.tip ?? 0) * 100}%)',
                value: expense.getConfirmedTipForUser(effectiveUid),
              ),
            ],
            Divider(thickness: 3),
            FooterEntry(
              label: 'Your Total',
              value: expense.getConfirmedTotalForUser(effectiveUid),
              bold: true,
            ),
            SizedBox(height: 10),
          ],
        );
      },
    );
  }
}
