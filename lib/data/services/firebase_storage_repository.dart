import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class FirebaseStorageRepository {
  late FirebaseStorage _storage;

  FirebaseStorageRepository() {
    _storage = FirebaseStorage.instance;
  }

  /// Uploads an `XFile` to Firebase Storage
  /// The [path] parameter should end with a trailing '/' if provided
  Future<String> uploadPickedFile(XFile file, {String path = ''}) async {
    if (path != '' && !path.endsWith('/'))
      throw Exception('Invalid path parameter');

    var ref = _storage.ref('${path}${file.name}');
    var task = await (kIsWeb
        ? ref.putData(await file.readAsBytes())
        : ref.putFile(File(file.path)));

    return task.ref.getDownloadURL();
  }
}
