import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class StepIndicator extends StatelessWidget {
  final int steps;
  final int currentStep;

  const StepIndicator({
    super.key,
    required this.steps,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    assert(0 < currentStep);
    assert(currentStep < steps);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          ...List.filled(
              currentStep - 1, StepBar(status: StepStatus.Completed)),
          StepBar(status: StepStatus.InProgress),
          ...List.filled(
              steps - currentStep, StepBar(status: StepStatus.NotStarted)),
        ],
      ),
    );
  }
}

class StepBar extends StatelessWidget {
  final StepStatus status;

  const StepBar({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      StepStatus.Completed => Colors.green,
      StepStatus.Failed => Colors.red,
      _ => Colors.grey
    };
    final bar = Expanded(
      child: Container(
        height: 4,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );

    if (status == StepStatus.InProgress) {
      return bar
          .animate(onComplete: (c) => c.repeat(reverse: true))
          .fade(duration: 1.seconds);
    }

    return bar;
  }
}

enum StepStatus { Completed, InProgress, Failed, NotStarted }
