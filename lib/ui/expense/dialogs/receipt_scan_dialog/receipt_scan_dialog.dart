import 'dart:developer';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/data/models/expense.dart';
import 'package:statera/data/models/item.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/ui/expense/dialogs/receipt_scan_dialog/step_indicator.dart';
import 'package:statera/ui/widgets/page_scaffold.dart';
import 'package:statera/utils/helpers.dart';

enum Store { Other, Walmart, LCBO }

class ReceiptScanDialog extends StatefulWidget {
  final Expense expense;

  const ReceiptScanDialog({
    Key? key,
    required this.expense,
  }) : super(key: key);

  @override
  State<ReceiptScanDialog> createState() => _ReceiptScanDialogState();

  Future<void> show(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => this,
      ),
    );
  }
}

class _ReceiptScanDialogState extends State<ReceiptScanDialog> {
  Store _selectedStore = Store.Other;
  bool _withNameImprovement = false;
  int _currentStep = 1;

  FileStorageService get _fileStorageService =>
      context.read<FileStorageService>();
  FilePickerService get _filePickerService => context.read<FilePickerService>();

  ExpenseService get _expenseService => context.read<ExpenseService>();

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Scan a receipt',
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StepIndicator(
              steps: [
                StepData(title: 'Choose a receipt'),
                StepData(title: 'Uploading the receipt...'),
                StepData(title: 'Analyzing the receipt...'),
              ],
              currentStep: _currentStep,
            ),
            DropdownButtonFormField<Store>(
              value: _selectedStore,
              onChanged: (store) {
                setState(() {
                  _selectedStore = store ?? _selectedStore;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Store',
              ),
              items: Store.values
                  .map((store) => DropdownMenuItem(
                        child: Text(store.toString().split('.')[1]),
                        value: store,
                      ))
                  .toList(),
            ),
            if (_selectedStore == Store.Walmart)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    value: _withNameImprovement,
                    onChanged: (isOn) {
                      setState(() {
                        _withNameImprovement = !_withNameImprovement;
                      });
                    },
                    title: Text('Improve product names'),
                  ),
                  if (_withNameImprovement)
                    Text(
                      'Checking this option will attempt to provide human readable names for Walmart products. This will also significantly increase the loading time.',
                      style: TextStyle(fontSize: 12),
                    ),
                ],
              ),
            SizedBox(height: 10),
            Row(
              children: [
                Spacer(),
                FilledButton.tonalIcon(
                  icon: Icon(Icons.photo_camera),
                  label: Text('Camera'),
                  onPressed: () => handleScan(ImageFileSource.camera),
                ),
                SizedBox(width: 10),
                Text('or'),
                SizedBox(width: 10),
                FilledButton.tonalIcon(
                  icon: Icon(Icons.collections),
                  label: Text('Gallery'),
                  onPressed: () => handleScan(ImageFileSource.gallery),
                ),
                Spacer(),
              ],
            ),
            SizedBox(height: 10),
            FilledButton(onPressed: () {}, child: Text('Continue'))
          ],
        ),
      ),
    );
  }

  void _incrementStep() {
    setState(() {
      _currentStep++;
    });
  }

  void handleScan(ImageFileSource source) async {
    final pickedFile = await _filePickerService.pickImage(source: source);

    try {
      _incrementStep();

      String url =
          await _fileStorageService.uploadFile(pickedFile, path: 'receipts/');

      log('Uploaded receipt: $url');

      _incrementStep();

      var scanSuccessful = await snackbarCatch(
        context,
        () async {
          List<Item> items = await Callables.getReceiptData(
            receiptUrl: url,
            selectedStore:
                _selectedStore.toString().split('.')[1].toLowerCase(),
            withNameImprovement: _withNameImprovement,
          );

          items.forEach(widget.expense.addItem);
        },
        errorMessage: 'Something went wrong while processing your photo',
      );

      if (scanSuccessful) {
        await _expenseService.updateExpense(widget.expense);
        Navigator.of(context).pop();
      }
    } on Exception catch (e) {
      showErrorSnackBar(context, 'Error while uploading: $e');
      await FirebaseCrashlytics.instance.recordError(
        e,
        null,
        reason: 'Receipt upload failed',
      );
    }
  }
}
