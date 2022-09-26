part of 'notifications_cubit.dart';

class NotificationsState extends Equatable {
  final bool allowed;
  final Exception? error;

  const NotificationsState(this.allowed, {this.error = null});

  @override
  List<Object?> get props => [allowed, error];
}
