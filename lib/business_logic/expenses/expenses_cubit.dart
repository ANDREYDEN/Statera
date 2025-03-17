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
  late final GroupRepository _groupService;
  late final PaymentService _paymentService;
  StreamSubscription? _expensesSubscription;
  static const int expensesPerPage = 10;

  ExpensesCubit(
    String? groupId,
    String userId,
    UserExpenseRepository userExpenseRepository,
    ExpenseService expenseService,
    GroupRepository groupService,
    PaymentService paymentService,
  ) : super(ExpensesLoading()) {
    _userExpenseRepository = userExpenseRepository;
    _expenseService = expenseService;
    _groupService = groupService;
    _paymentService = paymentService;
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
      emit(loadedState.copyWith(
          expenses: updatedExpenses,
          processingExpenseIds: [
            ...loadedState.processingExpenseIds,
            expense.id
          ]));
      return await _groupService.addExpense(groupId, expense);
    }

    return null;
  }

  Future<void> deleteExpense(String expenseId) async {
    if (state case final ExpensesLoaded loadedState) {
      final newExpenses =
          loadedState.expenses.where((e) => e.id != expenseId).toList();
      emit(loadedState.copyWith(expenses: newExpenses));
      return await _expenseService.deleteExpense(expenseId);
    }
    return null;
  }

  Future<void> updateExpense(
    Expense updatedExpense, {
    bool persist = false,
  }) async {
    if (state case final ExpensesLoaded loadedState) {
      final newExpenses = loadedState.expenses
          .map((e) => e.id == updatedExpense.id ? updatedExpense : e)
          .toList();

      emit(ExpensesLoaded(expenses: newExpenses, stages: loadedState.stages));
      if (persist) {
        await _expenseService.updateExpense(updatedExpense);
      }
    }
  }

  Future<void> finalizeExpense(Expense expense, Group group) async {
    if (state is! ExpensesLoaded) return;

    emit(ExpensesLoading());

    // TODO: use transaction
    await _expenseService.finalizeExpense(expense.id);
    // Add expense payments from author to all assignees
    final payments = expense.assigneeUids
        .where((assigneeUid) => assigneeUid != expense.authorUid)
        .map(
      (assigneeUid) {
        return Payment.fromFinalizedExpense(
          expense: expense,
          receiverId: assigneeUid,
          oldAuthorBalance: group.balance[expense.authorUid]?[assigneeUid],
        );
      },
    );
    await Future.wait(payments.map(_paymentService.addPayment));

    for (var payment in payments) {
      group.payOffBalance(payment: payment);
    }
    await _groupService.saveGroup(group);
  }

  Future<void> revertExpense(Expense expense, Group group) async {
    if (state is! ExpensesLoaded) return;

    emit(ExpensesLoading());

    // TODO: use transaction
    await _expenseService.revertExpense(expense);
    // add expense payments from all assignees to author
    final payments = expense.assigneeUids
        .where((assigneeUid) => assigneeUid != expense.authorUid)
        .map(
          (assigneeUid) => Payment.fromRevertedExpense(
            expense: expense,
            payerId: assigneeUid,
            oldPayerBalance: group.balance[assigneeUid]?[expense.authorUid],
          ),
        );
    await Future.wait(payments.map(_paymentService.addPayment));

    for (var payment in payments) {
      group.payOffBalance(payment: payment);
    }
    await _groupService.saveGroup(group);
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
