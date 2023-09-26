import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/group/members/debt_redirect/redirect_debt_visual.dart';
import 'package:statera/ui/widgets/dialogs/dialogs.dart';
import 'package:statera/ui/widgets/section_title.dart';
import 'package:statera/utils/utils.dart';

class RedirectDebtView extends StatefulWidget {
  final Group group;

  const RedirectDebtView({super.key, required this.group});

  @override
  State<RedirectDebtView> createState() => _RedirectDebtViewState();
}

class _RedirectDebtViewState extends State<RedirectDebtView> {
  late String _owerUid;
  late String _receiverUid;
  late List<String> _owerUids;
  late List<String> _receiverUids;
  late double _newOwerDebt;
  late double _newAuthorDebt;

  get uid => context.read<AuthBloc>().uid;

  @override
  void initState() {
    _owerUids = widget.group.getMembersThatOweToUser(uid);
    _receiverUids = widget.group.getMembersThatUserOwesTo(uid);

    // TODO: Select this better
    _owerUid = _owerUids.first;
    _receiverUid = _receiverUids.first;

    final (newOwerDebt, newAuthorDebt, _) = widget.group.estimateRedirect(
      authorUid: uid,
      owerUid: _owerUid,
      receiverUid: _receiverUid,
    );
    _newAuthorDebt = newAuthorDebt;
    _newOwerDebt = newOwerDebt;

    super.initState();
  }

  Future<void> _handleOwerTap() async {
    final newOwerUid = await showDialog(
      context: context,
      builder: (_) => BlocProvider<GroupCubit>.value(
        value: context.read<GroupCubit>(),
        child: MemberSelectDialog(
          value: [_owerUid],
          title: 'Select ower',
          singleSelection: true,
          excludeMe: true,
          memberUids: _owerUids,
        ),
      ),
    );

    if (newOwerUid != null) {
      setState(() {
        _owerUid = newOwerUid;

        final (newOwerDebt, newAuthorDebt, _) = widget.group.estimateRedirect(
          authorUid: uid,
          owerUid: _owerUid,
          receiverUid: _receiverUid,
        );
        _newAuthorDebt = newAuthorDebt;
        _newOwerDebt = newOwerDebt;
      });
    }
  }

  Future<void> _handleReceiverTap() async {
    final newReceiverUid = await showDialog(
      context: context,
      builder: (_) => BlocProvider<GroupCubit>.value(
        value: context.read<GroupCubit>(),
        child: MemberSelectDialog(
          value: [_receiverUid],
          title: 'Select receiver',
          singleSelection: true,
          excludeMe: true,
          memberUids: _receiverUids,
        ),
      ),
    );

    if (newReceiverUid != null) {
      setState(() {
        _receiverUid = newReceiverUid;

        final (newOwerDebt, newAuthorDebt, _) = widget.group.estimateRedirect(
          authorUid: uid,
          owerUid: _owerUid,
          receiverUid: _receiverUid,
        );
        _newAuthorDebt = newAuthorDebt;
        _newOwerDebt = newOwerDebt;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var uid = context.read<AuthBloc>().uid;
    var groupCubit = context.read<GroupCubit>();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionTitle('Before', alignment: Alignment.centerLeft),
          RedirectDebtVisual(
            owerUid: _owerUid,
            receiverUid: _receiverUid,
            onOwerTap: _handleOwerTap,
            onReceiverTap: _handleReceiverTap,
          ),
          SizedBox(height: 20),
          SectionTitle('After', alignment: Alignment.centerLeft),
          RedirectDebtVisual(
            owerUid: _owerUid,
            receiverUid: _receiverUid,
            owerDebt: _newOwerDebt,
            receiverDebt: _newAuthorDebt,
            onOwerTap: _handleOwerTap,
            onReceiverTap: _handleReceiverTap,
          ),
          SizedBox(height: 50),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  groupCubit.update((group) => group.redirect(
                        authorUid: uid,
                        owerUid: _owerUid,
                        receiverUid: _receiverUid,
                      ));
                  Navigator.pop(context);
                },
                child: Text('Redirect'),
              ),
            ),
          )
        ],
      ),
    );
  }
}
