import 'package:flutter/material.dart';
import 'package:statera/custom_theme_builder.dart';

import 'crud_dialog.dart';

main() {
  runApp(
    CustomThemeBuilder(
      builder: (lightTheme, darkTheme) {
        return MaterialApp(
          theme: lightTheme,
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
        );
      },
    ),
  );
}
