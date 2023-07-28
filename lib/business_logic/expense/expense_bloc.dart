import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/callables.dart';
import 'package:statera/data/services/expense_service.dart';
import 'package:statera/data/services/services.dart';

part 'expense_event.dart';
part 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final ExpenseService _expenseService;

  ExpenseBloc(this._expenseService) : super(ExpenseLoading()) {
    on<UpdateRequested>(_handleUpdate);
    on<ExpenseChanged>(_handleExpenseChanged);
  }

  StreamSubscription? _expenseSubscription;

  void load(String? expenseId) {
    _expenseSubscription?.cancel();
    _expenseSubscription = _expenseService
        .expenseStream(expenseId)
        .listen((expense) => add(ExpenseChanged(expense)));
  }

  _handleUpdate(UpdateRequested event, Emitter<ExpenseState> emit) async {
    if (state is ExpenseLoaded) {
      final expense = (state as ExpenseLoaded).expense;

      final wasCompleted = expense.completed;
      await event.update.call(expense);
      await _expenseService.updateExpense(expense);

      if (!wasCompleted &&
          expense.completed &&
          event.issuerUid != expense.authorUid) {
        Callables.notifyWhenExpenseCompleted(expenseId: expense.id);
      }
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
