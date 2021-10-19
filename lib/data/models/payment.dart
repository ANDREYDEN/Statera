import 'package:statera/data/models/expense.dart';

class PaymentExpenseInfo {
  String? id;
  String name;

  PaymentExpenseInfo({
    required this.id,
    required this.name,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory PaymentExpenseInfo.fromFirestore(Map<String, dynamic> map) {
    return PaymentExpenseInfo(
      id: map['id'],
      name: map['name'],
    );
  }

  factory PaymentExpenseInfo.fromExpense(Expense expense) {
    return PaymentExpenseInfo(
      id: expense.id,
      name: expense.name,
    );
  }
}

class Payment {
  String? groupId;
  String payerId;
  String receiverId;
  double value;
  PaymentExpenseInfo? relatedExpense;
  DateTime? timeCreated;

  Payment({
    required this.groupId,
    required this.payerId,
    required this.receiverId,
    required this.value,
    this.relatedExpense,
    this.timeCreated,
  });

  bool isReceivedBy(String? uid) => this.receiverId == uid;

  bool get hasRelatedExpense => relatedExpense != null;

  Map<String, dynamic> toFirestore() {
    return {
      'groupId': groupId,
      'payerId': payerId,
      'receiverId': receiverId,
      'value': value,
      'relatedExpense': relatedExpense == null ? null : relatedExpense!.toFirestore(),
      'payerReceiverId': '${payerId}_$receiverId'
    };
  }

  factory Payment.fromFirestore(Map<String, dynamic> map) {
    return Payment(
      groupId: map['groupId'],
      payerId: map['payerId'],
      receiverId: map['receiverId'],
      value: double.parse(map['value'].toString()),
      relatedExpense: map['relatedExpense'] == null ? null : PaymentExpenseInfo.fromFirestore(map['relatedExpense']),
      timeCreated: map['timeCreated'] == null ? null : DateTime.parse(map['timeCreated'].toDate().toString())
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Payment &&
        other.payerId == payerId &&
        other.receiverId == receiverId &&
        other.value == value;
  }

  @override
  int get hashCode => payerId.hashCode ^ receiverId.hashCode ^ value.hashCode;
}
