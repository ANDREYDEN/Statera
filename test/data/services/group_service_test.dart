import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/services.dart';

main() {
  group('GroupService', () {
    test('does not add new member to finalized expenses', () async {
      final firestore = FakeFirebaseFirestore();

      final admin = CustomUser.fake(uid: 'admin');
      final testGroup = Group(
        name: 'Foo',
        code: 'bar',
        adminId: admin.uid,
        members: [admin],
      );
      final finalizedExpense = Expense(
        authorUid: admin.uid,
        name: 'bar',
        groupId: testGroup.id,
      );
      finalizedExpense.finalizedDate = DateTime.now();

      await firestore.collection('groups').add(testGroup.toFirestore());
      final finalizedExpensesRef = await firestore
          .collection('expenses')
          .add(finalizedExpense.toFirestore());
      final groupService = GroupRepository(firestore);

      final newUser = CustomUser.fake();
      await groupService.addMember(testGroup.code!, newUser);

      final newFinalizedExpenseDoc = await finalizedExpensesRef.get();
      final newFinalizedExpense = Expense.fromFirestore(
        newFinalizedExpenseDoc.data()!,
        newFinalizedExpenseDoc.id,
      );
      expect(newFinalizedExpense.assigneeUids, isNot(contains(newUser.uid)));
    });
  });
}
