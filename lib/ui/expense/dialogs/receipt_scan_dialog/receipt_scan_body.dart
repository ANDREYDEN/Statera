import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/data/models/expense.dart';
import 'package:statera/data/models/item.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/ui/expense/dialogs/receipt_scan_dialog/receipt_picker.dart';
import 'package:statera/ui/expense/dialogs/receipt_scan_dialog/step_indicator.dart';
import 'package:statera/ui/expense/dialogs/receipt_scan_dialog/store.dart';
import 'package:statera/ui/expense/dialogs/receipt_scan_dialog/store_input.dart';
import 'package:statera/ui/expense/dialogs/receipt_scan_dialog/with_name_improvement_input.dart';
import 'package:statera/ui/widgets/buttons/cancel_button.dart';
import 'package:statera/ui/widgets/buttons/ok_button.dart';

class ReceiptScanBody extends StatefulWidget {
  final Expense expense;

  const ReceiptScanBody({
    Key? key,
    required this.expense,
  }) : super(key: key);

  @override
  State<ReceiptScanBody> createState() => _ReceiptScanBodyState();
}

class _ReceiptScanBodyState extends State<ReceiptScanBody> {
  ValueNotifier<Store> _storeController = ValueNotifier(Store.other);
  ValueNotifier<bool> _withNameImprovementController = ValueNotifier(false);
  ValueNotifier<ImageFile?> _receiptImageController = ValueNotifier(null);
  int _currentStep = 1;
  String? _error = null;

  FileStorageService get _fileStorageService =>
      context.read<FileStorageService>();
  Callables get _callables => context.read<Callables>();
  ExpenseService get _expenseService => context.read<ExpenseService>();
  ErrorService get _errorService => context.read<ErrorService>();

  static const List<StepData> steps = const [
    StepData(title: 'Choose a receipt'),
    StepData.background(title: 'Uploading the receipt...'),
    StepData.background(title: 'Analyzing the receipt...'),
    StepData.background(title: 'Updating expense...'),
  ];
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StepIndicator(
          steps: steps,
          currentStepNumber: _currentStep,
          error: _error,
        ),
        if (_currentStep == 1) ...[
          ReceiptPicker(controller: _receiptImageController),
          SizedBox(height: 20),
          StoreInput(controller: _storeController),
          ValueListenableBuilder(
            valueListenable: _storeController,
            builder: (_, value, child) =>
                value == Store.walmart ? child! : SizedBox.shrink(),
            child: WithNameImprovementInput(
              controller: _withNameImprovementController,
            ),
          ),
          SizedBox(height: 40),
          ValueListenableBuilder(
            valueListenable: _receiptImageController,
            builder: (context, receiptImage, _) {
              return Row(
                children: [
                  Expanded(child: CancelButton()),
                  SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: receiptImage == null ? null : _processImage,
                      child: Text('Continue'),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
        if (_error != null)
          Column(children: [
            SelectableText(
              _error!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            SizedBox(height: 40),
            OkButton()
          ])
      ],
    );
  }

  void _incrementStep() {
    setState(() {
      _currentStep++;
    });
  }

  void _processImage() async {
    if (_receiptImageController.value == null) {
      return;
    }

    try {
      _incrementStep();

      final url = await _fileStorageService.uploadFile(
        _receiptImageController.value!,
        path: 'receipts/',
      );
      _incrementStep();

      List<Item> items = await _callables.getReceiptData(
        receiptUrl: url,
        selectedStore: _storeController.value.title.toLowerCase(),
        withNameImprovement: _withNameImprovementController.value,
      );
      _incrementStep();

      items.forEach(widget.expense.addItem);
      await _expenseService.updateExpense(widget.expense);
      Navigator.of(context).pop();
    } on Exception catch (e) {
      setState(() {
        _error = e.toString();
      });
      await _errorService.recordError(
        e,
        reason: 'Receipt upload failed',
      );
    }
  }
}
