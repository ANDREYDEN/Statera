import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/notifications/notifications_cubit.dart';

class NotificationsHandler extends StatefulWidget {
  final Widget child;

  const NotificationsHandler({Key? key, required this.child}) : super(key: key);

  @override
  State<NotificationsHandler> createState() => _NotificationsHandlerState();
}

class _NotificationsHandlerState extends State<NotificationsHandler> {
  NotificationsCubit get notificationsCubit =>
      context.read<NotificationsCubit>();

  @override
  void initState() {
    var authBloc = context.read<AuthBloc>();

    notificationsCubit.requestPermission(context: context, uid: authBloc.uid);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
