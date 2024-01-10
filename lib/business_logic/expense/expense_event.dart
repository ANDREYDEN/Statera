part of 'expense_bloc.dart';

abstract class ExpenseEvent extends Equatable {
  const ExpenseEvent();

  @override
  List<Object?> get props => [];
}

class LoadRequested extends ExpenseEvent {}

class UpdateRequested extends ExpenseEvent {
  final String issuerUid;
  final FutureOr<void> Function(Expense) update;

  const UpdateRequested({required this.issuerUid, required this.update})
      : super();

  @override
  List<Object> get props => [issuerUid];
}

class _FinishedUpdating extends ExpenseEvent {
  final Expense expense;
  const _FinishedUpdating(this.expense) : super();
}

class _ExpenseUpdatedFromDB extends ExpenseEvent {
  final Expense? expense;
  const _ExpenseUpdatedFromDB(this.expense) : super();

  @override
  List<Object?> get props => [expense];
}