import 'package:equatable/equatable.dart';
import 'package:statera/data/models/models.dart';

abstract class GroupsState extends Equatable {
  const GroupsState();

  @override
  List<Object> get props => [];
}

class GroupsLoading extends GroupsState {}

class GroupsNotLoaded extends GroupsState {}

class GroupsLoaded extends GroupsState {
  final List<Group> groups;

  const GroupsLoaded([this.groups = const []]);

  @override
  List<Object> get props => [groups];

  @override
  String toString() => 'GroupsLoaded { groups: $groups }';
}