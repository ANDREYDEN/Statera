import 'package:flutter/material.dart';
import 'package:statera/data/models/custom_user.dart';
import 'package:statera/ui/widgets/user_avatar.dart';
import 'package:statera/utils/theme.dart';

void main() {
  runApp(UserAvatarExamples());
}

class UserAvatarExamples extends StatelessWidget {
  const UserAvatarExamples({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: theme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      home: Scaffold(
        body: ListView(
          children: [
            UserAvatar(
              author: CustomUser.fake(photoURL: 'https://picsum.photos/300'),
              dimension: 40,
            ),
            Row(
              children: List.generate(
                5,
                (index) => UserAvatar(
                  author: CustomUser.fake(name: 'User', photoURL: null),
                  dimension: 20 + 20.0 * index,
                ),
              ),
            ),
            UserAvatar(
              author: CustomUser.fake(
                name: 'John Doe',
                photoURL: 'https://picsum.photos/300',
              ),
              dimension: 40,
              withName: true,
            ),
          ],
        ),
      ),
    );
  }
}
