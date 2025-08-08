import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/ui/widgets/buttons/large_action_button.dart';
import 'package:statera/utils/preview_helpers.dart';

void main() {
  runApp(CustomPreview(
    providers: [Provider.value(value: PreferencesService())],
    body: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LargeActionButton(
            onPressed: () {},
            title: 'Add Item',
            description: 'Start by adding the first item',
            icon: Icons.add,
          ),
          SizedBox(height: 8),
          LargeActionButton(
            onPressed: () {},
            title: 'Upload receipt',
            description: 'Fill out the expense by taking a photo of a receipt',
            icon: Icons.photo_camera,
            width: 300,
          ),
          SizedBox(height: 8),
          LargeActionButton(
            onPressed: () {},
            title: 'Descriptionless',
            icon: Icons.add,
          ),
        ],
      ),
    ),
  ));
}
