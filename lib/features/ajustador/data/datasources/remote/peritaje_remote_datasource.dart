import 'package:claimvision/shared/data/dtos/page_dto.dart';
import 'package:claimvision/shared/data/dtos/siniestro_response_dto.dart';
import 'package:dio/dio.dart';

import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/network/api_error_mapper.dart';
import '../../dtos/ajustador_response_dto.dart';
import '../../dtos/dano_ajustado_dto.dart';
import '../../dtos/peritaje_response_dto.dart';
import '../../dtos/peritaje_upsert_dto.dart';

abstract interface class PeritajeRemoteDataSource {
  Future<PageDto<SiniestroResponseDto>> getAsignados({int page = 1, int pageSize = 20, String? estatus});
  Future<SiniestroResponseDto> obtenerDetalleSiniestro(String id);
  Future<PeritajeResponseDto> registrarPeritaje(String siniestroId, PeritajeUpsertDto body);
  Future<PeritajeResponseDto> editarPeritaje(String peritajeId, Map<String, dynamic> body);
  Future<PeritajeResponseDto> agregarDano(String peritajeId, DanoAjustadoDto dano);
  Future<AjustadorResponseDto> obtenerPerfil();
}

class PeritajeRemoteDataSourceImpl implements PeritajeRemoteDataSource {
  PeritajeRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<PageDto<SiniestroResponseDto>> getAsignados({
    int page = 1,
    int pageSize = 20,
    String? estatus,
  }) async {
    try {
      final params = <String, dynamic>{'page': page, 'page_size': pageSize};
      if (estatus != null) params['estatus'] = estatus;
      final response = await _dio.get(
        ApiConstants.ajustadorAsignaciones,
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
  Future<SiniestroResponseDto> obtenerDetalleSiniestro(String id) async {
    try {
      final response = await _dio.get(ApiConstants.ajustadorSiniestro(id));
      _ensureSuccess(response);
      return SiniestroResponseDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiErrorMapper.fromDioException(e);
    }
  }

  @override
  Future<PeritajeResponseDto> registrarPeritaje(
      String siniestroId, PeritajeUpsertDto body) async {
    try {
      final response = await _dio.post(
        ApiConstants.ajustadorRegistrarPeritaje(siniestroId),
        data: body.toJson(),
      );
      _ensureSuccess(response);
      return PeritajeResponseDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiErrorMapper.fromDioException(e);
    }
  }

  @override
  Future<PeritajeResponseDto> editarPeritaje(
      String peritajeId, Map<String, dynamic> body) async {
    try {
      final response = await _dio.patch(
        ApiConstants.ajustadorEditarPeritaje(peritajeId),
        data: body,
      );
      _ensureSuccess(response);
      return PeritajeResponseDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiErrorMapper.fromDioException(e);
    }
  }

  @override
  Future<PeritajeResponseDto> agregarDano(
      String peritajeId, DanoAjustadoDto dano) async {
    try {
      final response = await _dio.post(
        ApiConstants.ajustadorPeritajeDanos(peritajeId),
        data: dano.toJson(),
      );
      _ensureSuccess(response);
      return PeritajeResponseDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiErrorMapper.fromDioException(e);
    }
  }

  @override
  Future<AjustadorResponseDto> obtenerPerfil() async {
    try {
      final response = await _dio.get(ApiConstants.ajustadorPerfil);
      _ensureSuccess(response);
      return AjustadorResponseDto.fromJson(
          response.data as Map<String, dynamic>);
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
