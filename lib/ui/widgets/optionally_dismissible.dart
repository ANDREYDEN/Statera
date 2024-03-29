import 'package:flutter/material.dart';
import 'package:statera/ui/widgets/dismiss_background.dart';

import 'dialogs/ok_cancel_dialog.dart';

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
    if (!isDismissible) return this.child;

    return Dismissible(
      key: this.key!,
      direction: DismissDirection.startToEnd,
      background: DismissBackground(),
      confirmDismiss: this.confirmation == null
          ? null
          : (dir) => showDialog<bool>(
                context: context,
                builder: (context) => OKCancelDialog(text: this.confirmation!),
              ),
      onDismissed: this.onDismissed,
      child: this.child,
    );
  }
}
