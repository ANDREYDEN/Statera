import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/layout/layout_state.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/widgets/author_avatar.dart';
import 'package:statera/ui/group/group_builder.dart';
import 'package:statera/ui/widgets/buttons/cancel_button.dart';

class MemberSelectDialog extends StatefulWidget {
  final String title;

  const MemberSelectDialog({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  State<MemberSelectDialog> createState() => _MemberSelectDialogState();
}

class _MemberSelectDialogState extends State<MemberSelectDialog> {
  Author? _selectedMember;

  bool get isWide => context.read<LayoutState>().isWide;

  @override
  Widget build(BuildContext context) {
    String uid = context.select<AuthBloc, String>((a) => a.uid);
    return AlertDialog(
      title: Text(this.widget.title),
      content: SizedBox(
        width: isWide ? 400 : 200,
        child: GroupBuilder(
          builder: (context, group) => ListView(
            children: group.members
                .where((m) => m.uid != uid)
                .map(
                  (member) => AuthorAvatar(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    onTap: () {
                      setState(() {
                        _selectedMember = member;
                      });
                    },
                    author: member,
                    withName: true,
                    checked: member.uid == _selectedMember?.uid,
                  ),
                )
                .toList(),
          ),
        ),
      ),
      actions: [
        CancelButton(),
        ElevatedButton(
          onPressed: _selectedMember != null
              ? () {
                  Navigator.pop(context, _selectedMember);
                }
              : null,
          child: Text('Confirm'),
        )
      ],
    );
  }
}
