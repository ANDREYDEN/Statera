import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'data/services/services.dart';

class RepositoryRegistrant extends StatelessWidget {
  final Widget child;
  const RepositoryRegistrant({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userRepository = UserRepository();
    final groupService = GroupService(userRepository);

    return MultiRepositoryProvider(providers: [
      RepositoryProvider(create: (_) => AuthService()),
      RepositoryProvider(create: (_) => userRepository),
      RepositoryProvider(create: (_) => DynamicLinkRepository()),
      RepositoryProvider(create: (_) => FirebaseStorageRepository()),
      RepositoryProvider(create: (_) => NotificationService()),
      RepositoryProvider(create: (_) => groupService),
      RepositoryProvider(create: (_) => PaymentService(groupService)),
    ], child: child);
  }
}
