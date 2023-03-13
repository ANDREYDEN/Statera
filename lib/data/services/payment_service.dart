import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:statera/data/models/group.dart';
import 'package:statera/data/models/payment.dart';
import 'package:statera/data/services/firestore.dart';
import 'package:statera/data/services/group_service.dart';

class PaymentService extends Firestore {
  final GroupService _groupService;

  PaymentService(this._groupService, FirebaseFirestore firestoreInstance) : super(firestoreInstance);

  /// in [userIds], payerId goes first
  Stream<List<Payment>> paymentsStream({
    String? groupId,
    String? userId1,
    String? userId2,
  }) {
    return paymentsCollection
        .where('groupId', isEqualTo: groupId)
        .where('payerReceiverId', whereIn: [
          '${userId1}_$userId2',
          '${userId2}_$userId1',
        ])
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) =>
                  Payment.fromFirestore(doc.data() as Map<String, dynamic>))
              .toList(),
        );
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
