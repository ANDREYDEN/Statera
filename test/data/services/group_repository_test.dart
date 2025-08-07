import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/services.dart';

main() {
  group('GroupRepository', () {
    group('addMember', () {
      test('adds a new member to group', () async {
        // arrange
        final firestore = FakeFirebaseFirestore();

        final admin = CustomUser.fake(uid: 'admin');
        final testGroup = Group(
          id: 'testGroupId',
          name: 'Foo',
          code: 'bar',
          adminId: admin.uid,
          members: [admin],
        );

        await firestore
            .collection('groups')
            .doc(testGroup.id)
            .set(testGroup.toFirestore());

        // act
        final groupService = GroupRepository(firestore);
        final newUser = CustomUser.fake();
        await groupService.addMember(testGroup.code!, newUser);

        // assert
        final updatedGroupDoc =
            await firestore.collection('groups').doc(testGroup.id).get();
        final updatedGroup = Group.fromFirestore(
          updatedGroupDoc.data() as Map<String, dynamic>,
          id: updatedGroupDoc.id,
        );

        expect(updatedGroup.members.map((m) => m.uid), contains(newUser.uid));
      });
    });
  });
}
