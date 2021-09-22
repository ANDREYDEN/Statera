import 'package:flutter/cupertino.dart';
import 'package:statera/models/expense.dart';
import 'package:statera/models/group.dart';
import 'package:statera/services/firestore.dart';

class GroupViewModel extends ChangeNotifier {
  Group? _group;

  Group get group {
    if (_group == null)
      return Group.fake();
    return _group!;
  }

  set group(Group? value) {
    _group = value;
    notifyListeners();
  }

  bool get hasGroup => _group != null;

  Stream<List<Expense>> getUnmarkedExpenses(String uid) =>
      Firestore.instance.listenForUnmarkedExpenses(this.group.id, uid);
}
