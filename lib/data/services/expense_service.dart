import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:statera/data/models/assignee.dart';
import 'package:statera/data/models/expense.dart';
import 'package:statera/data/models/payment.dart';
import 'package:statera/data/services/firestore.dart';
import 'package:statera/data/services/payment_service.dart';

class ExpenseService {
  static get expensesCollection => Firestore.instance.expensesCollection;

  static Query _expensesQuery({
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

  static Stream<List<Expense>> _queryToExpensesStream(Query query) {
    return query.snapshots().map<List<Expense>>((snap) => snap.docs
        .map((doc) =>
            Expense.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
        .toList());
  }

  static Stream<List<Expense>> listenForRelatedExpenses(String uid, String? groupId) {
    return _queryToExpensesStream(
            expensesCollection.where("groupId", isEqualTo: groupId))
        .map((expenses) => expenses
            .where((expense) =>
                expense.hasAssignee(uid) || expense.isAuthoredBy(uid))
            .toList());
    // final assignedExpensesStream = _queryToExpensesStream(
    //   expensesCollection
    //       .where("assigneeIds", arrayContains: uid)
    // );

    // return authoredExpensesStream.()
  }

  static Stream<List<Expense>> listenForUnmarkedExpenses(String? groupId, String uid) {
    return _queryToExpensesStream(expensesCollection
        .where("groupId", isEqualTo: groupId)
        .where("unmarkedAssigneeIds", arrayContains: uid));
  }

  static Future<Expense> getExpense(String? expenseId) async {
    var expenseDoc = await expensesCollection.doc(expenseId).get();
    if (!expenseDoc.exists)
      throw new Exception("Expense with id $expenseId does not exist.");
    return Expense.fromFirestore(
      expenseDoc.data() as Map<String, dynamic>,
      expenseDoc.id,
    );
  }

  static Future<void> updateExpense(Expense expense) async {
    var docRef = expensesCollection.doc(expense.id);
    expensesCollection.doc(docRef.id).set(expense.toFirestore());
  }

  static Stream<Expense> listenForExpense(String? expenseId) {
    return expensesCollection
        .doc(expenseId)
        .snapshots()
        .map((snap) => Expense.fromFirestore(
              snap.data() as Map<String, dynamic>,
              snap.id,
            ));
  }

  static Future<void> addUserToOutstandingExpenses(User user, String? groupId) async {
    var expensesSnap = await _expensesQuery(groupId: groupId).get();
    List<Expense> expenses = expensesSnap.docs
        .map((doc) =>
            Expense.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
    var outstandingExpenses =
        expenses.where((expense) => expense.canReceiveAssignees);
    outstandingExpenses.forEach((expense) {
      expense.addAssignee(Assignee(uid: user.uid));
    });

    await Future.wait(
      outstandingExpenses.map((expense) => saveExpense(expense)),
    );
  }

  static Future<void> finalizeExpense(Expense expense) async {
    await expensesCollection
        .doc(expense.id)
        .update({'finalizedDate': Timestamp.now()});
    // add expense payments from author to all assignees
    await Future.wait(
      expense.assignees.map((assignee) => PaymentService.addPayment(
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

  static Future<void> saveExpense(Expense expense) async {
    return expensesCollection.doc(expense.id).set(expense.toFirestore());
  }

  static Future<void> deleteExpense(Expense expense) {
    return expensesCollection.doc(expense.id).delete();
  }
}
