import 'package:statera/data/models/models.dart';
import 'package:statera/ui/widgets/entity_action.dart';

abstract class UserGroupAction extends EntityAction {
  final UserGroup userGroup;

  UserGroupAction(this.userGroup);
}