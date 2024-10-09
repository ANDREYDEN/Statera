import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

extension WidgetTesterExtensions on WidgetTester {
  Future<void> enterTextByLabel(String label, String text) async {
    var field = find.ancestor(
      of: find.text(label),
      matching: find.byType(TextField),
    );
    await enterText(field, text);
  }
}
