import 'dart:io';

import 'ocr_extraction.dart';

abstract class OcrRepository {
  Future<OcrExtraction> extract({
    required File ineFront,
    File? ineBack,
    required File policy,
  });
}
