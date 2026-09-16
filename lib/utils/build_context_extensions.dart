import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/expense/impersonation_cubit.dart';

extension BuildContextExtension on BuildContext {
  String watchEffectiveUid() =>
      this.watch<ImpersonationCubit>().state ??
      this.select<AuthBloc, String>((bloc) => bloc.uid);

  String readEffectiveUid() =>
      this.read<ImpersonationCubit>().state ?? this.read<AuthBloc>().uid;
}
