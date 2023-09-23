import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/ui/group/group_builder.dart';
import 'package:statera/ui/widgets/price_text.dart';
import 'package:statera/ui/widgets/section_title.dart';
import 'package:statera/ui/widgets/user_avatar.dart';

class RedirectDebtButton extends StatelessWidget {
  const RedirectDebtButton({super.key});

  @override
  Widget build(BuildContext context) {
    var uid = context.watch<AuthBloc>().uid;
    var groupCubit = context.read<GroupCubit>();

    return GroupBuilder(
      builder: (context, group) {
        if (!group.canRedirect(uid)) return SizedBox.shrink();

        final owerUid = group.getMembersThatOweToUser(uid).first;
        final receiverUid = group.getMembersThatUserOwesTo(uid).first;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: ElevatedButton.icon(
            icon: Icon(Icons.bolt),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => BlocProvider<GroupCubit>.value(
                  value: groupCubit,
                  child: AlertDialog(
                      title: Text('Redirect Debt'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SectionTitle('Before'),
                          Row(
                            children: [
                              UserAvatar(
                                author: group.getMember(owerUid),
                                dimension: 75,
                                withName: true,
                                namePosition: NamePosition.bottom,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.arrow_forward_rounded, size: 50),
                                    PriceText(
                                        value: group.balance[owerUid]![uid]!),
                                  ],
                                ),
                              ),
                              UserAvatar(
                                author: group.getMember(uid),
                                dimension: 75,
                                withName: true,
                                namePosition: NamePosition.bottom,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.arrow_forward_rounded, size: 50),
                                    PriceText(
                                        value:
                                            group.balance[uid]![receiverUid]!),
                                  ],
                                ),
                              ),
                              UserAvatar(
                                author: group.getMember(receiverUid),
                                dimension: 75,
                                withName: true,
                                namePosition: NamePosition.bottom,
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          SectionTitle('After'),
                          Row(
                            children: [
                              UserAvatar(
                                author: group.getMember(owerUid),
                                dimension: 75,
                                withName: true,
                                namePosition: NamePosition.bottom,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.arrow_forward_rounded, size: 50),
                                    PriceText(
                                        value: group.balance[owerUid]![uid]!),
                                  ],
                                ),
                              ),
                              UserAvatar(
                                author: group.getMember(uid),
                                dimension: 75,
                                withName: true,
                                namePosition: NamePosition.bottom,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.arrow_forward_rounded, size: 50),
                                    PriceText(
                                        value:
                                            group.balance[uid]![receiverUid]!),
                                  ],
                                ),
                              ),
                              UserAvatar(
                                author: group.getMember(receiverUid),
                                dimension: 75,
                                withName: true,
                                namePosition: NamePosition.bottom,
                              ),
                            ],
                          ),
                        ],
                      )),
                ),
              );
            },
            label: Text('Redirect Debt'),
          ),
        );
      },
    );
  }
}
