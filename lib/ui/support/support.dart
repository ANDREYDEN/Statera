import 'package:flutter/material.dart';
import 'package:statera/ui/widgets/page_scaffold.dart';

class AboutPage extends StatelessWidget {
  static final String route = '/support';

  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      child: Column(
        children: [
          Row(
            children: [
              Text('Statera'),
            ],
          ),
          Row(
            children: [
              Text('Andrii Denysenko, 2022'),
            ],
          ),
          
        ],
      ),
    );
  }
}
