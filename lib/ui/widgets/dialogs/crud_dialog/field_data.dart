part of 'crud_dialog.dart';

typedef Validator = String Function(String);

class FieldData {
  String id;
  String label;
  late TextEditingController controller;
  late FocusNode focusNode;
  TextInputType inputType;
  dynamic initialData;
  List<Validator> validators;
  List<TextInputFormatter> formatters;
  bool isAdvanced;

  FieldData({
    required this.id,
    required this.label,
    this.initialData,
    TextEditingController? controller,
    this.validators = const [],
    this.formatters = const [],
    this.inputType = TextInputType.text,
    this.isAdvanced = false,
  }) {
    this.controller = controller ?? TextEditingController();
    resetController();
    this.focusNode = FocusNode(debugLabel: this.id);
  }

  static String requiredValidator(String text) =>
      text.isEmpty ? "Can't be empty" : '';
  static String doubleValidator(String text) =>
      double.tryParse(text) == null ? 'Must be a number' : '';
  static String intValidator(String text) =>
      int.tryParse(text) == null ? 'Must be a whole number' : '';

  String getError() {
    for (final validator in validators) {
      var error = validator(controller.text);
      if (error.isNotEmpty) return error;
    }
    return '';
  }

  void resetController() {
    controller.text = initialData?.toString() ?? '';
  }
}