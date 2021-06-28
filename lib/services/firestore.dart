import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:statera/models/expense.dart';

class Firestore {
  late FirebaseFirestore _firestore;

  Firestore._privateConstructor() {
    _firestore = FirebaseFirestore.instance;
  }

  static Firestore get instance => Firestore._privateConstructor();

  addExpense(Expense expense) {
    _firestore.collection("expenses").add(expense.toFirestore());
  }
}