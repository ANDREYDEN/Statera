import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'data/services/services.dart';

class RepositoryRegistrant extends StatelessWidget {
  final Widget child;
  final FirebaseFirestore firestore;

  const RepositoryRegistrant({
    Key? key,
    required this.child,
    required this.firestore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final groupService = GroupRepository(firestore);

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => AuthService()),
        RepositoryProvider(create: (_) => UserRepository(firestore)),
        RepositoryProvider(create: (_) => DynamicLinkService()),
        RepositoryProvider(create: (_) => FirebaseStorageRepository()),
        RepositoryProvider(create: (_) => NotificationService()),
        RepositoryProvider(create: (_) => PreferencesService()),
        RepositoryProvider(create: (_) => groupService),
        RepositoryProvider(create: (_) => UserGroupRepository(firestore)),
        RepositoryProvider(
            create: (_) => PaymentService(groupService, firestore)),
        RepositoryProvider(create: (_) => ExpenseService(firestore)),
        RepositoryProvider(create: (_) => UserExpenseRepository(firestore)),
        RepositoryProvider(create: (_) => FeatureService()),
      ],
      child: child,
    );
  }
}
