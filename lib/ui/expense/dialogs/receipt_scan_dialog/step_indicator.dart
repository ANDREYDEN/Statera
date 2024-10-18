import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class StepIndicator extends StatelessWidget {
  final List<StepData> steps;
  final int currentStepNumber;

  const StepIndicator({
    super.key,
    required this.steps,
    required this.currentStepNumber,
  });

  @override
  Widget build(BuildContext context) {
    assert(0 < currentStepNumber);
    assert(currentStepNumber <= steps.length);

    final currentStep = steps[currentStepNumber - 1];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              ...List.filled(
                currentStepNumber - 1,
                StepBar(status: StepStatus.Completed),
              ),
              StepBar(status: StepStatus.InProgress),
              ...List.filled(
                steps.length - currentStepNumber,
                StepBar(status: StepStatus.NotStarted),
              ),
            ],
          ),
          if (currentStep.backgroundProcessed) ...[
            SizedBox(height: 20),
            Text(
              currentStep.title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineLarge,
            )
          ] else
            Text(
              currentStep.title,
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
}

class StepData {
  final String title;
  final bool backgroundProcessed;

  const StepData({required this.title, this.backgroundProcessed = false});
  const StepData.background({required this.title})
      : this.backgroundProcessed = true;
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
