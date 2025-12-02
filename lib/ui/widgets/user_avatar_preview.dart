import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/data/models/custom_user.dart';
import 'package:statera/data/services/preferences_service.dart';
import 'package:statera/ui/widgets/user_avatar.dart';
import 'package:statera/utils/preview_helpers.dart';

void main() {
  runApp(UserAvatarExamples());
}

class UserAvatarExamples extends StatelessWidget {
  const UserAvatarExamples({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPreview(
      providers: [Provider.value(value: PreferencesService())],
      body: ListView(
        children: [
          UserAvatar(
            author: CustomUser.fake(photoURL: 'https://picsum.photos/300'),
          ),
          UserAvatar(
            author: CustomUser.fake(photoURL: 'https://picsum.photos/300'),
            borderColor: Colors.green,
          ),
          UserAvatar(author: CustomUser.fake(), loading: true),
          UserAvatar(author: CustomUser.inactive()),
          Row(
            children: [20, 40, 60, 100, 200]
                .map(
                  (dimension) => UserAvatar(
                    author: CustomUser.fake(name: 'User', photoURL: null),
                    dimension: dimension * 1.0,
                  ),
                )
                .toList(),
          ),
          UserAvatar(
            author: CustomUser.fake(
              name: 'John Doe',
              photoURL: 'https://picsum.photos/300',
            ),
            withName: true,
          ),
          UserAvatar(author: CustomUser.fake(), loading: true, withName: true),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              UserAvatar(
                author: CustomUser.fake(
                  name: 'Very long name',
                  photoURL: 'https://picsum.photos/300',
                ),
                dimension: 80,
                withName: true,
                namePosition: NamePosition.bottom,
              ),
              UserAvatar(
                author: CustomUser.fake(
                  name: 'short',
                  photoURL: 'https://picsum.photos/300',
                ),
                dimension: 80,
                withName: true,
                namePosition: NamePosition.bottom,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
