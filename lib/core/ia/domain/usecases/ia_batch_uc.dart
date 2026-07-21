import 'dart:io';

import '../../data/dtos/ia_batch_dto.dart';
import '../ia_repository.dart';

class IaPredictAllDamage {
  const IaPredictAllDamage(this._repository);
  final IaRepository _repository;

  Future<IaPredictAllResponseDto> call({required List<File> files}) {
    return _repository.predictAll(files: files);
  }
}

class IaObtenerResumen {
  const IaObtenerResumen(this._repository);
  final IaRepository _repository;

  Future<IaResumenResponseDto> call({
    required List<({String tipo, String severidad})> danos,
  }) {
    return _repository.obtenerResumen(danos: danos);
  }
}
