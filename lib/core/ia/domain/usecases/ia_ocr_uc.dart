import 'dart:io';

import '../../data/dtos/ia_ocr_dto.dart';
import '../ia_repository.dart';

class IaExtractOcr {
  const IaExtractOcr(this._repository);
  final IaRepository _repository;

  Future<IaOcrResponseDto> call({required File file}) {
    return _repository.ocr(file: file);
  }
}

class IaExtractPoliza {
  const IaExtractPoliza(this._repository);
  final IaRepository _repository;

  Future<IaPolizaExtractedDto> call({required File file}) {
    return _repository.extractPoliza(file: file);
  }
}

class IaExtractIne {
  const IaExtractIne(this._repository);
  final IaRepository _repository;

  Future<IaIneExtractedDto> call({required File file}) {
    return _repository.extractIne(file: file);
  }
}

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
