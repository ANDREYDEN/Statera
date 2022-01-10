import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/expense_service.dart';
import 'package:statera/data/services/services.dart';
import 'package:equatable/equatable.dart';

part 'expense_state.dart';
part 'expense_event.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  ExpenseBloc() : super(ExpenseLoading());

  StreamSubscription? _expenseSubscription;

  void load(String? expenseId) {
    _expenseSubscription?.cancel();
    _expenseSubscription = ExpenseService.instance
        .expenseStream(expenseId)
        .listen((expense) => add(ExpenseChanged(expense)));
    on<UpdateRequested>(_handleUpdate);
    on<ExpenseChanged>(_handleExpenseChanged);
  }

  _handleUpdate(UpdateRequested event, Emitter<ExpenseState> emit) async {
    if (state is ExpenseLoaded) {
      final expense = (state as ExpenseLoaded).expense;

      if (expense.finalized) {
        return emit(ExpenseLoaded(
          expense: expense,
          updateFailure: ExpenseUpdateFailure.ExpenseFinalized,
        ));
      }

      final hash = expense.hashCode;
      final itemsHash = expense.itemsHash;
      await event.update.call(expense);

      final itemsChanged = itemsHash != expense.itemsHash;
      final expenseChanged = hash != expense.hashCode;

      if (!expenseChanged) return;

      // this is potentially vulnerable because other things might change together with items
      if (!itemsChanged && !expense.isAuthoredBy(event.issuer.uid)) {
        return emit(ExpenseLoaded(
          expense: expense,
          updateFailure: ExpenseUpdateFailure.ExpenseRestricted,
        ));
      }

      ExpenseService.instance.updateExpense(expense);
    }
  }

  _handleExpenseChanged(ExpenseChanged event, Emitter<ExpenseState> emit) {
    emit(event.expense == null
        ? ExpenseError(error: Exception('expense does not exist'))
        : ExpenseLoaded(expense: event.expense!));
  }

  @override
  Future<void> close() {
    _expenseSubscription?.cancel();
    return super.close();
  }
}
