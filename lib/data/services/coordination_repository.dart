import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/firestore.dart';

class CoordinationRepository extends Firestore {
  CoordinationRepository(FirebaseFirestore firestoreInstance) : super(firestoreInstance);

  Future<void> finalizeExpense(String groupId, String expenseId) async {
    await firestore.runTransaction((transaction) async {
      final expenseDocRef = expensesCollection.doc(expenseId);
      final expenseDoc = await transaction.get(expenseDocRef);
      final expense = Expense.fromSnapshot(expenseDoc);

      final groupDocRef = groupsCollection.doc(groupId);
      final groupDoc = await transaction.get(groupDocRef);
      final group = Group.fromFirestore(groupDoc.data() as Map<String, dynamic>, id: groupDoc.id);

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
      await Future.wait(payments.map((payment) => paymentsCollection.add(payment.toFirestore())));
      for (final payment in payments) {
        group.payOffBalance(payment: payment);
      }
      await transaction.set(groupDocRef, group.toFirestore());
    });
  }

  Future<void> revertExpense(String groupId, String expenseId) async {
    await firestore.runTransaction((transaction) async {
      final expenseDocRef = expensesCollection.doc(expenseId);
      final expenseDoc = await transaction.get(expenseDocRef);
      final expense = Expense.fromSnapshot(expenseDoc);

      final groupDocRef = groupsCollection.doc(groupId);
      final groupDoc = await transaction.get(groupDocRef);
      final group = Group.fromFirestore(groupDoc.data() as Map<String, dynamic>, id: groupDoc.id);

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

      await Future.wait(payments.map((payment) => paymentsCollection.add(payment.toFirestore())));
      for (final payment in payments) {
        group.payOffBalance(payment: payment);
      }
      await transaction.set(groupDocRef, group.toFirestore());
    });
  }
}