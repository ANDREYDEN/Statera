import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:statera/business_logic/expenses/expenses_cubit.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/expense_service.mocks.dart';
import 'package:statera/data/services/group_service.mocks.dart';

void main() {
  late final expenseService = MockExpenseService();
  late final groupService = MockGroupService();
  ExpensesCubit expensesCubit = ExpensesCubit(expenseService, groupService);
  final uid = 'testUserId';
  final groupId = 'testGroupId';
  final expenses = List.generate(
    15,
    (index) => Expense(
      name: 'Expense $index',
      authorUid: uid,
      groupId: groupId,
    ),
  );

  group('ExpensesCubit', () {
    setUp(() async {
      expensesCubit = ExpensesCubit(expenseService, groupService);
    });

    test(
      'has initial state of ExpensesLoading',
      () => expect(expensesCubit.state, ExpensesLoading()),
    );

    blocTest(
      'has state of ExpensesLoaded once loaded',
      setUp: () {
        when(expenseService.listenForRelatedExpenses(
          uid,
          groupId,
          quantity: anyNamed('quantity'),
        )).thenAnswer((_) => Stream.fromIterable([[]]));
      },
      build: () => expensesCubit,
      act: (ExpensesCubit cubit) => cubit.load('testUserId', 'testGroupId'),
      expect: () => [isA<ExpensesLoaded>()],
      verify: (_) {
        verify(expenseService.listenForRelatedExpenses(
          uid,
          groupId,
          quantity: ExpensesCubit.expensesPerPage,
        )).called(1);
      },
    );

    final firstExpenses = expenses.take(ExpensesCubit.expensesPerPage).toList();
    final secondExpenses = expenses.sublist(
      ExpensesCubit.expensesPerPage,
      ExpensesCubit.expensesPerPage + 3,
    );
    
    blocTest(
      'can load more expenses',
      setUp: () {
        int invocation = 0;
        when(expenseService.listenForRelatedExpenses(
          uid,
          groupId,
          quantity: anyNamed('quantity'),
        )).thenAnswer((_) {
          return [
            Stream.fromIterable([firstExpenses]),
            Stream.fromIterable([secondExpenses])
          ][invocation++];
        });
      },
      build: () => expensesCubit,
      act: (ExpensesCubit cubit) async {
        cubit.load(uid, groupId);
        await Future.delayed(0.5.seconds);
        cubit.loadMore(uid);
      },
      expect: () => [
        ExpensesLoaded(
          expenses: firstExpenses,
          stages: Expense.expenseStages(uid),
          allLoaded: false,
        ),
        ExpensesLoaded(
          expenses: secondExpenses,
          stages: Expense.expenseStages(uid),
          allLoaded: true,
        ),
      ],
      verify: (_) {
        verify(expenseService.listenForRelatedExpenses(
          uid,
          groupId,
          quantity: anyNamed('quantity'),
        )).called(2);
      },
    );
  });
}
