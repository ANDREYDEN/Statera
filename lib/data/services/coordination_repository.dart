import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/annotations.dart';
import 'package:statera/data/exceptions/not_found_exception.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/firestore.dart';
import 'package:statera/utils/helpers.dart';

@GenerateNiceMocks([MockSpec<CoordinationRepository>()])
class CoordinationRepository extends Firestore {
  CoordinationRepository(FirebaseFirestore firestoreInstance)
    : super(firestoreInstance);

  Future<void> finalizeExpense(String expenseId) async {
    await firestore.runTransaction((transaction) async {
      final (expense, expenseDocRef) = await _getExpense(
        transaction,
        expenseId,
      );
      final (group, groupDocRef) = await _getGroup(
        transaction,
        expense.groupId,
      );

      expense.finalizedDate = Timestamp.now().toDate();
      await transaction.set(expenseDocRef, expense.toJson());

      // Add expense payments from author to all assignees
      final payments = expense.assigneeUids
          .where((assigneeUid) => assigneeUid != expense.authorUid)
          .map((assigneeUid) {
            return Payment.fromFinalizedExpense(
              expense: expense,
              receiverId: assigneeUid,
              oldAuthorBalance: group.balance[expense.authorUid]?[assigneeUid],
              groupName: group.name,
              currency: group.currency,
            );
          });
      await Future.wait(
        payments.map(
          (payment) => paymentsCollection.add(payment.toFirestore()),
        ),
      );
      for (final payment in payments) {
        group.payOffBalance(payment: payment);
      }
      await transaction.set(groupDocRef, group);
    });
  }

  Future<void> revertExpense(String expenseId) async {
    await firestore.runTransaction((transaction) async {
      final (expense, expenseDocRef) = await _getExpense(
        transaction,
        expenseId,
      );
      final (group, groupDocRef) = await _getGroup(
        transaction,
        expense.groupId,
      );

      expense.finalizedDate = null;
      await transaction.set(expenseDocRef, expense.toJson());

      // add expense payments from all assignees to author
      final payments = expense.assigneeUids
          .where((assigneeUid) => assigneeUid != expense.authorUid)
          .map(
            (assigneeUid) => Payment.fromRevertedExpense(
              expense: expense,
              payerId: assigneeUid,
              oldPayerBalance: group.balance[assigneeUid]?[expense.authorUid],
              groupName: group.name,
              currency: group.currency,
            ),
          );

      await Future.wait(
        payments.map(
          (payment) => paymentsCollection.add(payment.toFirestore()),
        ),
      );
      for (final payment in payments) {
        group.payOffBalance(payment: payment);
      }
      await transaction.set(groupDocRef, group);
    });
  }

  /// Settles the balance between [uid] and [otherUid] in every group where balance > 0.
  /// Creates a payment for each.
  Future<void> settleDebt({
    required String uid,
    required String otherUid,
  }) async {
    final sharedGroupIds = await _getSharedGroupIds(uid, otherUid);

    await firestore.runTransaction((transaction) async {
      final groups = await _getGroups(transaction, sharedGroupIds);

      for (final group in groups) {
        final balance = group.balance[uid]?[otherUid];
        final reverseBalance = group.balance[otherUid]?[uid];
        final hasBalanceRecords = balance != null && reverseBalance != null;
        if (!hasBalanceRecords || approxEqual(balance, 0)) continue;

        final payment = _createSettlingPayment(group, uid, otherUid, balance);
        group.payOffBalance(payment: payment);

        transaction.set(groupsCollection.doc(group.id), group);
        transaction.set(paymentsCollection.doc(), payment.toFirestore());
      }
    });
  }

  Future<(Expense, DocumentReference)> _getExpense(
    Transaction transaction,
    String expenseId,
  ) async {
    final expenseDocRef = expensesCollection.doc(expenseId);
    final expenseDoc = await transaction.get(expenseDocRef);
    if (!expenseDoc.exists) throw EntityNotFoundException<Expense>(expenseId);

    final expense = Expense.fromSnapshot(expenseDoc);

    return (expense, expenseDocRef);
  }

  Future<(Group, DocumentReference<Group>)> _getGroup(
    Transaction transaction,
    String? groupId,
  ) async {
    final groupDocRef = groupsCollection.doc(groupId);
    final groupDoc = await transaction.get(groupDocRef);
    final group = groupDoc.data();

    if (!groupDoc.exists || group == null) {
      throw EntityNotFoundException<Group>(groupId);
    }

    return (group, groupDocRef);
  }

  Future<List<String>> _getSharedGroupIds(String uid, String otherUid) async {
    // Firestore allows only one `arrayContains` per query, so the other member is checked locally.
    final snap = await groupsCollection
        .where('memberIds', arrayContains: uid)
        .get();

    return snap.docs
        .where(
          (doc) => doc.data().members.any((member) => member.uid == otherUid),
        )
        .map((doc) => doc.id)
        .toList();
  }

  /// Reads the groups within the transaction, ignoring the ones that no longer exist.
  Future<List<Group>> _getGroups(
    Transaction transaction,
    List<String> groupIds,
  ) async {
    final snaps = await Future.wait(
      groupIds.map((id) => transaction.get(groupsCollection.doc(id))),
    );

    return snaps
        .where((snap) => snap.exists)
        .map((snap) => snap.data()!)
        .toList();
  }

  /// A positive [balance] means that [uid] owes [otherUid].
  Payment _createSettlingPayment(
    Group group,
    String uid,
    String otherUid,
    double balance,
  ) {
    final uidIsPayer = balance > 0;
    final payerId = uidIsPayer ? uid : otherUid;
    final receiverId = uidIsPayer ? otherUid : uid;

    return Payment(
      groupId: group.id,
      groupName: group.name,
      currency: group.currency,
      payerId: payerId,
      receiverId: receiverId,
      value: balance.abs(),
      oldPayerBalance: balance.abs(),
      newFor: [otherUid],
    );
  }
}
