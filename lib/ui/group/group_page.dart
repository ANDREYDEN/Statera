import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/expense/expense_bloc.dart';
import 'package:statera/business_logic/expenses/expenses_cubit.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/business_logic/layout/layout_state.dart';
import 'package:statera/business_logic/owing/owing_cubit.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/expense/expense_details_web.dart';
import 'package:statera/ui/expense/expense_page.dart';
import 'package:statera/ui/group/expenses/expense_list.dart';
import 'package:statera/ui/group/nav_bar/group_bottom_nav_bar.dart';
import 'package:statera/ui/group/group_builder.dart';
import 'package:statera/ui/group/group_qr_button.dart';
import 'package:statera/ui/group/nav_bar/group_side_nav_bar.dart';
import 'package:statera/ui/group/group_title.dart';
import 'package:statera/ui/group/members/owings_list.dart';
import 'package:statera/ui/group/nav_bar/nav_bar_item_data.dart';
import 'package:statera/ui/group/settings/group_settings.dart';
import 'package:statera/ui/payments/payment_list_body.dart';
import 'package:statera/ui/widgets/dialogs/crud_dialog.dart';
import 'package:statera/ui/widgets/page_scaffold.dart';
import 'package:statera/ui/widgets/unmarked_expenses_badge.dart';

class GroupPage extends StatefulWidget {
  static const String route = "/group";
  static final scaffoldKey = GlobalKey<ScaffoldState>();
  final String? groupId;

  const GroupPage({Key? key, this.groupId}) : super(key: key);

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  int _selectedNavBarItemIndex = 0;
  PageController _pageController = PageController();

  var _navBarItems = [
    NavBarItemData(
      label: 'Home',
      icon: Icons.group_outlined,
      activeIcon: Icons.group_rounded,
    ),
    NavBarItemData(
      label: 'Expenses',
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long_rounded,
      wrapper: (child) => UnmarkedExpensesBadge(child: child),
    ),
    NavBarItemData(
      label: 'Settings',
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings_rounded,
    )
  ];

  Widget build(BuildContext context) {
    final authBloc = context.read<AuthBloc>();
    final isWide = context.read<LayoutState>().isWide;

    if (_pageController.hasClients) {
      _pageController.animateToPage(
        _selectedNavBarItemIndex,
        duration: Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    }

    return PageScaffold(
      key: GroupPage.scaffoldKey,
      titleWidget: GroupTitle(),
      actions: [GroupQRButton()],
      onFabPressed: _selectedNavBarItemIndex == 0
          ? null
          : () => _handleNewExpenseClick(authBloc.user, isWide),
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
                setState(() {
                  this._selectedNavBarItemIndex = index;
                });
              },
            ),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => ExpenseBloc()),
          BlocProvider(create: (context) => OwingCubit()),
        ],
        child: isWide
            ? Row(
                children: [
                  Container(
                    width: 100,
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
                  ..._renderContent()
                ],
              )
            : PageView(
                controller: this._pageController,
                onPageChanged: (index) {
                  setState(() {
                    this._selectedNavBarItemIndex = index;
                  });
                },
                children: [
                  OwingsList(),
                  BlocProvider(
                    create: (context) => ExpenseBloc(),
                    child: ExpenseList(),
                  ),
                  GroupSettings()
                ],
              ),
      ),
    );
  }

  List<Widget> _renderContent() {
    switch (_selectedNavBarItemIndex) {
      case 0:
        return [
          Flexible(flex: 1, child: OwingsList()),
          Flexible(flex: 2, child: PaymentListBody())
        ];
      case 1:
        return [
          Flexible(flex: 1, child: ExpenseList()),
          Flexible(flex: 2, child: ExpenseDetails())
        ];
      case 2:
        return [Flexible(child: GroupSettings())];
      default:
        return [];
    }
  }

  void _handleNewExpenseClick(User user, bool isWide) {
    final groupCubit = context.read<GroupCubit>();
    final groupId = groupCubit.loadedState.group.id;
    final expensesCubit = context.read<ExpensesCubit>();

    showDialog(
      context: context,
      builder: (context) => CRUDDialog(
        title: "New Expense",
        fields: [
          FieldData(
            id: "expense_name",
            label: "Expense Name",
            validators: [FieldData.requiredValidator],
          )
        ],
        closeAfterSubmit: false,
        onSubmit: (values) async {
          var newExpense = Expense(
            author: Author.fromUser(user),
            name: values["expense_name"]!,
            groupId: groupId,
          );
          final expenseId = await expensesCubit.addExpense(newExpense, groupId);
          if (isWide) {
            Navigator.of(context).pop();
          } else {
            Navigator.of(context)
                .popAndPushNamed('${ExpensePage.route}/$expenseId');
          }
        },
      ),
    );
  }
}
