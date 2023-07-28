import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/layout/layout_state.dart';

class DialogWidth extends StatelessWidget {
  final Widget child;
  const DialogWidth({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isWide = context.read<LayoutState>().isWide;

    return SizedBox(width: isWide ? 400 : 200, child: child);
  }
}
