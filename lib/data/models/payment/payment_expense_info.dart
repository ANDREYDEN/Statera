import 'package:statera/data/models/models.dart';

class PaymentExpenseInfo {
  String? id;
  String name;
  PaymentExpenseAction? action;

  PaymentExpenseInfo({
    required this.id,
    required this.name,
    this.action,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'action': action == null ? null : action!.name,
    };
  }

  factory PaymentExpenseInfo.fromFirestore(Map<String, dynamic> map) {
    return PaymentExpenseInfo(
      id: map['id'],
      name: map['name'],
      action: map['action'] == null
          ? PaymentExpenseAction.finalize
          : PaymentExpenseAction.fromFirestore(map['action']),
    );
  }

  factory PaymentExpenseInfo.fromExpense(
    Expense expense, {
    required PaymentExpenseAction action,
  }) {
    return PaymentExpenseInfo(
      id: expense.id,
      name: expense.name,
      action: action,
    );
  }
}

enum PaymentExpenseAction {
  revert('reverted'),
  finalize('finalized');

  final String name;

  const PaymentExpenseAction(this.name);

  factory PaymentExpenseAction.fromFirestore(String action) {
    return values.firstWhere((e) => e.name == action, orElse: () => finalize);
  }
}