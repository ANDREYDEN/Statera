import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:statera/data/models/expense.dart';

class Payment implements Comparable {
  String? id;
  String? groupId;
  String payerId;
  String receiverId;
  double value;

  /// List of uids of users who have seen this payment. Might be either payer or receiver.
  List<String> newFor;

  PaymentExpenseInfo? relatedExpense;
  DateTime? timeCreated;
  String? reason;
  double? oldPayerBalance;

  Payment({
    this.id,
    required this.groupId,
    required this.payerId,
    required this.receiverId,
    required this.value,
    this.newFor = const [],
    this.relatedExpense,
    this.timeCreated,
    this.reason,
    this.oldPayerBalance,
  });

  bool isReceivedBy(String? uid) => this.receiverId == uid;

  bool get hasRelatedExpense => relatedExpense != null;

  bool get isAdmin => reason != null;

  Map<String, dynamic> toFirestore() {
    return {
      'groupId': groupId,
      'payerId': payerId,
      'receiverId': receiverId,
      'value': value,
      'relatedExpense':
          relatedExpense == null ? null : relatedExpense!.toFirestore(),
      'reason': reason,
      'oldPayerBalance': oldPayerBalance,
      'newFor': newFor,
    };
  }

  factory Payment.fromFirestore(QueryDocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;

    return Payment(
      id: doc.id,
      groupId: map['groupId'],
      payerId: map['payerId'],
      receiverId: map['receiverId'],
      value: double.parse(map['value'].toString()),
      relatedExpense: map['relatedExpense'] == null
          ? null
          : PaymentExpenseInfo.fromFirestore(map['relatedExpense']),
      timeCreated: map['timeCreated'] == null
          ? null
          : DateTime.parse(map['timeCreated'].toDate().toString()),
      reason: map['reason'],
      oldPayerBalance: map['oldPayerBalance'] == null
          ? null
          : double.parse(map['oldPayerBalance'].toString()),
      newFor: List<String>.from(map['newFor'] ?? []),
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

  @override
  int compareTo(other) {
    if (other is Payment) {
      if (timeCreated == null) {
        return 1;
      }
      if (other.timeCreated == null) {
        return -1;
      }
      return timeCreated!.isAfter(other.timeCreated!) ? -1 : 1;
    }

    return -1;
  }
}

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
