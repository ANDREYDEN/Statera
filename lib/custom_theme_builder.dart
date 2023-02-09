import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

import 'utils/utils.dart';

class CustomThemeBuilder extends StatelessWidget {
  final Widget Function(ThemeData, ThemeData) builder;

  const CustomThemeBuilder({Key? key, required this.builder}) : super(key: key);

  ThemeData _buildTheme(ColorScheme colorScheme) => ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        primarySwatch: createMaterialColor(Colors.white),
        textButtonTheme: textButtonTheme,
        cardTheme: cardTheme,
        fontFamily: 'Nunito',
      );

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        ColorScheme lightColorScheme;
        ColorScheme darkColorScheme;

        if (lightDynamic != null && darkDynamic != null) {
          lightColorScheme = lightDynamic.harmonized();
          darkColorScheme = darkDynamic.harmonized();
        } else {
          lightColorScheme = ColorScheme.fromSeed(
            seedColor: Color(0xFFffd100),
          );
          darkColorScheme = ColorScheme.fromSeed(
            seedColor: Color(0xFFffd100),
            brightness: Brightness.dark,
          );
        }

        return builder(
          _buildTheme(lightColorScheme),
          _buildTheme(darkColorScheme),
        );
      },
    );
  }
}
