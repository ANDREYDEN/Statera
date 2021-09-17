
import 'package:flutter/material.dart';

class PagePath {
  final String pattern;
  final Widget Function(BuildContext, String?) builder;

  const PagePath({ required this.pattern, required this.builder});
}