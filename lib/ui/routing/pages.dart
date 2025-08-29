import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/ui/authentication/sign_in_page.dart';
import 'package:statera/ui/expense/expense_page.dart';
import 'package:statera/ui/group/group_page.dart';
import 'package:statera/ui/group_joining/group_joining.dart';
import 'package:statera/ui/groups/group_list_page.dart';
import 'package:statera/ui/landing/landing_page.dart';
import 'package:statera/ui/notifications_initializer.dart';
import 'package:statera/ui/payments/payment_list_page.dart';
import 'package:statera/ui/settings/settings_page.dart';
import 'package:statera/ui/support/support.dart';
import 'package:statera/utils/stream_extensions.dart';

class CustomRouterConfig {
  static GoRouter create(BuildContext context) {
    final authBloc = context.read<AuthBloc>();

    return GoRouter(
      initialLocation: kIsWeb ? '/' : '/groups',
      refreshListenable: authBloc.stream.toChangeNotifier(),
      routes: [
        GoRoute(
          name: LandingPage.name,
          path: '/',
          builder: (_, __) => LandingPage(),
        ),
        GoRoute(
          name: SignInPage.name,
          path: '/sign-in',
          builder: (_, __) => SignInPage.init(),
        ),
        GoRoute(
          name: SupportPage.name,
          path: '/support',
          builder: (_, __) => SupportPage(),
        ),
        AuthenticatedGoRoute(
          name: GroupListPage.name,
          path: '/groups',
          builder: (_) => GroupListPage.init(),
          isHomePage: true,
          redirect: (context, routeState) {
            if (routeState.topRoute is AuthenticatedGoRoute) {
              return null;
            }

            final authBloc = context.read<AuthBloc>();
            if (authBloc.state.status == AuthStatus.unauthenticated) {
              return '/sign-in';
            }

            return null;
          },
          routes: [
            AuthenticatedGoRoute(
              name: SettingsPage.name,
              path: 'settings',
              builder: (_) => SettingsPage.init(),
            ),
            AuthenticatedGoRoute(
              name: GroupPage.name,
              path: ':groupId',
              builder: (state) =>
                  GroupPage.init(state.pathParameters['groupId']),
              routes: [
                AuthenticatedGoRoute(
                  name: ExpensePage.name,
                  path: 'expenses/:expenseId',
                  builder: (state) =>
                      ExpensePage.init(state.pathParameters['expenseId']),
                ),
                AuthenticatedGoRoute(
                  name: PaymentListPage.name,
                  path: 'payments/:memberId',
                  builder: (state) => PaymentListPage.init(
                    state.pathParameters['groupId'],
                    state.pathParameters['memberId'],
                  ),
                ),
                AuthenticatedGoRoute(
                  name: GroupJoining.name,
                  path: 'join/:code',
                  builder: (state) => GroupJoining.init(
                    state.pathParameters['groupId'],
                    state.pathParameters['code'],
                  ),
                )
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class AuthenticatedGoRoute extends GoRoute {
  AuthenticatedGoRoute({
    required super.path,
    required super.name,
    super.routes,
    required Widget Function(GoRouterState routerState) builder,
    bool isHomePage = false,
    super.redirect,
  }) : super(
          builder: (context, state) => NotificationsInitializer(
            child: builder(state),
            isHomePage: isHomePage,
          ),
        );
}
