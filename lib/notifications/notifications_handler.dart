import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class NotificationsHandler extends StatefulWidget {
  final Widget child;

  const NotificationsHandler({Key? key, required this.child}) : super(key: key);

  @override
  State<NotificationsHandler> createState() => _NotificationsHandlerState();
}

class _NotificationsHandlerState extends State<NotificationsHandler> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}