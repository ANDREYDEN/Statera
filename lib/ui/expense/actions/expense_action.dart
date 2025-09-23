import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/expense/expense_bloc.dart';
import 'package:statera/business_logic/expenses/expenses_cubit.dart';
import 'package:statera/business_logic/layout/layout_state.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/ui/expense/dialogs/expense_dialogs.dart';
import 'package:statera/ui/widgets/dialogs/dialogs.dart';
import 'package:statera/ui/widgets/entity_action.dart';
import 'package:statera/utils/utils.dart';

part 'revert_expense_action.dart';
part 'finalize_expense_action.dart';
part 'delete_expense_action.dart';
part 'share_expense_action.dart';
part 'settings_expense_action.dart';
part 'edit_expense_action.dart';

abstract class ExpenseAction extends EntityAction {
  final Expense expense;

  ExpenseAction(this.expense);
}
