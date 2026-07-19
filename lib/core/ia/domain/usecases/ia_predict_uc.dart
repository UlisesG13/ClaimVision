import 'dart:io';

import '../../data/dtos/ia_predict_dto.dart';
import '../../data/dtos/ia_v2_dto.dart';
import '../ia_repository.dart';

class IaPredictDamage {
  const IaPredictDamage(this._repository);
  final IaRepository _repository;

  Future<IaPredictResponseDto> call({required File file}) {
    return _repository.predict(file: file);
  }
}

class IaPredictDamageV2 {
  const IaPredictDamageV2(this._repository);
  final IaRepository _repository;

  Future<IaV2PredictResponseDto> call({required File file}) {
    return _repository.predictV2(file: file);
  }
}
