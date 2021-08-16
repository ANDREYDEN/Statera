import 'package:firebase_auth/firebase_auth.dart';
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

  void removeUser(User user) {
    this.members.removeWhere((member) => member.uid == user.uid);
    this.balance.remove(user.uid);
    this.balance.forEach((key, value) => value.remove(user.uid));
  }

  Map<Author, double> extendedBalance(String consumerUid) {
    return this.balance[consumerUid]!.map(
          (uid, balance) => MapEntry(
              this.members.where((member) => member.uid == uid).first, balance),
        );
  }

  void payOffBalance(
      {required String payerUid,
      required String receiverUid,
      required double value}) {
    if (this.members.every((member) => member.uid != payerUid)) {
      throw new Exception(
          "User with id $payerUid is not a member of group $name");
    }
    if (this.members.every((member) => member.uid != receiverUid)) {
      throw new Exception(
          "User with id $receiverUid is not a member of group $name");
    }

    this.balance[payerUid]![receiverUid] =
        this.balance[payerUid]![receiverUid]! - value;
    this.balance[receiverUid]![payerUid] =
        this.balance[receiverUid]![payerUid]! + value;
  }

  void resolveBalance(String member1Uid, String member2Uid) {
    this.balance[member1Uid]![member2Uid] = 0;
    this.balance[member2Uid]![member1Uid] = 0;
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
