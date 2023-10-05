import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/utils/stream_extensions.dart';

part 'expenses_state.dart';

class ExpensesCubit extends Cubit<ExpensesState> {
  late final ExpenseService _expenseService;
  late final GroupService _groupService;
  StreamSubscription? _expensesSubscription;
  static const int expensesPerPage = 10;

  ExpensesCubit(ExpenseService expenseService, GroupService groupService)
      : super(ExpensesLoading()) {
    _expenseService = expenseService;
    _groupService = groupService;
  }

  void load(
    String userId,
    String? groupId, {
    int numberOfExpenses = expensesPerPage,
  }) {
    _expensesSubscription?.cancel();
    _expensesSubscription = _expenseService
        .listenForRelatedExpenses(userId, groupId, quantity: numberOfExpenses)
        .map((expenses) {
          return ExpensesLoaded(
            expenses: expenses,
            stages: Expense.expenseStages(userId),
            allLoaded: expenses.length < numberOfExpenses,
          );
        })
        .throttle(Duration(milliseconds: 200))
        .listen(emit, onError: (error) => emit(ExpensesError(error: error)));
  }

  void loadMore(String userId) {
    final currentState = state;
    if (currentState is ExpensesLoaded) {
      if (currentState.allLoaded) return;

      final groupId = currentState.expenses.first.groupId;
      print('loading more');
      load(
        userId,
        groupId,
        numberOfExpenses: currentState.expenses.length + expensesPerPage,
      );
    }
  }

  void updateExpense(Expense expense) async {
    if (state is ExpensesLoaded) {
      emit(ExpensesProcessing.fromLoaded((state as ExpensesLoaded)));
      await _expenseService.updateExpense(expense);
    }
  }

  Future<String?> addExpense(Expense expense, String? groupId) async {
    if (state is ExpensesLoaded) {
      emit(ExpensesProcessing.fromLoaded((state as ExpensesLoaded)));
      return await _groupService.addExpense(groupId, expense);
    }
    return null;
  }

  deleteExpense(Expense expense) async {
    if (state is ExpensesLoaded) {
      emit(ExpensesLoading());
      return await _expenseService.deleteExpense(expense);
    }
    return null;
  }

  void selectExpenseStages(String uid, List<String> stageNames) {
    if (state is ExpensesLoaded) {
      final stages = Expense.expenseStages(uid)
          .where((es) => stageNames.contains(es.name))
          .toList();
      emit(ExpensesLoaded(
        expenses: (state as ExpensesLoaded).expenses,
        stages: stages,
      ));
    }
  }

  @override
  Future<void> close() {
    _expensesSubscription?.cancel();
    return super.close();
  }
}
