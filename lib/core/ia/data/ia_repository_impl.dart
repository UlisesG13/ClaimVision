import 'dart:developer' as developer;
import 'dart:io';

import '../../errors/exceptions.dart';
import '../../errors/failures.dart';
import '../domain/ia_repository.dart';
import 'datasources/ia_bridge_remote_datasource.dart';
import 'dtos/ia_batch_dto.dart';
import 'dtos/ia_nlp_dto.dart';
import 'dtos/ia_ocr_dto.dart';
import 'dtos/ia_predict_dto.dart';
import 'dtos/ia_v2_dto.dart';

class IaRepositoryImpl implements IaRepository {
  IaRepositoryImpl(this._remote);

  final IaBridgeRemoteDataSource _remote;

  @override
  Future<IaOcrResponseDto> ocr({required File file}) =>
      _wrap(() => _remote.ocr(file: file));

  @override
  Future<Map<String, dynamic>> ocrHistory({int page = 1, int limit = 20}) =>
      _wrap(() => _remote.ocrHistory(page: page, limit: limit));

  @override
  Future<IaPolizaExtractedDto> extractPoliza({required File file}) =>
      _wrap(() => _remote.extractPoliza(file: file));

  @override
  Future<IaIneExtractedDto> extractIne({required File file}) =>
      _wrap(() => _remote.extractIne(file: file));

  @override
  Future<IaExtractAndValidateDto> extractAndValidate({
    required File poliza,
    required File ine,
  }) async {
    developer.log('[OCR-Repo] extractAndValidate llamado');
    try {
      final result = await _remote.extractAndValidate(poliza: poliza, ine: ine);
      developer.log('[OCR-Repo] Resultado exitoso');
      return result;
    } on AppException catch (e) {
      developer.log('[OCR-Repo] AppException: ${e.message}');
      throw _toFailure(e);
    }
  }

  @override
  Future<IaPredictResponseDto> predict({required File file}) =>
      _wrap(() => _remote.predict(file: file));

  @override
  Future<Map<String, dynamic>> history({int page = 1, int limit = 20}) =>
      _wrap(() => _remote.history(page: page, limit: limit));

  @override
  Future<IaRetrainResponseDto> retrain({
    required int k,
    required List<File> files,
  }) =>
      _wrap(() => _remote.retrain(k: k, files: files));

  @override
  Future<IaHealthResponseDto> health() => _wrap(() => _remote.health());

  @override
  Future<IaV2PredictResponseDto> predictV2({required File file}) =>
      _wrap(() => _remote.predictV2(file: file));

  @override
  Future<IaV2RetrainResponseDto> retrainV2({
    required String labels,
    required List<File> files,
    int epochs = 40,
    double lr = 0.001,
  }) =>
      _wrap(() => _remote.retrainV2(labels: labels, files: files, epochs: epochs, lr: lr));

  @override
  Future<IaV2RetrainStatusResponseDto> retrainV2Status(String jobId) =>
      _wrap(() => _remote.retrainV2Status(jobId));

  @override
  Future<Map<String, dynamic>> historyV2({int page = 1, int limit = 20}) =>
      _wrap(() => _remote.historyV2(page: page, limit: limit));

  @override
  Future<IaV2HealthResponseDto> healthV2() => _wrap(() => _remote.healthV2());

  @override
  Future<IaPredictAllResponseDto> predictAll({required List<File> files}) =>
      _wrap(() => _remote.predictAll(files: files));

  @override
  Future<IaResumenResponseDto> obtenerResumen({
    required List<({String tipo, String severidad})> danos,
  }) =>
      _wrap(() => _remote.obtenerResumen(danos: danos));

  @override
  Future<IaTranscribirJobResponseDto> transcribir({required File file}) =>
      _wrap(() => _remote.transcribir(file: file));

  @override
  Future<IaTranscribirJobStatusResponseDto> transcribirStatus(String jobId) =>
      _wrap(() => _remote.transcribirStatus(jobId));

  @override
  Future<IaAnalizarResponseDto> analizar(String texto) =>
      _wrap(() => _remote.analizar(texto));

  @override
  Future<Map<String, dynamic>> nlpHistory({int page = 1, int limit = 20}) =>
      _wrap(() => _remote.nlpHistory(page: page, limit: limit));

  @override
  Future<IaTranscribirResponseDto> nlpDetail(String id) =>
      _wrap(() => _remote.nlpDetail(id));

  Future<T> _wrap<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on AppException catch (e) {
      throw _toFailure(e);
    }
  }

  Failure _toFailure(AppException e) {
    return switch (e) {
      UnauthorizedException() => AuthFailure(e.message),
      ForbiddenException() => ForbiddenFailure(e.message),
      NotFoundException() => NotFoundFailure(e.message),
      ConflictException() => ConflictFailure(e.message),
      ValidationException() => ValidationFailure(e.message),
      _ => ServerFailure(e.message),
    };
  }
}
