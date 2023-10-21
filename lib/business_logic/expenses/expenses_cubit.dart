import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/utils/stream_extensions.dart';

part 'expenses_state.dart';

class ExpensesCubit extends Cubit<ExpensesState> {
  late final String? _groupId;
  late final ExpenseService _expenseService;
  late final GroupService _groupService;
  StreamSubscription? _expensesSubscription;
  static const int expensesPerPage = 10;

  ExpensesCubit(
      String? groupId, ExpenseService expenseService, GroupService groupService)
      : super(ExpensesLoading()) {
    _expenseService = expenseService;
    _groupService = groupService;
    _groupId = groupId;
  }

  void load(
    String userId, {
    int numberOfExpenses = expensesPerPage,
    List<String>? stageNames,
  }) {
    final allStages = Expense.expenseStages(userId);
    final stageIndexes = stageNames == null
        ? null
        : stageNames
            .map((stageName) =>
                allStages.indexWhere((stage) => stage.name == stageName))
            .toList();
    _expensesSubscription?.cancel();
    _expensesSubscription = _expenseService
        .listenForRelatedExpenses(
          userId,
          _groupId,
          quantity: numberOfExpenses,
          stageIndexes: stageIndexes,
        )
        .map((expenses) => ExpensesLoaded(
              expenses: expenses,
              stages: Expense.expenseStages(userId),
              allLoaded: expenses.length < numberOfExpenses,
            ))
        .throttle(Duration(milliseconds: 200))
        .listen(emit, onError: (error) => emit(ExpensesError(error: error)));
  }

  void loadMore(String userId) async {
    if (state case final ExpensesLoaded currentState) {
      if (currentState.allLoaded) return;

      emit(ExpensesProcessing.fromLoaded(currentState));
      await Future.delayed(Duration(seconds: 2));
      print('loading more...');
      load(
        userId,
        numberOfExpenses: currentState.expenses.length + expensesPerPage,
      );
    }
  }

  void updateExpense(Expense expense) async {
    if (state case final ExpensesLoaded currentState) {
      emit(ExpensesProcessing.fromLoaded(currentState));
      await _expenseService.updateExpense(expense);
    }
  }

  Future<String?> addExpense(Expense expense, String? groupId) async {
    if (state case final ExpensesLoaded currentState) {
      emit(ExpensesProcessing.fromLoaded(currentState));
      return await _groupService.addExpense(groupId, expense);
    }
    return null;
  }

  Future<void> deleteExpense(Expense expense) async {
    if (state is ExpensesLoaded) {
      emit(ExpensesLoading());
      return await _expenseService.deleteExpense(expense);
    }
    return null;
  }

  void selectExpenseStages(String uid, List<String> stageNames) {
    if (state case final ExpensesLoaded currentState) {
      emit(ExpensesProcessing.fromLoaded(currentState));
      load(uid, stageNames: stageNames);
    }
  }

  @override
  Future<void> close() {
    _expensesSubscription?.cancel();
    return super.close();
  }
}
