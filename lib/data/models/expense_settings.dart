import 'package:json_annotation/json_annotation.dart';

part 'expense_settings.g.dart';

@JsonSerializable()
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

  factory ExpenseSettings.fromJson(Map<String, dynamic> data) =>
      _$ExpenseSettingsFromJson(data);

  Map<String, dynamic> toJson() => _$ExpenseSettingsToJson(this);

  static ExpenseSettings from(ExpenseSettings other) {
    return ExpenseSettings(
      acceptNewMembers: other.acceptNewMembers,
      showItemDecisions: other.showItemDecisions,
      itemsAreTaxableByDefault: other.itemsAreTaxableByDefault,
      tax: other.tax,
      tip: other.tip,
    );
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
