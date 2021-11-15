import 'package:statera/data/models/group.dart';
import 'package:statera/data/models/payment.dart';
import 'package:statera/data/services/firestore.dart';
import 'package:statera/data/services/group_service.dart';

class PaymentService extends Firestore {
  static PaymentService? _instance;

  PaymentService() : super();

  static PaymentService get instance {
    if (_instance == null) {
      _instance = PaymentService();
    }
    return _instance!;
  }

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
    Group group = await GroupService.instance.getGroupById(payment.groupId);
    group.payOffBalance(payment: payment);
    await paymentsCollection.add(payment.toFirestore());
    await GroupService.instance.saveGroup(group);
  }
}