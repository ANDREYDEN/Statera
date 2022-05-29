import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/services.dart';

part 'expenses_state.dart';

class ExpensesCubit extends Cubit<ExpensesState> {
  late final ExpenseService _expenseService;
  late final GroupService _groupService;
  StreamSubscription? _expensesSubscription;

  ExpensesCubit(ExpenseService expenseService, GroupService groupService)
      : super(ExpensesLoading()) {
    _expenseService = expenseService;
    _groupService = groupService;
  }

  void load(String userId, String? groupId) {
    _expensesSubscription?.cancel();
    _expensesSubscription = _expenseService
        .listenForRelatedExpenses(userId, groupId)
        .map((expenses) {
      expenses.sort((firstExpense, secondExpense) {
        final expenseStages = Expense.expenseStages(userId);
        for (var stage in expenseStages) {
          if (firstExpense.isIn(stage) && secondExpense.isIn(stage)) {
            return firstExpense.wasEarlierThan(secondExpense) ? 1 : -1;
          }
          if (firstExpense.isIn(stage)) return -1;
          if (secondExpense.isIn(stage)) return 1;
        }

        return 0;
      });

      return ExpensesLoaded(expenses: expenses);
    }).listen(
      emit,
      onError: (error) {
        emit(ExpensesError(error: error));
      },
    );
  }

  void updateExpense(Expense expense) async {
    if (state is ExpensesLoaded) {
      emit(ExpensesProcessing(expenses: (state as ExpensesLoaded).expenses));
      await _expenseService.updateExpense(expense);
    }
  }

  Future<String?> addExpense(Expense expense, String? groupId) async {
    if (state is ExpensesLoaded) {
      emit(ExpensesProcessing(expenses: (state as ExpensesLoaded).expenses));
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
          .where((es) => stageNames.contains(es.name));
      emit(ExpensesLoaded(
        expenses: (state as ExpensesLoaded).expenses.where((expense) {
          return stages.any((stage) => expense.isIn(stage));
        }).toList(),
      ));
    }
  }

  @override
  Future<void> close() {
    _expensesSubscription?.cancel();
    return super.close();
  }
}
