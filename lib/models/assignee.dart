class Assignee {
  String uid;
  bool paid;

  Assignee({
    required this.uid,
    this.paid = false,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'paid': paid,
    };
  }

  factory Assignee.fromFirestore(Map<String, dynamic> map) {
    return Assignee(
      uid: map['uid'],
      paid: map['paid'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Assignee &&
      other.uid == uid &&
      other.paid == paid;
  }

  @override
  int get hashCode => uid.hashCode ^ paid.hashCode;
}
