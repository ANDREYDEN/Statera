import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/services.dart';

part 'group_joining_state.dart';

class GroupJoiningCubit extends Cubit<GroupJoiningState> {
  final GroupService groupService;

  GroupJoiningCubit(this.groupService)
      : super(GroupJoiningLoading());

  void load(String? groupCode) {

  }
}
