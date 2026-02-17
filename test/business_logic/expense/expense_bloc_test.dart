import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:statera/business_logic/expense/expense_bloc.dart';
import 'package:statera/data/exceptions/exceptions.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/coordination_repository.mocks.dart';
import 'package:statera/data/services/expense_service.mocks.dart';
import 'package:statera/utils/utils.dart';

void main() {
  final expenseService = MockExpenseService();
  final coordinationRepository = MockCoordinationRepository();
  final expense = Expense(
    id: 'testExpenseId',
    name: 'Test Expense',
    authorUid: 'testUserId',
    groupId: 'testGroupId',
  );
  late ExpenseBloc expenseBloc;

  group('ExpenseBloc', () {
    setUp(() {
      expenseBloc = ExpenseBloc(expenseService, coordinationRepository);
      reset(expenseService);
      reset(coordinationRepository);
    });

    test(
      'has initial state of ExpenseNotSelected',
      () => expect(expenseBloc.state, ExpenseNotSelected()),
    );

    group('load', () {
      blocTest<ExpenseBloc, ExpenseState>(
        'can load expense',
        setUp: () {
          when(
            expenseService.expenseStream(any),
          ).thenAnswer((_) => Stream.value(expense));
        },
        build: () => expenseBloc,
        act: (bloc) => bloc.load(expense.id),
        expect: () => [ExpenseLoading(), ExpenseLoaded(expense)],
        verify: (_) {
          verify(expenseService.expenseStream(expense.id)).called(1);
        },
      );

      blocTest<ExpenseBloc, ExpenseState>(
        'handles expense loading error',
        setUp: () {
          when(
            expenseService.expenseStream(any),
          ).thenAnswer((_) => Stream.value(null));
        },
        build: () => expenseBloc,
        act: (bloc) => bloc.load(expense.id),
        expect: () => [
          ExpenseLoading(),
          ExpenseError(error: EntityNotFoundException<Expense>(null)),
        ],
      );
    });

    blocTest<ExpenseBloc, ExpenseState>(
      'emits ExpenseNotSelected when unloaded',
      build: () => expenseBloc,
      seed: () => ExpenseLoaded(expense),
      act: (bloc) => bloc.unload(),
      expect: () => [ExpenseNotSelected()],
    );

    group('when UpdateRequested', () {
      final updatedExpense = Expense.from(expense);
      updatedExpense.name = 'Updated Expense';

      blocTest<ExpenseBloc, ExpenseState>(
        'updates expense',
        setUp: () {
          when(expenseService.updateExpense(any)).thenAnswer((_) async => {});
        },
        build: () => expenseBloc,
        seed: () => ExpenseLoaded(expense),
        act: (bloc) {
          bloc.add(UpdateRequested(updatedExpense: updatedExpense));
        },
        wait: kExpenseUpdateDelay,
        expect: () => [
          ExpenseLoaded(
            updatedExpense,
            loading: true,
            lastPersistedExpense: expense,
          ),
          ExpenseLoaded(updatedExpense),
        ],
        verify: (_) {
          verify(expenseService.updateExpense(updatedExpense)).called(1);
        },
      );

      blocTest<ExpenseBloc, ExpenseState>(
        'handles update error',
        setUp: () {
          when(
            expenseService.updateExpense(any),
          ).thenThrow(Exception('Update failed'));
        },
        build: () => ExpenseBloc(expenseService, coordinationRepository),
        seed: () => ExpenseLoaded(expense),
        act: (bloc) {
          bloc.add(UpdateRequested(updatedExpense: updatedExpense));
        },
        wait: kExpenseUpdateDelay,
        errors: () => [isA<Exception>()],
        expect: () => [
          ExpenseLoaded(
            updatedExpense,
            loading: true,
            lastPersistedExpense: expense,
          ),
          ExpenseLoaded(
            expense,
            error: Exception('Update failed'),
            lastPersistedExpense: expense,
          ),
        ],
      );

      blocTest<ExpenseBloc, ExpenseState>(
        'does not emit new state when updated expense equals current expense',
        build: () => expenseBloc,
        seed: () => ExpenseLoaded(expense),
        act: (bloc) => bloc.add(UpdateRequested(updatedExpense: expense)),
        expect: () => [],
        verify: (_) {
          verifyNever(expenseService.updateExpense(any));
        },
      );
    });

    blocTest<ExpenseBloc, ExpenseState>(
      'can revert expense',
      setUp: () {
        when(
          coordinationRepository.revertExpense(any),
        ).thenAnswer((_) async => {});
      },
      build: () => expenseBloc,
      seed: () => ExpenseLoaded(expense),
      act: (bloc) => bloc.revertExpense(expense),
      expect: () => [],
      verify: (_) {
        verify(coordinationRepository.revertExpense(expense.id)).called(1);
      },
    );
  });
}
