import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/ui/widgets/loader.dart';

class PriceText extends StatelessWidget {
  final double value;
  final TextStyle? textStyle;

  const PriceText({Key? key, required this.value, this.textStyle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupCubit, GroupState>(
      builder: (context, groupState) {
        if (groupState is GroupLoadingState) {
          return Center(child: Loader());
        }

        if (groupState is GroupErrorState) {
          return Text('Error: ${groupState.error.toString()}');
        }

        if (groupState is GroupLoadedState) {
          return Text(
            groupState.group.renderPrice(value),
            style: textStyle,
          );
        }

        return Text('Something went wrong');
      },
    );
  }
}
