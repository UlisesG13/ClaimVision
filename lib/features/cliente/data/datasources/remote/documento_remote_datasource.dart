import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/network/api_error_mapper.dart';
import '../../../../../shared/domain/models/documento.dart';

abstract interface class DocumentoRemoteDataSource {
  Future<DocumentosResponse> obtener();
  Future<DocumentosResponse> subir({
    required File identificacion,
    required File poliza,
  });
}

class DocumentoRemoteDataSourceImpl implements DocumentoRemoteDataSource {
  DocumentoRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<DocumentosResponse> obtener() async {
    try {
      final response = await _dio.get(ApiConstants.documentosObtener);
      _ensureSuccess(response);
      return DocumentosResponse.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiErrorMapper.fromDioException(e);
    }
  }

  @override
  Future<DocumentosResponse> subir({
    required File identificacion,
    required File poliza,
  }) async {
    try {
      final formData = FormData.fromMap({
        'identificacion': await MultipartFile.fromFile(
          identificacion.path,
          filename:
              'identificacion_${DateTime.now().millisecondsSinceEpoch}.${_extension(identificacion)}',
        ),
        'poliza': await MultipartFile.fromFile(
          poliza.path,
          filename:
              'poliza_${DateTime.now().millisecondsSinceEpoch}.pdf',
        ),
      });
      final response = await _dio.post(
        ApiConstants.documentosSubir,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      _ensureSuccess(response);
      return DocumentosResponse.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiErrorMapper.fromDioException(e);
    }
  }

  String _extension(File f) =>
      f.path.contains('.pdf') ? 'pdf' : 'jpg';

  void _ensureSuccess(Response response) {
    final status = response.statusCode ?? 500;
    if (status >= 400) {
      throw ApiErrorMapper.fromResponse(response);
    }
  }
}
