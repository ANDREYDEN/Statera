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
          return ElevatedButton(
            child: Text('Open'),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => Provider.value(
                  value: context.read<LayoutState>(),
                  child: CRUDDialog(
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
                ),
              );
            },
          );
        },
      ),
    ),
  );
}
