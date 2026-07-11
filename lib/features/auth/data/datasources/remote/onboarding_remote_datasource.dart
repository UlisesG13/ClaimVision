import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/network/api_error_mapper.dart';
import '../../dtos/confirm_data_request_dto.dart';
import '../../dtos/consent_request_dto.dart';
import '../../dtos/ocr_response_dto.dart';

abstract interface class OnboardingRemoteDataSource {
  Future<OcrResponseDto> extractOcr({required File cedula, required File poliza});
  Future<void> sendConsent(ConsentRequestDto body);
  Future<void> confirmData(ConfirmDataRequestDto body);
}

class OnboardingRemoteDataSourceImpl implements OnboardingRemoteDataSource {
  OnboardingRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<OcrResponseDto> extractOcr({
    required File cedula,
    required File poliza,
  }) async {
    try {
      final formData = FormData.fromMap({
        'cedula': await _filePart(cedula, 'cedula.jpg'),
        'poliza': await _filePart(poliza, 'poliza.jpg'),
      });
      final response = await _dio.post(
        ApiConstants.onboardingOcr,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      _ensureSuccess(response);
      return OcrResponseDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiErrorMapper.fromDioException(e);
    }
  }

  @override
  Future<void> sendConsent(ConsentRequestDto body) async {
    try {
      final response = await _dio.post(
        ApiConstants.consentimiento,
        data: body.toJson(),
      );
      _ensureSuccess(response);
    } on DioException catch (e) {
      throw ApiErrorMapper.fromDioException(e);
    }
  }

  @override
  Future<void> confirmData(ConfirmDataRequestDto body) async {
    try {
      final response = await _dio.post(
        ApiConstants.onboardingConfirmar,
        data: body.toJson(),
      );
      _ensureSuccess(response);
    } on DioException catch (e) {
      throw ApiErrorMapper.fromDioException(e);
    }
  }

  Future<MultipartFile> _filePart(File file, String filename) {
    return MultipartFile.fromFile(file.path, filename: filename);
  }

  void _ensureSuccess(Response response) {
    final status = response.statusCode ?? 500;
    if (status >= 400) {
      throw ApiErrorMapper.fromResponse(response);
    }
  }
}
