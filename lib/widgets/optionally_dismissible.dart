import 'package:flutter/material.dart';
import 'package:statera/widgets/dismiss_background.dart';
import 'package:statera/widgets/ok_cancel_dialog.dart';

class OptionallyDismissible extends StatelessWidget {
  final bool isDismissible;
  final Widget child;
  final String? confirmation;
  late final Function(DismissDirection) onDismissed;

  OptionallyDismissible({
    required Key key,
    this.isDismissible = true,
    required this.child,
    this.confirmation,
    onDismissed,
  }) : super(key: key) {
    this.onDismissed = onDismissed ?? (_) {};
  }

  @override
  Widget build(BuildContext context) {
    return this.isDismissible
        ? Dismissible(
            key: this.key!,
            direction: DismissDirection.startToEnd,
            background: DismissBackground(),
            child: this.child,
            confirmDismiss: this.confirmation == null
                ? null
                : (dir) => showDialog<bool>(
                      context: context,
                      builder: (context) =>
                          OKCancelDialog(text: this.confirmation!),
                    ),
            onDismissed: this.onDismissed,
          )
        : this.child;
  }
}
