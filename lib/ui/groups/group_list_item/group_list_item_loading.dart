import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class GroupListItemLoading extends StatelessWidget {
  final double height;
  const GroupListItemLoading({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return Card(child: SizedBox(height: height))
        .animate(onPlay: (c) => c.repeat())
        .shimmer(duration: 1.seconds, delay: 0.5.seconds);
  }
}
