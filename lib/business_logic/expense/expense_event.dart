part of 'expense_bloc.dart';

abstract class ExpenseEvent extends Equatable {
  const ExpenseEvent();

  @override
  List<Object?> get props => [];
}

class _LoadRequested extends ExpenseEvent {}

class _UnloadRequested extends ExpenseEvent {}

class UpdateRequested extends ExpenseEvent {
  final String issuerUid;
  final Expense updatedExpense;

  const UpdateRequested({required this.issuerUid, required this.updatedExpense})
      : super();

  @override
  List<Object> get props => [issuerUid];
}

class _ExpenseUpdated extends ExpenseEvent {
  final Expense expense;
  const _ExpenseUpdated(this.expense) : super();

  @override
  List<Object?> get props => [expense];
}

class _ExpenseUpdatedFromDB extends ExpenseEvent {
  final Expense? expense;
  const _ExpenseUpdatedFromDB(this.expense) : super();

  @override
  List<Object?> get props => [expense];
}
