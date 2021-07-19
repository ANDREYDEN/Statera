import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:statera/models/author.dart';
import 'package:statera/utils/helpers.dart';

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
    this.name = "foo";
    this.members = [];
    this.balance = {};
    if (members != null) {
      this.members = members;
      this.balance = createBalanceFromMembers(members);
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

  void generateCode() {
    code = "";
    for (var i = 0; i < 5; i++) {
      code = code! + getRandomLetter();
    }
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
      name: map['name'],
      members: members,
      code: map['code'],
      balance: map['balance'] == null
          ? null
          : Map<String, Map<String, double>>.from(map['balance'].map(
              (uid, balance) =>
                  MapEntry(uid, Map<String, double>.from(balance)))),
      id: id,
    );
  }

  void removeUser(User user) {
    this.members.removeWhere((member) => member.uid == user.uid);
    this.balance.remove(user.uid);
    this.balance.forEach((key, value) => value.remove(user.uid));
  }
}
