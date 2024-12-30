import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/services.dart';

part 'expense_event.dart';
part 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final ExpenseService _expenseService;
  Timer? updateTimer;

  ExpenseBloc(this._expenseService) : super(ExpenseNotSelected()) {
    on<_LoadRequested>((_, emit) => emit(ExpenseLoading()));
    on<_UnloadRequested>((_, emit) => emit(ExpenseNotSelected()));
    on<UpdateRequested>(_handleUpdate);
    on<_FinishedUpdating>(
      (event, emit) => emit(ExpenseLoaded(expense: event.expense)),
    );
    on<_UpdateErrorOccurred>(
      (event, emit) => emit(ExpenseError(error: event.error)),
    );
    on<_ExpenseUpdatedFromDB>(_handleExpenseUpdatedFromDB);
  }

  StreamSubscription? _expenseSubscription;

  void load(String? expenseId) {
    add(_LoadRequested());
    _expenseSubscription?.cancel();
    _expenseSubscription = _expenseService
        .expenseStream(expenseId)
        .listen((expense) => add(_ExpenseUpdatedFromDB(expense)));
  }

  void unload() {
    add(_UnloadRequested());
    _expenseSubscription?.cancel();
  }

  Future<void> _handleUpdate(
    UpdateRequested event,
    Emitter<ExpenseState> emit,
  ) async {
    if (state is! ExpenseLoaded) return;

    final expense = (state as ExpenseLoaded).expense;
    emit(ExpenseUpdating(expense: expense));

    final wasCompleted = expense.completed;
    await event.update(expense);

    updateTimer?.cancel();
    updateTimer = Timer(Duration(seconds: 2), () async {
      try {
        await _expenseService.updateExpense(expense);
      } catch (e) {
        print(e);
        add(_UpdateErrorOccurred(e));
        throw e;
      } finally {}

      add(_FinishedUpdating(expense));
    });
  }

  void _handleExpenseUpdatedFromDB(
    _ExpenseUpdatedFromDB event,
    Emitter<ExpenseState> emit,
  ) {
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
