import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/layout/layout_state.dart';
import 'package:statera/data/models/custom_user.dart';
import 'package:statera/ui/widgets/loading_text.dart';
import 'package:statera/ui/widgets/user_avatar.dart';
import 'package:statera/utils/constants.dart';

class ExpenseListItemLoading extends StatelessWidget {
  const ExpenseListItemLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = context.read<LayoutState>().isWide;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: isWide ? 0 : kMobileMargin.left),
      clipBehavior: Clip.hardEdge,
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey, Theme.of(context).colorScheme.surface],
            stops: [0, 0.8],
          ),
        ),
        child: InkWell(
          mouseCursor: SystemMouseCursors.click,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          UserAvatar(author: CustomUser.fake(), loading: true),
                          SizedBox(width: 15),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                LoadingText(height: 20, width: 100),
                                LoadingText(height: 14, width: 150),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        LoadingText(height: 24, width: 65),
                        LoadingText(height: 12, width: 40),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
