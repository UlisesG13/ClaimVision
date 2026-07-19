import '../../data/dtos/ia_nlp_dto.dart';
import '../../data/dtos/ia_paginated_dto.dart';
import '../../data/dtos/ia_v2_dto.dart';
import '../ia_repository.dart';

class IaGetV2History {
  const IaGetV2History(this._repository);
  final IaRepository _repository;

  Future<PaginatedResponseDto<IaV2HistoryItemDto>> call({
    int page = 1,
    int limit = 20,
  }) async {
    final json = await _repository.historyV2(page: page, limit: limit);
    return PaginatedResponseDto.fromJson(json, IaV2HistoryItemDto.fromJson);
  }
}

class IaGetNlpHistory {
  const IaGetNlpHistory(this._repository);
  final IaRepository _repository;

  Future<PaginatedResponseDto<IaNlpHistoryItemDto>> call({
    int page = 1,
    int limit = 20,
  }) async {
    final json = await _repository.nlpHistory(page: page, limit: limit);
    return PaginatedResponseDto.fromJson(json, IaNlpHistoryItemDto.fromJson);
  }
}

class IaGetNlpDetail {
  const IaGetNlpDetail(this._repository);
  final IaRepository _repository;

  Future<IaTranscribirResponseDto> call(String id) {
    return _repository.nlpDetail(id);
  }
}
