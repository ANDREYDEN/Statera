import 'package:flutter/material.dart';

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

  static PlatformOption ios = PlatformOption(
    name: 'iOS',
    platform: TargetPlatform.iOS,
    icon: Icons.phone_iphone,
    url: 'https://apps.apple.com/us/app/statera/id1609503817?platform=iphone',
  );

  static PlatformOption android = PlatformOption(
    name: 'Android',
    platform: TargetPlatform.android,
    icon: Icons.phone_android,
    url: 'https://play.google.com/store/apps/details?id=com.statera.app',
  );

  static PlatformOption web = PlatformOption(
    name: 'Web',
    platform: null,
    icon: Icons.web,
    url: 'https://statera-0.web.app',
  );

  static PlatformOption mac = PlatformOption(
    name: 'MacOS',
    platform: TargetPlatform.macOS,
    icon: Icons.desktop_mac,
    url: 'https://apps.apple.com/ca/app/statera/id1609503817',
  );

  static PlatformOption windows = PlatformOption(
    name: 'Windows',
    platform: TargetPlatform.windows,
    icon: Icons.desktop_windows,
    // url gets assigned later
  );

  static PlatformOption linux = PlatformOption(
    name: 'Linux',
    platform: TargetPlatform.linux,
    icon: Icons.desktop_windows,
  );

  static List<PlatformOption> all = [ios, android, web, mac, windows, linux];
}
