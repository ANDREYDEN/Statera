import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/data/services/preferences_service.dart';
import 'package:statera/ui/widgets/buttons/slider_button.dart';
import 'package:statera/utils/preview_helpers.dart';

void main() {
  runApp(
    CustomPreview(
      providers: [Provider.value(value: PreferencesService())],
      body: Container(
        padding: const EdgeInsets.all(16.0),
        width: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SliderButton(
              text: 'Slide to Finalize',
              onSlideComplete: () =>
                  Future.delayed(const Duration(milliseconds: 800)),
            ),
          ],
        ),
      ),
    ),
  );
}
