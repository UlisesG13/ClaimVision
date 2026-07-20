import 'dart:io';

import '../../data/dtos/ia_ocr_dto.dart';
import '../ia_repository.dart';

class IaExtractAndValidate {
  const IaExtractAndValidate(this._repository);
  final IaRepository _repository;

  Future<IaExtractAndValidateDto> call({
    required File poliza,
    required File ine,
  }) {
    return _repository.extractAndValidate(poliza: poliza, ine: ine);
  }
}
