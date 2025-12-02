import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/utils/mapping_utils.dart';
import 'package:statera/data/value_objects/redirect.dart';
import 'package:statera/utils/helpers.dart';

/// Describes a group of users sharing expenses
class Group {
  String? id;
  late String name;
  late List<CustomUser> members = [];
  String? _adminId;

  /// Describes the debt that each member of the group has
  ///
  /// For example, the following configuration describes that Alice owes Bob $145:
  ///
  /// ```balance: {
  ///   Alice: {
  ///     Bob: 145
  ///   },
  ///   Bob: {
  ///     Alice: -145
  ///   }
  /// }```
  late Map<String, Map<String, double>> balance;
  String? code;
  late String currencySign;
  String? inviteLink;
  late double debtThreshold;
  late ExpenseSettings defaultExpenseSettings;
  bool supportsDebtRedirection;

  static const String kdefaultCurrencySign = '\$';
  static const double kdefaultDebtThreshold = 50;

  Group({
    required this.name,
    this.code,
    this.id,
    List<CustomUser>? members,
    String? adminId,
    Map<String, Map<String, double>>? balance,
    String? currencySign,
    this.inviteLink,
    double? debtThreshold,
    ExpenseSettings? defaultExpenseSettings,
    this.supportsDebtRedirection = false,
  }) {
    this.members = [];
    this.balance = {};
    if (members != null) {
      this.members = members;
      this.balance = balance ?? _createBalanceFromMembers(members);
    }
    this.currencySign = currencySign ?? kdefaultCurrencySign;
    this.debtThreshold = debtThreshold ?? kdefaultDebtThreshold;
    if (code == null) _generateCode();
    this._adminId = adminId;
    this.defaultExpenseSettings = defaultExpenseSettings ?? ExpenseSettings();
  }

  Group.empty({
    String? name,
    String? code,
    List<CustomUser>? members,
    String? adminId,
  }) : this(
         name: name ?? 'Empty',
         code: code,
         members: members,
         adminId: adminId,
       );

  CustomUser get admin =>
      _adminId != null ? getMember(_adminId!) : members.first;

  set adminUid(String uid) {
    if (!memberExists(uid))
      throw Exception('Member with id $uid does not exist in group "$name"');
    _adminId = uid;
  }

  bool isAdmin(String uid) => uid == admin.uid;

  void _generateCode() {
    code = '';
    for (var i = 0; i < 5; i++) {
      code = code! + getRandomLetter();
    }
  }

  String renderPrice(double value) =>
      '$currencySign${value.toStringAsFixed(2)}';

  static Map<String, Map<String, double>> _createBalanceFromMembers(
    List<CustomUser> members,
  ) {
    return Map.fromEntries(
      members.map(
        (member) => MapEntry(
          member.uid,
          Map.fromEntries(
            members
                .where((otherMember) => otherMember.uid != member.uid)
                .map((otherMember) => MapEntry(otherMember.uid, 0)),
          ),
        ),
      ),
    );
  }

  bool memberExists(String uid) =>
      this.members.any((member) => member.uid == uid);

  CustomUser getMember(String uid) => this.members.firstWhere(
    (member) => member.uid == uid,
    orElse: () => CustomUser.inactive(),
  );

  void addMember(CustomUser member) {
    this.members.add(member);
    this.balance.keys.forEach((uid) {
      this.balance[uid]![member.uid] = 0;
    });
    this.balance[member.uid] = Map.fromEntries(
      this.balance.entries.map((entry) => MapEntry(entry.key, 0)),
    );
  }

  void removeMember(String uid) {
    this.members.removeWhere((member) => member.uid == uid);
    this.balance.remove(uid);
    this.balance.forEach((key, value) => value.remove(uid));
  }

  Map<CustomUser, double> getOwingsForUser(String uid) {
    return this.balance[uid]!.map(
      (otherUid, balance) => MapEntry(getMember(otherUid), balance),
    );
  }

  void payOffBalance({required Payment payment}) {
    if (this.members.every((member) => member.uid != payment.payerId)) {
      throw new Exception(
        'User with id ${payment.payerId} is not a member of group $name',
      );
    }
    if (this.members.every((member) => member.uid != payment.receiverId)) {
      throw new Exception(
        'User with id ${payment.receiverId} is not a member of group $name',
      );
    }

    this.balance[payment.payerId]![payment.receiverId] =
        this.balance[payment.payerId]![payment.receiverId]! - payment.value;
    this.balance[payment.receiverId]![payment.payerId] =
        this.balance[payment.receiverId]![payment.payerId]! + payment.value;
  }

