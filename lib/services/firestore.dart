import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:statera/models/Author.dart';
import 'package:statera/models/expense.dart';
import 'package:statera/models/group.dart';

class Firestore {
  late FirebaseFirestore _firestore;

  CollectionReference get expensesCollection =>
      _firestore.collection("expenses");

  CollectionReference get groupsCollection => _firestore.collection("groups");

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
        .where("finalized", isEqualTo: false)
        .snapshots()
        .map<List<Expense>>((snap) => snap.docs
            .map((doc) => Expense.fromFirestore(
                doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  Query _authoredExpensesForUserQuery(String uid) {
    return expensesCollection
        .where("author.uid", isEqualTo: uid)
        .where("finalized", isEqualTo: false);
  }

  Stream<List<Expense>> listenForAuthoredExpensesForUser(String uid) {
    return _authoredExpensesForUserQuery(uid).snapshots().map<List<Expense>>(
        (snap) => snap.docs
            .map((doc) => Expense.fromFirestore(
                doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  listenForFinalizedExpensesForUser(String uid) {
    return expensesCollection
        .where("finalized", isEqualTo: true)
        .snapshots()
        .map<List<Expense>>((snap) => snap.docs
            .map((doc) => Expense.fromFirestore(
                doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  Future<void> saveExpense(Expense expense) async {
    return expensesCollection.doc(expense.id).set(expense.toFirestore());
  }

  Future<void> addUserToGroup(User user, String groupCode) async {
    var group = await getGroup(groupCode);
    if (group.members.any((member) => member.uid == user.uid)) return;

    group.members.add(Author.fromUser(user));

    await groupsCollection.doc(group.id).set(group.toFirestore());
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

  Stream<Map<Author, double>> getOwingsForUserInGroup(
      String consumerUid, String? groupCode) {
    return groupsCollection
        .where('code', isEqualTo: groupCode)
        .snapshots()
        .asyncMap((snap) async {
      var group =
          Group.fromFirestore(snap.docs.first.data() as Map<String, dynamic>);

      Map<Author, double> owings = {};

      // TODO: this might take longer as Future.forEach is consecutively waiting for each Future
      await Future.forEach(group.members, (Author member) async {
        var payerExpensesSnap =
            await _authoredExpensesForUserQuery(member.uid).get();

        List<Expense> payerExpenses = payerExpensesSnap.docs
            .map((doc) => Expense.fromFirestore(
                doc.data() as Map<String, dynamic>, doc.id))
            .where((expense) => expense.hasAssignee(member.uid))
            .toList();

        owings[member] = payerExpenses.fold(
            0,
            (previousValue, expense) =>
                previousValue + expense.getTotalForUser(consumerUid));
      });

      return owings;
    });
  }

  Future<void> deleteExpense(Expense expense) {
    return expensesCollection.doc(expense.id).delete();
  }

  Stream<List<Group>> userGroupsStream(String uid) {
    return groupsCollection
        .where('memberIds', arrayContains: uid)
        .snapshots()
        .map(
          (event) => event.docs
              .map(
                (doc) =>
                    Group.fromFirestore(doc.data() as Map<String, dynamic>),
              )
              .toList(),
        );
  }

  Future<void> addGroupForUser(User user, Group group) async {
    group.members.add(Author.fromUser(user));
    await groupsCollection.add(group.toFirestore());
  }

  Future<void> joinGroup(User user, String groupCode) async {
    var group = await getGroup(groupCode);
    group.members.add(Author.fromUser(user));
    await groupsCollection.doc(group.id).update(group.toFirestore());
  }
}
