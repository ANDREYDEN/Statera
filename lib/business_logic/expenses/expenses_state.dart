part of 'expenses_cubit.dart';

abstract class ExpensesState extends Equatable {
  const ExpensesState();

  @override
  List<Object> get props => [];
}

/// Before the expenses were first loaded
class ExpensesLoading extends ExpensesState {}

class ExpensesLoaded extends ExpensesState {
  final List<Expense> expenses;

  const ExpensesLoaded({required this.expenses});

  @override
  List<Object> get props => [expenses];
}

/// After the expenses were loaded; whenever the list is changing (creates, updates)
class ExpensesProcessing extends ExpensesLoaded {
  ExpensesProcessing({required List<Expense> expenses}) : super(expenses: expenses);
}

class ExpensesError extends ExpensesState {
  final Object error;

  ExpensesError({required this.error});

  @override
  List<Object> get props => [error];
}