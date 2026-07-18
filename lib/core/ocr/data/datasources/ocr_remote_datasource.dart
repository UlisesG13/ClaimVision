import 'dart:io';

import 'package:dio/dio.dart';

class OcrRemoteDataSource {
  OcrRemoteDataSource(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> extractOcr({
    required File ineFront,
    File? ineBack,
    required File policy,
  }) async {
    final form = FormData.fromMap({
      'ine_front': await MultipartFile.fromFile(ineFront.path,
          filename: 'ine_front.jpg'),
      if (ineBack != null)
        'ine_back': await MultipartFile.fromFile(ineBack.path,
            filename: 'ine_back.jpg'),
      'policy': await MultipartFile.fromFile(policy.path,
          filename: 'policy.jpg'),
    });

    final response = await _dio.post(
      '/api/v1/cliente/onboarding/ocr',
      data: form,
    );

    return response.data as Map<String, dynamic>;
  }
}
