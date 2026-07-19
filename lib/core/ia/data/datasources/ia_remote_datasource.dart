import 'dart:io';

import 'package:dio/dio.dart';

import '../../../constants/api_constants.dart';
import '../../../network/api_error_mapper.dart';
import '../dtos/ia_nlp_dto.dart';
import '../dtos/ia_ocr_dto.dart';
import '../dtos/ia_predict_dto.dart';
import '../dtos/ia_v2_dto.dart';

class IaRemoteDataSource {
  IaRemoteDataSource(this._dio);

  final Dio _dio;

  String _fileName(File f) => f.path.split(RegExp(r'[\\/]')).last;

  // ── OCR ────────────────────────────────────────────────────────────────

  Future<IaOcrResponseDto> ocr({required File file}) async {
    try {
      final form = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: _fileName(file)),
      });
      final response = await _dio.post(ApiConstants.iaOcr, data: form);
      _ensureSuccess(response);
      return IaOcrResponseDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiErrorMapper.fromDioException(e);
    }
  }

  Future<Map<String, dynamic>> ocrHistory({int page = 1, int limit = 20}) async {
    try {
      final response = await _dio.get(
        ApiConstants.iaOcrHistory,
        queryParameters: {'page': page, 'limit': limit},
      );
      _ensureSuccess(response);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiErrorMapper.fromDioException(e);
    }
  }

  Future<IaPolizaExtractedDto> extractPoliza({required File file}) async {
    try {
      final form = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: _fileName(file)),
      });
      final response = await _dio.post(ApiConstants.iaOcrExtractPoliza, data: form);
      _ensureSuccess(response);
      return IaPolizaExtractedDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiErrorMapper.fromDioException(e);
    }
  }

  Future<IaIneExtractedDto> extractIne({required File file}) async {
    try {
      final form = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: _fileName(file)),
      });
      final response = await _dio.post(ApiConstants.iaOcrExtractIne, data: form);
      _ensureSuccess(response);
      return IaIneExtractedDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiErrorMapper.fromDioException(e);
    }
  }

  Future<IaExtractAndValidateDto> extractAndValidate({
    required File poliza,
    required File ine,
  }) async {
    try {
      final form = FormData.fromMap({
        'poliza': await MultipartFile.fromFile(poliza.path, filename: _fileName(poliza)),
        'ine': await MultipartFile.fromFile(ine.path, filename: _fileName(ine)),
      });
      final response = await _dio.post(
        ApiConstants.iaOcrExtractAndValidate,
        data: form,
      );
      _ensureSuccess(response);
      return IaExtractAndValidateDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiErrorMapper.fromDioException(e);
    }
  }

  // ── Predict v1 (No Supervised) ─────────────────────────────────────────

  Future<IaPredictResponseDto> predict({required File file}) async {
    try {
      final form = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: _fileName(file)),
      });
      final response = await _dio.post(ApiConstants.iaPredict, data: form);
      _ensureSuccess(response);
      return IaPredictResponseDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiErrorMapper.fromDioException(e);
    }
  }

  Future<Map<String, dynamic>> history({int page = 1, int limit = 20}) async {
    try {
      final response = await _dio.get(
        ApiConstants.iaHistory,
        queryParameters: {'page': page, 'limit': limit},
      );
      _ensureSuccess(response);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiErrorMapper.fromDioException(e);
    }
  }

  Future<IaRetrainResponseDto> retrain({
    required int k,
    required List<File> files,
  }) async {
    try {
      final form = FormData.fromMap({
        'k': k,
        'files': await Future.wait(
          files.map((f) => MultipartFile.fromFile(f.path, filename: _fileName(f))),
        ),
      });
      final response = await _dio.post(ApiConstants.iaRetrain, data: form);
      _ensureSuccess(response);
      return IaRetrainResponseDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiErrorMapper.fromDioException(e);
    }
  }

  Future<IaHealthResponseDto> health() async {
    try {
      final response = await _dio.get(ApiConstants.iaHealth);
      _ensureSuccess(response);
      return IaHealthResponseDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiErrorMapper.fromDioException(e);
    }
  }

  // ── Predict v2 (Supervised / ResNet18) ─────────────────────────────────

  Future<IaV2PredictResponseDto> predictV2({required File file}) async {
    try {
      final form = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: _fileName(file)),
      });
      final response = await _dio.post(ApiConstants.iaV2Predict, data: form);
      _ensureSuccess(response);
      return IaV2PredictResponseDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiErrorMapper.fromDioException(e);
    }
  }

  Future<IaV2RetrainResponseDto> retrainV2({
    required String labels,
    required List<File> files,
    int epochs = 40,
    double lr = 0.001,
  }) async {
    try {
      final form = FormData.fromMap({
        'labels': labels,
        'epochs': epochs,
        'lr': lr,
        'files': await Future.wait(
          files.map((f) => MultipartFile.fromFile(f.path, filename: _fileName(f))),
        ),
      });
      final response = await _dio.post(ApiConstants.iaV2Retrain, data: form);
      _ensureSuccess(response);
      return IaV2RetrainResponseDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiErrorMapper.fromDioException(e);
    }
  }

  Future<IaV2RetrainStatusResponseDto> retrainV2Status(String jobId) async {
    try {
      final response = await _dio.get(ApiConstants.iaV2RetrainStatus(jobId));
      _ensureSuccess(response);
      return IaV2RetrainStatusResponseDto.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiErrorMapper.fromDioException(e);
    }
  }

  Future<Map<String, dynamic>> historyV2({int page = 1, int limit = 20}) async {
    try {
      final response = await _dio.get(
        ApiConstants.iaV2History,
        queryParameters: {'page': page, 'limit': limit},
      );
      _ensureSuccess(response);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiErrorMapper.fromDioException(e);
    }
  }

  Future<IaV2HealthResponseDto> healthV2() async {
    try {
      final response = await _dio.get(ApiConstants.iaV2Health);
      _ensureSuccess(response);
      return IaV2HealthResponseDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiErrorMapper.fromDioException(e);
    }
  }

  // ── NLP ────────────────────────────────────────────────────────────────

  Future<IaTranscribirJobResponseDto> transcribir({required File file}) async {
    try {
      final form = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: _fileName(file)),
      });
      final response = await _dio.post(ApiConstants.iaNlpTranscribir, data: form);
      _ensureSuccess(response);
      return IaTranscribirJobResponseDto.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiErrorMapper.fromDioException(e);
    }
  }

  Future<IaTranscribirJobStatusResponseDto> transcribirStatus(String jobId) async {
    try {
      final response = await _dio.get(ApiConstants.iaNlpTranscribirStatus(jobId));
      _ensureSuccess(response);
      return IaTranscribirJobStatusResponseDto.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiErrorMapper.fromDioException(e);
    }
  }

  Future<IaAnalizarResponseDto> analizar(String texto) async {
    try {
      final response = await _dio.post(
        ApiConstants.iaNlpAnalizar,
        data: IaAnalizarRequestDto(texto: texto).toJson(),
      );
      _ensureSuccess(response);
      return IaAnalizarResponseDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiErrorMapper.fromDioException(e);
    }
  }

  Future<Map<String, dynamic>> nlpHistory({int page = 1, int limit = 20}) async {
    try {
      final response = await _dio.get(
        ApiConstants.iaNlpHistory,
        queryParameters: {'page': page, 'limit': limit},
      );
      _ensureSuccess(response);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiErrorMapper.fromDioException(e);
    }
  }

  Future<IaTranscribirResponseDto> nlpDetail(String id) async {
    try {
      final response = await _dio.get(ApiConstants.iaNlpDetail(id));
      _ensureSuccess(response);
      return IaTranscribirResponseDto.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiErrorMapper.fromDioException(e);
    }
  }

  void _ensureSuccess(Response response) {
    final status = response.statusCode ?? 500;
    if (status >= 400) {
      throw ApiErrorMapper.fromResponse(response);
    }
  }
}
