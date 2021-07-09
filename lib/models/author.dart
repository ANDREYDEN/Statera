import 'package:firebase_auth/firebase_auth.dart';

class Author {
  late String uid;
  late String name;

  Author({required this.uid, required this.name});

  Author.fromUser(User user) {
    this.uid = user.uid;
    this.name = user.displayName ?? 'anonymous';
  }

  static Author fromFirestore(Map<String, dynamic> data) {
    return Author(uid: data['uid'], name: data['name']);
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'name': name
    };
  }
}