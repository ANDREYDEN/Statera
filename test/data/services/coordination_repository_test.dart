import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:statera/data/exceptions/exceptions.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/utils/helpers.dart';

main() {
  late FakeFirebaseFirestore firestore;
  late CustomUser admin;
  late CustomUser member;
  late Group testGroup;
  late Expense testExpense;
  late SimpleItem testItem;

  setUp(() {
    firestore = FakeFirebaseFirestore();

    admin = CustomUser.fake(uid: 'admin');
    member = CustomUser.fake(uid: 'member');

    testGroup = Group(
      id: 'testGroupId',
      name: 'Test Group',
      members: [admin, member],
    );
    testGroup.balance = {
      admin.uid: {member.uid: 0},
      member.uid: {admin.uid: 0},
    };

    testExpense = Expense(
      authorUid: admin.uid,
      name: 'Test Expense',
      groupId: testGroup.id,
    );
    testExpense.assigneeUids = [admin.uid, member.uid];

    testItem = SimpleItem(
      name: 'Test Item',
      value: 100,
    );
    testExpense.addItem(testItem);
    testItem.setAssigneeDecision(member.uid, 1);
    testItem.setAssigneeDecision(admin.uid, 1);
  });

  group('CoordinationRepository', () {
    group('finalizeExpense', () {
      test('updates expense and creates payments', () async {
        // arrange
        final groupRef = firestore.collection('groups').doc(testGroup.id);
        await groupRef.set(testGroup.toFirestore());
        final expenseRef = firestore.collection('expenses').doc(testExpense.id);
        await expenseRef.set(testExpense.toFirestore());

        // act
        final coordinationRepo = CoordinationRepository(firestore);
        await coordinationRepo.finalizeExpense(testExpense.id);

        // assert
        final updatedExpenseDoc = await expenseRef.get();
        final updatedExpense = Expense.fromFirestore(
          updatedExpenseDoc.data()!,
          updatedExpenseDoc.id,
        );
        expect(updatedExpense.finalizedDate, isNotNull);

        final paymentsSnapshot = await firestore.collection('payments').get();
        expect(paymentsSnapshot.docs.length, 1);
        final payments =
            paymentsSnapshot.docs.map(Payment.fromFirestore).toList();
        final payment1 = payments[0];
        expect(payment1.payerId, admin.uid);
        expect(payment1.receiverId, member.uid);
        expect(approxEqual(payment1.value, 50), true);

        final updatedGroupDoc = await groupRef.get();
        final updatedGroup = Group.fromFirestore(
          updatedGroupDoc.data() as Map<String, dynamic>,
          id: updatedGroupDoc.id,
        );
        expect(
          approxEqual(updatedGroup.balance[member.uid]![admin.uid]!, 50),
          isTrue,
        );
      });

      test('throws not found exception if expense does not exist', () async {
        // act & assert
        final coordinationRepo = CoordinationRepository(firestore);
        expect(
          () async => await coordinationRepo.finalizeExpense('invalidId'),
          throwsA(isA<EntityNotFoundException<Expense>>()),
        );
      });

      test('throws not found exception if expense is tied to an invalid group',
          () async {
        // arrange
        final invalidExpense = Expense(
          authorUid: 'uid',
          name: 'Test Expense',
          groupId: 'invalidGroupId',
        );

        final expenseRef =
            firestore.collection('expenses').doc(invalidExpense.id);
        await expenseRef.set(invalidExpense.toFirestore());

        // act & assert
        final coordinationRepo = CoordinationRepository(firestore);
        expect(
          () async => await coordinationRepo.finalizeExpense(invalidExpense.id),
          throwsA(isA<EntityNotFoundException<Group>>()),
        );
      });
    });

    group('revertExpense', () {
      test('removes finalization and creates reverse payments', () async {
        // arrange
        testGroup.balance = {
          admin.uid: {member.uid: -50},
          member.uid: {admin.uid: 50},
        };
        testExpense.finalizedDate = DateTime.now();

        final groupRef = firestore.collection('groups').doc(testGroup.id);
        await groupRef.set(testGroup.toFirestore());
        final expenseRef = firestore.collection('expenses').doc(testExpense.id);
        await expenseRef.set(testExpense.toFirestore());

        // act
        final coordinationRepo = CoordinationRepository(firestore);
        await coordinationRepo.revertExpense(testExpense.id);

        // assert
        final updatedExpenseDoc = await expenseRef.get();
        final updatedExpense = Expense.fromFirestore(
          updatedExpenseDoc.data()!,
          updatedExpenseDoc.id,
        );
        expect(updatedExpense.finalizedDate, isNull);

        final paymentsSnapshot = await firestore.collection('payments').get();
        expect(paymentsSnapshot.docs.length, 1);
        final payments =
            paymentsSnapshot.docs.map(Payment.fromFirestore).toList();
        final payment1 = payments[0];
        expect(payment1.payerId, member.uid);
        expect(payment1.receiverId, admin.uid);
        expect(approxEqual(payment1.value, 50), true);

        final updatedGroupDoc = await groupRef.get();
        final updatedGroup = Group.fromFirestore(
          updatedGroupDoc.data() as Map<String, dynamic>,
          id: updatedGroupDoc.id,
        );
        expect(
          approxEqual(updatedGroup.balance[member.uid]![admin.uid]!, 0),
          isTrue,
        );
      });
    });
  });
}
