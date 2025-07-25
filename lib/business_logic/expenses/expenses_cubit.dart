import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/data/enums/enums.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/utils/stream_extensions.dart';

part 'expenses_state.dart';

class ExpensesCubit extends Cubit<ExpensesState> {
  late final String? _groupId;
  late final String _userId;
  late final UserExpenseRepository _userExpenseRepository;
  late final ExpenseService _expenseService;
  late final GroupRepository _groupRepository;
  late final CoordinationRepository _coordinationRepository;
  StreamSubscription? _expensesSubscription;
  static const int expensesPerPage = 10;

  ExpensesCubit(
    String? groupId,
    String userId,
    UserExpenseRepository userExpenseRepository,
    ExpenseService expenseService,
    GroupRepository groupRepository,
    CoordinationRepository coordinationRepository,
  ) : super(ExpensesLoading()) {
    _userExpenseRepository = userExpenseRepository;
    _expenseService = expenseService;
    _groupRepository = groupRepository;
    _coordinationRepository = coordinationRepository;
    _groupId = groupId;
    _userId = userId;
  }

  void load({
    int numberOfExpenses = expensesPerPage,
    List<ExpenseStage>? expenseStages,
  }) {
    final selectedStages = expenseStages ?? ExpenseStage.values;
    final stageValues = selectedStages.map((e) => e.index).toList();
    _expensesSubscription?.cancel();
    _expensesSubscription = _userExpenseRepository
        .listenForRelatedExpenses(
          _userId,
          _groupId,
          quantity: numberOfExpenses,
          stages: stageValues,
        )
        .map((expenses) => ExpensesLoaded(
              expenses: expenses,
              stages: expenseStages ?? ExpenseStage.values,
              allLoaded: expenses.length < numberOfExpenses,
            ))
        .throttle(Duration(milliseconds: 200))
        .listen(emit, onError: (error) => emit(ExpensesError(error: error)));
  }

  void loadMore() async {
    if (state case final ExpensesLoaded loadedState) {
      if (loadedState.allLoaded) return;

      emit(loadedState.copyWith(loadingMore: true));
      load(
        numberOfExpenses: loadedState.expenses.length + expensesPerPage,
        expenseStages: loadedState.stages,
      );
    }
  }

  Future<String?> addExpense(Expense expense, String? groupId) async {
    if (state case ExpensesLoaded loadedState) {
      final updatedExpenses = [expense, ...loadedState.expenses];
      emit(loadedState.copyWith(expenses: updatedExpenses)
        ..startProcessing(expense.id));
      return await _groupRepository.addExpense(groupId, expense);
    }

    return null;
  }

  Future<void> deleteExpense(String expenseId) async {
    final loadedState = state;
    if (loadedState is! ExpensesLoaded) return;

    final newExpenses =
        loadedState.expenses.where((e) => e.id != expenseId).toList();
    emit(loadedState.copyWith(expenses: newExpenses));
    try {
      await _expenseService.deleteExpense(expenseId);
    } catch (e) {
      emit(loadedState.copyWith(error: e, errorActionName: 'deleting'));
    }
  }

  Future<void> updateExpense(
    Expense updatedExpense, {
    bool persist = false,
  }) async {
    final loadedState = state;
    if (loadedState is! ExpensesLoaded) return;

    final newExpenses = loadedState.expenses
        .map((e) => e.id == updatedExpense.id ? updatedExpense : e)
        .toList();

    emit(loadedState.copyWith(expenses: newExpenses));
    if (persist) {
      try {
        await _expenseService.updateExpense(updatedExpense);
      } catch (e) {
        emit(loadedState.copyWith(error: e, errorActionName: 'updating'));
      }
    }
  }

  Future<void> finalizeExpense(Expense expense) async {
    if (state case ExpensesLoaded loadedState) {
      emit(loadedState.copyWith()..startProcessing(expense.id));

      await _coordinationRepository.finalizeExpense(expense.id);
    }
  }

  Future<void> revertExpense(Expense expense) async {
    if (state case ExpensesLoaded loadedState) {
      emit(loadedState.copyWith()..startProcessing(expense.id));

      await _coordinationRepository.revertExpense(expense.id);
    }
  }

  void selectExpenseStages(List<ExpenseStage> expenseStages) {
    if (state is! ExpensesLoaded) return;

    emit(ExpensesLoading());
    load(expenseStages: expenseStages);
  }

  @override
  Future<void> close() {
    _expensesSubscription?.cancel();
    return super.close();
  }
}
