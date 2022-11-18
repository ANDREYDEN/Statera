import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:statera/ui/groups/group_list.dart';
import 'package:statera/ui/widgets/page_scaffold.dart';
import 'package:statera/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';

void main(List<String> args) {
  runApp(MaterialApp(
    title: kAppName,
    theme: theme,
    darkTheme: darkTheme,
    themeMode: ThemeMode.system,
    initialRoute: GroupList.route,
    debugShowCheckedModeBanner: false,
    home: LandingPage(),
  ));
}

class PlatformOption {
  String name;
  IconData icon;
  TargetPlatform? platform;
  String? url;

  PlatformOption({
    required this.name,
    required this.icon,
    required this.platform,
    this.url,
  });
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

  List<PlatformOption> _platformOptions = [
    PlatformOption(
      name: 'iOS',
      platform: TargetPlatform.iOS,
      icon: Icons.phone_iphone,
      url: 'https://apps.apple.com/us/app/statera/id1609503817?platform=iphone',
    ),
    PlatformOption(
      name: 'Android',
      platform: TargetPlatform.android,
      icon: Icons.phone_android,
      url: 'https://play.google.com/store/apps/details?id=com.statera.statera',
    ),
    PlatformOption(
      name: 'Web',
      platform: null,
      icon: Icons.web,
      url: 'https://statera-0.web.app',
    ),
    PlatformOption(
      name: 'MacOS',
      platform: TargetPlatform.macOS,
      icon: Icons.desktop_mac,
      url: 'https://apps.apple.com/ca/app/statera/id1609503817',
    ),
    PlatformOption(
      name: 'Windows',
      platform: TargetPlatform.windows,
      icon: Icons.desktop_windows,
      // url gets assigned later
    ),
    PlatformOption(
      name: 'Linux',
      platform: TargetPlatform.linux,
      icon: Icons.desktop_windows,
    ),
  ];

  late PlatformOption _selectedOption;

  @override
  void initState() {
    _selectedOption = _platformOptions
        .firstWhere((po) => po.platform == defaultTargetPlatform);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Statera',
      actions: [
        TextButton.icon(
          onPressed: () => Navigator.pushNamed(context, GroupList.route),
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
                  children: _platformOptions
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
                    final windowsOption = _platformOptions.firstWhere(
                        (p) => p.platform == TargetPlatform.windows);
                    windowsOption.url = _windowsDownloadUrl;
                  }

                  return ElevatedButton(
                    style: ButtonStyle(
                      visualDensity: VisualDensity(
                        horizontal: VisualDensity.maximumDensity,
                        vertical: VisualDensity.maximumDensity,
                      ),
                      foregroundColor:
                          MaterialStateProperty.resolveWith((states) {
                        if (states.contains(MaterialState.disabled)) {
                          return Colors.grey;
                        }

                        return Theme.of(context).colorScheme.onSecondary;
                      }),
                      textStyle: MaterialStateProperty.all(Theme.of(context)
                          .textTheme
                          .button!
                          .copyWith(fontSize: 20)),
                    ),
                    onPressed: _selectedOption.url == null &&
                            _selectedOption.platform != null
                        ? null
                        : () {
                            if (_selectedOption.platform == null) {
                              Navigator.pushNamed(context, GroupList.route);
                              return;
                            }

                            final url = _selectedOption.url;
                            if (url != null) {
                              launchUrl(Uri.parse(url));
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
