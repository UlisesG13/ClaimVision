import 'dart:io';

import 'document_type.dart';
import 'image_quality.dart';

abstract class ImageValidator {
  Future<ImageQuality> validate(File image, DocumentType type);
}
