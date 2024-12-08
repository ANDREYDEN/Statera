import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:statera/ui/widgets/buttons/text_link.dart';
import 'package:statera/ui/widgets/loader.dart';
import 'package:statera/ui/widgets/page_scaffold.dart';
import 'package:statera/ui/widgets/section_title.dart';

class SupportPage extends StatelessWidget {
  static const String name = 'Support';

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
                  SectionTitle('Questions about the app?'),
                  SizedBox(height: 20),
                  TextLink(
                    text: 'Submit an issue report',
                    url: 'https://github.com/ANDREYDEN/Statera/issues',
                  ),
                  SizedBox(height: 10),
                  TextLink(
                    text: 'Contact the developer',
                    url: 'mailto:andrey2850@gmail.com?subject=Statera',
                  ),
                  SizedBox(height: 10),
                  TextLink(
                    text: 'Contribute to the app',
                    url: 'https://github.com/ANDREYDEN/Statera',
                  ),
                  SizedBox(height: 30),
                  FutureBuilder<PackageInfo>(
                    future: PackageInfo.fromPlatform(),
                    builder: ((context, snapshot) {
                      final packageInfo = snapshot.data;

                      if (snapshot.hasError) {
                        return Text('Error getting version: ${snapshot.error}');
                      }

                      if (packageInfo == null) return Loader();

                      return Text('v${packageInfo.version}');
                    }),
                  ),
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
