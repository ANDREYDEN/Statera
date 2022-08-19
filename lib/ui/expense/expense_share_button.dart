import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/ui/widgets/buttons/share_button.dart';
import 'package:statera/ui/widgets/loader.dart';

class ExpenseShareButton extends StatelessWidget {
  const ExpenseShareButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dynamicLinkRepository = context.read<DynamicLinkRepository>();

    return FutureBuilder<String>(
      future: dynamicLinkRepository.generateDynamicLink(
        path: ModalRoute.of(context)!.settings.name,
      ),
      builder: (context, snap) {
        final link = snap.data;
        if (link == null) return Loader();
        if (snap.hasError) return Text(snap.error.toString());

        return ShareButton(data: link, webIcon: Icons.share);
      },
    );
  }
}
