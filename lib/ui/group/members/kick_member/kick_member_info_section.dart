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
    if (children.isEmpty) {
      return Row(children: [
        Icon(Icons.check_circle_rounded, color: Colors.green),
        SizedBox(width: 5),
        Text(
          'No ${title.toLowerCase()}',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ]);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.amber),
            SizedBox(width: 5),
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
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
