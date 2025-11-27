part of 'user_avatar.dart';

class UserAvatarName extends StatelessWidget {
  final String name;
  final bool loading;
  final NamePosition namePosition;
  final double? dimension;

  const UserAvatarName(
    String this.name, {
    super.key,
    required this.loading,
    required this.namePosition,
    this.dimension,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Container(
        width: 80,
        height: 16,
        margin: namePosition == NamePosition.right
            ? EdgeInsets.symmetric(horizontal: 10)
            : null,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey,
        ),
      );
    }
    return Flexible(
      child: Container(
        padding: namePosition == NamePosition.right
            ? EdgeInsets.symmetric(horizontal: 10)
            : null,
        width: dimension == null
            ? null
            : this.namePosition == NamePosition.bottom
            ? dimension! + 10
            : null,
        child: Text(
          name,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
