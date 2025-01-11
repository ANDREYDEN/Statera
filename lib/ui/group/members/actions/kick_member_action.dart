import 'dart:async';

import 'package:flutter/material.dart';
import 'package:statera/ui/widgets/entity_action.dart';

class KickMemberAction extends EntityAction{
  @override
  IconData get icon => Icons.delete_forever;

  @override
  String get name => 'Remove';

  @override
  FutureOr<void> handle(BuildContext context) {
    debugPrint('you clicked me');
  }
}