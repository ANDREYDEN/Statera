import 'dart:async';

import 'package:statera/data/services/services.dart';
import 'package:statera/data/states/group_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GroupCubit extends Cubit<GroupState> {
  GroupCubit() : super(GroupLoadingState());

  StreamSubscription? _groupSubscription;

  load(String? groupId) {
    _groupSubscription?.cancel();
    _groupSubscription = GroupService.instance
        .groupStream(groupId)
        .map((group) => GroupLoadedState(group))
        .listen(update);
  }

  update(GroupState groupState) async {
    await GroupService.instance.saveGroup(groupState.group);
  }
}
