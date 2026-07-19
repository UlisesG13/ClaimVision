import '../../data/dtos/ia_predict_dto.dart';
import '../../data/dtos/ia_v2_dto.dart';
import '../ia_repository.dart';

class IaCheckHealth {
  const IaCheckHealth(this._repository);
  final IaRepository _repository;

  Future<IaHealthResponseDto> call() => _repository.health();
}

class IaCheckHealthV2 {
  const IaCheckHealthV2(this._repository);
  final IaRepository _repository;

  Future<IaV2HealthResponseDto> call() => _repository.healthV2();
}
