import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/expense/expense_bloc.dart';
import 'package:statera/business_logic/expenses/expenses_cubit.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/business_logic/layout/layout_state.dart';
import 'package:statera/business_logic/owing/owing_cubit.dart';
import 'package:statera/business_logic/payments/new_payments_cubit.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/ui/expense/expense_page.dart';
import 'package:statera/ui/group/expenses/expense_list.dart';
import 'package:statera/ui/group/group_qr_button.dart';
import 'package:statera/ui/group/group_title.dart';
import 'package:statera/ui/group/group_wide_content.dart';
import 'package:statera/ui/group/members/owings_list.dart';
import 'package:statera/ui/group/nav_bar/group_bottom_nav_bar.dart';
import 'package:statera/ui/group/nav_bar/group_side_nav_bar.dart';
import 'package:statera/ui/group/nav_bar/nav_bar_item_data.dart';
import 'package:statera/ui/group/settings/group_settings.dart';
import 'package:statera/ui/widgets/dialogs/new_expense_dialog/new_expense_dialog.dart';
import 'package:statera/ui/widgets/page_scaffold.dart';
import 'package:statera/ui/widgets/unmarked_expenses_badge.dart';

class GroupPage extends StatefulWidget {
  static const String name = 'Group';
  static final scaffoldKey = GlobalKey<ScaffoldState>();
  final String? groupId;

  const GroupPage({Key? key, this.groupId}) : super(key: key);

  static Widget init(String? groupId) {
    return MultiProvider(
      key: Key(groupId ?? 'unknown'),
      providers: [
        BlocProvider<GroupCubit>(
          create: (context) => GroupCubit(
            context.read<GroupRepository>(),
            context.read<ExpenseService>(),
            context.read<UserRepository>(),
          )..load(groupId),
        ),
        BlocProvider(
          create: (context) => ExpensesCubit(
            groupId,
            context.read<AuthBloc>().uid,
            context.read<UserExpenseRepository>(),
            context.read<ExpenseService>(),
            context.read<GroupRepository>(),
          )..load(),
        ),
        BlocProvider(
          create: (context) => NewPaymentsCubit(context.read<PaymentService>())
            ..load(
              groupId: groupId,
              uid: context.read<AuthBloc>().uid,
            ),
        ),
      ],
      child: GroupPage(groupId: groupId),
    );
  }

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  int _selectedNavBarItemIndex = 0;
  PageController _pageController = PageController();

  Widget build(BuildContext context) {
    final isWide = context.select((LayoutState state) => state.isWide);

    final _navBarItems = [
      NavBarItemData(
        label: 'Home',
        icon: Icons.group_outlined,
        activeIcon: Icons.group_rounded,
      ),
      NavBarItemData(
        label: 'Expenses',
        icon: Icons.receipt_long_outlined,
        activeIcon: Icons.receipt_long_rounded,
        wrapper: (child) =>
            UnmarkedExpensesBadge(groupId: widget.groupId, child: child),
      ),
      NavBarItemData(
        label: 'Settings',
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings_rounded,
      )
    ];

    return PageScaffold(
      key: GroupPage.scaffoldKey,
      titleWidget: GroupTitle(),
      actions: [GroupQRButton()],
      fabText: 'New Expense',
      onFabPressed: isWide || _selectedNavBarItemIndex != 1
          ? null
          : () => NewExpenseDialog.show(
                context,
                afterAddition: (expenseId) {
                  context.goNamed(
                    ExpensePage.name,
                    pathParameters: {
                      'expenseId': expenseId!,
                      'groupId': widget.groupId!
                    },
                  );
                },
              ),
      bottomNavBar: isWide
          ? null
          : GroupBottomNavBar(
              currentIndex: this._selectedNavBarItemIndex,
              items: _navBarItems,
              onTap: (index) async {
                await _pageController.animateToPage(
                  index,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.ease,
                );
              },
            ),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (context) => ExpenseBloc(context.read<ExpenseService>())),
          BlocProvider(create: (context) => OwingCubit()),
        ],
        child: isWide
            ? GroupWideContent(
                navIndex: _selectedNavBarItemIndex,
                sideNavBar: Container(
                  width: 180,
                  child: GroupSideNavBar(
                    selectedItem: _selectedNavBarItemIndex,
                    onItemSelected: (index) {
                      setState(() {
                        _selectedNavBarItemIndex = index;
                      });
                    },
                    items: _navBarItems,
                  ),
                ),
              )
            : PageView(
                controller: this._pageController,
                onPageChanged: (index) {
                  setState(() {
                    this._selectedNavBarItemIndex = index;
                  });
                },
                children: [OwingsList(), ExpenseList(), GroupSettings()],
              ),
      ),
    );
  }
}
