import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:statera/data/models/payment.dart';
import 'package:statera/data/services/firestore.dart';

class PaymentService {
  static CollectionReference get paymentsCollection => Firestore.instance.paymentsCollection;

  /// in [userIds], payerId goes first
  static Stream<List<Payment>> paymentsStream({
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

  static Future<void> addPayment(Payment payment) async {
    await paymentsCollection.add(payment.toFirestore());
  }
}