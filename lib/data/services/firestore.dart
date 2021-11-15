import 'package:cloud_firestore/cloud_firestore.dart';

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

  CollectionReference get paymentsCollection =>
      _firestore.collection("payments");
}
