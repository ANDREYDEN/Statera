import 'package:statera/models/group.dart';

class GroupViewModel {
  Group? _group;

  Group get group {
    if (_group == null) throw Exception("Trying to get a group but nothing is chosen.");
    return _group!;
  }

  set group(Group value) {
    _group = value;
  }
}