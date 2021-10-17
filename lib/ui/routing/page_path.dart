import 'package:flutter/material.dart';

class PagePath {
  final bool isPublic;
  final String pattern;
  final Widget Function(BuildContext, List<String?>?) builder;

  const PagePath({
    this.isPublic = false,
    required this.pattern,
    required this.builder,
  });
}
