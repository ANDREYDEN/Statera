import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/expenses/expenses_cubit.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/widgets/buttons/cancel_button.dart';
import 'package:statera/ui/widgets/buttons/protected_button.dart';
import 'package:statera/ui/widgets/dialogs/dialog_width.dart';
import 'package:statera/ui/widgets/dialogs/new_expense_dialog/payment_warning.dart';
import 'package:statera/ui/widgets/inputs/member_picker.dart';
import 'package:statera/utils/utils.dart';

class NewExpenseDialog extends StatefulWidget {
  final Function(String?)? afterAddition;

  const NewExpenseDialog({Key? key, this.afterAddition}) : super(key: key);

  @override
  State<NewExpenseDialog> createState() => _NewExpenseDialogState();

  static show(
    BuildContext context, {
    required Function(String?) afterAddition,
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
}

class _NewExpenseDialogState extends State<NewExpenseDialog> {
  final TextEditingController _nameController = TextEditingController();
  final MemberController _memberController = MemberController();
  late final Expense _newExpense;
  bool _dirty = false;

  ExpensesCubit get _expensesCubit => context.read<ExpensesCubit>();
  GroupCubit get _groupCubit => context.read<GroupCubit>();
  String get _currentUid => context.read<AuthBloc>().uid;

  bool get _nameIsValid => _nameController.text != '';
  bool get _pickedValidAssignees => _memberController.value.isNotEmpty;

  @override
  void initState() {
    _newExpense = Expense(name: '', authorUid: _currentUid);
    super.initState();
  }

  Future<void> _handleSubmit() async {
    if (!_nameIsValid || !_pickedValidAssignees) return;

    _newExpense.name = _nameController.text;
    _newExpense.updateAssignees(_memberController.value);
    final newExpenseId = await _expensesCubit.addExpense(
      _newExpense,
      _groupCubit.loadedState.group.id,
    );
    Navigator.of(context).pop();
    widget.afterAddition?.call(newExpenseId);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('New Expense'),
      content: DialogWidth(
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
              onSubmitted: (_) => _handleSubmit(),
            ),
            SizedBox(height: 20),
            Text('Pick Assignees'),
            Flexible(
              child: MemberPicker(
                controller: _memberController,
                allSelected: true,
              ),
            ),
            SizedBox(height: 5),
            PaymentWarning(memberController: _memberController),
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

            await _handleSubmit();
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}
