import 'package:statera/data/models/custom_user.dart';
import 'package:statera/ui/widgets/entity_action.dart';

abstract class MemberAction extends EntityAction {
  final CustomUser user;

  MemberAction(this.user);
}
