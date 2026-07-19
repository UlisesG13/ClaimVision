import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_error_mapper.dart';

class OcrRemoteDataSource {
  OcrRemoteDataSource(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> extractOcr({
    required File ineFront,
    File? ineBack,
    required File policy,
  }) async {
    try {
      final form = FormData.fromMap({
        'poliza': await MultipartFile.fromFile(policy.path, filename: 'poliza.pdf'),
        'ine': await MultipartFile.fromFile(ineFront.path, filename: 'ine_front.jpg'),
      });

      final response = await _dio.post(
        ApiConstants.iaOcrExtractAndValidate,
        data: form,
        options: Options(contentType: 'multipart/form-data'),
      );
      _ensureSuccess(response);
      return response.data as Map<String, dynamic>;
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
