import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/expenses/expenses_cubit.dart';
import 'package:statera/data/services/coordination_repository.mocks.dart';
import 'package:statera/data/services/feature_service.dart';
import 'package:statera/data/services/feature_service.mocks.dart';
import 'package:statera/ui/group/expenses/expense_list_item/finalize_button.dart';
import 'package:statera/ui/group/group_page.dart';

import '../../../../helpers.dart';

void main() {
  group('FinalizeButton', () {
    final expense = createPendingExpense(authorUid: defaultCurrentUserId);

    testWidgets('shows a regular button when the feature flag is disabled', (
      tester,
    ) async {
      final featureService = MockFeatureService();
      when(featureService.slideToFinalizeEnabled).thenReturn(false);

      await pumpFinalizeButton(tester, expense: expense, featureService: featureService);

      expect(find.text('Finalize'), findsOneWidget);
      expect(find.text('Slide to Finalize'), findsNothing);
    });

    testWidgets('shows a slider when the feature flag is enabled', (
      tester,
    ) async {
      final featureService = MockFeatureService();
      when(featureService.slideToFinalizeEnabled).thenReturn(true);

      await pumpFinalizeButton(tester, expense: expense, featureService: featureService);

      expect(find.text('Slide to Finalize'), findsOneWidget);
      expect(find.text('Finalize'), findsNothing);
    });

    testWidgets(
      'finalizes the expense once the slider is dragged to the end',
      (tester) async {
        final featureService = MockFeatureService();
        when(featureService.slideToFinalizeEnabled).thenReturn(true);

        final coordinationRepository = MockCoordinationRepository();
        when(
          coordinationRepository.finalizeExpense(any),
        ).thenAnswer((_) async {});

        await pumpFinalizeButton(
          tester,
          expense: expense,
          featureService: featureService,
          coordinationRepository: coordinationRepository,
        );

        await tester.drag(
          find.byKey(const Key('slideToFinalizeKnob')),
          const Offset(300, 0),
        );
        await tester.pumpAndSettle();

        verify(coordinationRepository.finalizeExpense(expense.id)).called(1);
      },
    );

    testWidgets(
      'snaps back without finalizing when the slider is not dragged far enough',
      (tester) async {
        final featureService = MockFeatureService();
        when(featureService.slideToFinalizeEnabled).thenReturn(true);

        final coordinationRepository = MockCoordinationRepository();
        when(
          coordinationRepository.finalizeExpense(any),
        ).thenAnswer((_) async {});

        await pumpFinalizeButton(
          tester,
          expense: expense,
          featureService: featureService,
          coordinationRepository: coordinationRepository,
        );

        await tester.drag(
          find.byKey(const Key('slideToFinalizeKnob')),
          const Offset(50, 0),
        );
        await tester.pumpAndSettle();

        verifyNever(coordinationRepository.finalizeExpense(any));
      },
    );
  });
}

Future<void> pumpFinalizeButton(
  WidgetTester tester, {
  required expense,
  required FeatureService featureService,
  MockCoordinationRepository? coordinationRepository,
}) async {
  await customPump(
    Scaffold(
      key: GroupPage.scaffoldKey,
      body: SizedBox(width: 300, child: FinalizeButton(expense: expense)),
    ),
    tester,
    featureService: featureService,
    coordinationRepository: coordinationRepository,
    expenses: [expense],
  );
  await tester.pumpAndSettle();

  // The expenses cubit loads its state via a Stream that isn't watched by
  // FinalizeButton, so pumpAndSettle can return before it settles.
  final expensesCubit = tester
      .element(find.byType(FinalizeButton))
      .read<ExpensesCubit>();
  while (expensesCubit.state is! ExpensesLoaded) {
    await tester.pump(const Duration(milliseconds: 50));
  }

  // Flush the expenses stream's pending throttle timer so it doesn't leak
  // into the test's timer-pending assertion at teardown.
  await tester.pump(const Duration(milliseconds: 250));
}
