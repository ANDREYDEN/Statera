import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/ui/widgets/buttons/cancel_button.dart';
import 'package:statera/ui/widgets/buttons/protected_button.dart';
import 'package:statera/ui/widgets/dialogs/dialog_width.dart';
import 'package:statera/ui/widgets/user_avatar.dart';

class AddContactDialog extends StatefulWidget {
  const AddContactDialog({super.key});

  static void show(BuildContext context) {
    showDialog(context: context, builder: (_) => const AddContactDialog());
  }

  @override
  State<AddContactDialog> createState() => _AddContactDialogState();
}

class _AddContactDialogState extends State<AddContactDialog> {
  Group? _selectedGroup;
  final Set<String> _selectedMemberUids = {};

  String get _uid => context.read<AuthBloc>().uid;

  void _selectGroup(Group group) {
    setState(() => _selectedGroup = group);
  }

  void _deselectGroup() {
    setState(() {
      _selectedGroup = null;
      _selectedMemberUids.clear();
    });
  }

  void _toggleMember(String memberUid) {
    setState(() {
      if (!_selectedMemberUids.remove(memberUid)) {
        _selectedMemberUids.add(memberUid);
      }
    });
  }

  Future<void> _handleSubmit() async {
    final contactRepository = context.read<ContactRepository>();

    await Future.wait(
      _selectedMemberUids.map(
        (memberUid) => contactRepository.addContact(_uid, memberUid),
      ),
    );

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final selectedGroup = _selectedGroup;

    return AlertDialog(
      title: Row(
        children: [
          if (selectedGroup != null) BackButton(onPressed: _deselectGroup),
          Text(selectedGroup == null ? 'Select a Group' : 'Add Contacts'),
        ],
      ),
      content: DialogWidth(
        child: selectedGroup == null
            ? _GroupList(onSelect: _selectGroup)
            : _MemberList(
                group: selectedGroup,
                currentUid: _uid,
                selectedMemberUids: _selectedMemberUids,
                onToggle: _toggleMember,
              ),
      ),
      actions: [
        CancelButton(),
        if (selectedGroup != null)
          ProtectedButton(
            onPressed: _selectedMemberUids.isEmpty ? null : _handleSubmit,
            child: const Text('Add'),
          ),
      ],
    );
  }
}

class _GroupList extends StatelessWidget {
  final void Function(Group group) onSelect;

  const _GroupList({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthBloc>().uid;
    final userGroupRepository = context.read<UserGroupRepository>();
    final groupRepository = context.read<GroupRepository>();

    return StreamBuilder<List<UserGroup>>(
      stream: userGroupRepository.userGroupsStream(uid),
      builder: (context, snap) {
        final userGroups = snap.data ?? [];

        if (userGroups.isEmpty) {
          return const Text('You are not a member of any groups yet.');
        }

        return ListView.builder(
          shrinkWrap: true,
          itemCount: userGroups.length,
          itemBuilder: (context, i) {
            final userGroup = userGroups[i];

            return ListTile(
              title: Text(userGroup.name),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final group = await groupRepository.getGroupById(
                  userGroup.groupId,
                );
                onSelect(group);
              },
            );
          },
        );
      },
    );
  }
}

class _MemberList extends StatelessWidget {
  final Group group;
  final String currentUid;
  final Set<String> selectedMemberUids;
  final void Function(String memberUid) onToggle;

  const _MemberList({
    required this.group,
    required this.currentUid,
    required this.selectedMemberUids,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final contactRepository = context.read<ContactRepository>();

    return StreamBuilder<List<Contact>>(
      stream: contactRepository.listenForContacts(currentUid),
      builder: (context, snap) {
        final existingContactUids = (snap.data ?? [])
            .map((contact) => contact.uid)
            .toSet();

        final candidates = group.members
            .where((member) => member.uid != currentUid)
            .where((member) => !existingContactUids.contains(member.uid))
            .toList();

        if (candidates.isEmpty) {
          return const Text(
            'All members of this group are already in your contacts.',
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          itemCount: candidates.length,
          itemBuilder: (context, i) {
            final member = candidates[i];

            return UserAvatar(
              margin: const EdgeInsets.symmetric(vertical: 4),
              user: member,
              withName: true,
              borderColor: selectedMemberUids.contains(member.uid)
                  ? Colors.green
                  : Colors.transparent,
              onTap: () => onToggle(member.uid),
            );
          },
        );
      },
    );
  }
}
