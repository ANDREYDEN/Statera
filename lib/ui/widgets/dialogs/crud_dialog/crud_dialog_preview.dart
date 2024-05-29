import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/layout/layout_state.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/utils/preview_helpers.dart';

import 'crud_dialog.dart';

main() {
  runApp(
    Preview(
      providers: [Provider.value(value: PreferencesService())],
      body: Builder(
        builder: (context) {
          return Column(
            children: [
              ElevatedButton(
                child: Text('Simple dialog'),
                onPressed: () {
                  showCRUDDialog(
                    context,
                    CRUDDialog(
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
                    ),
                  );
                },
              ),
              ElevatedButton(
                child: Text('Segmented dialog'),
                onPressed: () {
                  showCRUDDialog(
                    context,
                    CRUDDialog.segmented(
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
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    ),
  );
}

Future<void> showCRUDDialog(BuildContext context, Widget dialog) {
  return showDialog(
    context: context,
    builder: (_) => Provider.value(
      value: context.read<LayoutState>(),
      child: dialog,
    ),
  );
}
