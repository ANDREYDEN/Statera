import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  StreamSubscription? _userSubscription;
  final UserRepository _userRepository;

  UserCubit(this._userRepository) : super(UserLoading());

  void load(String? userId) {
    _userSubscription?.cancel();
    _userSubscription = _userRepository
        .userStream(userId)
        .map((user) => user == null
            ? UserError(error: 'User does not exist')
            : UserLoaded(user: user))
        .handleError((e) {
      if (e is FirebaseException) {
        emit(UserError(error: 'Permission denied'));
      } else {
        emit(UserError(error: 'Something went wrong: ${e.toString()}'));
      }
    }).listen(emit);
  }

  void updateName(String uid, String newName) {
    emit(UserLoading());
    _userRepository.updateUser(uid: uid, name: newName);
  }

  void updatePhotoUrl(String uid, String newPhotoUrl) {
    emit(UserLoading());
    _userRepository.updateUser(uid: uid, photoURL: newPhotoUrl);
  }

  void updatePaymentInfo(String uid, String newPaymentInfo) {
    emit(UserLoading());
    _userRepository.updateUser(uid: uid, paymentInfo: newPaymentInfo);
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
