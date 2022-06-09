import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/owing/owing_cubit.dart';
import 'package:statera/ui/widgets/loader.dart';

class OwingBuilder extends StatelessWidget {
  final Widget Function(BuildContext, String) builder;
  final Widget Function(BuildContext, OwingError)? errorBuilder;
  final Widget? loadingWidget;

  const OwingBuilder({
    Key? key,
    required this.builder,
    this.errorBuilder,
    this.loadingWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OwingCubit, OwingState>(
      builder: (groupContext, state) {
        if (state is OwingLoading) {
          return Center(child: loadingWidget ?? Loader());
        }

        if (state is OwingError) {
          return errorBuilder == null
              ? Center(child: Text(state.error.toString()))
              : errorBuilder!(groupContext, state);
        }

        if (state is OwingLoaded) {
          return builder(groupContext, state.memberId);
        }

        return Container();
      },
    );
  }
}
