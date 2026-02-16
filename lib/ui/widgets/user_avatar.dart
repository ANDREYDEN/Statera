import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:statera/data/models/custom_user.dart';
import 'package:statera/utils/utils.dart';

part 'user_avatar_name.dart';

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
  final bool loading;

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
    this.dimension = 36,
    this.margin,
    this.namePosition = NamePosition.right,
    this.loading = false,
  }) : super(key: key);

  String get firstLetter {
    if (!author.isActive || author.name.isEmpty) return '?';
    return author.name[0];
  }

  void Function()? getTapHandler(BuildContext context) {
    if (!author.isActive && onTap == null) {
      return () {
        showSnackBar(context, 'This user is no longer active');
      };
    }

    return onTap;
  }

  @override
  Widget build(BuildContext context) {
    final photoUrl = author.photoURL;
    final tapHandler = getTapHandler(context);

    final result = Padding(
      padding: this.margin ?? EdgeInsets.all(0),
      child: MouseRegion(
        cursor: tapHandler != null
            ? SystemMouseCursors.click
            : MouseCursor.defer,
        child: GestureDetector(
          onTap: tapHandler,
          behavior: HitTestBehavior.translucent,
          child: Flex(
            direction: namePosition == NamePosition.bottom
                ? Axis.vertical
                : Axis.horizontal,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                children: [
                  Container(
                    margin: EdgeInsets.all(2),
                    width: this.dimension,
                    height: this.dimension,
                    child: CircleAvatar(
                      backgroundImage: photoUrl == null
                          ? null
                          : NetworkImage(photoUrl),
                      child: photoUrl != null
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
                                if (!loading)
                                  Text(
                                    firstLetter,
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
                  if (borderColor != null)
                    Container(
                      margin: EdgeInsets.all(2),
                      width: this.dimension,
                      height: this.dimension,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(width: 3, color: this.borderColor!),
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
                    ),
                ],
              ),
              if (this.withName)
                UserAvatarName(
                  author.name,
                  loading: loading,
                  namePosition: namePosition,
                  dimension: dimension,
                ),
            ],
          ),
        ),
      ),
    );

    if (loading) {
      return result
          .animate(onPlay: (controller) => controller.repeat())
          .shimmer(duration: 1.seconds, delay: 0.5.seconds);
    }

    return result;
  }
}

enum NamePosition { bottom, right }
