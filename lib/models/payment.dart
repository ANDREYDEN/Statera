class Payment {
  String? groupId;
  late String payerId;
  late String receiverId;
  late double value;

  Payment({
    required this.groupId,
    required this.payerId,
    required this.receiverId,
    required this.value,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'groupId': groupId,
      'payerId': payerId,
      'receiverId': receiverId,
      'value': value,
    };
  }

  factory Payment.fromFirestore(Map<String, dynamic> map) {
    return Payment(
      groupId: map['groupId'],
      payerId: map['payerId'],
      receiverId: map['receiverId'],
      value: map['value'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Payment &&
        other.payerId == payerId &&
        other.receiverId == receiverId &&
        other.value == value;
  }

  @override
  int get hashCode => payerId.hashCode ^ receiverId.hashCode ^ value.hashCode;
}
