import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:statera/models/Author.dart';
import 'package:statera/models/expense.dart';

class Firestore {
  late FirebaseFirestore _firestore;

  CollectionReference get expensesCollection =>
      _firestore.collection("expenses");

  CollectionReference get groupsCollection => _firestore.collection("groups");

  DocumentReference get theGroup => groupsCollection.doc('group145');

  Firestore._privateConstructor() {
    _firestore = FirebaseFirestore.instance;
  }

  static Firestore get instance => Firestore._privateConstructor();

  addExpense(Expense expense) {
    expensesCollection.add(expense.toFirestore());
  }

  Stream<List<Expense>> listenForAssignedExpensesForUser(String uid) {
    return expensesCollection
        .where("assignees", arrayContains: uid)
        .snapshots()
        .map<List<Expense>>((snap) => snap.docs
            .map((doc) => Expense.fromFirestore(
                doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  Query _authoredExpensesForUserQuery(String uid) {
    return expensesCollection.where("author.uid", isEqualTo: uid);
  }

  Stream<List<Expense>> listenForAuthoredExpensesForUser(String uid) {
    return _authoredExpensesForUserQuery(uid).snapshots().map<List<Expense>>(
        (snap) => snap.docs
            .map((doc) => Expense.fromFirestore(
                doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  Future<void> saveExpense(Expense expense) async {
    return expensesCollection.doc(expense.id).set(expense.toFirestore());
  }

  Future<void> addUserToGroup(User user) async {
    await groupsCollection.doc('group145').update({
      'members': [Author.fromUser(user).toFirestore()]
    });
  }

  Future<List<Author>> getUsersGroupMembers(String uid) async {
    var groupSnap = await theGroup.get();
    List<dynamic> members =
        (groupSnap.data() as Map<String, dynamic>)['members'];
    return members
        .map((memberData) => Author.fromFirestore(memberData))
        .toList();
  }

  Future<Map<Author, double>> getOwingsForUser(String consumerUid) async {
    List<Author> members = await getUsersGroupMembers(consumerUid);

    Map<Author, double> owings = {};

    // TODO: this might take longer as Future.forEach is consecutively waiting for each Future
    await Future.forEach(members, (Author member) async {
      var payerExpensesSnap =
          await _authoredExpensesForUserQuery(member.uid).get();
      List<Expense> payerExpenses = payerExpensesSnap.docs
          .map((doc) =>
              Expense.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
      owings[member] = payerExpenses.fold(
          0,
          (previousValue, expense) =>
              previousValue + expense.getTotalForUser(consumerUid));
    });

    return owings;
  }
}
