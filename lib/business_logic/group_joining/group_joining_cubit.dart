import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/data/models/models.dart';


part 'group_joining_state.dart';

class GroupJoiningCubit extends Cubit<GroupJoiningState> {
  GroupJoiningCubit(Group group) : super(GroupJoiningLoaded(group: group));

  void join() {
    emit(GroupJoiningLoading());
    emit(GroupJoiningSuccess());
  }
}