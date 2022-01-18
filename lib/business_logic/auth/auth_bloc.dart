import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/services.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc()
      : super(
          Auth.instance.currentUser != null
              ? AuthState.authenticated(Auth.instance.currentUser)
              : const AuthState.unauthenticated(),
        ) {
    on<UserChanged>(_onUserChanged);
    on<LogoutRequested>(_onLogoutRequested);
    _userSubscription = Auth.instance.currentUserStream().listen(
          (user) => add(UserChanged(user)),
        );
  }

  List<ExpenseStage> get expenseStages {
    return [
      ExpenseStage(
        name: "Not Marked",
        color: Colors.red[200]!,
        test: (expense) =>
            state.user != null &&
            expense.hasAssignee(state.user!.uid) &&
            !expense.isMarkedBy(state.user!.uid),
      ),
      ExpenseStage(
        name: "Pending",
        color: Colors.yellow[300]!,
        test: (expense) =>
            state.user != null &&
            (expense.isMarkedBy(state.user!.uid) ||
                !expense.hasAssignee(state.user!.uid)) &&
            !expense.finalized,
      ),
      ExpenseStage(
        name: "Finalized",
        color: Colors.grey[400]!,
        test: (expense) => expense.finalized,
      ),
    ];
  }

  late final StreamSubscription<User?> _userSubscription;

  void _onUserChanged(UserChanged event, Emitter<AuthState> emit) {
    emit(event.user != null
        ? AuthState.authenticated(event.user)
        : const AuthState.unauthenticated());
  }

  void _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) {
    unawaited(Auth.instance.signOut());
  }

  Color getExpenseColor(Expense expense) {
    for (var stage in expenseStages) {
      if (expense.isIn(stage)) {
        return stage.color;
      }
    }
    return Colors.blue[200]!;
  }

  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }
}
