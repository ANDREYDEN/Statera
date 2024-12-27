import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:statera/ui/auth_guard.dart';
import 'package:statera/ui/expense/expense_page.dart';
import 'package:statera/ui/group/group_page.dart';
import 'package:statera/ui/group_joining/group_joining.dart';
import 'package:statera/ui/groups/group_list.dart';
import 'package:statera/ui/landing/landing_page.dart';
import 'package:statera/ui/payments/payment_list_page.dart';
import 'package:statera/ui/settings/settings.dart';
import 'package:statera/ui/support/support.dart';

final router = GoRouter(
  initialLocation: kIsWeb ? '/' : '/groups',
  routes: [
    GoRoute(
      name: LandingPage.name,
      path: '/',
      builder: (_, __) => _renderPage(LandingPage(), isPublic: true),
    ),
    GoRoute(
      name: GroupList.name,
      path: '/groups',
      builder: (_, __) => _renderPage(GroupList.init(), isHomePage: true),
      routes: [
        GoRoute(
          name: SupportPage.name,
          path: 'support',
          builder: (_, __) => _renderPage(SupportPage(), isPublic: true),
        ),
        GoRoute(
          name: Settings.name,
          path: 'settings',
          builder: (_, state) => _renderPage(Settings.init()),
        ),
        GoRoute(
          name: GroupPage.name,
          path: ':groupId',
          builder: (_, state) =>
              _renderPage(GroupPage.init(state.pathParameters['groupId'])),
          routes: [
            GoRoute(
              name: ExpensePage.name,
              path: 'expenses/:expenseId',
              builder: (_, state) => _renderPage(
                ExpensePage.init(state.pathParameters['expenseId']),
              ),
            ),
            GoRoute(
              name: PaymentListPage.name,
              path: 'payments/:memberId',
              builder: (_, state) => _renderPage(PaymentListPage.init(
                state.pathParameters['groupId'],
                state.pathParameters['memberId'],
              )),
            ),
            GoRoute(
              name: GroupJoining.name,
              path: 'join/:code',
              builder: (_, state) => _renderPage(GroupJoining.init(
                state.pathParameters['groupId'],
                state.pathParameters['code'],
              )),
            )
          ],
        ),
      ],
    ),
  ],
);

Widget _renderPage(
  Widget widget, {
  bool isPublic = false,
  bool isHomePage = false,
}) {
  return isPublic ? widget : AuthGuard(isHomePage: isHomePage, child: widget);
}
