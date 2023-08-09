import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/notifications/notifications_cubit.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/utils/utils.dart';

class NotificationsInitializer extends StatelessWidget {
  final Widget child;
  final bool isHomePage;

  const NotificationsInitializer(
      {super.key, required this.child, required this.isHomePage});

  @override
  Widget build(BuildContext context) {
    final notificationsRepository = context.read<NotificationService>();
    final userRepository = context.read<UserRepository>();
    final notificationsCubit = NotificationsCubit(
      notificationsRepository: notificationsRepository,
      userRepository: userRepository,
    )..load(context);
    final uid = context.read<AuthBloc>().uid;

    if (!kCheckNotifications) {
      return BlocProvider<NotificationsCubit>(
        create: (context) => NotificationsCubit(
          notificationsRepository: notificationsRepository,
          userRepository: userRepository,
          allowed: true,
        )..load(context),
        child: child,
      );
    }

    notificationsCubit.requestPermission(uid: uid);

    if (isHomePage) {
      notificationsCubit.updateToken(uid: uid);
    }

    return BlocProvider<NotificationsCubit>(
      create: (context) => notificationsCubit,
      child: child,
    );
  }
}
