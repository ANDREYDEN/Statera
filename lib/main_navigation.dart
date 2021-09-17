import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/viewModels/group_vm.dart';
import 'package:statera/views/group_list.dart';
import 'package:statera/widgets/group_page.dart';

class MainNavigation extends StatelessWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<GroupViewModel>(
        builder: (context, groupVm, _) => Navigator(
          pages: [
            MaterialPage(key: ValueKey('GroupList'), child: GroupList()),
            if (groupVm.hasGroup)
              MaterialPage(key: ValueKey(groupVm.group), child: GroupPage()),
          ],
          onPopPage: (route, result) {
            if (!route.didPop(result)) return false;

            groupVm.group = null;

            return true;
          },
        ),
      ),
    );
  }
}
