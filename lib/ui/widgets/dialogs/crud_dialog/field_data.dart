part of 'crud_dialog.dart';

typedef Validator = String Function(String);

class FieldData {
  String id;
  String label;
  late FocusNode focusNode;
  dynamic initialData;
  List<Validator> validators;
  List<TextInputFormatter> formatters;
  bool isAdvanced;

  dynamic _data;

  FieldData({
    required this.id,
    required this.label,
    this.initialData,
    TextEditingController? controller,
    this.validators = const [],
    this.formatters = const [],
    this.isAdvanced = false,
  }) {
    resetController();
    this.focusNode = FocusNode(debugLabel: this.id);
  }

  static String requiredValidator(String text) =>
      text.isEmpty ? "Can't be empty" : '';
  static String doubleValidator(String text) =>
      double.tryParse(text) == null ? 'Must be a number' : '';
  static String intValidator(String text) =>
      int.tryParse(text) == null ? 'Must be a whole number' : '';
  static String Function(String) constrainedDoubleValidator(
          double min, double max) =>
      (String text) => double.parse(text) < min
          ? 'The value should be larger than $min'
          : double.parse(text) > max
              ? 'The value should be smaller than $max'
              : '';

  dynamic get data => _data;

  void set data(dynamic value) {
    if (value is String) {
      if (_data is String) {
        _data = value;
      } else if (_data is int) {
        _data = int.parse(value);
      } else if (_data is double) {
        _data = double.parse(value);
      }
    } else {
      _data = value;
    }
  }

  String getError() {
    for (final validator in validators) {
      var error = validator(_data);
      if (error.isNotEmpty) return error;
    }
    return '';
  }

  void resetController() {
    _data = initialData;
  }
}
