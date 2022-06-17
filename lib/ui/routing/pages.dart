import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/expense/expense_bloc.dart';
import 'package:statera/business_logic/expenses/expenses_cubit.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/business_logic/groups/groups_cubit.dart';
import 'package:statera/business_logic/owing/owing_cubit.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/settings/settings.dart';
import 'package:statera/ui/auth_guard.dart';
import 'package:statera/ui/expense/expense_page.dart';
import 'package:statera/ui/group_joining/group_joining.dart';
import 'package:statera/ui/group/group_page.dart';
import 'package:statera/ui/groups/group_list.dart';
import 'package:statera/ui/payments/payment_list_page.dart';
import 'package:statera/ui/routing/page_path.dart';
import 'package:statera/ui/support/support.dart';

final _homePath = PagePath(
  pattern: '^${GroupList.route}\$',
  builder: (context, _) => BlocProvider<GroupsCubit>(
    create: (_) =>
        GroupsCubit(GroupService.instance)..load(context.read<AuthBloc>().uid),
    child: GroupList(),
  ),
);

final List<PagePath> _paths = [
  _homePath,
  PagePath(
    pattern: '^${SupportPage.route}\$',
    isPublic: true,
    builder: (context, matches) => SupportPage(),
  ),
  PagePath(
    pattern: '^${GroupPage.route}/([\\w-]+)\$',
    builder: (context, matches) => MultiProvider(
      providers: [
        BlocProvider<GroupCubit>(
          create: (context) => GroupCubit(
            GroupService.instance,
            ExpenseService.instance,
          )..load(matches?[0]),
        ),
        BlocProvider(
          create: (context) => ExpensesCubit(
            ExpenseService.instance,
            GroupService.instance,
          )..load(context.read<AuthBloc>().uid, matches?[0]),
        )
      ],
      child: GroupPage(groupId: matches?[0]),
    ),
  ),
  PagePath(
    pattern: '^${Settings.route}\$',
    builder: (context, matches) => Settings(),
  ),
  PagePath(
    pattern: '^${ExpensePage.route}/([\\w-]+)\$',
    builder: (context, matches) => MultiProvider(
      providers: [
        BlocProvider<ExpenseBloc>(
          create: (_) => ExpenseBloc()..load(matches?[0]),
        ),
        BlocProvider<GroupCubit>(
          create: (_) => GroupCubit(
            GroupService.instance,
            ExpenseService.instance,
          )..loadFromExpense(matches?[0]),
        )
      ],
      child: ExpensePage(),
    ),
  ),
  PagePath(
    pattern:
        '^${GroupPage.route}/([\\w-]+)${PaymentListPage.route}/([\\w-]+)\$',
    builder: (context, matches) => MultiBlocProvider(
      providers: [
        BlocProvider<GroupCubit>(
          create: (context) => GroupCubit(
            GroupService.instance,
            ExpenseService.instance,
          )..load(matches?[0]),
        ),
        BlocProvider<OwingCubit>(
          create: (context) => OwingCubit()..load(matches?[1] ?? ''),
        ),
      ],
      child: PaymentListPage(),
    ),
  ),
  PagePath(
    pattern: '^${GroupPage.route}/([\\w-]+)${GroupJoining.route}/([\\w-]+)\$',
    builder: (context, matches) => BlocProvider<GroupCubit>(
      create: (context) => GroupCubit(
        GroupService.instance,
        ExpenseService.instance,
      )..load(matches?[0]),
      child: GroupJoining(code: matches?[1]),
    ),
  )
];

Route<dynamic> onGenerateRoute(RouteSettings settings) {
  var route = settings.name ?? '/404';
  var builder;

  // try to match route to page
  for (PagePath path in _paths) {
    final regExpPattern = RegExp(path.pattern);
    if (regExpPattern.hasMatch(route)) {
      final firstMatch = regExpPattern.firstMatch(route);
      builder = (context) => _renderPage(
            path,
            context,
            match: firstMatch,
            originalRoute: route,
          );
      break;
    }
  }

  // navigate home if nothing matched
  if (builder == null) {
    builder = (context) =>
        _renderPage(_homePath, context, originalRoute: GroupList.route);
    route = GroupList.route;
  }

  return MaterialPageRoute(
    settings: settings.copyWith(name: route),
    builder: builder,
  );
}

Widget _renderPage(
  PagePath path,
  BuildContext context, {
  RegExpMatch? match,
  required String originalRoute,
}) {
  final matches = match?.groups(
    List.generate(match.groupCount, (index) => index + 1),
  );
  return SafeArea(
    child: path.isPublic
        ? path.builder(context, matches)
        : AuthGuard(
            originalRoute: originalRoute,
            builder: () => path.builder(context, matches),
          ),
  );
}
