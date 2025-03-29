import 'dart:async';

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
  Timer? _updateTimer;
  final void Function(Expense)? onExpenseUpdated;

  ExpenseBloc(
    this._expenseService,
    this._coordinationRepository, {
    this.onExpenseUpdated,
  }) : super(ExpenseNotSelected()) {
    on<_LoadRequested>((_, emit) => emit(ExpenseLoading()));
    on<_UnloadRequested>((_, emit) => emit(ExpenseNotSelected()));
    on<UpdateRequested>(_handleUpdate);
    on<_FinishedUpdating>(
      (event, emit) => emit(ExpenseLoaded(event.expense)),
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

    final oldExpense = (state as ExpenseLoaded).expense;
    final newExpense = event.updatedExpense;

    if (newExpense == oldExpense) return;

    onExpenseUpdated?.call(newExpense);
    emit(ExpenseUpdating(expense: newExpense));
    _updateTimer?.cancel();
    _updateTimer = Timer(kExpenseUpdateDelay, () async {
      try {
        await _expenseService.updateExpense(newExpense);
      } catch (e) {
        print(e);
        add(_UpdateErrorOccurred(e));
        throw e;
      } finally {}

      add(_FinishedUpdating(newExpense));
    });
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
        : ExpenseLoaded(event.expense!));
    
  }

  @override
  Future<void> close() {
    _expenseSubscription?.cancel();
    return super.close();
  }
}
