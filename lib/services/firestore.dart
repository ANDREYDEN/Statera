import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:statera/models/assignee.dart';
import 'package:statera/models/author.dart';
import 'package:statera/models/expense.dart';
import 'package:statera/models/group.dart';

class Firestore {
  late FirebaseFirestore _firestore;
  static Firestore? _instance;

  Firestore._privateConstructor() {
    // FirebaseFirestore.instance.settings = Settings(host: '10.0.2.2:9099');
    _firestore = FirebaseFirestore.instance;
  }

  static Firestore get instance {
    if (_instance == null) {
      _instance = Firestore._privateConstructor();
    }
    return _instance!;
  }

  CollectionReference get expensesCollection =>
      _firestore.collection("expenses");

  CollectionReference get groupsCollection => _firestore.collection("groups");

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
    return query.snapshots().map<List<Expense>>((snap) => snap.docs
        .map((doc) =>
            Expense.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
        .toList());
  }

  Stream<List<Expense>> listenForRelatedExpenses(String uid, String? groupId) {
    return _queryToExpensesStream(expensesCollection.where(
      "groupId",
      isEqualTo: groupId,
    ));
  }

  Stream<List<Expense>> listenForUnmarkedExpenses(String? groupId, String uid) {
    return _queryToExpensesStream(expensesCollection
        .where(
          "groupId",
          isEqualTo: groupId,
        )
        .where(
          "unmarkedAssigneeIds",
          arrayContains: uid,
        ));
  }

  Future<void> addExpenseToGroup(Expense expense, String? groupCode) async {
    var group = await getGroup(groupCode);
    expense.assignGroup(group);
    await expensesCollection.add(expense.toFirestore());
  }

  Future<Expense> getExpense(String? expenseId) async {
    var expenseDoc = await expensesCollection.doc(expenseId).get();
    if (!expenseDoc.exists)
      throw new Exception("Expense with id $expenseId does not exist.");
    return Expense.fromFirestore(
      expenseDoc.data() as Map<String, dynamic>,
      expenseDoc.id,
    );
  }

  Future<void> updateExpense(
      String? expenseId, Function(Expense) update) async {
    await _firestore.runTransaction((transaction) async {
      var docRef = expensesCollection.doc(expenseId);
      var expenseSnap = await transaction.get(docRef);
      Expense expense = Expense.fromFirestore(
        expenseSnap.data() as Map<String, dynamic>,
        expenseSnap.id,
      );
      update(expense);
      transaction.set(docRef, expense.toFirestore());
    });
  }

  Stream<Expense> listenForExpense(String? expenseId) {
    return expensesCollection
        .doc(expenseId)
        .snapshots()
        .map((snap) => Expense.fromFirestore(
              snap.data() as Map<String, dynamic>,
              snap.id,
            ));
  }

  Future<void> saveExpense(Expense expense) async {
    return expensesCollection.doc(expense.id).set(expense.toFirestore());
  }

  Future<void> deleteExpense(Expense expense) {
    return expensesCollection.doc(expense.id).delete();
  }

  Future<Group> getGroup(String? groupCode) async {
    var groupSnap =
        await groupsCollection.where('code', isEqualTo: groupCode).get();
    if (groupSnap.docs.isEmpty)
      throw new Exception("There was no group with code $groupCode");
    var groupDoc = groupSnap.docs.first;
    return Group.fromFirestore(
      groupDoc.data() as Map<String, dynamic>,
      id: groupDoc.id,
    );
  }

  Future<void> deleteGroup(String? groupId) async {
    var expensesSnap = await Firestore.instance.expensesCollection
        .where('groupId', isEqualTo: groupId)
        .get();
    await Future.wait(expensesSnap.docs.map((doc) => doc.reference.delete()));
    await Firestore.instance.groupsCollection.doc(groupId).delete();
  }

  Stream<Map<Author, double>> getOwingsForUserInGroup(
    String consumerUid,
    String? groupId,
  ) {
    return groupsCollection.doc(groupId).snapshots().map((groupSnap) {
      var group = Group.fromFirestore(groupSnap.data() as Map<String, dynamic>, id: groupSnap.id);
      return group.extendedBalance(consumerUid);
    });
  }

  Stream<List<Group>> userGroupsStream(String uid) {
    return groupsCollection
        .where('memberIds', arrayContains: uid)
        .snapshots()
        .map(
          (event) => event.docs
              .map(
                (doc) => Group.fromFirestore(
                  doc.data() as Map<String, dynamic>,
                  id: doc.id,
                ),
              )
              .toList(),
        );
  }

  Future<void> addUserToOutstandingExpenses(User user, String? groupId) async {
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

  Future<void> saveGroup(Group group) async {
    return groupsCollection.doc(group.id).set(group.toFirestore());
  }
}
