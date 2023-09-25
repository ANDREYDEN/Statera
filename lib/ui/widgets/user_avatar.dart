import 'package:flutter/material.dart';
import 'package:statera/data/models/custom_user.dart';

class UserAvatar extends StatelessWidget {
  final CustomUser author;
  final void Function()? onTap;
  final bool withName;
  final Color? borderColor;
  final bool withIcon;
  final IconData? icon;
  final Color? iconColor;
  final Color? iconBackgroudColor;
  final double? dimension;
  final EdgeInsets? margin;
  final NamePosition namePosition;

  UserAvatar({
    Key? key,
    required this.author,
    this.onTap,
    this.withName = false,
    this.borderColor,
    this.withIcon = false,
    this.icon = Icons.check,
    this.iconColor = Colors.white,
    this.iconBackgroudColor = Colors.green,
    this.dimension,
    this.margin,
    this.namePosition = NamePosition.right,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: this.margin ?? EdgeInsets.all(0),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: this.onTap,
          child: Flex(
            direction: namePosition == NamePosition.bottom
                ? Axis.vertical
                : Axis.horizontal,
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  Container(
                    width: this.dimension,
                    height: this.dimension,
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
                                  this.author.name.isEmpty
                                      ? '?'
                                      : this.author.name[0],
                                  style: TextStyle(
                                    fontSize: dimension == null
                                        ? 24
                                        : (dimension! / 2),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  if (this.withIcon)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: this.iconBackgroudColor,
                        ),
                        padding: EdgeInsets.all(2),
                        child: Icon(this.icon, size: 20, color: this.iconColor),
                      ),
                    )
                ],
              ),
              if (this.withName)
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      this.author.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

enum NamePosition { bottom, right }
