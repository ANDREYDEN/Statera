import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/expenses/user_expenses_cubit.dart';
import 'package:statera/ui/widgets/loader.dart';

class ExpensesBuilder extends StatelessWidget {
  final Widget Function(BuildContext, ExpensesLoaded) builder;
  final Widget Function(BuildContext, ExpensesError)? errorBuilder;
  final Widget? loadingWidget;
  final void Function(BuildContext, ExpensesState)? onStagesChanged;
  final bool renderExpensesProcessing;

  const ExpensesBuilder({
    Key? key,
    required this.builder,
    this.errorBuilder,
    this.loadingWidget,
    this.onStagesChanged,
    this.renderExpensesProcessing = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserExpensesCubit, ExpensesState>(
      listenWhen: (previous, current) =>
          (previous is ExpensesLoaded && current is ExpensesLoaded) &&
          previous.stagesAreDifferentFrom(current),
      listener: onStagesChanged ?? (_, __) {},
      builder: (groupContext, state) {
        if (state is ExpensesLoading) {
          return loadingWidget ?? Center(child: Loader());
        }

        if (state is ExpensesError) {
          return errorBuilder == null
              ? Center(child: SelectableText(state.error.toString()))
              : errorBuilder!(groupContext, state);
        }

        if (state is ExpensesLoaded) {
          if (!renderExpensesProcessing) {
            return builder(groupContext, state);
          }

          return Column(
            children: [
              if (state is ExpensesProcessing)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: LinearProgressIndicator(),
                ),
              Expanded(child: builder(groupContext, state))
            ],
          );
        }

        return Container();
      },
    );
  }
}
