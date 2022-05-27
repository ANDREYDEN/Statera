import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/expense/expense_bloc.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/dynamic_link_service.dart';
import 'package:statera/ui/expense/dialogs/qr_dialog.dart';
import 'package:statera/ui/expense/expense_details_web.dart';
import 'package:statera/ui/group/expenses/expense_list.dart';
import 'package:statera/ui/expense/expense_page.dart';
import 'package:statera/ui/group/home/owings_list.dart';
import 'package:statera/ui/payments/payment_list.dart';
import 'package:statera/ui/widgets/custom_layout_builder.dart';
import 'package:statera/ui/widgets/dialogs/crud_dialog.dart';
import 'package:statera/ui/widgets/loader.dart';
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

  Widget build(BuildContext context) {
    final user = context.select((AuthBloc b) => b.state.user);

    if (user == null) {
      return PageScaffold(child: Center(child: Text('Unauthorized')));
    }

    return CustomLayoutBuilder(
      builder: (context, isWide) => BlocBuilder<GroupCubit, GroupState>(
        builder: (context, groupState) {
          if (groupState is GroupLoading) {
            return PageScaffold(child: Center(child: Loader()));
          }

          if (groupState is GroupError) {
            return PageScaffold(child: Text(groupState.error.toString()));
          }

          if (groupState is GroupLoaded) {
            return PageScaffold(
              key: GroupPage.scaffoldKey,
              title: groupState.group.name,
              actions: [
                IconButton(
                  onPressed: () async {
                    final dynamicLink = DynamicLinkService.generateDynamicLink(
                      path:
                          "group/${groupState.group.id}/join/${groupState.group.code}",
                    );

                    showDialog(
                      context: context,
                      builder: (_) => QRDialog(data: dynamicLink.toString()),
                    );
                  },
                  icon: Icon(Icons.qr_code_rounded),
                )
              ],
              onFabPressed: _selectedNavBarItemIndex == 0
                  ? null
                  : () => _handleNewExpenseClick(user),
              bottomNavBar: isWide
                  ? null
                  : BottomNavigationBar(
                      iconSize: 36,
                      items: [
                        BottomNavigationBarItem(
                          label: "Home",
                          icon: Icon(Icons.home_rounded),
                          activeIcon: Icon(Icons.home_rounded),
                        ),
                        BottomNavigationBarItem(
                          label: "Expenses",
                          icon: UnmarkedExpensesBadge(
                            groupId: groupState.group.id,
                            child: Icon(Icons.receipt_long_rounded),
                          ),
                          activeIcon: Icon(Icons.receipt_long_rounded),
                        ),
                      ],
                      currentIndex: this._selectedNavBarItemIndex,
                      onTap: (index) {
                        setState(() {
                          this._selectedNavBarItemIndex = index;
                        });
                        _pageController.animateToPage(
                          index,
                          duration: Duration(milliseconds: 500),
                          curve: Curves.ease,
                        );
                      },
                    ),
              child: isWide
                  ? BlocProvider(
                      create: (context) => ExpenseBloc(),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            child: ListView(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      this._selectedNavBarItemIndex = 0;
                                    });
                                  },
                                  icon: Icon(Icons.home_rounded),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      this._selectedNavBarItemIndex = 1;
                                    });
                                  },
                                  icon: Icon(Icons.receipt_rounded),
                                ),
                              ],
                            ),
                          ),
                          ...(_selectedNavBarItemIndex == 0
                              ? [
                                Flexible(flex: 1, child: OwingsList()),
                                  Flexible(flex: 2, child: Placeholder())
                              ]
                              : [
                                  Flexible(flex: 1, child: ExpenseList()),
                                  Flexible(flex: 2, child: ExpenseDetails())
                                ])
                        ],
                      ),
                    )
                  : PageView(
                      controller: this._pageController,
                      onPageChanged: (index) {
                        setState(() {
                          this._selectedNavBarItemIndex = index;
                        });
                      },
                      children: [OwingsList(), ExpenseList()],
                    ),
            );
          }

          return PageScaffold(child: Text('Something went wrong'));
        },
      ),
    );
  }

  void _handleNewExpenseClick(User user) {
    final groupCubit = context.read<GroupCubit>();
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
            groupId: groupCubit.loadedState.group.id,
          );
          final expenseId = await groupCubit.addExpense(newExpense);
          Navigator.of(context)
              .popAndPushNamed('${ExpensePage.route}/$expenseId');
        },
      ),
    );
  }
}
