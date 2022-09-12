import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:statera/data/services/notifications_repository.dart';

part 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  late final NotificationsRepository _notificationsRepository;

  NotificationsCubit(NotificationsRepository notificationsRepository)
      : super(NotificationsState(false)) {
    _notificationsRepository = notificationsRepository;
  }

  void requestPermission({
    required String uid,
    required Function(RemoteMessage) onMessage,
  }) async {
    try {
      final success = await _notificationsRepository.setupNotifications(
          uid: uid, onMessage: onMessage);
      emit(NotificationsState(success));
    } on Exception catch (e) {
      emit(NotificationsState(false, error: e));
    }
  }

  void removeListeners() {
    _notificationsRepository.cancelSubscriptions();
    emit(NotificationsState(false));
  }

  @override
  Future<void> close() {
    _notificationsRepository.cancelSubscriptions();
    return super.close();
  }
}
