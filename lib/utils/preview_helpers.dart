import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:statera/custom_theme_builder.dart';
import 'package:statera/data/services/error_service.mocks.dart';
import 'package:statera/ui/custom_layout_builder.dart';

import '../data/services/services.dart';

class Preview extends StatelessWidget {
  final List<SingleChildWidget> providers;
  final Widget body;

  const Preview({super.key, required this.providers, required this.body});

  @override
  Widget build(BuildContext context) {
    final errorServiceMock = MockErrorService();
    when(errorServiceMock.recordError(any)).thenAnswer((_) => Future.value());

    return MultiBlocProvider(
      providers: [
        ...providers,
        Provider<ErrorService>.value(value: errorServiceMock)
      ],
      child: CustomLayoutBuilder(
        child: CustomThemeBuilder(
          builder: (lightTheme, darkTheme) {
            return MaterialApp(
              theme: lightTheme,
              darkTheme: darkTheme,
              themeMode: ThemeMode.system,
              home: Scaffold(body: body),
            );
          },
        ),
      ),
    );
  }
}
