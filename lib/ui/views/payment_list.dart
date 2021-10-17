import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/ui/viewModels/authentication_vm.dart';
import 'package:statera/ui/widgets/page_scaffold.dart';

class PaymentList extends StatelessWidget {
  static const String route = "/payments";

  final String? otherMemberId;
  final String? groupId;

  const PaymentList({
    Key? key,
    required this.otherMemberId,
    required this.groupId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var authVm = Provider.of<AuthenticationViewModel>(context);

    return PageScaffold(
      title: "",
      child: Text("Payments"),
    );
  }
}
