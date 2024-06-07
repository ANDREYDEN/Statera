import 'package:statera/data/models/user_group.dart';
import 'package:statera/data/services/services.dart';

class UserGroupRepository extends Firestore {
  UserGroupRepository(super.firestoreInstance);

  Stream<List<UserGroup>> userGroupsStream(String? uid) {
    return usersCollection
        .doc(uid)
        .collection('groups')
        .snapshots()
        .map((event) => event.docs.map(UserGroup.fromSnapshot).toList());
  }
}
