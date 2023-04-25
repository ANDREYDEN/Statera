import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/owing/owing_cubit.dart';
import 'package:statera/ui/widgets/loader.dart';

class OwingBuilder extends StatelessWidget {
  final Widget Function(BuildContext, String) builder;
  
  /// The widget to show when there is no selected member
  final Widget? noneWidget;

  const OwingBuilder({
    Key? key,
    required this.builder,
    this.noneWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OwingCubit, OwingState>(
      builder: (groupContext, state) {
        if (state is OwingNone) {
          return Center(child: noneWidget ?? Loader());
        }

        if (state is OwingSelected) {
          return builder(groupContext, state.memberId);
        }

        return Container();
      },
    );
  }
}
