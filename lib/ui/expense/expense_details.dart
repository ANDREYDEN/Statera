import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/expense/expense_bloc.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/business_logic/layout/layout_state.dart';
import 'package:statera/ui/expense/actions/expense_actions_button.dart';
import 'package:statera/ui/expense/assignee_list.dart';
import 'package:statera/ui/expense/expense_builder.dart';
import 'package:statera/ui/expense/header/expense_price.dart';
import 'package:statera/ui/expense/items/items_list.dart';
import 'package:statera/ui/group/group_builder.dart';
import 'package:statera/ui/widgets/dialogs/dialogs.dart';
import 'package:statera/ui/widgets/list_empty.dart';
import 'package:statera/ui/widgets/price_text.dart';
import 'package:statera/ui/widgets/user_avatar.dart';
import 'package:statera/utils/utils.dart';

import 'dialogs/expense_dialogs.dart';

part 'footer.dart';
part 'footer_entry.dart';
part 'header/header.dart';

class ExpenseDetails extends StatelessWidget {
  const ExpenseDetails({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authBloc = context.read<AuthBloc>();
    final isWide = context.select((LayoutState state) => state.isWide);

    return ExpenseBuilder(
      loadingWidget: ListEmpty(text: 'Pick an expense first'),
      onError: (context, expenseErrorState) {
        showErrorSnackBar(context, 'Error occured: ${expenseErrorState.error}');
      },
      builder: (context, expense) {
        final expenseCanBeUpdated = expense.canBeUpdatedBy(authBloc.uid);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isWide)
              Align(
                alignment: Alignment.centerRight,
                child: ExpenseActionsButton(expense: expense),
              ),
            Header(),
            if (expense.hasNoItems &&
                expenseCanBeUpdated &&
                defaultTargetPlatform != TargetPlatform.macOS)
              ElevatedButton.icon(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => ReceiptScanDialog(expense: expense),
                ),
                label: Text('Upload receipt'),
                icon: Icon(Icons.photo_camera),
              ),
            Flexible(child: ItemsList()),
            if (expense.items.isNotEmpty) Footer(),
          ],
        );
      },
    );
  }
}
