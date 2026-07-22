import 'dart:io';

import 'package:file_picker/file_picker.dart';

/// Envoltorio sobre `file_picker` para seleccionar archivos PDF.
/// Separado de [ImagePickerService] porque éste maneja imágenes (cámara/galería).
class FilePickerService {
  /// Selecciona un archivo PDF del sistema. Retorna `null` si el usuario cancela.
  Future<File?> pickPdf() async {
    final result = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result == null) return null;
    final path = result.path;
    if (path == null) return null;
    return File(path);
  }
}
