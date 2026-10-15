import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:statera/data/models/custom_user.dart';
import 'package:statera/ui/styling/index.dart';
import 'package:statera/utils/utils.dart';

part 'user_avatar_name.dart';

class UserAvatar extends StatelessWidget {
  final CustomUser user;
  final void Function()? onTap;
  final bool withName;
  final Color? borderColor;
  final bool withIcon;
  final IconData? icon;
  final double iconSize;
  final Color? iconColor;
  final Color? iconBackgroudColor;
  final double dimension;
  final EdgeInsets? margin;
  final NamePosition namePosition;
  final bool loading;
  final String? extendedText;

  UserAvatar({
    Key? key,
    required this.user,
    this.onTap,
    this.withName = false,
    this.borderColor,
    this.withIcon = false,
    this.icon = Icons.check,
    this.iconSize = 20,
    this.iconColor = Colors.white,
    this.iconBackgroudColor = Colors.green,
    this.dimension = 36,
    this.margin,
    this.namePosition = NamePosition.right,
    this.loading = false,
    this.extendedText,
  }) : super(key: key);

  String get firstLetter {
    if (!user.isActive || user.name.isEmpty) return '?';
    return user.name[0];
  }

  void Function()? getTapHandler(BuildContext context) {
    if (!user.isActive && onTap == null) {
      return () {
        showSnackBar(context, 'This user is no longer active');
      };
    }

    return onTap;
  }

  @override
  Widget build(BuildContext context) {
    final photoUrl = user.photoURL;
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
                  if (extendedText != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(dimension),
                      child: Container(
                        color: Theme.of(context).colorScheme.secondary,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _UserAvatarImage(
                              dimension: dimension,
                              photoUrl: photoUrl,
                              loading: loading,
                              firstLetter: firstLetter,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: Spacing.xs_5,
                              ),
                              child: Text(
                                extendedText!,
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    _UserAvatarImage(
                      dimension: dimension,
                      photoUrl: photoUrl,
                      loading: loading,
                      firstLetter: firstLetter,
                    ),
                  if (borderColor != null)
                    Container(
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
                        child: Icon(
                          this.icon,
                          size: this.iconSize,
                          color: this.iconColor,
                        ),
                      ),
                    ),
                ],
              ),
              if (this.withName)
                UserAvatarName(
                  user.name,
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

class _UserAvatarImage extends StatelessWidget {
  final double? dimension;
  final String? photoUrl;
  final bool loading;
  final String firstLetter;

  const _UserAvatarImage({
    required this.dimension,
    required this.photoUrl,
    required this.loading,
    required this.firstLetter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: this.dimension,
      height: this.dimension,
      child: CircleAvatar(
        backgroundImage: photoUrl == null ? null : NetworkImage(photoUrl!),
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
                        fontSize: dimension == null ? 24 : (dimension! / 2),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

enum NamePosition { bottom, right }
