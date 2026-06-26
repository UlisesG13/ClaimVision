import 'dart:io';

import 'package:image_picker/image_picker.dart';

/// Envoltorio sobre `image_picker` para capturar/seleccionar imágenes de
/// documentos (cédula, póliza, evidencia). Centralizado para no repetir la
/// configuración de compresión por toda la app.
class ImagePickerService {
  ImagePickerService([ImagePicker? picker]) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  Future<File?> fromCamera() => _pick(ImageSource.camera);
  Future<File?> fromGallery() => _pick(ImageSource.gallery);

  Future<File?> _pick(ImageSource source) async {
    final XFile? file = await _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 2000,
    );
    return file == null ? null : File(file.path);
  }
}
