import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'contact.g.dart';

@JsonSerializable()
class Contact {
  late final String uid;
  late final String name;
  late final String? photoURL;

  Contact({required this.uid, required this.name, this.photoURL});

  static Contact fromJson(Map<String, dynamic> data) => _$ContactFromJson(data);

  static Contact fromSnapshot(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>;
    return fromJson(data)..uid = snap.id;
  }

  Map<String, dynamic> toJson() => _$ContactToJson(this);
}
