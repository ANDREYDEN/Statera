import 'package:statera/models/assignee.dart';
import 'package:statera/models/item.dart';

class User {
  String uid;

  User({
    required this.uid,
  });
}

class AuthenticationViewModel {
  User user;

  AuthenticationViewModel({
    required this.user,
  });

  bool isConfirmed(Item item) {
    return item.assigneeDecision(user.uid) == ExpenseDecision.Confirmed;
  }

  bool isDenied(Item item) {
    return item.assigneeDecision(user.uid) == ExpenseDecision.Denied;
  }

  String getNameByUID(String uid) {
    return "Andrew";
  }
}
