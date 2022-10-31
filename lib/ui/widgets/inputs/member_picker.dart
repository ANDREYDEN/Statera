import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/ui/group/group_builder.dart';
import 'package:statera/ui/widgets/author_avatar.dart';

class MemberPicker extends StatefulWidget {
  final List<String> value;
  final MemberController controller;
  final void Function(List<String> value)? onChange;
  final bool singleSelection;
  final bool excludeMe;
  final bool allSelected;

  MemberPicker({
    Key? key,
    List<String>? value,
    MemberController? controller,
    this.onChange,
    this.singleSelection = false,
    this.excludeMe = false,
    this.allSelected = false,
  })  : this.value = value ?? [],
        this.controller = controller ?? MemberController(value: value ?? []),
        super(key: key);

  @override
  State<MemberPicker> createState() => _MemberPickerState();
}

class _MemberPickerState extends State<MemberPicker> {
  bool isDirty = false;

  @override
  Widget build(BuildContext context) {
    String uid = context.select<AuthBloc, String>((a) => a.uid);

    return GroupBuilder(
      builder: (context, group) {
        final members =
            group.members.where((m) => !widget.excludeMe || m.uid != uid);

        if (widget.allSelected && !isDirty) {
          widget.controller.value = members.map((e) => e.uid).toList();
        }

        return ListView(
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          children: [
            Visibility(
              visible: isDirty && widget.controller.value.isEmpty,
              child: Text(
                'Please select at least one assignee',
                style: TextStyle(color: Theme.of(context).errorColor),
              ),
            ),
            ...members.map((member) {
              return AuthorAvatar(
                margin: const EdgeInsets.symmetric(vertical: 4),
                author: member,
                borderColor: widget.controller.value.contains(member.uid)
                    ? Colors.green
                    : Colors.transparent,
                withName: true,
                onTap: () {
                  setState(() {
                    isDirty = true;

                    if (widget.singleSelection) {
                      if (!widget.controller.value.contains(member.uid)) {
                        widget.controller.value = [member.uid];
                      }
                    } else {
                      if (widget.controller.value.contains(member.uid)) {
                        widget.controller.value.remove(member.uid);
                      } else {
                        widget.controller.value.add(member.uid);
                      }
                    }
                  });
                  widget.onChange?.call(widget.controller.value);
                },
              );
            }).toList(),
          ],
        );
      },
    );
  }
}

class MemberController extends ValueNotifier<List<String>> {
  MemberController({List<String>? value}) : super(value ?? []);
}
