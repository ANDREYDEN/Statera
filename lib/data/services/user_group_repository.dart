import 'package:statera/data/models/user_group.dart';
import 'package:statera/data/services/services.dart';

class UserGroupRepository extends Firestore {
  UserGroupRepository(super.firestoreInstance);

  Future<void> toggleArchive(UserGroup userGroup, String uid) async {
    userGroup.archived = !userGroup.archived;
    await getUserGroupsCollection(uid)
        .doc(userGroup.groupId)
        .set(userGroup.toFirestore());
  }

  Stream<List<UserGroup>> userGroupsStream(String? uid) {
    return usersCollection
        .doc(uid)
        .collection('groups')
        .snapshots()
        .map((event) => event.docs.map(UserGroup.fromSnapshot).toList());
  }
}
