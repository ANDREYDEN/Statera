import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:statera/business_logic/expenses/expenses_cubit.dart';
import 'package:statera/data/enums/enums.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/coordination_repository.mocks.dart';
import 'package:statera/data/services/expense_service.mocks.dart';
import 'package:statera/data/services/group_repository.mocks.dart';
import 'package:statera/data/services/user_expense_repository.mocks.dart';

void main() {
  final expenseService = MockExpenseService();
  final groupService = MockGroupRepository();
  final userExpenseRepository = MockUserExpenseRepository();
  final coordinationRepository = MockCoordinationRepository();
  final groupId = 'testGroupId';
  final uid = 'testUserId';
  ExpensesCubit expensesCubit = ExpensesCubit(
    groupId,
    uid,
    userExpenseRepository,
    expenseService,
    groupService,
    coordinationRepository,
  );
  final expenses = List.generate(
    25,
    (index) => Expense(
      id: 'expense-$index',
      name: 'Expense $index',
      authorUid: uid,
      groupId: groupId,
    ),
  );

  group('ExpensesCubit', () {
    setUp(() async {
      expensesCubit = ExpensesCubit(
        groupId,
        uid,
        userExpenseRepository,
        expenseService,
        groupService,
        coordinationRepository,
      );
      reset(expenseService);
      reset(groupService);
      reset(userExpenseRepository);
      reset(coordinationRepository);
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
    var secondExpenses =
        expenses.take(ExpensesCubit.expensesPerPage * 2).toList();
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
        ExpensesLoading(),
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

    group('loadMore', () {
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
          ExpensesLoaded(
            expenses: firstExpenses,
            stages: ExpenseStage.values,
            allLoaded: false,
            loadingMore: true,
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
          ExpensesLoaded(
            expenses: firstExpenses,
            stages: ExpenseStage.values,
            allLoaded: false,
            loadingMore: true,
          ),
          ExpensesLoaded(
            expenses: secondExpenses,
            stages: ExpenseStage.values,
            allLoaded: false,
          ),
          ExpensesLoaded(
            expenses: secondExpenses,
            stages: ExpenseStage.values,
            allLoaded: false,
            loadingMore: true,
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

      var withoutFirstFive =
          expenses.skip(5).take(ExpensesCubit.expensesPerPage).toList();
      var thirdExpenses =
          expenses.take(ExpensesCubit.expensesPerPage * 2).toList();
      blocTest(
        'keeps the selected expense stages',
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
          ExpensesLoading(),
          ExpensesLoaded(
            expenses: withoutFirstFive,
            stages: selectedStages,
            allLoaded: false,
          ),
          ExpensesLoaded(
            expenses: withoutFirstFive,
            stages: selectedStages,
            allLoaded: false,
            loadingMore: true,
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

    final newExpense = Expense(
      id: 'newExpenseId',
      name: 'New Expense',
      authorUid: uid,
      groupId: groupId,
    );
    blocTest<ExpensesCubit, ExpensesState>(
      'addExpense adds expense to the list and calls groupRepository',
      setUp: () {
        when(groupService.addExpense(any, any))
            .thenAnswer((_) async => 'newExpenseId');
      },
      build: () => expensesCubit,
      seed: () => ExpensesLoaded(
        expenses: firstExpenses,
        stages: ExpenseStage.values,
        allLoaded: false,
      ),
      act: (ExpensesCubit cubit) async {
        await cubit.addExpense(newExpense, groupId);
      },
      expect: () => [
        ExpensesLoaded(
          expenses: [
            newExpense,
            ...firstExpenses,
          ],
          stages: ExpenseStage.values,
          allLoaded: false,
        )..startProcessing('newExpenseId'),
      ],
      verify: (_) {
        verify(groupService.addExpense(groupId, any)).called(1);
      },
    );

    group('deleteExpense', () {
      blocTest<ExpensesCubit, ExpensesState>(
        'deleteExpense removes expense from the list and calls expenseService',
        setUp: () {
          when(expenseService.deleteExpense(any)).thenAnswer((_) async => {});
        },
        build: () => expensesCubit,
        seed: () => ExpensesLoaded(
          expenses: firstExpenses,
          stages: ExpenseStage.values,
          allLoaded: false,
        ),
        act: (ExpensesCubit cubit) async {
          await cubit.deleteExpense(firstExpenses.first.id);
        },
        expect: () => [
          ExpensesLoaded(
            expenses: firstExpenses.sublist(1),
            stages: ExpenseStage.values,
            allLoaded: false,
          ),
        ],
        verify: (_) {
          verify(expenseService.deleteExpense(firstExpenses.first.id))
              .called(1);
        },
      );

      blocTest<ExpensesCubit, ExpensesState>(
        'deleteExpense rolls back expenses state if delete fails',
        build: () => expensesCubit,
        seed: () => ExpensesLoaded(
          expenses: firstExpenses,
          stages: ExpenseStage.values,
          allLoaded: false,
        ),
        act: (ExpensesCubit cubit) async {
          when(expenseService.deleteExpense(any))
              .thenThrow(Exception('Delete failed'));
          try {
            await cubit.deleteExpense(firstExpenses.first.id);
          } catch (_) {}
        },
        expect: () => [
          ExpensesLoaded(
            expenses: firstExpenses.sublist(1),
            stages: ExpenseStage.values,
          ),
          ExpensesLoaded(
            expenses: firstExpenses,
            stages: ExpenseStage.values,
            errorActionName: 'deleting',
          ),
        ],
      );
    });

    group('updateExpense', () {
      final updatedExpense = Expense.from(firstExpenses.first);
      updatedExpense.name = 'Updated Expense';
      blocTest<ExpensesCubit, ExpensesState>(
        'updateExpense updates expense in the list and calls expenseService if persist is true',
        setUp: () {
          when(expenseService.updateExpense(any)).thenAnswer((_) async => {});
        },
        build: () => expensesCubit,
        seed: () => ExpensesLoaded(
          expenses: firstExpenses,
          stages: ExpenseStage.values,
          allLoaded: false,
        ),
        act: (ExpensesCubit cubit) async {
          await cubit.updateExpense(updatedExpense, persist: true);
        },
        expect: () => [
          ExpensesLoaded(
            expenses: [
              updatedExpense,
              ...firstExpenses.sublist(1),
            ],
            stages: ExpenseStage.values,
            allLoaded: false,
          ),
        ],
        verify: (_) {
          verify(expenseService.updateExpense(any)).called(1);
        },
      );

      blocTest<ExpensesCubit, ExpensesState>(
        'updateExpense updates expense in the list but does not call expenseService if persist is false',
        build: () => expensesCubit,
        seed: () => ExpensesLoaded(
          expenses: firstExpenses,
          stages: ExpenseStage.values,
          allLoaded: false,
        ),
        act: (ExpensesCubit cubit) async {
          await cubit.updateExpense(updatedExpense, persist: false);
        },
        expect: () => [
          ExpensesLoaded(
            expenses: [
              updatedExpense,
              ...firstExpenses.sublist(1),
            ],
            stages: ExpenseStage.values,
            allLoaded: false,
          ),
        ],
        verify: (_) {
          verifyNever(expenseService.updateExpense(any));
        },
      );

      blocTest<ExpensesCubit, ExpensesState>(
        'updateExpense rolls back expenses state if update fails',
        build: () => expensesCubit,
        seed: () => ExpensesLoaded(
          expenses: firstExpenses,
          stages: ExpenseStage.values,
          allLoaded: false,
        ),
        act: (ExpensesCubit cubit) async {
          when(expenseService.updateExpense(any))
              .thenThrow(Exception('Update failed'));
          try {
            await cubit.updateExpense(updatedExpense, persist: true);
          } catch (_) {}
        },
        expect: () => [
          ExpensesLoaded(
            expenses: [
              updatedExpense,
              ...firstExpenses.sublist(1),
            ],
            stages: ExpenseStage.values,
          ),
          ExpensesLoaded(
            expenses: firstExpenses,
            stages: ExpenseStage.values,
            errorActionName: 'updating',
          ),
        ],
      );
    });

    blocTest<ExpensesCubit, ExpensesState>(
      'finalizeExpense calls coordinationRepository',
      setUp: () {
        when(coordinationRepository.finalizeExpense(any))
            .thenAnswer((_) async => {});
      },
      build: () => expensesCubit,
      seed: () => ExpensesLoaded(
        expenses: firstExpenses,
        stages: ExpenseStage.values,
        allLoaded: false,
      ),
      act: (ExpensesCubit cubit) async {
        await cubit.finalizeExpense(firstExpenses.first);
      },
      expect: () => [
        ExpensesLoaded(
          expenses: firstExpenses,
          stages: ExpenseStage.values,
          allLoaded: false,
        )..startProcessing(firstExpenses.first.id),
      ],
      verify: (_) {
        verify(coordinationRepository.finalizeExpense(firstExpenses.first.id))
            .called(1);
      },
    );

    blocTest<ExpensesCubit, ExpensesState>(
      'revertExpense calls coordinationRepository',
      setUp: () {
        when(coordinationRepository.revertExpense(any))
            .thenAnswer((_) async => {});
      },
      build: () => expensesCubit,
      seed: () => ExpensesLoaded(
        expenses: firstExpenses,
        stages: ExpenseStage.values,
        allLoaded: false,
      ),
      act: (ExpensesCubit cubit) async {
        await cubit.revertExpense(firstExpenses.first);
      },
      expect: () => [
        ExpensesLoaded(
          expenses: firstExpenses,
          stages: ExpenseStage.values,
          allLoaded: false,
        )..startProcessing(firstExpenses.first.id),
      ],
      verify: (_) {
        verify(coordinationRepository.revertExpense(firstExpenses.first.id))
            .called(1);
      },
    );
  });
}
