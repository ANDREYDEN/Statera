import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:statera/data/models/models.dart';

class Firestore {
  late FirebaseFirestore firestore;

  Firestore(FirebaseFirestore firestoreInstance) {
    firestore = firestoreInstance;
  }

  CollectionReference get expensesCollection =>
      firestore.collection('expenses');

  CollectionReference get groupsCollection => firestore.collection('groups');

  CollectionReference get paymentsCollection =>
      firestore.collection('payments');

  CollectionReference get usersCollection => firestore.collection('users');

  CollectionReference getUserGroupsCollection(String uid) =>
      usersCollection.doc(uid).collection('groups');

  Query expensesQuery({
    String? groupId,
    String? assigneeId,
    String? unmarkedAssigneeId,
    String? authorId,
    bool? finalized,
  }) {
    var query = expensesCollection.where('groupId', isEqualTo: groupId);

    if (assigneeId != null) {
      query = query.where('assigneeIds', arrayContains: assigneeId);
    }

    if (authorId != null) {
      query = query.where('authorUid', isEqualTo: authorId);
    }

    if (unmarkedAssigneeId != null) {
      query =
          query.where('unmarkedAssigneeIds', arrayContains: unmarkedAssigneeId);
    }

    if (finalized != null) {
      if (finalized) {
        query = query.where('finalizedDate', isNull: false);
      } else {
        query = query.where('finalizedDate', isNull: true);
      }
    }

    return query;
  }

  Stream<List<Expense>> queryToExpensesStream(Query query) {
    return query.snapshots().map<List<Expense>>(
        (snap) => snap.docs.map((doc) => Expense.fromSnapshot(doc)).toList());
  }
}
