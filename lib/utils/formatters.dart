import 'package:flutter/services.dart';

class CommaReplacerTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String truncated = newValue.text;
    TextSelection newSelection = newValue.selection;

    truncated = newValue.text.replaceAll(RegExp(','), '.');
    return TextEditingValue(
      text: truncated,
      selection: newSelection,
    );
  }
}

class SingleCharacterTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) =>
      newValue.text.length > 1 ? oldValue : newValue;
}
