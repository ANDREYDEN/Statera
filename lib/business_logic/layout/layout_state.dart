import 'package:flutter/cupertino.dart';

class LayoutState {
  late final bool isWide;

  LayoutState(BoxConstraints constraints) {
    isWide = constraints.maxWidth > 1000;
  }
}
