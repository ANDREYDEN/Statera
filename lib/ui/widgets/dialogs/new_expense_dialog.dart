import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/expenses/expenses_cubit.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/group/group_builder.dart';
import 'package:statera/ui/widgets/assignee_picker.dart';
import 'package:statera/ui/widgets/buttons/cancel_button.dart';
import 'package:statera/ui/widgets/buttons/protected_button.dart';
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
  final AssigneeController _assigneeController = AssigneeController();
  late final Expense _newExpense;
  bool _dirty = false;

  ExpensesCubit get expensesCubit => context.read<ExpensesCubit>();
  GroupCubit get groupCubit => context.read<GroupCubit>();

  bool get _nameIsValid => _nameController.text != '';
  bool get _assigneePickerValid => _assigneeController.value.isNotEmpty;

  @override
  void initState() {
    final user = context.read<AuthBloc>().user;
    _newExpense = Expense(name: '', author: Author.fromUser(user));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('New Expense'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
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
            Container(
              width: 400,
              height: 400,
              child: GroupBuilder(
                builder: (context, group) {
                  _newExpense.updateAssignees(
                      group.members.map((m) => m.uid).toList());
                  return AssigneePicker(
                    controller: _assigneeController,
                    expense: _newExpense,
                  );
                },
              ),
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

            if (_nameIsValid && _assigneePickerValid) {
              _newExpense.name = _nameController.text;
              _newExpense.updateAssignees(_assigneeController.value);
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
