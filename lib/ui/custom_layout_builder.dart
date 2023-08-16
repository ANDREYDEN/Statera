import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/layout/layout_state.dart';

class CustomLayoutBuilder extends StatelessWidget {
  final Widget child;
  const CustomLayoutBuilder({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Provider<LayoutState>.value(
          value: LayoutState(constraints),
          child: child,
        );
      },
    );
  }
}
