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
    return _queryToExpensesStream(
        expensesCollection.where("groupId", isEqualTo: groupId));
  }

  Future<void> addExpenseToGroup(Expense expense, String? groupCode) async {
    var group = await getGroup(groupCode);
    expense.setAssignees(
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
    Group group,
  ) {
    // TODO: oprtimize to only unpaid expenses
    return _expensesQuery(groupId: group.id)
        .snapshots()
        .asyncMap((expensesSnap) async {
      var expenses = expensesSnap.docs.map((doc) => Expense.fromFirestore(
            doc.data() as Map<String, dynamic>,
            doc.id,
          ));
      Map<Author, List<Expense>> owings = {};

      // TODO: this might take longer as Future.forEach is consecutively waiting for each Future
      group.members
          .where((member) => member.uid != consumerUid)
          .forEach((member) {
        owings[member] = expenses
            .where((expense) =>
                expense.isAuthoredBy(member.uid) &&
                !expense.isPaidBy(consumerUid))
            .toList();
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
}
