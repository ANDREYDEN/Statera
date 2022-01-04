import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/firestore.dart';
import 'package:statera/data/services/payment_service.dart';

class ExpenseService extends Firestore {
  static ExpenseService? _instance;

  ExpenseService() : super();

  static ExpenseService get instance {
    if (_instance == null) {
      _instance = ExpenseService();
    }
    return _instance!;
  }

  Query _expensesQuery({
    String? groupId,
    String? assigneeId,
    String? authorId,
  }) {
    var query = expensesCollection.where("groupId", isEqualTo: groupId);

    if (assigneeId != null) {
      query = query.where("assigneeIds", arrayContains: assigneeId);
    }

    if (authorId != null) {
      query = query.where("author.uid", isEqualTo: authorId);
    }

    return query;
  }

  Stream<List<Expense>> _queryToExpensesStream(Query query) {
    return query.snapshots().map<List<Expense>>(
        (snap) => snap.docs.map((doc) => Expense.fromSnapshot(doc)).toList());
  }

  Stream<List<Expense>> listenForRelatedExpenses(String uid, String? groupId) {
    return _queryToExpensesStream(
            expensesCollection.where("groupId", isEqualTo: groupId))
        .map((expenses) => expenses
            .where((expense) =>
                expense.hasAssignee(uid) || expense.isAuthoredBy(uid))
            .toList());
  }

  Stream<List<Expense>> listenForUnmarkedExpenses(String? groupId, String uid) {
    return _queryToExpensesStream(expensesCollection
        .where("groupId", isEqualTo: groupId)
        .where("unmarkedAssigneeIds", arrayContains: uid));
  }

  Future<Expense> getExpense(String? expenseId) async {
    var expenseDoc = await expensesCollection.doc(expenseId).get();
    if (!expenseDoc.exists)
      throw new Exception("Expense with id $expenseId does not exist.");
    return Expense.fromSnapshot(expenseDoc);
  }

  Future<void> updateExpense(Expense expense) async {
    var docRef = expensesCollection.doc(expense.id);
    expensesCollection.doc(docRef.id).set(expense.toFirestore());
  }

  Stream<Expense?> expenseStream(String? expenseId) {
    return expensesCollection
        .doc(expenseId)
        .snapshots()
        .map((snap) => !snap.exists ? null : Expense.fromSnapshot(snap));
  }

  Future<void> addUserToOutstandingExpenses(String uid, String? groupId) async {
    var expensesSnap = await _expensesQuery(groupId: groupId).get();
    final expenses =
        expensesSnap.docs.map((doc) => Expense.fromSnapshot(doc)).toList();

    for (var expense in expenses) {
      final containsUser = expense.assignees.any((a) => a.uid == uid);
      if (expense.canReceiveAssignees &&
          expense.acceptNewMembers &&
          !containsUser) {
        expense.addAssignee(Assignee(uid: uid));
      }
    }

    await Future.wait(
      expenses.map((expense) => saveExpense(expense)),
    );
  }

  Future<void> finalizeExpense(Expense expense) async {
    await expensesCollection
        .doc(expense.id)
        .update({'finalizedDate': Timestamp.now()});
    // add expense payments from author to all assignees
    await Future.wait(
      expense.assignees.map((assignee) => PaymentService.instance.addPayment(
            Payment(
              groupId: expense.groupId,
              payerId: expense.author.uid,
              receiverId: assignee.uid,
              value: expense.getConfirmedTotalForUser(assignee.uid),
              relatedExpense: PaymentExpenseInfo.fromExpense(expense),
            ),
          )),
    );
  }

  Future<void> saveExpense(Expense expense) async {
    return expensesCollection.doc(expense.id).set(expense.toFirestore());
  }

  Future<void> deleteExpense(Expense expense) {
    return expensesCollection.doc(expense.id).delete();
  }
}
