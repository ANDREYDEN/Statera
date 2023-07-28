import 'dart:async';

import 'package:flutter/material.dart';

abstract class EntityAction {
  IconData get icon;
  String get name;

  Color? getIconColor(BuildContext context) => null;

  FutureOr<void> handle(BuildContext context);
}