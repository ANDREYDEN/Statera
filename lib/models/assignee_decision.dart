import 'dart:math';

enum ProductDecision { Undefined, Confirmed, Denied }

const pdToString = {
  ProductDecision.Undefined: "Undefined",
  ProductDecision.Confirmed: "Confirmed",
  ProductDecision.Denied: "Denied",
};

const pdFromString = {
  "Undefined": ProductDecision.Undefined,
  "Confirmed": ProductDecision.Confirmed,
  "Denied": ProductDecision.Denied,
};

class AssigneeDecision {
  String uid;
  ProductDecision decision = ProductDecision.Undefined;
  int? _parts;

  AssigneeDecision({required this.uid, int? parts, ProductDecision? decision}) {
    if (decision != null) {
      this.decision = decision;
      this._parts = parts;
    }
  }

  int get parts => decision == ProductDecision.Undefined
      ? 0
      : _parts ?? (decision == ProductDecision.Confirmed ? 1 : 0);
  set parts(int value) => _parts = max(value, 0);

  bool get madeDecision => decision != ProductDecision.Undefined;

  Map<String, dynamic> toFirestore() {
    return {
      "uid": uid,
      "decision": pdToString[decision],
      "parts": _parts,
    };
  }

  static AssigneeDecision fromFirestore(Map<String, dynamic> data) {
    var dataDecision = data["decision"];
    return AssigneeDecision(
      uid: data["uid"],
      decision: pdFromString[dataDecision],
      parts: data["parts"],
    );
  }
}
