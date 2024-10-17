import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/data/models/expense.dart';
import 'package:statera/data/models/item.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/ui/expense/dialogs/receipt_scan_dialog/step_indicator.dart';
import 'package:statera/ui/expense/dialogs/receipt_scan_dialog/store.dart';
import 'package:statera/ui/expense/dialogs/receipt_scan_dialog/store_input.dart';
import 'package:statera/ui/widgets/page_scaffold.dart';
import 'package:statera/utils/helpers.dart';

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
  ValueNotifier<Store> _storeController = ValueNotifier(Store.other);
  bool _withNameImprovement = false;
  int _currentStep = 1;
  ImageFile? _receiptImage;

  FileStorageService get _fileStorageService =>
      context.read<FileStorageService>();
  FilePickerService get _filePickerService => context.read<FilePickerService>();
  Callables get _callables => context.read<Callables>();

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
                StepData(title: 'Updating expense...'),
              ],
              currentStep: _currentStep,
            ),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 200,
                  height: 200,
                  child: (_receiptImage != null)
                      ? Image.memory(
                          _receiptImage!.bytes,
                          fit: BoxFit.cover,
                        )
                      : Icon(
                          Icons.receipt_long,
                          size: 100,
                          color: Theme.of(context).colorScheme.onInverseSurface,
                        ),
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Spacer(),
                FilledButton.tonalIcon(
                  icon: Icon(Icons.photo_camera),
                  label: Text('Camera'),
                  onPressed: () => selectImage(ImageFileSource.camera),
                ),
                SizedBox(width: 10),
                Text('or'),
                SizedBox(width: 10),
                FilledButton.tonalIcon(
                  icon: Icon(Icons.collections),
                  label: Text('Gallery'),
                  onPressed: () => selectImage(ImageFileSource.gallery),
                ),
                Spacer(),
              ],
            ),
            SizedBox(height: 20),
            StoreInput(controller: _storeController),
            ValueListenableBuilder(
              valueListenable: _storeController,
              builder: (context, value, _) {
                if (value != Store.walmart) {
                  return SizedBox.shrink();
                }

                return Column(
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
                    Text(
                      'Checking this option will attempt to provide human readable names for Walmart products. This will also significantly increase the loading time.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: 10),
            FilledButton(onPressed: processImage, child: Text('Continue'))
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

  void selectImage(ImageFileSource source) async {
    final pickedImage = await _filePickerService.pickImage(source: source);
    setState(() {
      _receiptImage = pickedImage;
    });
  }

  void processImage() async {
    if (_receiptImage == null) {
      return;
    }

    try {
      _incrementStep();

      final url = await _fileStorageService.uploadFile(
        _receiptImage!,
        path: 'receipts/',
      );
      _incrementStep();

      List<Item> items = await _callables.getReceiptData(
        receiptUrl: url,
        selectedStore: _storeController.value.title.toLowerCase(),
        withNameImprovement: _withNameImprovement,
      );
      _incrementStep();

      items.forEach(widget.expense.addItem);
      await _expenseService.updateExpense(widget.expense);
      Navigator.of(context).pop();
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
