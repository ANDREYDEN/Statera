import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'owing_state.dart';

class OwingCubit extends Cubit<OwingState> {
  OwingCubit() : super(OwingLoading());

  void load(String memberId) {
      emit(OwingLoaded(memberId: memberId));
  }
}
