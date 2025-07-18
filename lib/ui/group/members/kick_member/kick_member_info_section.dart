import 'package:flutter/material.dart';

class KickMemberInfoSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;

  const KickMemberInfoSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          subtitle,
          style: TextStyle(fontSize: 12),
        ),
        SizedBox(height: 8),
        Container(
          height: 70,
          child: ListView(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            children: children,
          ),
        ),
      ],
    );
  }
}
