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

  bool stagesAreDifferentFrom(ExpensesLoaded other) {
    return stages.length != other.stages.length ||
        stages.any((stage) => !other.stages.contains(stage));
  }

  ExpensesLoaded copyWith({
    List<Expense>? expenses,
    List<ExpenseStage>? stages,
    bool? allLoaded,
  }) {
    return ExpensesLoaded(
      expenses: expenses ?? this.expenses,
      stages: stages ?? this.stages,
      allLoaded: allLoaded ?? this.allLoaded,
    );
  }

  @override
  List<Object> get props => [expenses, allLoaded, stages];
}

/// After the expenses were loaded; whenever the list is changing (creates, updates)
class ExpensesLoadingMore extends ExpensesLoaded {
  ExpensesLoadingMore({
    required List<Expense> expenses,
    required List<ExpenseStage> stages,
  }) : super(expenses: expenses, stages: stages);

  ExpensesLoadingMore.fromLoaded(ExpensesLoaded loaded)
      : super(expenses: loaded.expenses, stages: loaded.stages);

  ExpensesLoaded toLoaded() {
    return ExpensesLoaded(
      expenses: expenses,
      stages: stages,
      allLoaded: allLoaded,
    );
  }
}

class ExpensesError extends ExpensesState {
  final Object error;

  ExpensesError({required this.error});

  @override
  List<Object> get props => [error];
}
