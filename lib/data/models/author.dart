import 'package:firebase_auth/firebase_auth.dart';

class Author {
  late String uid;
  late String name;
  String? photoURL;

  Author({required this.uid, required this.name, this.photoURL});

  Author.fromUser(User user) {
    this.uid = user.uid;
    this.name = user.displayName ?? 'anonymous';
    this.photoURL = user.photoURL;
  }

  Author.fake({ String? name, String? uid, String? photoURL}) {
    this.uid = uid ?? "foo";
    this.name = name ?? "bar";
    this.photoURL = photoURL ?? "baz";
  }

  static Author fromFirestore(Map<String, dynamic> data) {
    return Author(
      uid: data['uid'],
      name: data['name'],
      photoURL: data['photoURL'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'name': name,
      'photoURL': photoURL,
    };
  }
}
