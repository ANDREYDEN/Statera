import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/data/services/dynamic_link_service.dart';
import 'package:statera/utils/helpers.dart';

class DynamicLinkHandler extends StatefulWidget {
  final Widget child;

  const DynamicLinkHandler({Key? key, required this.child}) : super(key: key);

  @override
  State<DynamicLinkHandler> createState() => _DynamicLinkHandlerState();
}

class _DynamicLinkHandlerState extends State<DynamicLinkHandler> {
  DynamicLinkService get dynamicLinkRepository =>
      context.read<DynamicLinkService>();

  @override
  void initState() {
    if (isMobilePlatform()) {
      dynamicLinkRepository.listen(context);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
