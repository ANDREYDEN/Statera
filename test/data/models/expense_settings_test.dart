import 'package:flutter_test/flutter_test.dart';
import 'package:statera/data/models/expense_settings.dart';

void main() {
  group('ExpenseSettings', () {
    group('fromFirestore', () {
      test('handles int values in double fields', () {
        final expenseSettings = ExpenseSettings.fromFirestore({'tax': 0});

        expect(expenseSettings.tax, 0.0);
      });

      test('handles invalid values in double fields', () {
        final expenseSettings = ExpenseSettings.fromFirestore({'tax': 'invalid'});

        expect(expenseSettings.tax, isNull);
      });
    });
  });
}
