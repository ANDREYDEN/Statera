import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/models/payment/payment_expense_info.dart';
import 'package:statera/data/models/payment/payment_redirect_info.dart';

class Payment implements Comparable, Equatable {
  String? id;
  String? groupId;
  String payerId;
  String receiverId;
  double value;

  /// List of uids of users who have seen this payment. Might be either payer or receiver.
  List<String> newFor;

  PaymentExpenseInfo? relatedExpense;
  PaymentRedirectInfo? redirectInfo;
  DateTime? timeCreated;
  String? reason;
  double? oldPayerBalance;
  final bool isAdmin;

  Payment({
    this.id,
    required this.groupId,
    required this.payerId,
    required this.receiverId,
    required this.value,
    this.newFor = const [],
    this.relatedExpense,
    this.redirectInfo,
    this.timeCreated,
    this.reason,
    this.oldPayerBalance,
    this.isAdmin = false,
  });

  Payment.fromFinalizedExpense({
    required Expense expense,
    required String receiverId,
    required double? oldAuthorBalance,
  })  : id = null,
        groupId = expense.groupId,
        payerId = expense.authorUid,
        receiverId = receiverId,
        value = expense.getConfirmedTotalForUser(receiverId),
        newFor = [receiverId],
        relatedExpense = PaymentExpenseInfo.fromExpense(
          expense,
          action: PaymentExpenseAction.finalize,
        ),
        oldPayerBalance = oldAuthorBalance,
        isAdmin = false;

  Payment.fromRevertedExpense({
    required Expense expense,
    required String payerId,
    required double? oldPayerBalance,
  })  : id = null,
        groupId = expense.groupId,
        payerId = payerId,
        receiverId = expense.authorUid,
        value = expense.getConfirmedTotalForUser(payerId),
        newFor = [payerId],
        relatedExpense = PaymentExpenseInfo.fromExpense(
          expense,
          action: PaymentExpenseAction.revert,
        ),
        oldPayerBalance = oldPayerBalance,
        isAdmin = false;

  Payment.fromRedirect({
    required String groupId,
    required String authorId,
    required String payerId,
    required String receiverId,
    required double amount,
    required double oldPayerBalance,
  })  : id = null,
        groupId = groupId,
        payerId = payerId,
        receiverId = receiverId,
        value = amount,
        newFor = [payerId, receiverId],
        redirectInfo = PaymentRedirectInfo(authorUid: authorId),
        oldPayerBalance = oldPayerBalance,
        isAdmin = false;

  bool isReceivedBy(String? uid) => this.receiverId == uid;

  bool get hasRelatedExpense => relatedExpense != null;

  bool get hasRelatedRedirect => redirectInfo != null;

  String getFullReason(String uid, Group group) {
    if (reason != null) return reason!;

    if (hasRelatedExpense) {
      return 'Expense "${relatedExpense!.name}" was ${relatedExpense!.action?.name ?? 'finalized'}.';
    }

    if (hasRelatedRedirect) {
      final authorName = uid == redirectInfo!.authorUid
          ? 'you'
          : group.getMember(redirectInfo!.authorUid).name;
      return 'This payment was created because $authorName redirected some debt.';
    }

    return 'Manual payment.';
  }

  Map<String, dynamic> toFirestore() {
    return {
      'groupId': groupId,
      'payerId': payerId,
      'receiverId': receiverId,
      'value': value,
      'relatedExpense':
          relatedExpense == null ? null : relatedExpense!.toFirestore(),
      'redirectInfo': redirectInfo == null ? null : redirectInfo!.toFirestore(),
      'reason': reason,
      'oldPayerBalance': oldPayerBalance,
      'newFor': newFor,
      'isAdmin': isAdmin,
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
      redirectInfo: map['redirectInfo'] == null
          ? null
          : PaymentRedirectInfo.fromFirestore(map['redirectInfo']),
      timeCreated: map['timeCreated'] == null
          ? null
          : DateTime.parse(map['timeCreated'].toDate().toString()),
      reason: map['reason'],
      oldPayerBalance: map['oldPayerBalance'] == null
          ? null
          : double.parse(map['oldPayerBalance'].toString()),
      newFor: List<String>.from(map['newFor'] ?? []),
      isAdmin: map['isAdmin'] ?? false,
    );
  }

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

  @override
  List<Object?> get props => [payerId, receiverId, value];

  @override
  bool? get stringify => true;
}
