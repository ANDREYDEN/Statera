class ExpenseSettings {
  /// Controls wether to add new group members to this expense
  bool acceptNewMembers;

  /// Controls wether to display individual item decisions made by expense asssignees.
  bool showItemDecisions;

  /// Controls wether to apply tax to new items by default
  bool itemsAreTaxableByDefault;

  /// Determines how much tax should be applied to the expense (0..1)
  double? tax;

  /// Determines how much tip should be applied to the expense (0..1)
  double? tip;

  ExpenseSettings({
    this.acceptNewMembers = true,
    this.showItemDecisions = true,
    this.itemsAreTaxableByDefault = false,
    this.tax,
    this.tip,
  });

  ExpenseSettings.fromFirestore(Map<String, dynamic> data)
      : this.acceptNewMembers = data['acceptNewMembers'] ?? true,
        this.showItemDecisions = data['showItemDecisions'] ?? true,
        this.itemsAreTaxableByDefault =
            data['itemsAreTaxableByDefault'] ?? false,
        this.tax = data['tax'],
        this.tip = data['tip'];

  Map<String, dynamic> toFirestore() {
    return {
      'acceptNewMembers': acceptNewMembers,
      'showItemDecisions': showItemDecisions,
      'itemsAreTaxableByDefault': itemsAreTaxableByDefault,
      'tax': tax,
      'tip': tip
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ExpenseSettings &&
        acceptNewMembers == other.acceptNewMembers &&
        showItemDecisions == other.showItemDecisions &&
        itemsAreTaxableByDefault == other.itemsAreTaxableByDefault &&
        tax == other.tax &&
        tip == other.tip;
  }

  @override
  int get hashCode {
    return acceptNewMembers.hashCode ^
        showItemDecisions.hashCode ^
        itemsAreTaxableByDefault.hashCode ^
        tax.hashCode ^
        tip.hashCode;
  }
}
