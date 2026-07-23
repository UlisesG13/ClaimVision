import 'dart:io';

import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  ImagePickerService([ImagePicker? picker]) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  Future<File?> fromCamera() => _pick(ImageSource.camera);
  Future<File?> fromGallery() => _pick(ImageSource.gallery);
  Future<List<File>> pickMultipleFromGallery() async {
    final files = await _picker.pickMultiImage(
      imageQuality: 80,
      maxWidth: 2000,
    );
    return files.map((f) => File(f.path)).toList();
  }

  Future<File?> _pick(ImageSource source) async {
    final XFile? file = await _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 2000,
    );
    return file == null ? null : File(file.path);
  }
}
