import 'package:firebase_auth/firebase_auth.dart';
import 'package:statera/models/assignee.dart';
import 'package:statera/models/item.dart';
import 'package:statera/services/auth.dart';

class AuthenticationViewModel {
  User? _user;

  AuthenticationViewModel() {
    this._user = Auth.instance.currentUser;
    Auth.instance.currentUserStream().listen((user) {
      this._user = user;
    });
  }

  User get user {
    if (_user == null) throw new Exception('Trying to get user when not signed in.');
    return _user!;
  }

  bool isConfirmed(Item item) {
    return item.assigneeDecision(user.uid) == ExpenseDecision.Confirmed;
  }

  bool isDenied(Item item) {
    return item.assigneeDecision(user.uid) == ExpenseDecision.Denied;
  }
}
