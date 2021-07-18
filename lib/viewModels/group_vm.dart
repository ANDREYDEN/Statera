import 'package:statera/models/expense.dart';
import 'package:statera/models/group.dart';
import 'package:statera/services/firestore.dart';

class GroupViewModel {
  Group? _group;

  Group get group {
    if (_group == null)
      throw Exception("Trying to get a group but nothing is chosen.");
    return _group!;
  }

  Stream<List<Expense>> getUnmarkedExpenses(String uid) =>
      Firestore.instance.listenForUnmarkedExpenses(this.group.id, uid);

  set group(Group value) {
    _group = value;
  }
}
