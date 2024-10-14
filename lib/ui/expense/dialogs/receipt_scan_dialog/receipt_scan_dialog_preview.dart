import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:statera/data/models/expense.dart';
import 'package:statera/data/services/expense_service.mocks.dart';
import 'package:statera/data/services/file_services/file_storage_service.mocks.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/ui/expense/dialogs/receipt_scan_dialog/receipt_scan_dialog.dart';
import 'package:statera/utils/preview_helpers.dart';

main() {
  runApp(ReceiptScanDialogPreview());
}

class ReceiptScanDialogPreview extends StatelessWidget {
  const ReceiptScanDialogPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final expense = Expense.empty();
    final mockFileStorageService = MockFileStorageService();
    when(
      mockFileStorageService.uploadFile(any, path: anyNamed('path')),
    ).thenAnswer((_) async {
      await Future.delayed(1.seconds);
      return '';
    });
    return Preview(
      providers: [
        Provider<FileStorageService>.value(value: mockFileStorageService),
        Provider.value(value: FilePickerService()),
        Provider.value(value: PreferencesService()),
        Provider<ExpenseService>.value(value: MockExpenseService()),
      ],
      body: ReceiptScanDialog(expense: expense),
    );
  }
}
