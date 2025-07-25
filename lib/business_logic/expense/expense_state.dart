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
  final Expense lastPersistedExpense;
  final Object? error;
  final bool loading;

  // TODO: copying expenses everytime is costly, expenses ahould be immutable
  Expense get expense => Expense.from(_expense);

  ExpenseLoaded(Expense expense,
      {Expense? lastPersistedExpense, this.error, this.loading = false})
      : _expense = expense,
        lastPersistedExpense = lastPersistedExpense ?? expense,
        super();

  ExpenseLoaded copyWith({
    Expense? expense,
    Object? error,
    bool loading = false,
  }) {
    return ExpenseLoaded(
      expense ?? _expense,
      error: error,
      loading: loading,
      lastPersistedExpense: lastPersistedExpense,
    );
  }

  @override
  List<Object?> get props =>
      [_expense, error.toString(), loading, lastPersistedExpense];
}

class ExpenseError extends ExpenseState {
  final Object? error;
  ExpenseError({required this.error}) : super();

  @override
  List<Object?> get props => [error.toString()];
}
