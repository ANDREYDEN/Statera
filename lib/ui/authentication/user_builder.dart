import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/user/user_cubit.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/widgets/loader.dart';

class UserBuilder extends StatelessWidget {
  final Widget Function(BuildContext, CustomUser) builder;
  final Widget Function(BuildContext, UserError)? errorBuilder;
  final Widget? loadingWidget;

  const UserBuilder({
    Key? key,
    required this.builder,
    this.errorBuilder,
    this.loadingWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (userContext, state) {
        if (state is UserLoading) {
          return Center(child: loadingWidget ?? Loader());
        }

        if (state is UserError) {
          return errorBuilder == null
              ? Center(child: Text(state.error.toString()))
              : errorBuilder!(userContext, state);
        }

        if (state is UserLoaded) {
          return builder(userContext, state.user);
        }

        return SizedBox.shrink();
      },
    );
  }
}
