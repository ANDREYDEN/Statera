import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/expense/expense_bloc.dart';
import 'package:statera/ui/widgets/price_text.dart';

class ExpensePrice extends StatelessWidget {
  const ExpensePrice({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExpenseBloc, ExpenseState>(builder: (context, state) {
      Widget content = switch (state) {
        ExpenseLoading() => Text('Loading...'),
        ExpenseUpdating() => Text('Updating...'),
        ExpenseLoaded(expense: final expense) => PriceText(
            value: expense.total,
            textStyle: TextStyle(color: Colors.white),
          ),
        _ => Text('Loading...')
      };

      final card = Card(
        color: Colors.grey[600],
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: content,
        ),
      );

      if (state is ExpenseUpdating || state is ExpenseLoading) {
        return card
            .animate(onPlay: (controller) => controller.repeat())
            .shimmer(delay: 0.5.seconds, duration: 0.5.seconds);
      }

      return card;
    });
  }
}
