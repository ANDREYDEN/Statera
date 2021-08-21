import 'package:flutter/material.dart';
import 'package:statera/models/author.dart';

class AuthorAvatar extends StatelessWidget {
  final Author author;
  late final Function()? onTap;
  final bool withName;

  AuthorAvatar({
    Key? key,
    required this.author,
    this.onTap,
    this.withName = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: this.onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            backgroundImage: this.author.photoURL == null
                ? null
                : NetworkImage(this.author.photoURL!),
            child: this.author.photoURL != null
                ? null
                : Container(color: Colors.grey),
          ),
          if (this.withName) Text(this.author.name),
        ],
      ),
    );
  }
}
