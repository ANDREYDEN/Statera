part of 'crud_dialog.dart';

typedef Validator = String Function(String);

class FieldData<T> {
  String id;
  String label;
  late FocusNode focusNode;
  T initialData;
  List<Validator> validators;
  List<TextInputFormatter> formatters;
  bool isAdvanced;
  bool Function(Map<String, dynamic>)? isVisible;

  T? _data;
  String? _fieldValue;

  FieldData({
    required this.id,
    required this.label,
    required this.initialData,
    TextEditingController? controller,
    this.validators = const [],
    this.formatters = const [],
    this.isAdvanced = false,
    this.isVisible,
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

  T get data {
    if (_fieldValue == null) {
      return _data!;
    }
    if (initialData is String) {
      return _fieldValue! as T;
    }
    if (initialData is int) {
      return (_fieldValue!.isEmpty ? 0 : int.parse(_fieldValue!)) as T;
    }
    if (initialData is double) {
      return (_fieldValue!.isEmpty ? 0 : double.parse(_fieldValue!)) as T;
    }

    return _data!;
  }

  void changeData(dynamic value) {
    if (value is String) {
      _fieldValue = value;
    } else if (value is bool && initialData is bool) {
      _data = value as T;
    }
  }

  String getError() {
    if (_fieldValue != null) {
      // TODO: resolve types differently as T is dynamic
      if (initialData is int) {
        final formatError = intValidator(_fieldValue!);
        if (formatError.isNotEmpty) return formatError;
      }

      if (initialData is double) {
        final formatError = doubleValidator(_fieldValue!);
        if (formatError.isNotEmpty) return formatError;
      }

      for (final validator in validators) {
        var error = validator(_fieldValue!);
        if (error.isNotEmpty) return error;
      }
    }
    return '';
  }

  void resetController() {
    _data = initialData;
  }
}
