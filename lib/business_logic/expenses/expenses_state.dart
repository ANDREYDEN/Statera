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
  final List<ExpenseStage> stages;
  final bool allLoaded;

  ExpensesLoaded({
    required expenses,
    required List<ExpenseStage> this.stages,
    this.allLoaded = false,
  }) : expenses = expenses;

  List<Expense> get filteredExpenses => expenses
      .where((expense) => stages.any((stage) => expense.isIn(stage)))
      .toList();

  @override
  List<Object> get props => [filteredExpenses];
}

/// After the expenses were loaded; whenever the list is changing (creates, updates)
class ExpensesProcessing extends ExpensesLoaded {
  ExpensesProcessing(
      {required List<Expense> expenses, required List<ExpenseStage> stages})
      : super(expenses: expenses, stages: stages);

  ExpensesProcessing.fromLoaded(ExpensesLoaded loaded)
      : super(expenses: loaded.filteredExpenses, stages: loaded.stages);
}

class ExpensesError extends ExpensesState {
  final Object error;

  ExpensesError({required this.error});

  @override
  List<Object> get props => [error];
}
