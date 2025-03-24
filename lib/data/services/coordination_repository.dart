import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/annotations.dart';
import 'package:statera/data/exceptions/not_found_exception.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/firestore.dart';

@GenerateNiceMocks([MockSpec<CoordinationRepository>()])
class CoordinationRepository extends Firestore {
  CoordinationRepository(FirebaseFirestore firestoreInstance)
      : super(firestoreInstance);

  Future<void> finalizeExpense(String expenseId) async {
    await firestore.runTransaction((transaction) async {
      final (expense, expenseDocRef) =
          await _getExpense(transaction, expenseId);
      final (group, groupDocRef) =
          await _getGroup(transaction, expense.groupId);

      expense.finalizedDate = Timestamp.now().toDate();
      await transaction.set(expenseDocRef, expense.toFirestore());

      // Add expense payments from author to all assignees
      final payments = expense.assigneeUids
          .where((assigneeUid) => assigneeUid != expense.authorUid)
          .map(
        (assigneeUid) {
          return Payment.fromFinalizedExpense(
            expense: expense,
            receiverId: assigneeUid,
            oldAuthorBalance: group.balance[expense.authorUid]?[assigneeUid],
          );
        },
      );
      await Future.wait(payments
          .map((payment) => paymentsCollection.add(payment.toFirestore())));
      for (final payment in payments) {
        group.payOffBalance(payment: payment);
      }
      await transaction.set(groupDocRef, group);
    });
  }

  Future<void> revertExpense(String expenseId) async {
    await firestore.runTransaction((transaction) async {
      final (expense, expenseDocRef) =
          await _getExpense(transaction, expenseId);
      final (group, groupDocRef) =
          await _getGroup(transaction, expense.groupId);

      expense.finalizedDate = null;
      await transaction.set(expenseDocRef, expense.toFirestore());

      // add expense payments from all assignees to author
      final payments = expense.assigneeUids
          .where((assigneeUid) => assigneeUid != expense.authorUid)
          .map(
            (assigneeUid) => Payment.fromRevertedExpense(
              expense: expense,
              payerId: assigneeUid,
              oldPayerBalance: group.balance[assigneeUid]?[expense.authorUid],
            ),
          );

      await Future.wait(
        payments
            .map((payment) => paymentsCollection.add(payment.toFirestore())),
      );
      for (final payment in payments) {
        group.payOffBalance(payment: payment);
      }
      await transaction.set(groupDocRef, group);
    });
  }

  Future<(Expense, DocumentReference)> _getExpense(
    Transaction transaction,
    String expenseId,
  ) async {
    final expenseDocRef = expensesCollection.doc(expenseId);
    final expenseDoc = await transaction.get(expenseDocRef);
    if (!expenseDoc.exists) throw EntityNotFoundException<Expense>(expenseId);

    final expense = Expense.fromSnapshot(expenseDoc);

    return (expense, expenseDocRef);
  }

  Future<(Group, DocumentReference<Group>)> _getGroup(
    Transaction transaction,
    String? groupId,
  ) async {
    final groupDocRef = groupsCollection.doc(groupId);
    final groupDoc = await transaction.get(groupDocRef);
    final group = groupDoc.data();

    if (!groupDoc.exists || group == null) {
      throw EntityNotFoundException<Group>(groupId);
    }

    return (group, groupDocRef);
  }
}
