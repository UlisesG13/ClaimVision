import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/network/api_error_mapper.dart';
import '../../../../../shared/data/dtos/page_dto.dart';
import '../../../../../shared/data/dtos/siniestro_response_dto.dart';
import '../../dtos/imagen_siniestro_response_dto.dart';
import '../../dtos/siniestro_inicializar_dto.dart';
import '../../dtos/vehiculo_response_dto.dart';

abstract interface class SiniestroRemoteDataSource {
  Future<SiniestroResponseDto> crear(SiniestroInicializarDto body);
  Future<ImagenSiniestroResponseDto> subirImagen(String id, File imagen);
  Future<PageDto<SiniestroResponseDto>> listar({int page = 1, int pageSize = 20, String? estatus});
  Future<SiniestroResponseDto> obtener(String id);
  Future<List<VehiculoResponseDto>> obtenerVehiculos();
}

class SiniestroRemoteDataSourceImpl implements SiniestroRemoteDataSource {
  SiniestroRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<SiniestroResponseDto> crear(SiniestroInicializarDto body) async {
    try {
      final response = await _dio.post(
        ApiConstants.clienteSiniestros,
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
        ApiConstants.clienteSiniestroImagenes(id),
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
  Future<PageDto<SiniestroResponseDto>> listar({
    int page = 1,
    int pageSize = 20,
    String? estatus,
  }) async {
    try {
      final params = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
      };
      if (estatus != null) params['estatus'] = estatus;
      final response = await _dio.get(
        ApiConstants.clienteSiniestros,
        queryParameters: params,
      );
      _ensureSuccess(response);
      return PageDto.fromJson(
        response.data as Map<String, dynamic>,
        SiniestroResponseDto.fromJson,
      );
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

  @override
  Future<List<VehiculoResponseDto>> obtenerVehiculos() async {
    try {
      final response = await _dio.get(ApiConstants.clienteVehiculos);
      _ensureSuccess(response);
      final page = PageDto.fromJson(
        response.data as Map<String, dynamic>,
        VehiculoResponseDto.fromJson,
      );
      return page.data;
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
