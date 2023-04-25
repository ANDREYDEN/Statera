import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:statera/data/models/group.dart';
import 'package:statera/data/models/payment.dart';
import 'package:statera/data/services/firestore.dart';
import 'package:statera/data/services/group_service.dart';

class PaymentService extends Firestore {
  final GroupService _groupService;

  PaymentService(this._groupService, FirebaseFirestore firestoreInstance)
      : super(firestoreInstance);

  /// in [userIds], payerId goes first
  Stream<List<Payment>> paymentsStream({
    String? groupId,
    String? userId1,
    String? userId2,
    bool? viewed
  }) {
    var paymentsQuery = paymentsCollection.where('groupId', isEqualTo: groupId);
    
    if (userId1 != null) {
      paymentsQuery = paymentsQuery.where(
        Filter.or(
          Filter('payerId', isEqualTo: userId1),
          Filter('receiverId', isEqualTo: userId1),
        ),
      );
    }
    
    if (userId2 != null) {
      paymentsQuery = paymentsQuery.where(
        Filter.or(
          Filter('payerId', isEqualTo: userId2),
          Filter('receiverId', isEqualTo: userId2),
        ),
      );
    }
    
    if (viewed != null) {
      paymentsQuery = paymentsQuery.where('viewed', isEqualTo: viewed);
    }

    return paymentsQuery.snapshots().map(
          (snap) => snap.docs
              .map((doc) =>
                  Payment.fromFirestore(doc.data() as Map<String, dynamic>))
              .toList(),
        );
  }

  Future<List<String>> getUidsByMostRecentPayment(
      Group group, String userId) async {
    final userDates = [];
    var otherMemberIds =
        group.members.map((m) => m.uid).where((m) => m != userId);
    for (final memberId in otherMemberIds) {
      final mostRecentPaymentSnapshot = await paymentsCollection
          .where('groupId', isEqualTo: group.id)
          .where('payerReceiverId', whereIn: [
            '${userId}_$memberId',
            '${memberId}_$userId',
          ])
          .orderBy('timeCreated', descending: true)
          .limit(1)
          .get();

      final mostRecentPaymentDocs = mostRecentPaymentSnapshot.docs;

      if (mostRecentPaymentDocs.isEmpty) {
        userDates.add([memberId, DateTime(0)]);
        continue;
      }

      final mostRecentPayment = Payment.fromFirestore(
          mostRecentPaymentSnapshot.docs.first.data() as Map<String, dynamic>);
      userDates.add([memberId, mostRecentPayment.timeCreated]);
    }

    userDates.sort((a, b) {
      final timeComparison = (b[1] as DateTime).compareTo(a[1] as DateTime);
      if (timeComparison != 0) return timeComparison;
      return b[0].compareTo(a[0]);
    });
    return userDates.map<String>((e) => e[0]).toList();
  }

  Future<void> addPayment(Payment payment) async {
    await paymentsCollection.add(payment.toFirestore());
  }

  Future<void> payOffBalance({required Payment payment}) async {
    Group group = await _groupService.getGroupById(payment.groupId);
    group.payOffBalance(payment: payment);
    await paymentsCollection.add(payment.toFirestore());
    await _groupService.saveGroup(group);
  }
}
