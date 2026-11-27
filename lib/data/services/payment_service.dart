import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/annotations.dart';
import 'package:statera/data/models/group.dart';
import 'package:statera/data/models/payment/payment.dart';
import 'package:statera/data/services/firestore.dart';
import 'package:statera/data/services/group_repository.dart';

@GenerateNiceMocks([MockSpec<PaymentService>()])
class PaymentService extends Firestore {
  final GroupRepository _groupService;

  PaymentService(this._groupService, FirebaseFirestore firestoreInstance)
    : super(firestoreInstance);

  Stream<List<Payment>> paymentsStream({
    required String userId1,
    String? userId2,
    String? groupId,
    String? newFor,
    int? limit,
  }) {
    var paymentsFilter = Filter.or(
      Filter('payerId', isEqualTo: userId1),
      Filter('receiverId', isEqualTo: userId1),
    );

    if (userId2 != null) {
      paymentsFilter = Filter.and(
        paymentsFilter,
        Filter.or(
          Filter('payerId', isEqualTo: userId2),
          Filter('receiverId', isEqualTo: userId2),
        ),
      );
    }

    if (groupId != null) {
      paymentsFilter = Filter.and(
        paymentsFilter,
        Filter('groupId', isEqualTo: groupId),
      );
    }

    if (newFor != null) {
      paymentsFilter = Filter.and(
        paymentsFilter,
        Filter('newFor', arrayContains: newFor),
      );
    }

    var query = paymentsCollection.where(paymentsFilter);

    if (limit != null) {
      query = query.orderBy('timeCreated', descending: true).limit(limit);
    }

    return query.snapshots().map(
      (snap) => snap.docs.map(Payment.fromFirestore).toList(),
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

  Future<void> view(List<Payment> payments, String userId) {
    final newPayments = payments.where((p) => p.newFor.contains(userId));
    if (newPayments.isEmpty) return Future.value();

    final batch = firestore.batch();
    for (final payment in newPayments) {
      batch.update(paymentsCollection.doc(payment.id), {
        'newFor': FieldValue.arrayRemove([userId]),
      });
    }
    return batch.commit();
  }
}
