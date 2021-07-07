import 'package:firebase_auth/firebase_auth.dart';
import 'package:statera/models/assignee.dart';
import 'package:statera/models/group.dart';
import 'package:statera/models/item.dart';
import 'package:statera/services/auth.dart';
import 'package:statera/services/firestore.dart';

class AuthenticationViewModel {
  User? _user;

  AuthenticationViewModel() {
    this._user = Auth.instance.currentUser;
    Auth.instance.currentUserStream().listen((user) {
      this._user = user;
    });
  }

  User get user {
    if (_user == null)
      throw new Exception('Trying to get user when not signed in.');
    return _user!;
  }

  bool hasConfirmed(Item item) {
    return item.assigneeDecision(user.uid) == ExpenseDecision.Confirmed;
  }

  bool hasDenied(Item item) {
    return item.assigneeDecision(user.uid) == ExpenseDecision.Denied;
  }

  Future<void> createGroup(Group newGroup) async {
    newGroup.addUser(user);
    await Firestore.instance.groupsCollection.add(newGroup.toFirestore());
  }

  Future<void> joinGroup(String groupCode) async {
    var group = await Firestore.instance.getGroup(groupCode);
    group.addUser(user);
    await Firestore.instance.groupsCollection
        .doc(group.id)
        .update(group.toFirestore());
  }
}
