import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:statera/data/models/assignee.dart';
import 'package:statera/data/models/author.dart';
import 'package:statera/data/models/expense.dart';
import 'package:statera/data/models/group.dart';
import 'package:statera/data/models/payment.dart';

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

  CollectionReference get paymentsCollection =>
      _firestore.collection("payments");

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

  Stream<List<Expense>> listenForUnmarkedExpenses(String? groupId, String uid) {
    return _queryToExpensesStream(expensesCollection
        .where("groupId", isEqualTo: groupId)
        .where("unmarkedAssigneeIds", arrayContains: uid));
  }

  Future<String> addExpenseToGroup(Expense expense, String? groupCode) async {
    var group = await getGroup(groupCode);
    expense.assignGroup(group);
    final docRef = await expensesCollection.add(expense.toFirestore());
    return docRef.id;
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

  Future<void> updateExpense(Expense expense) async {
    var docRef = expensesCollection.doc(expense.id);
    expensesCollection.doc(docRef.id).set(expense.toFirestore());
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

  Future<Group> getGroupById(String? groupId) async {
    var groupDoc = await groupsCollection.doc(groupId).get();
    if (!groupDoc.exists)
      throw new Exception("There was no group with id $groupId");
    return Group.fromFirestore(
      groupDoc.data() as Map<String, dynamic>,
      id: groupDoc.id,
    );
  }

  Stream<Group> groupStream(String? groupId) {
    var groupStream = groupsCollection.doc(groupId).snapshots();
    return groupStream.map((groupSnap) {
      if (!groupSnap.exists)
        throw new Exception("There was no group with id $groupId");
      return Group.fromFirestore(
        groupSnap.data() as Map<String, dynamic>,
        id: groupSnap.id,
      );
    });
  }

  Future<void> deleteGroup(String? groupId) async {
    var expensesSnap = await Firestore.instance.expensesCollection
        .where('groupId', isEqualTo: groupId)
        .get();
    await Future.wait(expensesSnap.docs.map((doc) => doc.reference.delete()));
    await Firestore.instance.groupsCollection.doc(groupId).delete();
  }

  Stream<Author> getGroupMemberStream(
      {String? groupId, required String memberId}) {
    return groupsCollection.doc(groupId).snapshots().map((groupSnap) {
      if (!groupSnap.exists) throw new Exception("No group with id $groupId");

      Group group = Group.fromFirestore(
          groupSnap.data() as Map<String, dynamic>,
          id: groupSnap.id);
      Author? member = group.getUser(memberId);

      if (member == null)
        throw new Exception("No member in group $groupId with id $memberId");

      return member;
    });
  }

  Stream<Map<Author, double>> getOwingsForUserInGroup(
    String consumerUid,
    String? groupId,
  ) {
    return groupsCollection.doc(groupId).snapshots().map((groupSnap) {
      var group = Group.fromFirestore(groupSnap.data() as Map<String, dynamic>,
          id: groupSnap.id);
      return group.extendedBalance(consumerUid);
    });
  }

  Future<void> payOffBalance({required Payment payment}) async {
    Group group = await getGroupById(payment.groupId);
    group.payOffBalance(payment: payment);
    await paymentsCollection.add(payment.toFirestore());
    await saveGroup(group);
  }

  Stream<List<Group>> userGroupsStream(String uid) {
    return groupsCollection
        .where('memberIds', arrayContains: uid)
        .snapshots()
        .map((event) => event.docs
            .map((doc) => Group.fromFirestore(
                  doc.data() as Map<String, dynamic>,
                  id: doc.id,
                ))
            .toList());
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

  Stream<Group> getExpenseGroupStream(Expense expense) {
    return this.groupStream(expense.groupId);
  }

  Future<void> finalizeExpense(Expense expense) async {
    await expensesCollection
        .doc(expense.id)
        .update({'finalizedDate': Timestamp.now()});
    // add expense payments from author to all assignees
    await Future.wait(
      expense.assignees.map((assignee) => paymentsCollection.add(
            Payment(
              groupId: expense.groupId,
              payerId: expense.author.uid,
              receiverId: assignee.uid,
              value: expense.getConfirmedTotalForUser(assignee.uid),
              relatedExpense: PaymentExpenseInfo.fromExpense(expense),
            ).toFirestore(),
          )),
    );
  }

  /// in [userIds], payerId goes first
  Stream<List<Payment>> paymentsStream({
    String? groupId,
    String? userId1,
    String? userId2,
  }) {
    return paymentsCollection
        .where('groupId', isEqualTo: groupId)
        .where('payerReceiverId', whereIn: [
          '${userId1}_$userId2',
          '${userId2}_$userId1',
        ])
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) =>
                  Payment.fromFirestore(doc.data() as Map<String, dynamic>))
              .toList(),
        );
  }
}
