part of 'expense_bloc.dart';

abstract class ExpenseState {
  ExpenseState();
}

class ExpenseNotSelected extends ExpenseState {
  ExpenseNotSelected() : super();
}

class ExpenseLoading extends ExpenseState {
  ExpenseLoading() : super();
}

class ExpenseLoaded extends ExpenseState {
  Expense expense;

  ExpenseLoaded({required this.expense}) : super();
}

class ExpenseUpdating extends ExpenseLoaded {
  ExpenseUpdating({required Expense expense}) : super(expense: expense);
}

class ExpenseError extends ExpenseState {
  Object? error;
  ExpenseError({required this.error}) : super();
}
