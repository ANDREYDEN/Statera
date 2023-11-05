import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/data/enums/enums.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/utils/stream_extensions.dart';

part 'expenses_state.dart';

class UserExpensesCubit extends Cubit<ExpensesState> {
  late final String? _groupId;
  late final String _userId;
  late final UserExpenseRepository _userExpenseRepository;
  late final ExpenseService _expenseService;
  late final GroupService _groupService;
  StreamSubscription? _expensesSubscription;
  static const int expensesPerPage = 10;

  UserExpensesCubit(
    String? groupId,
    String userId,
    UserExpenseRepository userExpenseRepository,
    ExpenseService expenseService,
    GroupService groupService,
  ) : super(ExpensesLoading()) {
    _userExpenseRepository = userExpenseRepository;
    _expenseService = expenseService;
    _groupService = groupService;
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
    if (state case final ExpensesLoaded currentState) {
      if (currentState.allLoaded) return;

      emit(ExpensesProcessing.fromLoaded(currentState));
      print('loading more...');
      load(
        numberOfExpenses: currentState.expenses.length + expensesPerPage,
        expenseStages: currentState.stages,
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

  Future<void> deleteExpense(String expenseId) async {
    if (state is ExpensesLoaded) {
      emit(ExpensesLoading());
      return await _expenseService.deleteExpense(expenseId);
    }
    return null;
  }

  void selectExpenseStages(List<ExpenseStage> expenseStages) {
    if (state case final ExpensesLoaded currentState) {
      emit(ExpensesProcessing.fromLoaded(currentState));
      load(expenseStages: expenseStages);
    }
  }

  @override
  Future<void> close() {
    _expensesSubscription?.cancel();
    return super.close();
  }
}
