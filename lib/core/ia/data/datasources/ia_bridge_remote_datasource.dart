import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:dio/dio.dart';

import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/network/api_error_mapper.dart';
import '../dtos/ia_batch_dto.dart';
import '../dtos/ia_nlp_dto.dart';
import '../dtos/ia_ocr_dto.dart';
import '../dtos/ia_predict_dto.dart';
import '../dtos/ia_v2_dto.dart';

class IaBridgeRemoteDataSource {
  IaBridgeRemoteDataSource(this._dio);

  final Dio _dio;

  String _fileName(File f) => f.path.split(RegExp(r'[\\/]')).last;

  // ── OCR ────────────────────────────────────────────────────────────

  Future<IaOcrResponseDto> ocr({required File file}) async {
    try {
      final form = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: _fileName(file)),
      });
      final response = await _dio.post(ApiConstants.iaBridgeOcr, data: form);
      _ensureSuccess(response);
      return IaOcrResponseDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiErrorMapper.fromDioException(e);
    }
  }

  Future<Map<String, dynamic>> ocrHistory({int page = 1, int limit = 20}) async {
    try {
      final response = await _dio.get(
        ApiConstants.iaBridgeOcrHistory,
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
      final response = await _dio.post(ApiConstants.iaBridgeOcrExtractPoliza, data: form);
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
      final response = await _dio.post(ApiConstants.iaBridgeOcrExtractIne, data: form);
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
      debugPrint('[OCR-HTTP] POST ${ApiConstants.iaBridgeOcrExtractAndValidate}');
      debugPrint(
        '[OCR-HTTP] poliza=${poliza.path} (${poliza.lengthSync()} B), ine=${ine.path} (${ine.lengthSync()} B)',
      );
      final form = FormData.fromMap({
        'poliza': await MultipartFile.fromFile(poliza.path, filename: _fileName(poliza)),
        'ine': await MultipartFile.fromFile(ine.path, filename: _fileName(ine)),
      });
      final response = await _dio.post(
        ApiConstants.iaBridgeOcrExtractAndValidate,
        data: form,
      );
      debugPrint('[OCR-HTTP] Response: status=${response.statusCode}');
      debugPrint('[OCR-HTTP] Response body: ${response.data}');
      _ensureSuccess(response);
      return IaExtractAndValidateDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      debugPrint('[OCR-HTTP] DioException type=${e.type} message=${e.message}');
      debugPrint('[OCR-HTTP] DioException request: ${e.requestOptions.uri}');
      if (e.response != null) {
        debugPrint('[OCR-HTTP] Error response status=${e.response!.statusCode} body=${e.response!.data}');
      } else {
        debugPrint('[OCR-HTTP] No response from server');
      }
      throw ApiErrorMapper.fromDioException(e);
    }
  }

  // ── Predict v1 (No Supervised) ─────────────────────────────────────────

  Future<IaPredictResponseDto> predict({required File file}) async {
    try {
      final form = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: _fileName(file)),
      });
      final response = await _dio.post(ApiConstants.iaBridgePredict, data: form);
      _ensureSuccess(response);
      return IaPredictResponseDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiErrorMapper.fromDioException(e);
    }
  }

  Future<Map<String, dynamic>> history({int page = 1, int limit = 20}) async {
    try {
      final response = await _dio.get(
        ApiConstants.iaBridgeHistory,
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
      final response = await _dio.post(ApiConstants.iaBridgeRetrain, data: form);
      _ensureSuccess(response);
      return IaRetrainResponseDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiErrorMapper.fromDioException(e);
    }
  }

  Future<IaHealthResponseDto> health() async {
    try {
      final response = await _dio.get(ApiConstants.iaBridgeHealth);
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
      final response = await _dio.post(ApiConstants.iaBridgeV2Predict, data: form);
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
      final response = await _dio.post(ApiConstants.iaBridgeV2Retrain, data: form);
      _ensureSuccess(response);
      return IaV2RetrainResponseDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiErrorMapper.fromDioException(e);
    }
  }

  Future<IaV2RetrainStatusResponseDto> retrainV2Status(String jobId) async {
    try {
      final response = await _dio.get(ApiConstants.iaBridgeV2RetrainStatus(jobId));
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
        ApiConstants.iaBridgeV2History,
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
      final response = await _dio.get(ApiConstants.iaBridgeV2Health);
      _ensureSuccess(response);
      return IaV2HealthResponseDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiErrorMapper.fromDioException(e);
    }
  }

  // ── Predict v2: batch + resumen ─────────────────────────────────────────

  Future<IaPredictAllResponseDto> predictAll({required List<File> files}) async {
    try {
      final form = FormData.fromMap({
        'files': await Future.wait(
          files.map((f) => MultipartFile.fromFile(f.path, filename: _fileName(f))),
        ),
      });
      final response = await _dio.post(
        ApiConstants.iaBridgeV2PredictAll,
        data: form,
        options: Options(receiveTimeout: const Duration(seconds: 120)),
      );
      _ensureSuccess(response);
      return IaPredictAllResponseDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiErrorMapper.fromDioException(e);
    }
  }

  Future<IaResumenResponseDto> obtenerResumen({
    required List<({String tipo, String severidad})> danos,
  }) async {
    try {
      final body = IaResumenRequestDto(danos).toJson();
      final response = await _dio.post(
        ApiConstants.iaBridgeV2Resumen,
        data: body,
      );
      _ensureSuccess(response);
      return IaResumenResponseDto.fromJson(response.data as Map<String, dynamic>);
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
      final response = await _dio.post(ApiConstants.iaBridgeNlpTranscribir, data: form);
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
      final response = await _dio.get(ApiConstants.iaBridgeNlpTranscribirStatus(jobId));
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
        ApiConstants.iaBridgeNlpAnalizar,
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
        ApiConstants.iaBridgeNlpHistory,
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
      final response = await _dio.get(ApiConstants.iaBridgeNlpDetail(id));
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
      debugPrint('[HTTP] Error ${response.requestOptions.uri}: status=$status body=${response.data}');
      throw ApiErrorMapper.fromResponse(response);
    }
  }
}