import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:statera/models/author.dart';
import 'package:statera/utils/helpers.dart';

class Group {
  String? id;
  late String name;
  late List<Author> members = [];
  String? code;

  Group({
    required this.name,
    this.code,
    this.id,
    members
  }) {
    this.members = members;
  }


  Group.fake() {
    this.name = "foo";
  }

  void addUser(User user) {
    this.members.add(Author.fromUser(user));
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
      'memberIds': members.map((x) => x.uid).toList()
    };
  }

  factory Group.fromFirestore(Map<String, dynamic> map, { required String? id }) {
    return Group(
      name: map['name'],
      members: List<Author>.from(map['members']?.map((x) => Author.fromFirestore(x))),
      code: map['code'],
      id: id
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Group &&
      other.name == name &&
      listEquals(other.members, members) &&
      other.code == code;
  }

  @override
  int get hashCode => name.hashCode ^ members.hashCode ^ code.hashCode;
}
