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
  final Expense _expense;
  Expense get expense => Expense.from(_expense);

  ExpenseLoaded(this._expense) : super();
}

class ExpenseUpdating extends ExpenseLoaded {
  ExpenseUpdating({required Expense expense}) : super(expense);
}

class ExpenseError extends ExpenseState {
  Object? error;
  ExpenseError({required this.error}) : super();
}
