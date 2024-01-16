import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LoadingText extends StatelessWidget {
  final double? height;
  final double? width;
  final double? radius;

  const LoadingText({super.key, this.height, this.width, this.radius});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(radius ?? 5),
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(duration: 1.seconds);
  }
}
