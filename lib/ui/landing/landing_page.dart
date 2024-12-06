import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:statera/custom_theme_builder.dart';
import 'package:statera/ui/groups/group_list.dart';
import 'package:statera/ui/widgets/page_scaffold.dart';
import 'package:statera/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';

void main(List<String> args) {
  runApp(CustomThemeBuilder(
    builder: (lightTheme, darkTheme) {
      return MaterialApp(
        title: kAppName,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.system,
        initialRoute: GroupList.route,
        debugShowCheckedModeBanner: false,
        home: LandingPage(),
      );
    },
  ));
}

class LandingPage extends StatefulWidget {
  static const String route = '/';

  const LandingPage({Key? key}) : super(key: key);

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin {
  String? _windowsDownloadUrl;

  late PlatformOption _selectedOption;

  @override
  void initState() {
    _selectedOption = PlatformOption.all
        .firstWhere((po) => po.platform == defaultTargetPlatform);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Statera',
      actions: [
        TextButton.icon(
          onPressed: () => context.go(GroupList.route),
          icon: Icon(Icons.login),
          label: Text('Log in'),
          style: TextButton.styleFrom(
            textStyle: TextStyle(decoration: TextDecoration.none),
          ),
        ),
      ],
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('images/logo.png', width: 200),
              Text(
                'Seamlessly share your expenses with friends',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: PlatformOption.all
                      .map((po) => Padding(
                            padding: EdgeInsets.only(right: 4),
                            child: ChoiceChip(
                              label: Row(
                                children: [
                                  Icon(po.icon),
                                  SizedBox(width: 4),
                                  Text(po.name)
                                ],
                              ),
                              selected: _selectedOption == po,
                              onSelected: (_) => setState(() {
                                _selectedOption = po;
                              }),
                            ),
                          ))
                      .toList(),
                ),
              ),
              SizedBox(height: 20),
              FutureBuilder<String>(
                future: FirebaseStorage.instance
                    .ref('statera.msix')
                    .getDownloadURL(),
                builder: (context, snap) {
                  if (_windowsDownloadUrl == null && snap.data != null) {
                    _windowsDownloadUrl = snap.data;
                    PlatformOption.windows.url = _windowsDownloadUrl;
                  }

                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      visualDensity: VisualDensity(
                        horizontal: VisualDensity.maximumDensity,
                        vertical: VisualDensity.maximumDensity,
                      ),
                      textStyle: TextStyle(fontSize: 20),
                    ),
                    onPressed: _selectedOption.url == null &&
                            _selectedOption.platform != null
                        ? null
                        : () {
                            if (_selectedOption.platform == null) {
                              context.go(GroupList.route);
                              return;
                            }

                            final url = _selectedOption.url;
                            if (url != null) {
                              launchUrl(
                                Uri.parse(url),
                                mode: LaunchMode.externalApplication,
                              );
                            }
                          },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _selectedOption.platform != null
                              ? _selectedOption.url == null
                                  ? 'Coming Soon'
                                  : 'Install'
                              : 'Enter',
                        ),
                        Icon(
                          _selectedOption.platform != null
                              ? Icons.download
                              : Icons.login,
                          size: 35,
                        )
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
