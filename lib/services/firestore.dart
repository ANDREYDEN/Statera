import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:statera/models/assignee.dart';
import 'package:statera/models/author.dart';
import 'package:statera/models/expense.dart';
import 'package:statera/models/group.dart';
import 'package:async/async.dart' show StreamGroup;

class Firestore {
  late FirebaseFirestore _firestore;

  CollectionReference get expensesCollection =>
      _firestore.collection("expenses");

  CollectionReference get groupsCollection => _firestore.collection("groups");

  Firestore._privateConstructor() {
    _firestore = FirebaseFirestore.instance;
  }

  static Firestore get instance => Firestore._privateConstructor();

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
        expensesCollection.where("groupId", isEqualTo: groupId));
  }

  Future<void> addExpenseToGroup(Expense expense, String? groupCode) async {
    var group = await getGroup(groupCode);
    expense.addAssignees(
      group.members.map((member) => Assignee(uid: member.uid)).toList(),
    );
    await expensesCollection.add(expense.toFirestore());
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

  Stream<Map<Author, List<Expense>>> getOwingsForUserInGroup(
    String consumerUid,
    String? groupId,
  ) {
    return groupsCollection.doc(groupId).snapshots().asyncMap((snap) async {
      var group = Group.fromFirestore(
        snap.data() as Map<String, dynamic>,
        id: snap.id,
      );
      Map<Author, List<Expense>> owings = {};

      // TODO: this might take longer as Future.forEach is consecutively waiting for each Future
      await Future.forEach(
        group.members,
        (Author member) async {
          // skip yourself
          if (member.uid == consumerUid) return;

          var payerExpensesSnap =
              await _expensesQuery(groupId: groupId, authorId: member.uid)
                  .get();

          List<Expense> payerExpenses = payerExpensesSnap.docs
              .map((doc) => Expense.fromFirestore(
                    doc.data() as Map<String, dynamic>,
                    doc.id,
                  ))
              .where((expense) => expense.hasAssignee(member.uid))
              .toList();

          owings[member] = payerExpenses
              .where((expense) => !expense.paidBy(consumerUid))
              .toList();
        },
      );

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
                (doc) => Group.fromFirestore(
                  doc.data() as Map<String, dynamic>,
                  id: doc.id,
                ),
              )
              .toList(),
        );
  }
}