  bool canRedirect(String uid) {
    final owers = getMembersThatOweToMember(uid);
    final receivers = getMembersThatMemberOwesTo(uid);

    return owers.isNotEmpty && receivers.isNotEmpty;
  }

  Redirect estimateRedirect({
    required String authorUid,
    required String owerUid,
    required String receiverUid,
  }) {
    final newOwerDebt = max(
      0.0,
      this.balance[owerUid]![authorUid]! -
          this.balance[authorUid]![receiverUid]!,
    );
    final newAuthorDebt = max(
      0.0,
      this.balance[authorUid]![receiverUid]! -
          this.balance[owerUid]![authorUid]!,
    );
    final redirectedBalance = min(
      this.balance[owerUid]![authorUid]!,
      this.balance[authorUid]![receiverUid]!,
    );

    return Redirect(
      owerUid,
      newOwerDebt,
      authorUid,
      newAuthorDebt,
      receiverUid,
      redirectedBalance,
    );
  }

  (String, String) getBestRedirect(String uid) {
    if (!this.canRedirect(uid)) {
      throw Exception('User with id $uid cannot redirect debt');
    }

    final owerUids = getMembersThatOweToMember(uid);
    final receiverUids = getMembersThatMemberOwesTo(uid);

    final bestOwerUid = owerUids.reduce((best, current) {
      if (this.balance[current]![uid]! > this.balance[best]![uid]!) {
        return current;
      }

      return best;
    });

    final bestReceiverUid = receiverUids.reduce((best, current) {
      if (this.balance[uid]![current]! > this.balance[uid]![best]!) {
        return current;
      }

      return best;
    });

    return (bestOwerUid, bestReceiverUid);
  }

  List<String> getMembersThatOweToMember(String uid) {
    return this.balance.keys
        .where((otherUid) => (this.balance[otherUid]![uid] ?? 0) > 0)
        .toList();
  }

  List<String> getMembersThatMemberOwesTo(String uid) {
    return this.balance.keys
        .where((otherUid) => (this.balance[uid]![otherUid] ?? 0) > 0)
        .toList();
  }

  bool memberHasOutstandingBalance(String uid) {
    return getMembersThatOweToMember(uid).isNotEmpty ||
        getMembersThatMemberOwesTo(uid).isNotEmpty;
  }

  Map<String, Map<String, double>> getFirestoreBalance() {
    return Map.fromEntries(
      this.balance.entries.map(
        (memberEntry) => MapEntry(
          memberEntry.key,
          Map.fromEntries(
            memberEntry.value.entries.map(
              (entry) => MapEntry(entry.key, round(entry.value, 2)),
            ),
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'members': members.map((x) => x.toFirestore()).toList(),
      'code': code,
      'memberIds': members.map((x) => x.uid).toList(),
      'adminId': admin.uid,
      'balance': getFirestoreBalance(),
      'currencySign': currencySign,
      'inviteLink': inviteLink,
      'debtThreshold': debtThreshold,
      'defaultExpenseSettings': defaultExpenseSettings.toFirestore(),
      'supportsDebtRedirection': supportsDebtRedirection,
    };
  }

  static Group fromSnapshot(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>;
    return fromFirestore(data, id: snap.id);
  }

  static Group fromFirestore(Map<String, dynamic> map, {required String? id}) {
    var members = List<CustomUser>.from(
      (map['members'] ?? []).map((x) => CustomUser.fromFirestore(x)),
    );

    return Group(
      id: id,
      name: map['name'],
      members: members,
      adminId: map['adminId'],
      code: map['code'],
      balance: mapBalance(map['balance']),
      currencySign: map['currencySign'],
      inviteLink: map['inviteLink'],
      debtThreshold: double.tryParse(map['debtThreshold'].toString()),
      defaultExpenseSettings: map['defaultExpenseSettings'] == null
          ? null
          : ExpenseSettings.fromFirestore(map['defaultExpenseSettings']),
      supportsDebtRedirection: map['supportsDebtRedirection'] ?? false,
    );
  }
}
