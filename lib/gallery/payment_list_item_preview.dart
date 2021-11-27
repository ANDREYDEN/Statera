import 'package:flutter/material.dart';
import 'package:statera/data/models/payment.dart';
import 'package:statera/ui/widgets/listItems/payment_list_item.dart';
import 'package:statera/utils/theme.dart';

main() {
  runApp(ListCover());
}

class ListCover extends StatelessWidget {
  const ListCover({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: theme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      home: Scaffold(
        body: ListView(
          children: [
            PaymentListItem(
              payment: Payment(
                  groupId: 'asd',
                  payerId: 'a',
                  receiverId: 'b',
                  value: 123,
                  timeCreated: DateTime.now()),
              receiverUid: 'a',
            ),
            PaymentListItem(
              payment: Payment(
                groupId: 'asd',
                payerId: 'a',
                receiverId: 'b',
                value: 123,
              ),
              receiverUid: 'b',
            ),
            PaymentListItem(
              payment: Payment(
                  groupId: 'asd',
                  payerId: 'a',
                  receiverId: 'b',
                  value: 123,
                  relatedExpense: PaymentExpenseInfo(
                    id: 'dummy_expense',
                    name: 'Some Expense',
                  )),
              receiverUid: 'b',
            ),
            PaymentListItem(
              payment: Payment(
                groupId: 'asd',
                payerId: 'a',
                receiverId: 'b',
                value: 123,
                reason: "There was a malfunction in the system",
              ),
              receiverUid: 'a',
            ),
            PaymentListItem(
              payment: Payment(
                groupId: 'asd',
                payerId: 'a',
                receiverId: 'b',
                value: 123,
                reason: "There was a malfunction in the system",
              ),
              receiverUid: 'b',
            )
          ],
        ),
      ),
    );
  }
}
