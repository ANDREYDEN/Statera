import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/services.dart';

part 'group_joining_state.dart';

class GroupJoiningCubit extends Cubit<GroupJoiningState> {
  final GroupService groupService;

  GroupJoiningCubit(Group group, this.groupService)
      : super(GroupJoiningLoaded(group: group));

  void join(String? code, User user) async {
    if (!(state is GroupJoiningLoaded)) {
      emit(GroupJoiningError(error: 'State error'));
      return;
    }

    if (code != (state as GroupJoiningLoaded).group.code) {
      emit(GroupJoiningError(error: 'Invalid invitation. Make sure you have copied the link correctly.'));
      return;
    }

    emit(GroupJoiningLoading());
    await groupService.joinGroup(code!, user);
    emit(GroupJoiningSuccess());
  }
}
