import 'package:flutter/material.dart';
import 'package:statera/ui/widgets/buttons/text_link.dart';
import 'package:statera/ui/widgets/page_scaffold.dart';

class SupportPage extends StatelessWidget {
  static final String route = '/support';

  const SupportPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Contact Support',
      child: Center(
        child: Container(
          width: 400,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Questions about the app?',
                    style: TextStyle(
                      fontSize: Theme.of(context).textTheme.headline5!.fontSize,
                    ),
                  ),
                  SizedBox(height: 20),
                  TextLink(
                    text: 'Submit an issue report',
                    url: 'https://github.com/ANDREYDEN/Statera/issues',
                  ),
                  TextLink(
                    text: 'Contact the developer',
                    url: 'mailto:andrey2850@gmail.com?subject=Statera',
                  ),
                  TextLink(
                    text: 'Contribute to the app',
                    url: 'https://github.com/ANDREYDEN/Statera',
                  ),
                  SizedBox(height: 30),
                  Text('Andrii Denysenko, ${DateTime.now().year}'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
