enum ProductDecision {
  Undefined,
  Confirmed,
  Denied
}

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

class Assignee {
  String uid;
  ProductDecision decision = ProductDecision.Undefined;

  Assignee({required this.uid, ProductDecision? decision}) {
    if (decision != null) {
      this.decision = decision;
    }
  }

  bool get madeDecision => decision != ProductDecision.Undefined;

  Map<String, dynamic> toFirestore() {
    return {
      "uid": uid,
      "decision": pdToString[decision]
    };
  }

  static Assignee fromFirestore(Map<String, dynamic> data) {
    var dataDecision = data["decision"];
    return Assignee(uid: data["uid"], decision: pdFromString[dataDecision]);
  }
}