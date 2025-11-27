import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/expense/expense_bloc.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/business_logic/layout/layout_state.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/error_service.dart';
import 'package:statera/ui/expense/actions/expense_actions_button.dart';
import 'package:statera/ui/expense/assignee_list.dart';
import 'package:statera/ui/expense/expense_builder.dart';
import 'package:statera/ui/expense/expense_details_loading.dart';
import 'package:statera/ui/expense/header/expense_price.dart';
import 'package:statera/ui/expense/items/items_list.dart';
import 'package:statera/ui/expense/buttons/new_item_button.dart';
import 'package:statera/ui/group/group_builder.dart';
import 'package:statera/ui/widgets/dialogs/dialogs.dart';
import 'package:statera/ui/widgets/loader.dart';
import 'package:statera/ui/widgets/price_text.dart';
import 'package:statera/ui/widgets/user_avatar.dart';
import 'package:statera/utils/utils.dart';

part 'footer.dart';
part 'footer_entry.dart';
part 'header/header.dart';

class ExpenseDetails extends StatelessWidget {
  const ExpenseDetails({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isWide = context.select((LayoutState state) => state.isWide);

    return ExpenseBuilder(
      onUpdateError: (context, error) {
        final simplifiedError =
            'Unexpected error occurred when updating the expense. Please try again.';
        print(error);
        showErrorSnackBar(context, simplifiedError);
        final errorService = context.read<ErrorService>();
        errorService.recordError(error, reason: simplifiedError);
      },
      loadingWidget: Column(
        children: [SizedBox(height: 34), ExpenseDetailsLoading()],
      ),
      builder: (context, expense) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isWide)
              Align(
                alignment: Alignment.centerRight,
                child: ExpenseActionsButton(expense: expense),
              ),
            Header(),
            if (expense.hasItems && isWide) NewItemButton(),
            SizedBox(height: 10),
            Flexible(child: ItemsList()),
            if (expense.hasItems) Footer(),
          ],
        );
      },
    );
  }
}
