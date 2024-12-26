import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/expense/expense_bloc.dart';
import 'package:statera/business_logic/expenses/expenses_cubit.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/business_logic/groups/groups_cubit.dart';
import 'package:statera/business_logic/owing/owing_cubit.dart';
import 'package:statera/business_logic/payments/new_payments_cubit.dart';
import 'package:statera/business_logic/payments/payments_cubit.dart';
import 'package:statera/business_logic/user/user_cubit.dart';
import 'package:statera/data/services/services.dart';
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
      builder: (_, __) => _renderPage(
        BlocProvider<GroupsCubit>(
          create: (context) => GroupsCubit(
            context.read<GroupRepository>(),
            context.read<UserRepository>(),
            context.read<UserGroupRepository>(),
          )..load(context.read<AuthBloc>().uid),
          child: GroupList(),
        ),
        isHomePage: true,
      ),
      routes: [
        GoRoute(
          name: SupportPage.name,
          path: 'support',
          builder: (_, __) => _renderPage(
            SupportPage(),
            isPublic: true,
          ),
        ),
        GoRoute(
          name: Settings.name,
          path: 'settings',
          builder: (_, state) => _renderPage(
            MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (context) => UserCubit(context.read<UserRepository>())
                    ..load(context.read<AuthBloc>().uid),
                )
              ],
              child: Settings(),
            ),
          ),
        ),
        GoRoute(
          name: GroupPage.name,
          path: ':groupId',
          builder: (_, state) => _renderPage(
            MultiProvider(
              providers: [
                BlocProvider<GroupCubit>(
                  create: (context) => GroupCubit(
                    context.read<GroupRepository>(),
                    context.read<ExpenseService>(),
                    context.read<UserRepository>(),
                  )..load(state.pathParameters['groupId']),
                ),
                BlocProvider(
                  create: (context) => ExpensesCubit(
                    state.pathParameters['groupId'],
                    context.read<AuthBloc>().uid,
                    context.read<UserExpenseRepository>(),
                    context.read<ExpenseService>(),
                    context.read<GroupRepository>(),
                  )..load(),
                ),
                BlocProvider(
                  create: (context) =>
                      NewPaymentsCubit(context.read<PaymentService>())
                        ..load(
                          groupId: state.pathParameters['groupId'],
                          uid: context.read<AuthBloc>().uid,
                        ),
                ),
              ],
              child: GroupPage(groupId: state.pathParameters['groupId']),
            ),
          ),
          routes: [
            GoRoute(
              name: ExpensePage.name,
              path: 'expenses/:expenseId',
              builder: (_, state) => _renderPage(
                MultiProvider(
                  providers: [
                    BlocProvider<ExpenseBloc>(
                      create: (context) =>
                          ExpenseBloc(context.read<ExpenseService>())
                            ..load(state.pathParameters['expenseId']),
                    ),
                    BlocProvider<GroupCubit>(
                      create: (context) => GroupCubit(
                        context.read<GroupRepository>(),
                        context.read<ExpenseService>(),
                        context.read<UserRepository>(),
                      )..loadFromExpense(state.pathParameters['expenseId']),
                    )
                  ],
                  child: ExpensePage(),
                ),
              ),
            ),
            GoRoute(
              name: PaymentListPage.name,
              path: 'payments/:memberId',
              builder: (_, state) => _renderPage(
                MultiBlocProvider(
                  providers: [
                    BlocProvider<GroupCubit>(
                      create: (context) => GroupCubit(
                        context.read<GroupRepository>(),
                        context.read<ExpenseService>(),
                        context.read<UserRepository>(),
                      )..load(state.pathParameters['groupId']),
                    ),
                    BlocProvider<OwingCubit>(
                      create: (context) => OwingCubit()
                        ..select(state.pathParameters['memberId'] ?? ''),
                    ),
                    BlocProvider(
                      create: (context) =>
                          PaymentsCubit(context.read<PaymentService>())
                            ..load(
                              groupId: state.pathParameters['groupId'] ?? '',
                              uid: context.select<AuthBloc, String>(
                                  (authBloc) => authBloc.uid),
                              otherUid: state.pathParameters['paymentId'] ?? '',
                            ),
                    ),
                  ],
                  child: PaymentListPage(),
                ),
              ),
            ),
            GoRoute(
              name: GroupJoining.name,
              path: 'join/:code',
              builder: (_, state) => _renderPage(
                BlocProvider<GroupCubit>(
                  create: (context) => GroupCubit(
                    context.read<GroupRepository>(),
                    context.read<ExpenseService>(),
                    context.read<UserRepository>(),
                  )..load(state.pathParameters['groupId']),
                  child: GroupJoining(code: state.pathParameters['code']),
                ),
              ),
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
