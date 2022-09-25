import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:statera/data/services/services.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  late final AuthService _authService;
  late final UserRepository _userRepostiry;
  late final StreamSubscription<User?> _userSubscription;

  AuthBloc(AuthService authRepository, UserRepository userRepository)
      : super(
          authRepository.currentUser != null
              ? AuthState.authenticated(authRepository.currentUser)
              : const AuthState.unauthenticated(),
        ) {
    _authService = authRepository;
    _userRepostiry = userRepository;
    on<UserChanged>(_onUserChanged);
    on<LogoutRequested>(_onLogoutRequested);
    on<AccountDeletionRequested>(_onAccountDeletionRequested);
    on<UserDataUpdated>(_onUserDataUpdated);
    _userSubscription = authRepository.currentUserStream().listen(
          (user) => add(UserChanged(user)),
        );
  }

  User get user => state.user!;
  String get uid => state.user!.uid;

  void _onUserChanged(UserChanged event, Emitter<AuthState> emit) {
    emit(event.user != null
        ? AuthState.authenticated(event.user)
        : const AuthState.unauthenticated());
  }

  void _onUserDataUpdated(UserDataUpdated event, Emitter<AuthState> emit) {
    _userRepostiry.updateUser(uid, event.name, event.photoURL);
  }

  void _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) {
    unawaited(_authService.signOut());
  }

  void _onAccountDeletionRequested(
    AccountDeletionRequested event,
    Emitter<AuthState> emit,
  ) {
    var currentUser = _authService.currentUser;
    if (currentUser != null) currentUser.delete();
  }

  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }
}
