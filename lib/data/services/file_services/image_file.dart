import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

class ImageFile {
  final String name;
  final String path;
  final Uint8List bytes;

  ImageFile({required this.name, required this.path, required this.bytes});

  static Future<ImageFile> fromXFile(XFile xFile) async {
    final bytes = await xFile.readAsBytes();
    return ImageFile(name: xFile.name, path: xFile.path, bytes: bytes);
  }
}
