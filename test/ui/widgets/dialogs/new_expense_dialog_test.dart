import 'package:flutter_test/flutter_test.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/widgets/dialogs/dialogs.dart';

import '../../../helpers.dart';
import '../../../widget_tester_extensions.dart';

void main() {
  group('NewExpenseDialog', () {
    testWidgets('shows payment suggestion when only 1 other member is selected',
        (tester) async {
      final currentUser = CustomUser.fake(name: 'Current User');
      final otherUser = CustomUser.fake(name: 'Other User');
      final group = Group(
        name: 'Test group',
        members: [currentUser, otherUser],
      );
      await customPump(NewExpenseDialog(), tester, group: group);

      await tester.enterTextByLabel('Name', 'New Expense');

      final currentUserOption = find.text(currentUser.name);
      await tester.tap(currentUserOption);
      final otherUserOption = find.text(otherUser.name);
      await tester.tap(otherUserOption);
      await tester.pumpAndSettle();

      final paymentSuggestion =
          find.textContaining('Consider making a payment');
      expect(paymentSuggestion, findsOneWidget);
    });
  });
}
