import 'package:flutter/material.dart';
import 'package:statera/ui/widgets/buttons/slider.dart';
import 'package:statera/utils/preview_helpers.dart';

void main() {
  runApp(
    CustomPreview(
      providers: [],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SlideButton(
              text: 'Slide to Finalize',
              onSlideComplete: () =>
                  Future.delayed(const Duration(milliseconds: 800)),
            ),
            const SizedBox(height: 24),
            SlideButton(
              text: 'Slide to Confirm',
              onSlideComplete: () =>
                  Future.delayed(const Duration(seconds: 2)),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 220,
              child: SlideButton(
                text: 'Narrow',
                onSlideComplete: () =>
                    Future.delayed(const Duration(milliseconds: 800)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
