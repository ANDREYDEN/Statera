import 'package:statera/data/models/user_group.dart';
import 'package:statera/data/services/services.dart';

class UserGroupRepository extends Firestore {
  UserGroupRepository(super.firestoreInstance);

  Future<void> saveUserGroup(String uid, UserGroup userGroup) async {
    await getUserGroup(uid, userGroup.groupId).set(userGroup.toFirestore());
  }

  Stream<List<UserGroup>> userGroupsStream(String uid) {
    return getUserGroupsCollection(uid)
        .snapshots()
        .map((event) => event.docs.map(UserGroup.fromSnapshot).toList());
  }
}
