import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/group/expenses/expense_list.dart';
import 'package:statera/ui/expense/expense_page.dart';
import 'package:statera/ui/group/home/group_home.dart';
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

  User? get user => context.select((AuthBloc b) => b.state.user);

  Widget build(BuildContext context) {
    return BlocBuilder<GroupCubit, GroupState>(
      builder: (context, groupState) {
        if (groupState is GroupLoadingState) {
          return PageScaffold(child: Center(child: Loader()));
        }

        if (groupState is GroupErrorState) {
          return PageScaffold(child: Text(groupState.error.toString()));
        }

        if (groupState is GroupLoadedState) {
          return PageScaffold(
            key: GroupPage.scaffoldKey,
            title: groupState.group.name,
            onFabPressed:
                _selectedNavBarItemIndex == 0 ? null : handleCreateExpense,
            bottomNavBar: BottomNavigationBar(
              iconSize: 36,
              items: [
                BottomNavigationBarItem(
                  label: "Home",
                  icon: Icon(Icons.home),
                  activeIcon: Icon(Icons.home),
                ),
                BottomNavigationBarItem(
                  label: "Expenses",
                  icon: UnmarkedExpensesBadge(
                    groupId: groupState.group.id,
                    child: Icon(Icons.receipt_long),
                  ),
                  activeIcon: Icon(Icons.receipt_long),
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
            child: PageView(
              controller: this._pageController,
              onPageChanged: (index) {
                setState(() {
                  this._selectedNavBarItemIndex = index;
                });
              },
              children: [GroupHome(), ExpenseList()],
            ),
          );
        }

        return PageScaffold(child: Text('Something went wrong'));
      },
    );
  }

  void handleCreateExpense() {
    if (user == null) return;
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
            author: Author.fromUser(user!),
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
