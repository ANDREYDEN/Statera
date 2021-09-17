import 'dart:math';

class AssigneeDecision {
  String uid;
  int? _parts; // if the value is null, then the decision has not been taken yet

  AssigneeDecision({required this.uid, int? parts}) {
    this._parts = parts;
  }

  int? get parts => _parts;
  set parts(int? value) => _parts = value == null ? null : max(value, 0);

  bool get madeDecision => _parts != null;

  Map<String, dynamic> toFirestore() {
    return {
      "uid": uid,
      "parts": _parts,
    };
  }

  // TODO: write an admin script to eliminate this
  static int? getPartsFromLegacyDecision(Map<String, dynamic> data) {
    if (!data.containsKey("decision")) return null;
    switch (data["decision"]) {
      case "Undefined":
        return null;
      case "Confirmed":
        return 1;
      case "Denied":
        return 0;
    }
  }

  static AssigneeDecision fromFirestore(Map<String, dynamic> data) {
    return AssigneeDecision(
      uid: data["uid"],
      parts: data.containsKey("parts")
          ? data["parts"]
          : getPartsFromLegacyDecision(data),
    );
  }
}
