import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:statera/ui/group/expenses/custom_filter_chip.dart';

class CustomFilterChipLoading extends StatelessWidget {
  const CustomFilterChipLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomFilterChip(
          label: List.generate(20, (_) => ' ').join(),
          onSelected: (_) {},
          color: Colors.grey,
        )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(duration: 1.seconds, delay: 0.5.seconds);
  }
}
