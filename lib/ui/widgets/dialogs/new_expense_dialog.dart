import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/expenses/expenses_cubit.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/business_logic/layout/layout_state.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/widgets/buttons/cancel_button.dart';
import 'package:statera/ui/widgets/buttons/protected_button.dart';
import 'package:statera/ui/widgets/inputs/member_picker.dart';
import 'package:statera/utils/utils.dart';

showNewExpenseDialog(
  BuildContext context, {
  required Function(String) afterAddition,
}) {
  showDialog(
    context: context,
    builder: (_) => MultiBlocProvider(
      providers: [
        BlocProvider.value(value: context.read<GroupCubit>()),
        BlocProvider.value(value: context.read<ExpensesCubit>())
      ],
      child: NewExpenseDialog(afterAddition: afterAddition),
    ),
  );
}

class NewExpenseDialog extends StatefulWidget {
  final Function(String) afterAddition;
  const NewExpenseDialog({
    Key? key,
    required this.afterAddition,
  }) : super(key: key);

  @override
  State<NewExpenseDialog> createState() => _NewExpenseDialogState();
}

class _NewExpenseDialogState extends State<NewExpenseDialog> {
  final TextEditingController _nameController = TextEditingController();
  final MemberController _memberController = MemberController();
  late final Expense _newExpense;
  bool _dirty = false;

  ExpensesCubit get expensesCubit => context.read<ExpensesCubit>();
  GroupCubit get groupCubit => context.read<GroupCubit>();
  bool get isWide => context.read<LayoutState>().isWide;

  bool get _nameIsValid => _nameController.text != '';
  bool get _pickedValidAssignees => _memberController.value.isNotEmpty;

  @override
  void initState() {
    final user = context.read<AuthBloc>().user;
    _newExpense = Expense(name: '', author: CustomUser.fromUser(user));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('New Expense'),
      content: SizedBox(
        width: isWide ? 400 : 200,
        child: ListView(
          shrinkWrap: true,
          children: [
            TextField(
              autofocus: true,
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                errorText: _dirty && _nameController.text == ''
                    ? kRequiredValidationMessage
                    : null,
              ),
              onChanged: (text) {
                setState(() {
                  this._dirty = true;
                });
              },
            ),
            SizedBox(height: 20),
            Text('Pick Assignees'),
            MemberPicker(
              controller: _memberController,
              allSelected: true,
            ),
          ],
        ),
      ),
      actions: [
        CancelButton(),
        ProtectedButton(
          onPressed: () async {
            setState(() {
              _dirty = true;
            });

            if (_nameIsValid && _pickedValidAssignees) {
              _newExpense.name = _nameController.text;
              _newExpense.updateAssignees(_memberController.value);
              await expensesCubit.addExpense(
                _newExpense,
                groupCubit.loadedState.group.id,
              );
              Navigator.of(context).pop();
            }
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}
