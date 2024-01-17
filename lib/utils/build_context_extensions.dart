import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

extension BuildContextExtension on BuildContext {
  T? readOrDefault<T>({T? defaultValue=null}) {
    try {
      return read<T>();
    } catch (e) {
      return defaultValue;
    }
  }
}