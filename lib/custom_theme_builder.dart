import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/ui/color/seed_color_cubit.dart';

import 'utils/utils.dart';

class CustomThemeBuilder extends StatelessWidget {
  final Widget Function(ThemeData, ThemeData) builder;

  const CustomThemeBuilder({Key? key, required this.builder}) : super(key: key);

  ThemeData _buildTheme(ColorScheme colorScheme) => ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    primarySwatch: createMaterialColor(Colors.white),
    cardTheme: cardTheme,
    listTileTheme: ListTileThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
    ),
    fontFamily: 'Nunito',
  );

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SeedColorCubit>(
      create: (context) =>
          SeedColorCubit(context.read<PreferencesService>())..load(),
      child: Builder(
        builder: (context) {
          return DynamicColorBuilder(
            builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
              ColorScheme lightColorScheme;
              ColorScheme darkColorScheme;

              if (lightDynamic != null && darkDynamic != null) {
                lightColorScheme = lightDynamic.harmonized();
                darkColorScheme = darkDynamic.harmonized();
              } else {
                var seedColor = context.watch<SeedColorCubit>().state;

                lightColorScheme = ColorScheme.fromSeed(seedColor: seedColor);
                darkColorScheme = ColorScheme.fromSeed(
                  seedColor: seedColor,
                  brightness: Brightness.dark,
                );
              }

              return builder(
                _buildTheme(lightColorScheme),
                _buildTheme(darkColorScheme),
              );
            },
          );
        },
      ),
    );
  }
}
