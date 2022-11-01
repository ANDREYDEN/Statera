import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/layout/layout_state.dart';
import 'package:statera/ui/widgets/buttons/cancel_button.dart';
import 'package:statera/ui/widgets/inputs/member_picker.dart';

/// Shows all group members to select from.
/// 
/// If [singleSelection] is `true`, returns a `String?` containing the picked member uid.
/// If [singleSelection] is `false`, returns a `List<String>?` containing the picked members' uids.
class MemberSelectDialog extends StatefulWidget {
  final String title;
  final List<String>? value;
  final bool singleSelection;
  final bool allSelected;
  final bool excludeMe;

  const MemberSelectDialog({
    Key? key,
    required this.title,
    this.value,
    this.singleSelection = false,
    this.allSelected = false,
    this.excludeMe = false,
  }) : super(key: key);

  @override
  State<MemberSelectDialog> createState() => _MemberSelectDialogState();
}

class _MemberSelectDialogState extends State<MemberSelectDialog> {
  late List<String> _selectedMemberUids;

  @override
  void initState() {
    _selectedMemberUids = widget.value ?? [];
    super.initState();
  }

  bool get isWide => context.read<LayoutState>().isWide;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(this.widget.title),
      content: SizedBox(
        width: isWide ? 400 : 200,
        child: MemberPicker(
          value: _selectedMemberUids,
          singleSelection: widget.singleSelection,
          allSelected: widget.allSelected,
          excludeMe: widget.excludeMe,
          onChange: (selectedMembers) => setState(() {
            _selectedMemberUids = selectedMembers;
          }),
        ),
      ),
      actions: [
        CancelButton(returnsNull: true),
        ElevatedButton(
          onPressed: _selectedMemberUids.isNotEmpty
              ? () {
                  Navigator.pop(
                      context,
                      widget.singleSelection
                          ? _selectedMemberUids.isEmpty
                              ? null
                              : _selectedMemberUids.first
                          : _selectedMemberUids);
                }
              : null,
          child: Text('Confirm'),
        )
      ],
    );
  }
}
