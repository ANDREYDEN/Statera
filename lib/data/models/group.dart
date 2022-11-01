import 'package:firebase_auth/firebase_auth.dart';
import 'package:statera/data/models/payment.dart';
import 'package:statera/utils/helpers.dart';

import 'author.dart';
import 'expense.dart';

/// Describes a group of users sharing expenses
class Group {
  String? id;
  late String name;
  late List<Author> members = [];
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

  static const String kdefaultCurrencySign = '\$';
  static const double kdefaultDebtThreshold = 50;

  Group({
    required this.name,
    this.code,
    this.id,
    members,
    String? adminId,
    balance,
    String? currencySign,
    this.inviteLink,
    double? debtThreshold,
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
  }

  Group.empty({
    String? name,
    String? code,
    List<Author>? members,
    String? adminId,
  }) : this(
          name: name ?? 'Empty',
          code: code,
          members: members,
          adminId: adminId,
        );

  Author get admin => _adminId != null ? getMember(_adminId!) : members.first;

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
    List<Author> members,
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

  Author getMember(String uid) =>
      this.members.firstWhere((member) => member.uid == uid);

  void addUser(User user) {
    var newAuthor = Author.fromUser(user);
    this.members.add(newAuthor);
    this.balance.keys.forEach((uid) {
      this.balance[uid]![newAuthor.uid] = 0;
    });
    this.balance[newAuthor.uid] = Map.fromEntries(
      this.balance.entries.map((entry) => MapEntry(entry.key, 0)),
    );
  }

  void removeUser(String uid) {
    this.members.removeWhere((member) => member.uid == uid);
    this.balance.remove(uid);
    this.balance.forEach((key, value) => value.remove(uid));
  }

  Map<Author, double> getOwingsForUser(String uid) {
    return this
        .balance[uid]!
        .map((otherUid, balance) => MapEntry(getMember(otherUid), balance));
  }

  void payOffBalance({required Payment payment}) {
    if (this.members.every((member) => member.uid != payment.payerId)) {
      throw new Exception(
          'User with id ${payment.payerId} is not a member of group $name');
    }
    if (this.members.every((member) => member.uid != payment.receiverId)) {
      throw new Exception(
          'User with id ${payment.receiverId} is not a member of group $name');
    }

    this.balance[payment.payerId]![payment.receiverId] =
        this.balance[payment.payerId]![payment.receiverId]! - payment.value;
    this.balance[payment.receiverId]![payment.payerId] =
        this.balance[payment.receiverId]![payment.payerId]! + payment.value;
  }

  void updateBalance(Expense expense) {
    expense.assignees
        .where((assignee) => assignee.uid != expense.author.uid)
        .forEach((assignee) {
      this.payOffBalance(
        payment: Payment(
          groupId: this.id,
          payerId: expense.author.uid,
          receiverId: assignee.uid,
          value: expense.getConfirmedTotalForUser(assignee.uid),
        ),
      );
    });
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'members': members.map((x) => x.toFirestore()).toList(),
      'code': code,
      'memberIds': members.map((x) => x.uid).toList(),
      'adminId': admin.uid,
      'balance': balance,
      'currencySign': currencySign,
      'inviteLink': inviteLink,
      'debtThreshold': debtThreshold,
    };
  }

  factory Group.fromFirestore(Map<String, dynamic> map, {required String? id}) {
    var members = List<Author>.from(
      (map['members'] ?? []).map((x) => Author.fromFirestore(x)),
    );

    return Group(
      id: id,
      name: map['name'],
      members: members,
      adminId: map['adminId'],
      code: map['code'],
      balance: map['balance'] == null
          ? null
          : Map<String, Map<String, double>>.from(
              map['balance'].map(
                (uid, balance) => MapEntry(
                  uid,
                  Map<String, double>.from(
                    (balance as Map<String, dynamic>).map((otherUid, value) =>
                        MapEntry(otherUid, double.tryParse(value.toString()))),
                  ),
                ),
              ),
            ),
      currencySign: map['currencySign'],
      inviteLink: map['inviteLink'],
      debtThreshold: double.tryParse(map['debtThreshold'].toString()),
    );
  }
}
