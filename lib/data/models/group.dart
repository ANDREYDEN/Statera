import 'package:firebase_auth/firebase_auth.dart';
import 'package:statera/data/models/payment.dart';
import 'package:statera/utils/helpers.dart';

import 'author.dart';
import 'expense.dart';

class Group {
  String? id;
  late String name;
  late List<Author> members = [];
  late Map<String, Map<String, double>> balance;
  String? code;

  Group({required this.name, this.code, this.id, members, balance}) {
    this.members = [];
    this.balance = {};
    if (members != null) {
      this.members = members;
      this.balance = balance ?? createBalanceFromMembers(members);
    }
  }

  Group.fake({List<Author>? members}) {
    this.name = "Empty";
    this.members = [];
    this.balance = {};
    if (members != null) {
      this.members = members;
      this.balance = createBalanceFromMembers(members);
    }
  }

  void generateCode() {
    code = "";
    for (var i = 0; i < 5; i++) {
      code = code! + getRandomLetter();
    }
  }

  static Map<String, Map<String, double>> createBalanceFromMembers(
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

  Author? getUser(String uid) {
    return this.members.firstWhere((member) => member.uid == uid, orElse: null);
  }

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

  void removeUser(User user) {
    this.members.removeWhere((member) => member.uid == user.uid);
    this.balance.remove(user.uid);
    this.balance.forEach((key, value) => value.remove(user.uid));
  }

  Map<Author, double> extendedBalance(String consumerUid) {
    return this.balance[consumerUid]!.map(
          (uid, balance) => MapEntry(
            this.members.where((member) => member.uid == uid).first,
            balance,
          ),
        );
  }

  void payOffBalance({required Payment payment}) {
    if (this.members.every((member) => member.uid != payment.payerId)) {
      throw new Exception(
          "User with id ${payment.payerId} is not a member of group $name");
    }
    if (this.members.every((member) => member.uid != payment.receiverId)) {
      throw new Exception(
          "User with id ${payment.receiverId} is not a member of group $name");
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
      'balance': balance
    };
  }

  factory Group.fromFirestore(Map<String, dynamic> map, {required String? id}) {
    var members = List<Author>.from(
      map['members']?.map((x) => Author.fromFirestore(x)),
    );

    return Group(
      id: id,
      name: map['name'],
      members: members,
      code: map['code'],
      balance: map['balance'] == null
          ? null
          : Map<String, Map<String, double>>.from(map['balance'].map(
              (uid, balance) => MapEntry(
                uid,
                Map<String, double>.from(
                  (balance as Map<String, dynamic>).map((otherUid, value) =>
                      MapEntry(otherUid, double.tryParse(value.toString()))),
                ),
              ),
            )),
    );
  }
}
