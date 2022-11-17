import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/utils/utils.dart';

part 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  late final NotificationService _notificationService;
  late final UserRepository _userRepostiry;

  NotificationsCubit({
    required UserRepository userRepository,
    required NotificationService notificationsRepository,
  }) : super(NotificationsState(false)) {
    _notificationService = notificationsRepository;
    _userRepostiry = userRepository;
  }

  void load(BuildContext context) {
    _listenForNotifications(context);
  }

  Future<void> requestPermission({required String uid}) async {
    try {
      final success = await _notificationService.requestPermission();
      emit(NotificationsState(success));
    } on Exception catch (e) {
      emit(NotificationsState(false, error: e));
    }
  }

  void updateToken({required String uid}) async {
    await _notificationService.updateToken(
      onUpdate: (token) =>
          _userRepostiry.updateUser(uid: uid, notificationToken: token),
    );
  }

  void _listenForNotifications(BuildContext context) {
    _notificationService.listenForNotification(
      onMessage: (message) =>
          AppLaunchHandler.handleNotificationMessage(message, context),
    );
  }
}
