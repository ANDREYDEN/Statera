class PaymentRedirectInfo {
  String authorUid;

  PaymentRedirectInfo({
    required this.authorUid,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'authorUid': authorUid,
    };
  }

  factory PaymentRedirectInfo.fromFirestore(Map<String, dynamic> map) {
    return PaymentRedirectInfo(
      authorUid: map['authorUid'],
    );
  }
}
