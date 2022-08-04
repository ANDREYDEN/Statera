import 'dart:async';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/data/services/dynamic_link_repository.dart';
import 'package:statera/utils/helpers.dart';

class DynamicLinkHandler extends StatefulWidget {
  final Widget child;

  const DynamicLinkHandler({Key? key, required this.child}) : super(key: key);

  @override
  State<DynamicLinkHandler> createState() => _DynamicLinkHandlerState();
}

class _DynamicLinkHandlerState extends State<DynamicLinkHandler> {
  StreamSubscription<PendingDynamicLinkData>? _dynamicLinkSubscription;

  DynamicLinkRepository get dynamicLinkRepository =>
      context.read<DynamicLinkRepository>();

  @override
  void initState() {
    if (isMobilePlatform()) {
      dynamicLinkRepository
          .retrieveDynamicLink(context)
          .then((subscription) => _dynamicLinkSubscription = subscription);
    }
    super.initState();
  }

  @override
  void deactivate() {
    _dynamicLinkSubscription?.cancel();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
