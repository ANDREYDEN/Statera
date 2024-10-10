import 'dart:developer';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:statera/data/models/expense.dart';
import 'package:statera/data/models/item.dart';
import 'package:statera/data/services/callables.dart';
import 'package:statera/data/services/expense_service.dart';
import 'package:statera/data/services/firebase_storage_repository.dart';
import 'package:statera/ui/widgets/buttons/cancel_button.dart';
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
}

class _ReceiptScanDialogState extends State<ReceiptScanDialog> {
  final ImagePicker _picker = ImagePicker();
  Store _selectedStore = Store.Other;
  bool _withNameImprovement = false;
  String? _status;

  FirebaseStorageRepository get _firebaseStorageRepository =>
      context.read<FirebaseStorageRepository>();

  ExpenseService get _expenseService => context.read<ExpenseService>();

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Scan a receipt',
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: _status != null
            ? Text(_status!)
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                      CancelButton(),
                      SizedBox(width: 5),
                      FilledButton.tonal(
                        onPressed: () => handleScan(ImageSource.camera),
                        child: Icon(Icons.photo_camera),
                      ),
                      SizedBox(width: 5),
                      FilledButton.tonal(
                        onPressed: () => handleScan(ImageSource.gallery),
                        child: Icon(Icons.collections),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  void setStatus(String? status) {
    setState(() {
      _status = status;
    });
  }

  void handleScan(ImageSource source) async {
    setStatus('Picking image...');

    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile == null)
      throw new Exception('Something went wrong while taking a photo');

    try {
      setStatus('Uploading...');

      String url = await _firebaseStorageRepository.uploadPickedFile(
        pickedFile,
        path: 'receipts/',
      );

      log('Uploaded receipt: $url');

      setStatus('Analyzing receipt (this might take up to a minute)...');

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
      }
    } on Exception catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error while uploading: $e')));
      await FirebaseCrashlytics.instance.recordError(
        e,
        null,
        reason: 'Receipt upload failed',
      );
    } finally {
      setStatus(null);
      Navigator.of(context).pop();
    }
  }
}
