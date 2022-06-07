import 'package:flutter/material.dart';

class NavBarItemData {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  late Widget Function(Widget child) wrapper;

  NavBarItemData({
    required this.label,
    required this.icon,
    required this.activeIcon,
    Widget Function(Widget child)? wrapper,
  }) {
    this.wrapper = wrapper ?? (w) => w;
  }
}