part of 'expense_bloc.dart';

enum ExpenseUpdateFailure { ExpenseFinalized, ExpenseRestricted }

abstract class ExpenseState {
  ExpenseState();
}

class ExpenseLoading extends ExpenseState {
  ExpenseLoading() : super();
}

class ExpenseLoaded extends ExpenseState {
  Expense expense;

  ExpenseUpdateFailure? updateFailure;

  ExpenseLoaded({required this.expense, this.updateFailure}) : super();
}

class ExpenseError extends ExpenseState {
  Object? error;
  ExpenseError({required this.error}) : super();
}
