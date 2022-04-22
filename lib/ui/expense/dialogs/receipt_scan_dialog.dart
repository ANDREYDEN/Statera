import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:statera/data/models/expense.dart';
import 'package:statera/data/models/item.dart';
import 'package:statera/data/services/expense_service.dart';
import 'package:statera/ui/widgets/loader.dart';
import 'package:statera/utils/helpers.dart';

enum Store { Walmart, Other }

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
  Store _selectedStore = Store.Walmart;
  bool _withNameImprovement = false;
  String? _status;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Scan a receipt'),
      content: _status != null
          ? Center(child: Text(_status!))
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
              ],
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            "Cancel",
            style: TextStyle(
              color: Theme.of(context).errorColor,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () => handleScan(ImageSource.camera),
          child: Icon(Icons.photo_camera),
        ),
        ElevatedButton(
          onPressed: () => handleScan(ImageSource.gallery),
          child: Icon(Icons.collections),
        ),
      ],
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
      throw new Exception("Something went wrong while taking a photo");

    try {
      setStatus('Uploading...');

      var ref = FirebaseStorage.instance.ref('receipts/${pickedFile.name}');
      var task = await (kIsWeb
          ? ref.putData(await pickedFile.readAsBytes())
          : ref.putFile(File(pickedFile.path)));

      String url = await task.ref.getDownloadURL();

      setStatus('Analyzing receipt (this might take up to a minute)...');

      var getItemsFromImage =
          FirebaseFunctions.instance.httpsCallable('getReceiptData');
      var scanSuccessful = await snackbarCatch(
        context,
        () async {
          var response = await getItemsFromImage({
            'receiptUrl': url,
            'isWalmart': _selectedStore == Store.Walmart,
            'withNameImprovement': _withNameImprovement
          });
          List<dynamic> items = response.data;

          items.forEach((itemData) {
            try {
              var item = Item(
                name: itemData["name"] ?? "",
                value: double.tryParse(itemData["value"].toString()) ?? 0,
              );
              widget.expense.addItem(item);
            } catch (e) {
              print("Could not parse item $itemData: $e");
            }
          });
        },
        errorMessage: 'Something went wrong while processing your photo',
      );

      if (scanSuccessful) {
        await ExpenseService.instance.updateExpense(widget.expense);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error while uploading: " + e.toString()),
      ));
      print(e);
      return;
    } finally {
      setStatus(null);
      Navigator.of(context).pop();
    }
  }
}
