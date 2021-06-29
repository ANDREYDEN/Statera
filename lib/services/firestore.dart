import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:statera/models/expense.dart';

class Firestore {
  late FirebaseFirestore _firestore;

  CollectionReference get expensesCollection =>
      _firestore.collection("expenses");

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
            .map((doc) =>
                Expense.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  Stream<List<Expense>> listenForAuthoredExpensesForUser(String uid) {
    return expensesCollection
        .where("author", isEqualTo: uid)
        .snapshots()
        .map<List<Expense>>((snap) => snap.docs
            .map((doc) =>
                Expense.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  Future<void> saveExpense(Expense expense) async {
    return expensesCollection.doc(expense.id).set(expense.toFirestore());
  }
}
