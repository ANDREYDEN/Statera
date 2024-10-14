import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:mockito/annotations.dart';
import 'package:statera/data/services/services.dart';

@GenerateNiceMocks([MockSpec<FileStorageService>()])
class FileStorageService {
  late FirebaseStorage _storage;

  FileStorageService() {
    _storage = FirebaseStorage.instance;
  }

  /// Uploads an [ImageFile] to Firebase Storage
  /// The [path] parameter should end with a trailing '/' if provided
  Future<String> uploadFile(ImageFile file, {String path = ''}) async {
    assert(path == '' || path.endsWith('/'));

    var ref = _storage.ref('${path}${file.name}');
    var task =
        await (kIsWeb ? ref.putData(file.bytes) : ref.putFile(File(file.path)));

    return task.ref.getDownloadURL();
  }
}
