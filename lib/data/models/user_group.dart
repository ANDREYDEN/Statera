import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:statera/data/enums/enums.dart';
import 'package:statera/data/utils/mapping_utils.dart';
import 'package:statera/utils/helpers.dart';

class UserGroup {
  String groupId;
  String name;
  int unmarkedExpenses;
  int memberCount;
  bool archived;
  bool pinned;
  Map<String, Map<String, double>>? balance;

  UserGroup({
    required this.groupId,
    required this.name,
    this.unmarkedExpenses = 0,
    this.memberCount = 0,
    this.archived = false,
    this.pinned = false,
    this.balance,
  });

  void toggleArchive() {
    if (archived) {
      archived = false;
      return;
    }

    pinned = false;
    archived = true;
  }

  double getDebt(DebtDirection debtDirection, String uid) {
    final balanceRef = balance;
    if (balanceRef == null) return 0;

    if (!balanceRef.containsKey(uid)) {
      throw Exception('User ($uid) is not part of group ($name)');
    }

    return balanceRef[uid]!
        .values
        .where((v) => (v > 0) ^ (debtDirection == DebtDirection.inward))
        .sum
        .abs();
  }

  bool hasDebt(DebtDirection debtDirection, String uid) {
    return !approxEqual(getDebt(debtDirection, uid), 0);
  }

  Map<String, dynamic> toFirestore() {
    return {
      'groupId': groupId,
      'name': name,
      'unmarkedExpenses': unmarkedExpenses,
      'memberCount': memberCount,
      'archived': archived,
      'pinned': pinned,
      'balance': balance,
    };
  }

  static UserGroup fromFirestore(Map<String, dynamic> data, String id) {
    assert(data['name'] is String);

    return UserGroup(
      groupId: data['groupId'],
      name: data['name'],
      unmarkedExpenses: data['unmarkedExpenses'] ?? 0,
      memberCount: data['memberCount'] ?? 0,
      archived: data['archived'] ?? false,
      pinned: data['pinned'] ?? false,
      balance: mapBalance(data['balance']),
    );
  }

  static UserGroup fromSnapshot(QueryDocumentSnapshot snap) {
    return fromFirestore(snap.data() as Map<String, dynamic>, snap.id);
  }
}
