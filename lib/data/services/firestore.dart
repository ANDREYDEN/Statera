import 'package:cloud_firestore/cloud_firestore.dart';

class Firestore {
  late FirebaseFirestore _firestore;

  Firestore() {
    // FirebaseGroupService.instance.settings = Settings(host: '10.0.2.2:9099');
    _firestore = FirebaseFirestore.instance;
  }

  CollectionReference get expensesCollection =>
      _firestore.collection("expenses");

  CollectionReference get groupsCollection => _firestore.collection("groups");

  CollectionReference get paymentsCollection =>
      _firestore.collection("payments");
}
