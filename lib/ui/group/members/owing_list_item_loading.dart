import 'package:flutter/material.dart';
import 'package:statera/data/models/custom_user.dart';
import 'package:statera/ui/widgets/user_avatar.dart';

class OwingListItemLoading extends StatelessWidget {
  const OwingListItemLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        children: [
          UserAvatar(author: CustomUser.fake(), loading: true, withName: true),
        ],
      ),
    );
  }
}
