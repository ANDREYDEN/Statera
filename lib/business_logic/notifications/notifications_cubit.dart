import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/utils/utils.dart';

part 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  late final NotificationService _notificationService;
  late final UserRepository _userRepostiry;
  late final BuildContext _context;

  NotificationsCubit({
    required BuildContext context,
    required UserRepository userRepository,
    required NotificationService notificationsRepository,
  }) : super(NotificationsState(false)) {
    _notificationService = notificationsRepository;
    _userRepostiry = userRepository;
    _context = context;
  }

  void setContext(BuildContext context) => _context = context;

  void requestPermission({required String uid}) async {
    try {
      final success = await _notificationService.setupNotifications(
        uid: uid,
        onMessage: (message) => handleMessage(message, _context),
      );
      emit(NotificationsState(success));
    } on Exception catch (e) {
      emit(NotificationsState(false, error: e));
    }
  }

  void updateToken({required String uid}) async {
    await _notificationService.updateNotificationToken(
      onUpdate: (token) =>
          _userRepostiry.updateUser(uid: uid, notificationToken: token),
    );
  }
}
