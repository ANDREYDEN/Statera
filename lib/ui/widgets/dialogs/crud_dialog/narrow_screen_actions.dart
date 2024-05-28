import 'package:flutter/material.dart';
import 'package:statera/ui/widgets/buttons/cancel_button.dart';
import 'package:statera/ui/widgets/buttons/protected_button.dart';

class NarrowScreenActions extends StatelessWidget {
  final bool allowAddAnother;
  final bool addAnother;
  final void Function() onAddAnother;
  final Future<void> Function() onSave;

  const NarrowScreenActions({
    super.key,
    required this.allowAddAnother,
    required this.onAddAnother,
    required this.onSave,
    required this.addAnother,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (allowAddAnother)
          GestureDetector(
            onTap: onAddAnother,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('Add another'),
                Checkbox(
                  value: addAnother,
                  onChanged: (_) => onAddAnother(),
                )
              ],
            ),
          ),
        SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(width: 8),
            CancelButton(),
            SizedBox(width: 16),
            ProtectedButton(
              onPressed: onSave,
              child: Text('Save'),
            ),
            SizedBox(width: 8),
          ],
        ),
      ],
    );
  }
}
