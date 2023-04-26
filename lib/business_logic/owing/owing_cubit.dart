import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'owing_state.dart';

class OwingCubit extends Cubit<OwingState> {
  OwingCubit() : super(OwingNone());

  void select(String memberId) {
    emit(OwingSelected(memberId: memberId));
  }
}
