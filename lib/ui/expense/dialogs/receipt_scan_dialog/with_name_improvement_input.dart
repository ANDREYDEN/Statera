import 'package:flutter/material.dart';

class WithNameImprovementInput extends StatelessWidget {
  final ValueNotifier<bool> controller;

  WithNameImprovementInput({super.key, ValueNotifier<bool>? controller})
      : this.controller = controller ?? ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SwitchListTile(
          value: controller.value,
          onChanged: (isOn) {
            controller.value = isOn;
          },
          title: Text('Improve product names'),
        ),
        Text(
          'Checking this option will attempt to provide human readable names for Walmart products. This will also significantly increase the loading time.',
          style: TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
