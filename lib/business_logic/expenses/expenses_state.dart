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
  final bool loadingMore;
  final List<String> processingExpenseIds;

  ExpensesLoaded({
    required expenses,
    required List<ExpenseStage> this.stages,
    this.allLoaded = false,
    this.loadingMore = false,
    this.processingExpenseIds = const [],
  }) : expenses = expenses;

  bool stagesAreDifferentFrom(ExpensesLoaded other) {
    return stages.length != other.stages.length ||
        stages.any((stage) => !other.stages.contains(stage));
  }

  ExpensesLoaded copyWith({
    List<Expense>? expenses,
    List<ExpenseStage>? stages,
    bool? allLoaded,
    bool? loadingMore,
    List<String>? processingExpenseIds,
  }) {
    return ExpensesLoaded(
      expenses: expenses ?? this.expenses,
      stages: stages ?? this.stages,
      allLoaded: allLoaded ?? this.allLoaded,
      loadingMore: loadingMore ?? this.loadingMore,
      processingExpenseIds: processingExpenseIds ?? this.processingExpenseIds,
    );
  }

  @override
  List<Object> get props => [
        expenses,
        stages,
        allLoaded,
        loadingMore,
        processingExpenseIds,
      ];
}

class ExpensesError extends ExpensesState {
  final Object error;

  ExpensesError({required this.error});

  @override
  List<Object> get props => [error];
}
