import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/annotations.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/services.dart';

@GenerateNiceMocks([MockSpec<UserExpenseRepository>()])
class UserExpenseRepository extends Firestore {
  UserExpenseRepository(FirebaseFirestore firestoreInstance)
      : super(firestoreInstance);

  CollectionReference userExpensesCollection(String uid) {
    return usersCollection.doc(uid).collection('expenses');
  }

  Stream<List<UserExpense>> listenForRelatedExpenses(
    String uid,
    String? groupId, {
    int? quantity,
    List<int>? stages,
  }) {
    var filter = Filter('groupId', isEqualTo: groupId);
    if (stages != null) {
      filter = Filter.and(
        filter,
        Filter('stage', whereIn: stages),
      );
    }
    var query = userExpensesCollection(uid)
        .where(filter)
        .orderBy('stage')
        .orderBy('date', descending: true);
    if (quantity != null) {
      query = query.limit(quantity);
    }
    return query.snapshots().map<List<UserExpense>>(
        (snap) => snap.docs.map((doc) => UserExpense.fromSnapshot(doc)).toList());
  }
}
