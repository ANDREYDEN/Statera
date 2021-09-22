import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:statera/models/group.dart';
import 'package:statera/viewModels/group_vm.dart';

class GroupProvider extends StatelessWidget {
  final Group? group;
  final Widget child;

  const GroupProvider({
    Key? key,
    this.group,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GroupViewModel>(
      create: (context) {
        final groupVm = GroupViewModel();
        groupVm.group = this.group;
        return groupVm;
      },
      builder: (context, _) => this.child,
    );
  }
}
