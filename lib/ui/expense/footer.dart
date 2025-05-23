part of 'expense_details.dart';

class Footer extends StatelessWidget {
  const Footer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authBloc = context.read<AuthBloc>();

    return ExpenseBuilder(
      builder: (context, expense) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (expense.hasTax || expense.hasTip) ...[
              Divider(thickness: 3),
              FooterEntry(
                label: 'Subtotal',
                value: expense.getConfirmedSubTotalForUser(authBloc.uid),
              )
            ],
            if (expense.hasTax) ...[
              Divider(),
              FooterEntry(
                label: 'Tax (${(expense.settings.tax ?? 0) * 100}%)',
                value: expense.getConfirmedTaxForUser(authBloc.uid),
              ),
            ],
            if (expense.hasTip) ...[
              Divider(),
              FooterEntry(
                label: 'Tip (${(expense.settings.tip ?? 0) * 100}%)',
                value: expense.getConfirmedTipForUser(authBloc.uid),
              ),
            ],
            Divider(thickness: 3),
            FooterEntry(
              label: 'Total',
              value: expense.getConfirmedTotalForUser(authBloc.uid),
              bold: true,
            ),
            SizedBox(height: 10)
          ],
        );
      },
    );
  }
}
