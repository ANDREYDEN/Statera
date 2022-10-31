import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class AdvancedDropdown extends StatelessWidget {
  final void Function() onTap;
  final bool isCollapsed;
  const AdvancedDropdown({
    Key? key,
    required this.onTap,
    required this.isCollapsed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Text('Advanced'),
            Icon(isCollapsed ? Icons.arrow_drop_up : Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }
}
