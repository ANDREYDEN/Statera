import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/feature_service.dart';
import 'package:statera/ui/expense/actions/expense_action.dart';
import 'package:statera/ui/group/group_page.dart';
import 'package:statera/ui/widgets/buttons/protected_button.dart';
import 'package:statera/ui/widgets/buttons/slider.dart';

class FinalizeButton extends StatelessWidget {
  final Expense expense;

  const FinalizeButton({Key? key, required this.expense}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final featureService = context.read<FeatureService>();

    Future<void> finalize() => FinalizeExpenseAction(
      expense,
    ).handle(GroupPage.scaffoldKey.currentContext!);

    if (featureService.slideToFinalizeEnabled) {
      return SlideButton(
        text: 'Slide to Finalize',
        onSlideComplete: finalize,
        knobKey: const Key('slideToFinalizeKnob'),
      );
    }

    return ProtectedButton(onPressed: finalize, child: Text('Finalize'));
  }
}
