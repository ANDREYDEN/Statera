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

class ExpenseChanged extends ExpenseEvent {
  final Expense? expense;
  const ExpenseChanged(this.expense) : super();

  @override
  List<Object?> get props => [expense];
}
