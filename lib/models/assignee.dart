enum ExpenseDecision {
  Undefined,
  Confirmed,
  Denied
}

class Assignee {
  String uid;
  ExpenseDecision decision = ExpenseDecision.Undefined;

  Assignee({required this.uid});
}