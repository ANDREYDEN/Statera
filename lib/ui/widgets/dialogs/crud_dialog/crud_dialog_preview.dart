import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/layout/layout_state.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/utils/preview_helpers.dart';

import 'crud_dialog.dart';

main() {
  runApp(
    CustomPreview(
      providers: [Provider.value(value: PreferencesService())],
      body: Builder(
        builder: (context) {
          return Column(
            children: [
              CRUDDialogButton(
                label: 'Simple',
                crudDialog: simpleDialog,
              ),
              SizedBox(height: 10),
              CRUDDialogButton(
                label: 'Simple with many fields',
                crudDialog: simpleDialogWithManyFields,
              ),
              SizedBox(height: 10),
              CRUDDialogButton(
                label: 'Segmented',
                crudDialog: segmentedDialog,
              ),
              SizedBox(height: 10),
              CRUDDialogButton(
                label: 'Advanced + Add another',
                crudDialog: advancedAddAnotherDialog,
              ),
            ],
          );
        },
      ),
    ),
  );
}

final simpleDialog = CRUDDialog(
  title: 'Edit Expense',
  fields: [
    FieldData(
      id: 'expense_name',
      label: 'Expense name',
      validators: [FieldData.requiredValidator],
      initialData: '',
    )
  ],
  onSubmit: (values) async {},
);

final simpleDialogWithManyFields = CRUDDialog(
  title: 'Edit Expense',
  fields: List.generate(
    5,
    (i) => FieldData(
      id: 'field$i',
      label: 'Field $i',
      initialData: '',
    ),
  ),
  onSubmit: (values) async {},
);

final segmentedDialog = CRUDDialog.segmented(
  title: 'Edit Expense',
  segments: [
    ButtonSegment(value: 'first', label: Text('First')),
    ButtonSegment(value: 'second', label: Text('Second'))
  ],
  fieldsMap: {
    'first': [
      FieldData(
        id: 'first_field',
        label: 'First Field',
        validators: [FieldData.requiredValidator],
        initialData: '',
      )
    ],
    'second': [
      FieldData(
        id: 'second_field',
        label: 'Second Field',
        validators: [FieldData.requiredValidator],
        initialData: '',
      )
    ]
  },
  onSubmit: (values) async {},
);

final advancedAddAnotherDialog = CRUDDialog(
  title: 'Edit Expense',
  fields: [
    FieldData(
      id: 'first_field',
      label: 'First Field',
      validators: [FieldData.requiredValidator],
      initialData: '',
    ),
    FieldData(
      id: 'second_field',
      label: 'Second Field',
      validators: [FieldData.requiredValidator],
      initialData: '',
    ),
    FieldData(
      id: 'advanced_field',
      label: 'Advanced Field',
      validators: [FieldData.requiredValidator],
      initialData: '',
      isAdvanced: true,
    ),
  ],
  allowAddAnother: true,
  onSubmit: (values) async {},
);

class CRUDDialogButton extends StatelessWidget {
  final String label;
  final CRUDDialog crudDialog;
  const CRUDDialogButton(
      {super.key, required this.crudDialog, required this.label});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: Text(label),
      onPressed: () {
        showDialog(
          context: context,
          builder: (_) => Provider.value(
            value: context.read<LayoutState>(),
            child: crudDialog,
          ),
        );
      },
    );
  }
}
