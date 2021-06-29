enum ExpenseDecision {
  Undefined,
  Confirmed,
  Denied
}

const edToString = {
  ExpenseDecision.Undefined: "Undefined",
  ExpenseDecision.Confirmed: "Confirmed",
  ExpenseDecision.Denied: "Denied",
};

const edFromString = {
  "Undefined": ExpenseDecision.Undefined,
  "Confirmed": ExpenseDecision.Confirmed,
  "Denied": ExpenseDecision.Denied,
};

class Assignee {
  String uid;
  ExpenseDecision decision = ExpenseDecision.Undefined;

  Assignee({required this.uid, ExpenseDecision? decision}) {
    if (decision != null) {
      this.decision = decision;
    }
  }

  bool get madeDecision => decision != ExpenseDecision.Undefined;

  Map<String, dynamic> toFirestore() {
    return {
      "uid": uid,
      "decision": edToString[decision]
    };
  }

  static Assignee fromFirestore(Map<String, dynamic> data) {
    var dataDecision = data["decision"];
    return Assignee(uid: data["uid"], decision: edFromString[dataDecision]);
  }
}