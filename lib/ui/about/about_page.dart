import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:statera/ui/groups/group_list.dart';
import 'package:statera/ui/widgets/page_scaffold.dart';
import 'package:statera/utils/utils.dart';

void main(List<String> args) {
  runApp(MaterialApp(
    title: kAppName,
    theme: theme,
    darkTheme: darkTheme,
    themeMode: ThemeMode.system,
    initialRoute: GroupList.route,
    debugShowCheckedModeBanner: false,
    home: AboutPage(),
  ));
}

class PlatformOption {
  String name;
  IconData icon;
  TargetPlatform? platform;
  String? url;

  PlatformOption(
      {required this.name,
      required this.icon,
      required this.platform,
      this.url});
}

class AboutPage extends StatefulWidget {
  static const String route = '/about';

  const AboutPage({Key? key}) : super(key: key);

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> with TickerProviderStateMixin {
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
    ),
    PlatformOption(
      name: 'Windows',
      platform: TargetPlatform.windows,
      icon: Icons.desktop_windows,
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
        IconButton(
          icon: Icon(Icons.login),
          onPressed: () => Navigator.pushNamed(context, GroupList.route),
        )
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
              SizedBox(height: 20),
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
              SizedBox(height: 10),
              ElevatedButton(
                style: ButtonStyle(
                  visualDensity: VisualDensity(
                    horizontal: VisualDensity.maximumDensity,
                    vertical: VisualDensity.maximumDensity,
                  ),
                ),
                onPressed: _selectedOption.url == null &&
                        _selectedOption.platform != null
                    ? null
                    : () {
                        if (_selectedOption.platform == null) {
                          Navigator.pushNamed(context, GroupList.route);
                          return;
                        }
                      },
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(
                    _selectedOption.platform != null
                        ? _selectedOption.url == null
                            ? 'Coming Soon'
                            : 'Install'
                        : 'Enter',
                    style: Theme.of(context)
                        .textTheme
                        .button!
                        .copyWith(fontSize: 20),
                  ),
                  Icon(
                    _selectedOption.platform != null
                        ? Icons.download
                        : Icons.login,
                    size: 35,
                  )
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
