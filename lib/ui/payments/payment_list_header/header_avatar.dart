import 'package:flutter/material.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/group/group_builder.dart';
import 'package:statera/ui/widgets/user_avatar.dart';

class HeaderAvatar extends StatelessWidget {
  final String otherMemberId;

  const HeaderAvatar({super.key, required this.otherMemberId});

  @override
  Widget build(BuildContext context) {
    return GroupBuilder(
      builder: (context, group) {
        final otherMember = group.getMember(otherMemberId);

        return UserAvatar(author: otherMember, dimension: 100);
      },
      loadingWidget: UserAvatar(
        author: CustomUser.fake(),
        loading: true,
        dimension: 100,
      ),
      loadOnError: true,
    );
  }
}
