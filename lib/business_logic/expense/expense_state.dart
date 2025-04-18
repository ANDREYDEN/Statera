part of 'expense_bloc.dart';

abstract class ExpenseState extends Equatable {
  ExpenseState();
}

class ExpenseNotSelected extends ExpenseState {
  ExpenseNotSelected() : super();

  @override
  List<Object?> get props => [];
}

class ExpenseLoading extends ExpenseState {
  ExpenseLoading() : super();

  @override
  List<Object?> get props => [];
}

class ExpenseLoaded extends ExpenseState {
  final Expense _expense;
  Expense get expense => Expense.from(_expense);

  ExpenseLoaded(this._expense) : super();

  @override
  List<Object?> get props => [_expense];
}

class ExpenseUpdating extends ExpenseLoaded {
  ExpenseUpdating({required Expense expense}) : super(expense);
}

class ExpenseError extends ExpenseState {
  final Object? error;
  ExpenseError({required this.error}) : super();

  @override
  List<Object?> get props => [error.toString()];
}
