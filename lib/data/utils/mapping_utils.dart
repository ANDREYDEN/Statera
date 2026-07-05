Map<String, Map<String, double>>? mapBalance(dynamic balanceData) {
  if (balanceData == null) return null;

  return Map<String, Map<String, double>>.from(
    balanceData.map(
      (uid, balance) => MapEntry(
        uid,
        Map<String, double>.from(
          (balance as Map<String, dynamic>).map((otherUid, value) =>
              MapEntry(otherUid, double.tryParse(value.toString()))),
        ),
      ),
    ),
  );
}

double? mapDouble(dynamic value) {
  if (value == null) return null;

  return double.tryParse(value.toString());
}