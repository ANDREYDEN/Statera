import 'package:flutter/material.dart';
import 'package:statera/utils/utils.dart';

import 'crud_dialog.dart';

main() {
  runApp(
    MaterialApp(
      theme: theme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Builder(builder: (context) {
          return ElevatedButton(
            child: Text('Open'),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => CRUDDialog(
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
          );
        }),
      ),
    ),
  );
}