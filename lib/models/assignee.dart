class Assignee {
  late String uid;

  Assignee({
    required this.uid,
  });

  Assignee.fake({ String? uid }) {
    this.uid = uid ?? "foo";
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
    };
  }

  factory Assignee.fromFirestore(Map<String, dynamic> map) {
    return Assignee(
      uid: map['uid'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Assignee &&
      other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;
}
