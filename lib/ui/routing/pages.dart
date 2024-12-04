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

Widget _renderPage(
  Widget widget, {
  bool isPublic = false,
  bool isHomePage = false,
}) {
  return isPublic ? widget : AuthGuard(isHomePage: isHomePage, child: widget);
}

final router = GoRouter(routes: [
  GoRoute(
    path: LandingPage.route,
    builder: (context, _) => _renderPage(LandingPage()),
  ),
  GoRoute(
    path: SupportPage.route,
    builder: (context, _) => _renderPage(SupportPage()),
  ),
  GoRoute(
    path: GroupList.route,
    builder: (context, _) => BlocProvider<GroupsCubit>(
      create: (context) => GroupsCubit(
        context.read<GroupRepository>(),
        context.read<UserRepository>(),
        context.read<UserGroupRepository>(),
      )..load(context.read<AuthBloc>().uid),
      child: GroupList(),
    ),
  ),
  GoRoute(
    path: '${GroupPage.route}/groupId',
    builder: (context, state) => MultiProvider(
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
          create: (context) => NewPaymentsCubit(context.read<PaymentService>())
            ..load(
              groupId: state.pathParameters['groupId'],
              uid: context.read<AuthBloc>().uid,
            ),
        ),
      ],
      child: GroupPage(groupId: state.pathParameters['groupId']),
    ),
  ),
  GoRoute(
    path: Settings.route,
    builder: (context, state) => MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => UserCubit(context.read<UserRepository>())
            ..load(context.read<AuthBloc>().uid),
        )
      ],
      child: Settings(),
    ),
  ),
  GoRoute(
    path: '${ExpensePage.route}/:expenseId',
    builder: (context, state) => MultiProvider(
      providers: [
        BlocProvider<ExpenseBloc>(
          create: (_) => ExpenseBloc(context.read<ExpenseService>())
            ..load(state.pathParameters['expenseId']),
        ),
        BlocProvider<GroupCubit>(
          create: (_) => GroupCubit(
            context.read<GroupRepository>(),
            context.read<ExpenseService>(),
            context.read<UserRepository>(),
          )..loadFromExpense(state.pathParameters['expenseId']),
        )
      ],
      child: ExpensePage(),
    ),
  ),
  GoRoute(
    path: '${GroupPage.route}/:groupId${PaymentListPage.route}/:paymentId',
    builder: (context, state) => MultiBlocProvider(
      providers: [
        BlocProvider<GroupCubit>(
          create: (context) => GroupCubit(
            context.read<GroupRepository>(),
            context.read<ExpenseService>(),
            context.read<UserRepository>(),
          )..load(state.pathParameters['groupId']),
        ),
        BlocProvider<OwingCubit>(
          create: (context) =>
              OwingCubit()..select(state.pathParameters['paymentId'] ?? ''),
        ),
        BlocProvider(
          create: (context) => PaymentsCubit(context.read<PaymentService>())
            ..load(
              groupId: state.pathParameters['groupId'] ?? '',
              uid: context.select<AuthBloc, String>((authBloc) => authBloc.uid),
              otherUid: state.pathParameters['paymentId'] ?? '',
            ),
        ),
      ],
      child: PaymentListPage(),
    ),
  ),
  GoRoute(
    path: '${GroupPage.route}/:groupId${GroupJoining.route}/:code',
    builder: (context, state) => BlocProvider<GroupCubit>(
      create: (context) => GroupCubit(
        context.read<GroupRepository>(),
        context.read<ExpenseService>(),
        context.read<UserRepository>(),
      )..load(state.pathParameters['groupId']),
      child: GroupJoining(code: state.pathParameters['code']),
    ),
  )
]);
