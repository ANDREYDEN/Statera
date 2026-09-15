import 'package:flutter_bloc/flutter_bloc.dart';

class ImpersonationCubit extends Cubit<String?> {
  ImpersonationCubit() : super(null);

  void start(String uid) => emit(uid);

  void stop() => emit(null);
}
