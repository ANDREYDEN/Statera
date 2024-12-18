import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:statera/ui/routing/page_path.dart';
import 'package:statera/ui/settings/settings.dart';
import 'package:statera/ui/support/support.dart';
import 'package:statera/utils/helpers.dart';

final _landingPagePath = PagePath(
  pattern: '^${LandingPage.route}\$',
  isPublic: true,
  builder: (context, matches) => LandingPage(),
);

final _groupsPagePath = PagePath(
  pattern: '^${GroupList.route}\$',
  builder: (context, _) => BlocProvider<GroupsCubit>(
    create: (context) => GroupsCubit(
      context.read<GroupRepository>(),
      context.read<UserRepository>(),
      context.read<UserGroupRepository>(),
    )..load(context.read<AuthBloc>().uid),
    child: GroupList(),
  ),
);

final List<PagePath> _paths = [
  _landingPagePath,
  PagePath(
    pattern: '^${SupportPage.route}\$',
    isPublic: true,
    builder: (context, matches) => SupportPage(),
  ),
  _groupsPagePath,
  PagePath(
    pattern: '^${GroupPage.route}/([\\w-]+)\$',
    builder: (context, matches) => MultiProvider(
      providers: [
        BlocProvider<GroupCubit>(
          create: (context) => GroupCubit(
            context.read<GroupRepository>(),
            context.read<ExpenseService>(),
            context.read<UserRepository>(),
          )..load(matches?[0]),
        ),
        BlocProvider(
          create: (context) => ExpensesCubit(
            matches?[0],
            context.read<AuthBloc>().uid,
            context.read<UserExpenseRepository>(),
            context.read<ExpenseService>(),
            context.read<GroupRepository>(),
          )..load(),
        ),
        BlocProvider(
          create: (context) => NewPaymentsCubit(context.read<PaymentService>())
            ..load(
              groupId: matches?[0],
              uid: context.read<AuthBloc>().uid,
            ),
        ),
      ],
      child: GroupPage(groupId: matches?[0]),
    ),
  ),
  PagePath(
    pattern: '^${Settings.route}\$',
    builder: (context, matches) => MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => UserCubit(context.read<UserRepository>())
            ..load(context.read<AuthBloc>().uid),
        )
      ],
      child: Settings(),
    ),
  ),
  PagePath(
    pattern: '^${ExpensePage.route}/([\\w-]+)\$',
    builder: (context, matches) => MultiProvider(
      providers: [
        BlocProvider<ExpenseBloc>(
          create: (_) =>
              ExpenseBloc(context.read<ExpenseService>())..load(matches?[0]),
        ),
        BlocProvider<GroupCubit>(
          create: (_) => GroupCubit(
            context.read<GroupRepository>(),
            context.read<ExpenseService>(),
            context.read<UserRepository>(),
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
            context.read<GroupRepository>(),
            context.read<ExpenseService>(),
            context.read<UserRepository>(),
          )..load(matches?[0]),
        ),
        BlocProvider<OwingCubit>(
          create: (context) => OwingCubit()..select(matches?[1] ?? ''),
        ),
        BlocProvider(
          create: (context) => PaymentsCubit(context.read<PaymentService>())
            ..load(
              groupId: matches?[0] ?? '',
              uid: context.select<AuthBloc, String>((authBloc) => authBloc.uid),
              otherUid: matches?[1] ?? '',
            ),
        ),
      ],
      child: PaymentListPage(),
    ),
  ),
  PagePath(
    pattern: '^${GroupPage.route}/([\\w-]+)${GroupJoining.route}/([\\w-]+)\$',
    builder: (context, matches) => BlocProvider<GroupCubit>(
      create: (context) => GroupCubit(
        context.read<GroupRepository>(),
        context.read<ExpenseService>(),
        context.read<UserRepository>(),
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
      builder = (context) => _renderPage(path, context, match: firstMatch);
      break;
    }
  }

  // navigate home if nothing matched
  if (builder == null) {
    builder = (context) => kIsWeb
        ? _renderPage(_landingPagePath, context)
        : _renderPage(_groupsPagePath, context);
    route = GroupList.route;
  }

  return MaterialPageRoute(
    settings: RouteSettings(name: route, arguments: settings.arguments),
    builder: builder,
  );
}

Widget _renderPage(PagePath path, BuildContext context, {RegExpMatch? match}) {
  final matches = match?.groups(
    List.generate(match.groupCount, (index) => index + 1),
  );

  if (isMobilePlatform()) {
    final dynamicLinkRepository = context.read<DynamicLinkService>();
    // dynamicLinkRepository.listen(context);
  }

  return path.isPublic
      ? path.builder(context, matches)
      : AuthGuard(
          isHomePage: path == _groupsPagePath,
          builder: () => path.builder(context, matches),
        );
}
