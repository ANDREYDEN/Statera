import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mockito/annotations.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/utils/utils.dart';

part 'notifications_state.dart';

@GenerateNiceMocks([MockSpec<NotificationsCubit>()])
class NotificationsCubit extends Cubit<NotificationsState> {
  late final NotificationService _notificationService;
  late final UserRepository _userRepostiry;

  NotificationsCubit({
    required UserRepository userRepository,
    required NotificationService notificationsService,
    bool allowed = false,
  }) : super(NotificationsState(allowed)) {
    _notificationService = notificationsService;
    _userRepostiry = userRepository;
  }

  void load(BuildContext context) {
    _listenForNotifications(context);
  }

  Future<void> requestPermission() async {
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
    _notificationService.checkForLaunchingNotification(
      onMessage: (message) =>
          AppLaunchHandler.handleNotificationMessage(message, context),
    );
    _notificationService.listenForNotification(
      onMessage: (message) =>
          AppLaunchHandler.handleNotificationMessage(message, context),
    );
  }
}
