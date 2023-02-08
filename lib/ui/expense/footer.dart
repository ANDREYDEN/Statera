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
            Divider(thickness: 3),
            if (expense.hasTax) ...[
              FooterEntry(
                label: 'Subtotal',
                value: expense.getConfirmedSubTotalForUser(authBloc.uid),
              ),
              Divider(),
              FooterEntry(
                label: 'Tax',
                value: expense.getConfirmedTaxForUser(authBloc.uid),
              ),
              Divider(thickness: 3),
            ],
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
