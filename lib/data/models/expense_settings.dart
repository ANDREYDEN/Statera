class ExpenseSettings {
  /// Controls wether to add new group members to this expense
  bool acceptNewMembers;

  /// Controls wether to display individual item decisions made by expense asssignees.
  bool showItemDecisions;

  ExpenseSettings({
    this.acceptNewMembers = true,
    this.showItemDecisions = true,
  });

  ExpenseSettings.fromFirestore(Map<String, dynamic> data)
      : this.acceptNewMembers = data['acceptNewMembers'] ?? true,
        this.showItemDecisions = data['showItemDecisions'] ?? true;

  Map<String, dynamic> toFirestore() {
    return {
      'acceptNewMembers': acceptNewMembers,
      'showItemDecisions': showItemDecisions,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ExpenseSettings &&
        acceptNewMembers == other.acceptNewMembers &&
        showItemDecisions == other.showItemDecisions;
  }

  @override
  int get hashCode {
    return acceptNewMembers.hashCode ^ showItemDecisions.hashCode;
  }
}
