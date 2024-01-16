part of 'expense_action.dart';

class ShareExpenseAction extends ExpenseAction {
  ShareExpenseAction(super.expense);

  @override
  IconData get icon => Icons.share;

  @override
  String get name => 'Share';

  @override
  @protected
  FutureOr<void> handle(BuildContext context) async {
    await snackbarCatch(context, () async {
      final dynamicLinkRepository = context.read<DynamicLinkService>();
      final link = await dynamicLinkRepository.generateDynamicLink(
        path: ModalRoute.of(context)!.settings.name,
      );

      ClipboardData clipData = ClipboardData(text: link);
      await Clipboard.setData(clipData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Link copied to clipboard')),
      );
    });
  }
}
