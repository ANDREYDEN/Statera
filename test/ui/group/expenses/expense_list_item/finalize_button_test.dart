import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/expenses/expenses_cubit.dart';
import 'package:statera/data/services/coordination_repository.mocks.dart';
import 'package:statera/data/services/feature_service.dart';
import 'package:statera/data/services/feature_service.mocks.dart';
import 'package:statera/ui/group/expenses/expense_list_item/finalize_button.dart';
import 'package:statera/ui/group/expenses/expenses_builder.dart';
import 'package:statera/ui/group/group_page.dart';

import '../../../../helpers.dart';

void main() {
  group('FinalizeButton', () {
    final expense = createPendingExpense(authorUid: defaultCurrentUserId);

    testWidgets('shows a regular button when the feature flag is disabled', (
      tester,
    ) async {
      await pumpFinalizeButton(tester, expense: expense, sliderEnabled: false);

      expect(find.text('Finalize'), findsOneWidget);
      expect(find.text('Slide to Finalize'), findsNothing);
    });

    testWidgets('shows a slider when the feature flag is enabled', (
      tester,
    ) async {
      await pumpFinalizeButton(tester, expense: expense, sliderEnabled: true);

      expect(find.text('Slide to Finalize'), findsOneWidget);
      expect(find.text('Finalize'), findsNothing);
    });

    testWidgets('finalizes the expense once the slider is dragged to the end', (
      tester,
    ) async {
      final coordinationRepository = MockCoordinationRepository();
      when(
        coordinationRepository.finalizeExpense(any),
      ).thenAnswer((_) async {});

      await pumpFinalizeButton(
        tester,
        expense: expense,
        sliderEnabled: true,
        coordinationRepository: coordinationRepository,
      );

      await tester.drag(
        find.byKey(const Key('slideToFinalizeKnob')),
        const Offset(300, 0),
      );
      await tester.pumpAndSettle();

      verify(coordinationRepository.finalizeExpense(expense.id)).called(1);
    });

    testWidgets(
      'snaps back without finalizing when the slider is not dragged far enough',
      (tester) async {
        final coordinationRepository = MockCoordinationRepository();
        when(
          coordinationRepository.finalizeExpense(any),
        ).thenAnswer((_) async {});

        await pumpFinalizeButton(
          tester,
          expense: expense,
          sliderEnabled: true,
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
  required bool sliderEnabled,
  MockCoordinationRepository? coordinationRepository,
}) async {
  final featureService = MockFeatureService();
  when(featureService.slideToFinalizeEnabled).thenReturn(sliderEnabled);

  await customPump(
    Scaffold(
      key: GroupPage.scaffoldKey,
      body: ExpensesBuilder(
        builder: (_, state) => SizedBox(
          width: 300,
          child: FinalizeButton(expense: state.expenses.first),
        ),
      ),
    ),
    tester,
    featureService: featureService,
    coordinationRepository: coordinationRepository,
    expenses: [expense],
  );
  await tester.pumpAndSettle();
}
