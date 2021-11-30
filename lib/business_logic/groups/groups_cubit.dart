import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/groups/groups_state.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/group_service.dart';
import 'package:statera/data/states/group_state.dart';

class GroupsCubit extends Cubit<GroupsState> {
  GroupsCubit() : super(GroupsLoading());
  
  updateGroup(Group group) {
    GroupService.instance.saveGroup(group);
  }

  addGroup() {

  }
}