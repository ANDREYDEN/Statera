part of 'user_expenses_cubit.dart';

abstract class ExpensesState extends Equatable {
  const ExpensesState();

  @override
  List<Object> get props => [];
}

/// Before the expenses were first loaded
class ExpensesLoading extends ExpensesState {}

class ExpensesLoaded extends ExpensesState {
  final List<UserExpense> expenses;
  final List<ExpenseStage> stages;
  final bool allLoaded;

  ExpensesLoaded({
    required expenses,
    required List<ExpenseStage> this.stages,
    this.allLoaded = false,
  }) : expenses = expenses;

  bool stagesAreDifferentFrom(ExpensesLoaded other) {
    return stages.length != other.stages.length ||
        stages.any((stage) => !other.stages.contains(stage));
  }

  @override
  List<Object> get props => [expenses, allLoaded, stages];
}

/// After the expenses were loaded; whenever the list is changing (creates, updates)
class ExpensesProcessing extends ExpensesLoaded {
  ExpensesProcessing({
    required List<UserExpense> expenses,
    required List<ExpenseStage> stages,
  }) : super(expenses: expenses, stages: stages);

  ExpensesProcessing.fromLoaded(ExpensesLoaded loaded)
      : super(expenses: loaded.expenses, stages: loaded.stages);
}

class ExpensesError extends ExpensesState {
  final Object error;

  ExpensesError({required this.error});

  @override
  List<Object> get props => [error];
}
