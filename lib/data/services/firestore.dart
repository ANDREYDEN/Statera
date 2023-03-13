import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:statera/data/models/models.dart';

class Firestore {
  late FirebaseFirestore _firestore;

  Firestore(FirebaseFirestore firestoreInstance) {
    _firestore = firestoreInstance;
  }

  CollectionReference get expensesCollection =>
      _firestore.collection('expenses');

  CollectionReference get groupsCollection => _firestore.collection('groups');

  CollectionReference get paymentsCollection =>
      _firestore.collection('payments');

  CollectionReference get usersCollection => _firestore.collection('users');

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
        query = query.where('finalizedDate', isNotEqualTo: null);
      } else {
        query = query.where('finalizedDate', isEqualTo: null);
      }
    }

    return query;
  }

  Stream<List<Expense>> queryToExpensesStream(Query query) {
    return query.snapshots().map<List<Expense>>(
        (snap) => snap.docs.map((doc) => Expense.fromSnapshot(doc)).toList());
  }
}
