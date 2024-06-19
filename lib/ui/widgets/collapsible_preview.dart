import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/ui/widgets/collapsible.dart';
import 'package:statera/utils/preview_helpers.dart';

void main() {
  runApp(CollapsiblePreview());
}

class CollapsiblePreview extends StatelessWidget {
  const CollapsiblePreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Preview(
      providers: [
        Provider.value(value: PreferencesService()),
      ],
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Collapsible(
            title: 'Hiddden',
            child: Text('Hidden Text'),
          ),
          Collapsible(
            title: 'Hidden list',
            child: ListView(
              shrinkWrap: true,
              children: [
                Text('Hidden 1'),
                Text('Hidden 2'),
              ],
            ),
          )
        ],
      ),
    );
  }
}
