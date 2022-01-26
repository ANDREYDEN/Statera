import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/expense/expense_bloc.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/business_logic/groups/groups_cubit.dart';
import 'package:statera/ui/auth_guard.dart';
import 'package:statera/ui/expense/expense_page.dart';
import 'package:statera/ui/group/group_page.dart';
import 'package:statera/ui/groups/group_list.dart';
import 'package:statera/ui/payments/payment_list.dart';
import 'package:statera/ui/routing/404.dart';
import 'package:statera/ui/routing/page_path.dart';

final List<PagePath> _paths = [
  PagePath(
    pattern: '^${GroupList.route}\$',
    builder: (context, _) => BlocProvider<GroupsCubit>(
      create: (_) => GroupsCubit(),
      child: GroupList(),
    ),
  ),
  PagePath(
    pattern: '^${GroupPage.route}/([\\w-]+)\$',
    builder: (context, matches) => BlocProvider<GroupCubit>(
      create: (context) => GroupCubit()..load(matches?[0]),
      child: GroupPage(groupId: matches?[0]),
    ),
  ),
  PagePath(
    pattern: '^${ExpensePage.route}/([\\w-]+)\$',
    builder: (context, matches) => MultiProvider(
      providers: [
        BlocProvider<ExpenseBloc>(
          create: (_) => ExpenseBloc()..load(matches?[0]),
        ),
        BlocProvider<GroupCubit>(
          create: (_) => GroupCubit()..loadFromExpense(matches?[0]),
        )
      ],
      child: ExpensePage(expenseId: matches?[0]),
    ),
  ),
  PagePath(
    pattern: '^${GroupPage.route}/([\\w-]+)${PaymentList.route}/([\\w-]+)\$',
    builder: (context, matches) => BlocProvider<GroupCubit>(
      create: (context) => GroupCubit()..load(matches?[0]),
      child: PaymentList(groupId: matches?[0], otherMemberId: matches?[1]),
    ),
  )
];

Route<dynamic> onGenerateRoute(RouteSettings settings) {
  return MaterialPageRoute(
    settings: settings,
    builder: (context) {
      var route = settings.name ?? '/404';
      for (PagePath path in _paths) {
        final regExpPattern = RegExp(path.pattern);
        if (regExpPattern.hasMatch(route)) {
          final firstMatch = regExpPattern.firstMatch(route);
          final matches = firstMatch?.groups(
            List.generate(firstMatch.groupCount, (index) => index + 1),
          );
          return SafeArea(
            child: path.isPublic
                ? path.builder(context, matches)
                : AuthGuard(
                    originalRoute: route,
                    builder: () => path.builder(context, matches),
                  ),
          );
        }
      }
      return PageNotFound();
    },
  );
}
