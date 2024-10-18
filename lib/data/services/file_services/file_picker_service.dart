import 'package:image_picker/image_picker.dart';
import 'package:mockito/annotations.dart';
import 'package:statera/data/services/services.dart';

@GenerateNiceMocks([MockSpec<FilePickerService>()])
class FilePickerService {
  Future<ImageFile> pickImage({
    ImageFileSource source = ImageFileSource.gallery,
  }) async {
    final picker = ImagePicker();
    final pickerImageSrouce = switch (source) {
      ImageFileSource.camera => ImageSource.camera,
      ImageFileSource.gallery => ImageSource.gallery
    };

    final file = await picker.pickImage(source: pickerImageSrouce);
    if (file == null) {
      throw Exception('Error occured while selecting an image');
    }

    return ImageFile.fromXFile(file);
  }
}

enum ImageFileSource { gallery, camera }
