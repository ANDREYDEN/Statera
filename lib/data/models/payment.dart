class Payment {
  String? groupId;
  String payerId;
  String receiverId;
  double value;
  String? relatedExpenseId;
  DateTime? timeCreated;

  Payment({
    required this.groupId,
    required this.payerId,
    required this.receiverId,
    required this.value,
    this.relatedExpenseId,
    this.timeCreated,
  });

  bool isReceivedBy(String? uid) => this.receiverId == uid;

  bool get hasRelatedExpense => relatedExpenseId != null;

  Map<String, dynamic> toFirestore() {
    return {
      'groupId': groupId,
      'payerId': payerId,
      'receiverId': receiverId,
      'value': value,
      'relatedExpenseId': relatedExpenseId,
      'payerReceiverId': '${payerId}_$receiverId'
    };
  }

  factory Payment.fromFirestore(Map<String, dynamic> map) {
    return Payment(
      groupId: map['groupId'],
      payerId: map['payerId'],
      receiverId: map['receiverId'],
      value: double.parse(map['value'].toString()),
      relatedExpenseId: map['relatedExpenseId'],
      timeCreated: map['timeCreated'] == null ? null : DateTime.parse(map['timeCreated'].toDate().toString())
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
