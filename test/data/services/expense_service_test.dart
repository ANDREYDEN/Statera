import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/services.dart';

main() {
  group('ExpenseService', () {
    group('when adding a new assignee', () {
      test('only adds them to non-finalized expenses', () async {
        // arrange
        final firestore = FakeFirebaseFirestore();

        final groupId = 'testGroup';
        // TODO: extract into a utility constructor
        final pendingExpense = Expense(
          authorUid: 'foo',
          name: 'bar',
          groupId: groupId,
        );
        final finalizedExpense = Expense(
          authorUid: 'foo',
          name: 'bar',
          groupId: groupId,
        );
        finalizedExpense.finalizedDate = DateTime.now();

        final finalizedExpensesRef = await firestore
            .collection('expenses')
            .add(finalizedExpense.toFirestore());
        final pendingExpensesRef = await firestore
            .collection('expenses')
            .add(pendingExpense.toFirestore());
        final expenseService = ExpenseService(firestore);
        final newUserId = 'newUser';

        // act
        await expenseService.addAssigneeToOutstandingExpenses(
          newUserId,
          groupId,
        );

        // assert
        final newFinalizedExpenseDoc = await finalizedExpensesRef.get();
        final newFinalizedExpense = Expense.fromFirestore(
          newFinalizedExpenseDoc.data()!,
          newFinalizedExpenseDoc.id,
        );
        final newPendingExpenseDoc = await pendingExpensesRef.get();
        final newPendingExpense = Expense.fromFirestore(
          newPendingExpenseDoc.data()!,
          newPendingExpenseDoc.id,
        );

        expect(newFinalizedExpense.assigneeUids, isNot(contains(newUserId)));
        expect(newPendingExpense.assigneeUids, contains(newUserId));
      });
    });
  });
}
