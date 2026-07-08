import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/network/api_error_mapper.dart';
import '../../dtos/imagen_siniestro_response_dto.dart';
import '../../dtos/siniestro_inicializar_dto.dart';
import 'package:claimvision/shared/data/dtos/siniestro_response_dto.dart';
import '../../dtos/siniestro_update_dto.dart';

/// Llamadas REST de siniestros del cliente. El token Bearer lo añade el
/// interceptor del Dio. Lanza [AppException] tipadas ante error.
abstract interface class SiniestroRemoteDataSource {
  Future<SiniestroResponseDto> inicializar(SiniestroInicializarDto body);
  Future<SiniestroResponseDto> actualizar(String id, SiniestroUpdateDto body);
  Future<ImagenSiniestroResponseDto> subirImagen(String id, File imagen);
  Future<List<SiniestroResponseDto>> listar();
  Future<SiniestroResponseDto> obtener(String id);
}

class SiniestroRemoteDataSourceImpl implements SiniestroRemoteDataSource {
  SiniestroRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<SiniestroResponseDto> inicializar(SiniestroInicializarDto body) async {
    try {
      final response = await _dio.post(
        ApiConstants.siniestroInicializar,
        data: body.toJson(),
      );
      _ensureSuccess(response);
      return SiniestroResponseDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiErrorMapper.fromDioException(e);
    }
  }

  @override
  Future<SiniestroResponseDto> actualizar(
      String id, SiniestroUpdateDto body) async {
    try {
      final response = await _dio.put(
        ApiConstants.siniestro(id),
        data: body.toJson(),
      );
      _ensureSuccess(response);
      return SiniestroResponseDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiErrorMapper.fromDioException(e);
    }
  }

  @override
  Future<ImagenSiniestroResponseDto> subirImagen(String id, File imagen) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imagen.path,
          filename: 'dano_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      });
      final response = await _dio.post(
        ApiConstants.siniestroImagenes(id),
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      _ensureSuccess(response);
      return ImagenSiniestroResponseDto.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiErrorMapper.fromDioException(e);
    }
  }

  @override
  Future<List<SiniestroResponseDto>> listar() async {
    try {
      final response = await _dio.get(ApiConstants.clienteSiniestros);
      _ensureSuccess(response);
      final data = (response.data as List?) ?? const [];
      return data
          .map((e) => SiniestroResponseDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiErrorMapper.fromDioException(e);
    }
  }

  @override
  Future<SiniestroResponseDto> obtener(String id) async {
    try {
      final response = await _dio.get(ApiConstants.clienteSiniestro(id));
      _ensureSuccess(response);
      return SiniestroResponseDto.fromJson(response.data as Map<String, dynamic>);
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
