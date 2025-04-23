import 'dart:async';

import 'package:bloc_event_transformers/bloc_event_transformers.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/data/exceptions/exceptions.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/utils/utils.dart';

part 'expense_event.dart';
part 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final ExpenseService _expenseService;
  final CoordinationRepository _coordinationRepository;
  final void Function(Expense)? onExpenseUpdated;

  ExpenseBloc(
    this._expenseService,
    this._coordinationRepository, {
    this.onExpenseUpdated,
  }) : super(ExpenseNotSelected()) {
    on<_LoadRequested>((_, emit) => emit(ExpenseLoading()));
    on<_UnloadRequested>((_, emit) => emit(ExpenseNotSelected()));
    on<UpdateRequested>(_updateExpense);
    on<_ExpenseUpdated>(
      _persistExpense,
      transformer: debounce(kExpenseUpdateDelay),
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

  Future<void> _updateExpense(
    UpdateRequested event,
    Emitter<ExpenseState> emit,
  ) async {
    final loadedState = state;
    if (loadedState is! ExpenseLoaded) return;

    final oldExpense = loadedState.expense;
    final newExpense = event.updatedExpense;

    if (newExpense == oldExpense) return;

    emit(loadedState.copyWith(expense: newExpense, loading: true));
    add(_ExpenseUpdated(newExpense));
    onExpenseUpdated?.call(newExpense);
  }

  Future<void> _persistExpense(
    _ExpenseUpdated event,
    Emitter<ExpenseState> emit,
  ) async {
    final loadedState = state;
    if (loadedState is! ExpenseLoaded) return;

    final newExpense = event.expense;

    try {
      await _expenseService.updateExpense(newExpense);
      emit(ExpenseLoaded(
        newExpense,
        lastPersistedExpense: newExpense,
      ));
    } catch (e) {
      emit(ExpenseLoaded(
        loadedState.lastPersistedExpense,
        lastPersistedExpense: loadedState.lastPersistedExpense,
        error: e,
      ));
      onExpenseUpdated?.call(loadedState.lastPersistedExpense);
      rethrow;
    }
  }

  Future<void> revertExpense(Expense expense) async {
    if (state is! ExpenseLoaded) return;

    await _coordinationRepository.revertExpense(expense.id);
  }

  void _handleExpenseUpdatedFromDB(
    _ExpenseUpdatedFromDB event,
    Emitter<ExpenseState> emit,
  ) {
    emit(event.expense == null
        ? ExpenseError(error: EntityNotFoundException<Expense>(null))
        : ExpenseLoaded(event.expense!, lastPersistedExpense: event.expense!));
  }

  @override
  Future<void> close() {
    _expenseSubscription?.cancel();
    return super.close();
  }
}
