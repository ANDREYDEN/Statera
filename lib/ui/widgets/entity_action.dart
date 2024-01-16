import 'dart:async';

import 'package:flutter/material.dart';
import 'package:statera/utils/utils.dart';

abstract class EntityAction {
  IconData get icon;
  String get name;

  Color? getIconColor(BuildContext context) => null;

  @protected
  FutureOr<void> handle(BuildContext context);

  FutureOr<void> safeHandle(BuildContext context) async {
    await snackbarCatch(
      context,
      () => handle(context),
      errorMessage: 'Error during $name',
    );
  }
}
