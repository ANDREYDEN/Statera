import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/annotations.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/firestore.dart';

@GenerateNiceMocks([MockSpec<ExpenseService>()])
class ExpenseService extends Firestore {
  ExpenseService(FirebaseFirestore firestoreInstance)
      : super(firestoreInstance);

  Future<Expense> getExpense(String? expenseId) async {
    var expenseDoc = await expensesCollection.doc(expenseId).get();
    if (!expenseDoc.exists)
      throw new Exception('Expense with id $expenseId does not exist.');
    return Expense.fromSnapshot(expenseDoc);
  }

  Future<void> updateExpense(Expense expense) {
    return expensesCollection.doc(expense.id).set(expense.toFirestore());
  }

  Stream<Expense?> expenseStream(String? expenseId) {
    return expensesCollection
        .doc(expenseId)
        .snapshots()
        .map((snap) => !snap.exists ? null : Expense.fromSnapshot(snap));
  }

  Future<void> addAssigneeToOutstandingExpenses(
    String uid,
    String? groupId,
  ) async {
    var outstandingExpensesSnap =
        await expensesQuery(groupId: groupId, finalized: false).get();
    final outstandingExpenses = outstandingExpensesSnap.docs
        .map((doc) => Expense.fromSnapshot(doc))
        .toList();

    for (var expense in outstandingExpenses) {
      final containsUser = expense.assigneeUids.any((aUid) => aUid == uid);
      if (expense.settings.acceptNewMembers && !containsUser) {
        expense.addAssignee(uid);
      }
    }

    await Future.wait(
      outstandingExpenses.map((expense) => updateExpense(expense)),
    );
  }

  Future<void> removeAssigneeFromOutstandingExpenses(
    String uid,
    String? groupId,
  ) async {
    final outstandingExpensesSnap =
        await expensesQuery(groupId: groupId, finalized: false).get();
    final outstandingExpenses =
        outstandingExpensesSnap.docs.map(Expense.fromSnapshot).toList();

    for (final expense in outstandingExpenses) {
      if (expense.assigneeUids.contains(uid)) {
        expense.removeAssignee(uid);
      }
    }

    await Future.wait(outstandingExpenses.map(updateExpense));
  }

  Future<void> deleteExpense(String expenseId) {
    return expensesCollection.doc(expenseId).delete();
  }

  Future<List<Expense>> getPendingExpenses(
      String groupId, String assigneeId) async {
    final expensesSnap = await expensesQuery(
      groupId: groupId,
      assigneeId: assigneeId,
      finalized: false,
    ).get();
    final expenses = expensesSnap.docs.map(Expense.fromSnapshot).toList();

    return expenses;
  }

  Future<List<Expense>> getPendingAuthoredExpenses(
      String groupId, String authorId) async {
    final expensesSnap = await expensesQuery(
      groupId: groupId,
      authorId: authorId,
      finalized: false,
    ).get();
    final expenses = expensesSnap.docs.map(Expense.fromSnapshot).toList();

    return expenses;
  }
}
