import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/data/services/services.dart';

class ReceiptPicker extends StatelessWidget {
  final ValueNotifier<ImageFile?> controller;

  ReceiptPicker({super.key, ValueNotifier<ImageFile?>? controller})
      : this.controller = controller ?? ValueNotifier(null);

  void selectImage(
    FilePickerService filePickerService,
    ImageFileSource source,
  ) async {
    final pickedImage = await filePickerService.pickImage(source: source);
    controller.value = pickedImage;
  }

  @override
  Widget build(BuildContext context) {
    FilePickerService _filePickerService = context.read<FilePickerService>();

    return Column(
      children: [
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: ValueListenableBuilder(
                valueListenable: controller,
                builder: (context, value, _) {
                  final bgColor = Theme.of(context).colorScheme.onSurface;
                  final iconColor =
                      Theme.of(context).colorScheme.onInverseSurface;

                  return Container(
                    width: 200,
                    height: 200,
                    child: (value != null)
                        ? Image.memory(value.bytes, fit: BoxFit.cover)
                        : Icon(Icons.receipt_long, size: 100, color: iconColor),
                    color: bgColor,
                  );
                }),
          ),
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Spacer(),
            FilledButton.tonalIcon(
              icon: Icon(Icons.photo_camera),
              label: Text('Camera'),
              onPressed: () =>
                  selectImage(_filePickerService, ImageFileSource.camera),
            ),
            SizedBox(width: 10),
            Text('or'),
            SizedBox(width: 10),
            FilledButton.tonalIcon(
              icon: Icon(Icons.collections),
              label: Text('Gallery'),
              onPressed: () =>
                  selectImage(_filePickerService, ImageFileSource.gallery),
            ),
            Spacer(),
          ],
        ),
      ],
    );
  }
}
