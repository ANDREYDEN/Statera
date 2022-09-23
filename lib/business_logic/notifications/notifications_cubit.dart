import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:statera/data/services/notifications_repository.dart';
import 'package:statera/utils/utils.dart';

part 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  late final NotificationsRepository _notificationsRepository;

  NotificationsCubit(NotificationsRepository notificationsRepository)
      : super(NotificationsState(false)) {
    _notificationsRepository = notificationsRepository;
  }

  void requestPermission({
    required BuildContext context,
    required String uid,
  }) async {
    try {
      final success = await _notificationsRepository.setupNotifications(
        uid: uid,
        onMessage: (message) => handleMessage(message, context),
      );
      emit(NotificationsState(success));
    } on Exception catch (e) {
      emit(NotificationsState(false, error: e));
    }
  }

  void updateToken({required String uid}) async {
    await _notificationsRepository.updateNotificationToken(uid: uid);
  }
}
