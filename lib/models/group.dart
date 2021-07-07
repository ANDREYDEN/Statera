import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';

import 'package:statera/models/Author.dart';

class Group {
  String? id;
  String name;
  late List<Author> members;
  String? code;

  Group({
    required this.name,
    this.code,
    this.id,
    members
  }) {
    this.members = members ?? [];
  }

  void generateCode() {
    code = "foo";
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'members': members.map((x) => x.toFirestore()).toList(),
      'code': code,
      'memberIds': members.map((x) => x.uid).toList()
    };
  }

  factory Group.fromFirestore(Map<String, dynamic> map, { String? id }) {
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
