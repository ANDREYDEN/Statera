import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:statera/business_logic/expenses/expenses_cubit.dart';
import 'package:statera/data/enums/enums.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/expense_service.mocks.dart';
import 'package:statera/data/services/group_repository.mocks.dart';
import 'package:statera/data/services/user_expense_repository.mocks.dart';

void main() {
  final expenseService = MockExpenseService();
  final groupService = MockGroupRepository();
  final userExpenseRepository = MockUserExpenseRepository();
  final groupId = 'testGroupId';
  final uid = 'testUserId';
  ExpensesCubit expensesCubit = ExpensesCubit(
    groupId,
    uid,
    userExpenseRepository,
    expenseService,
    groupService,
  );
  final expenses = List.generate(
    25,
    (index) => Expense(
      name: 'Expense $index',
      authorUid: uid,
      groupId: groupId,
    ),
  );

  group('ExpensesCubit', () {
    setUp(() async {
      expensesCubit = ExpensesCubit(
          groupId, uid, userExpenseRepository, expenseService, groupService);
    });

    test(
      'has initial state of ExpensesLoading',
      () => expect(expensesCubit.state, ExpensesLoading()),
    );

    blocTest(
      'has state of ExpensesLoaded once loaded',
      setUp: () {
        when(userExpenseRepository.listenForRelatedExpenses(
          uid,
          groupId,
          quantity: anyNamed('quantity'),
          stages: anyNamed('stages'),
        )).thenAnswer((_) => Stream.fromIterable([[]]));
      },
      build: () => expensesCubit,
      act: (ExpensesCubit cubit) => cubit.load(),
      expect: () => [isA<ExpensesLoaded>()],
      verify: (_) {
        verify(userExpenseRepository.listenForRelatedExpenses(
          uid,
          groupId,
          quantity: ExpensesCubit.expensesPerPage,
          stages: anyNamed('stages'),
        )).called(1);
      },
    );

    final firstExpenses = expenses.take(ExpensesCubit.expensesPerPage).toList();
    blocTest(
      'can load more expenses',
      setUp: () {
        int invocation = 0;
        when(userExpenseRepository.listenForRelatedExpenses(
          uid,
          groupId,
          quantity: anyNamed('quantity'),
          stages: anyNamed('stages'),
        )).thenAnswer((_) {
          return [
            Stream.fromIterable([firstExpenses]),
            Stream.fromIterable(
              [expenses.take(ExpensesCubit.expensesPerPage + 3).toList()],
            )
          ][invocation++];
        });
      },
      build: () => expensesCubit,
      act: (ExpensesCubit cubit) async {
        cubit.load();
        await Future.delayed(0.5.seconds);
        cubit.loadMore();
      },
      expect: () => [
        ExpensesLoaded(
          expenses: firstExpenses,
          stages: ExpenseStage.values,
          allLoaded: false,
        ),
        ExpensesProcessing.fromLoaded(
          ExpensesLoaded(
            expenses: firstExpenses,
            stages: ExpenseStage.values,
            allLoaded: false,
          ),
        ),
        ExpensesLoaded(
          expenses: expenses.take(ExpensesCubit.expensesPerPage + 3).toList(),
          stages: ExpenseStage.values,
          allLoaded: true,
        ),
      ],
      verify: (_) {
        verify(userExpenseRepository.listenForRelatedExpenses(
          uid,
          groupId,
          quantity: ExpensesCubit.expensesPerPage,
          stages: anyNamed('stages'),
        )).called(1);
        verify(userExpenseRepository.listenForRelatedExpenses(
          uid,
          groupId,
          quantity: ExpensesCubit.expensesPerPage * 2,
          stages: anyNamed('stages'),
        )).called(1);
      },
    );

    var secondExpenses =
        expenses.take(ExpensesCubit.expensesPerPage * 2).toList();

    blocTest(
      'sets allLoaded to true if the total number of expenses is divisible by page size',
      setUp: () {
        int invocation = 0;
        when(userExpenseRepository.listenForRelatedExpenses(
          uid,
          groupId,
          quantity: anyNamed('quantity'),
          stages: anyNamed('stages'),
        )).thenAnswer((_) {
          return [
            Stream.fromIterable([firstExpenses]),
            Stream.fromIterable([secondExpenses]),
            Stream.fromIterable([secondExpenses]),
          ][invocation++];
        });
      },
      build: () => expensesCubit,
      act: (ExpensesCubit cubit) async {
        cubit.load();
        await Future.delayed(0.5.seconds);
        cubit.loadMore();
        await Future.delayed(0.5.seconds);
        cubit.loadMore();
      },
      expect: () => [
        ExpensesLoaded(
          expenses: firstExpenses,
          stages: ExpenseStage.values,
          allLoaded: false,
        ),
        ExpensesProcessing.fromLoaded(
          ExpensesLoaded(
            expenses: firstExpenses,
            stages: ExpenseStage.values,
            allLoaded: false,
          ),
        ),
        ExpensesLoaded(
          expenses: secondExpenses,
          stages: ExpenseStage.values,
          allLoaded: false,
        ),
        ExpensesProcessing.fromLoaded(
          ExpensesLoaded(
            expenses: secondExpenses,
            stages: ExpenseStage.values,
            allLoaded: false,
          ),
        ),
        ExpensesLoaded(
          expenses: secondExpenses,
          stages: ExpenseStage.values,
          allLoaded: true,
        ),
      ],
      verify: (_) {
        verify(userExpenseRepository.listenForRelatedExpenses(
          uid,
          groupId,
          quantity: ExpensesCubit.expensesPerPage,
          stages: anyNamed('stages'),
        )).called(1);
        verify(userExpenseRepository.listenForRelatedExpenses(
          uid,
          groupId,
          quantity: ExpensesCubit.expensesPerPage * 2,
          stages: anyNamed('stages'),
        )).called(1);
        verify(userExpenseRepository.listenForRelatedExpenses(
          uid,
          groupId,
          quantity: ExpensesCubit.expensesPerPage * 3,
          stages: anyNamed('stages'),
        )).called(1);
      },
    );

    final allStages = ExpenseStage.values;
    final selectedStages = allStages.take(2).toList();
    blocTest(
      'can change expense stages',
      setUp: () {
        int invocation = 0;
        when(userExpenseRepository.listenForRelatedExpenses(
          uid,
          groupId,
          quantity: anyNamed('quantity'),
          stages: anyNamed('stages'),
        )).thenAnswer((_) {
          return [
            Stream.fromIterable([firstExpenses]),
            Stream.fromIterable([secondExpenses]),
          ][invocation++];
        });
      },
      build: () => expensesCubit,
      act: (ExpensesCubit cubit) async {
        cubit.load();
        await Future.delayed(0.5.seconds);
        cubit.selectExpenseStages(selectedStages);
      },
      expect: () => [
        ExpensesLoaded(
          expenses: firstExpenses,
          stages: ExpenseStage.values,
          allLoaded: false,
        ),
        ExpensesProcessing.fromLoaded(
          ExpensesLoaded(
            expenses: firstExpenses,
            stages: ExpenseStage.values,
            allLoaded: false,
          ),
        ),
        ExpensesLoaded(
          expenses: secondExpenses,
          stages: selectedStages,
          allLoaded: false,
        ),
      ],
      verify: (_) {
        verify(userExpenseRepository.listenForRelatedExpenses(
          uid,
          groupId,
          quantity: anyNamed('quantity'),
          stages: allStages.map((e) => e.index).toList(),
        )).called(1);
        verify(userExpenseRepository.listenForRelatedExpenses(
          uid,
          groupId,
          quantity: anyNamed('quantity'),
          stages: selectedStages.map((e) => e.index).toList(),
        )).called(1);
      },
    );

    var withoutFirstFive =
        expenses.skip(5).take(ExpensesCubit.expensesPerPage).toList();
    var thirdExpenses =
        expenses.take(ExpensesCubit.expensesPerPage * 2).toList();
    blocTest(
      'loading more keeps the selected expense stages',
      setUp: () {
        int invocation = 0;
        when(userExpenseRepository.listenForRelatedExpenses(
          uid,
          groupId,
          quantity: anyNamed('quantity'),
          stages: anyNamed('stages'),
        )).thenAnswer((_) {
          return [
            Stream.fromIterable([firstExpenses]),
            Stream.fromIterable([withoutFirstFive]),
            Stream.fromIterable([thirdExpenses]),
          ][invocation++];
        });
      },
      build: () => expensesCubit,
      act: (ExpensesCubit cubit) async {
        cubit.load();
        await Future.delayed(0.5.seconds);
        cubit.selectExpenseStages(selectedStages);
        await Future.delayed(0.5.seconds);
        cubit.loadMore();
      },
      expect: () => [
        ExpensesLoaded(
          expenses: firstExpenses,
          stages: ExpenseStage.values,
          allLoaded: false,
        ),
        ExpensesProcessing.fromLoaded(
          ExpensesLoaded(
            expenses: firstExpenses,
            stages: ExpenseStage.values,
            allLoaded: false,
          ),
        ),
        ExpensesLoaded(
          expenses: withoutFirstFive,
          stages: selectedStages,
          allLoaded: false,
        ),
        ExpensesProcessing.fromLoaded(
          ExpensesLoaded(
            expenses: withoutFirstFive,
            stages: selectedStages,
            allLoaded: false,
          ),
        ),
        ExpensesLoaded(
          expenses: thirdExpenses,
          stages: selectedStages,
          allLoaded: false,
        ),
      ],
      verify: (_) {
        verify(userExpenseRepository.listenForRelatedExpenses(
          uid,
          groupId,
          quantity: anyNamed('quantity'),
          stages: allStages.map((e) => e.index).toList(),
        )).called(1);
        verify(userExpenseRepository.listenForRelatedExpenses(
          uid,
          groupId,
          quantity: anyNamed('quantity'),
          stages: selectedStages.map((e) => e.index).toList(),
        )).called(2);
      },
    );
  });
}
