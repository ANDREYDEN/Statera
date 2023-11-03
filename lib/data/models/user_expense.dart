import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:statera/data/enums/enums.dart';

class UserExpense {
  String id;
  String? groupId;
  int itemQuantity = 0;
  String name;
  String authorUid;
  DateTime? date;
  ExpenseStage stage = ExpenseStage.NotMarked;
  double total = 0.0;
  double confirmedTotal = 0.0;
  bool canBeFinalized = false;
  bool hasItemsDeniedByAll = false;

  UserExpense({
    required this.id,
    required this.name,
    required this.authorUid,
    this.groupId,
  });

  static UserExpense fromFirestore(Map<String, dynamic> data, String id) {
    final authorUid = data['authorUid'] ?? '';

    var userExpense = new UserExpense(
      id: id,
      authorUid: authorUid,
      name: data['name'],
      groupId: data['groupId'],
    );
    userExpense.date = data['date'] == null
        ? null
        : DateTime.parse(data['date'].toDate().toString());
    userExpense.stage = ExpenseStage.values[data['stage']];
    userExpense.itemQuantity = data['itemQuantity'];
    userExpense.total = data['total'];
    userExpense.confirmedTotal = data['confirmedTotal'];
    userExpense.canBeFinalized = data['canBeFinalized'];
    userExpense.hasItemsDeniedByAll = data['hasItemsDeniedByAll'];

    return userExpense;
  }

  static UserExpense fromSnapshot(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>;
    return fromFirestore(data, snap.id);
  }
}