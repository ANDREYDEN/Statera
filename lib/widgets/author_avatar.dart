import 'package:flutter/material.dart';

import 'package:statera/models/author.dart';

class AuthorAvatar extends StatelessWidget {
  final Author author;
  late final Function()? onTap;
  final bool withName;
  final Color? borderColor;
  final bool checked;
  final double? width;

  AuthorAvatar({
    Key? key,
    required this.author,
    this.onTap,
    this.withName = false,
    this.borderColor,
    this.checked = false,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: this.onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Container(
                width: this.width,
                height: this.width,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: 3,
                    color: this.borderColor ?? Colors.transparent,
                  ),
                ),
                child: CircleAvatar(
                  backgroundImage: this.author.photoURL == null
                      ? null
                      : NetworkImage(this.author.photoURL!),
                  child: this.author.photoURL != null
                      ? null
                      : Stack(
                          alignment: AlignmentDirectional.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              this.author.name[0],
                              style: TextStyle(fontSize: 24),
                            ),
                          ],
                        ),
                ),
              ),
              if (this.checked)
                Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green,
                      ),
                      padding: EdgeInsets.all(2),
                      child: Icon(
                        Icons.check,
                        size: 20,
                        color: Colors.white,
                      ),
                    ))
            ],
          ),
          if (this.withName) SizedBox(width: 10),
          if (this.withName) Text(this.author.name),
        ],
      ),
    );
  }
}
